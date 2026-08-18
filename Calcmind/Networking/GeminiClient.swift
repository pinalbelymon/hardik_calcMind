import Foundation
import Observation

enum GeminiClientError: LocalizedError {
    case missingAPIKey
    case server(status: Int, message: String)
    case decoding
    case network(Error)
    case blocked(String?)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "AI engine key hasn't loaded yet — try again in a moment."
        case .server(let status, let message):
            return "AI service error (\(status)): \(message)"
        case .decoding:
            return "Couldn't understand AI engine response."
        case .network(let error):
            return error.localizedDescription
        case .blocked(let reason):
            if let reason {
                return "Response blocked by safety settings: \(reason)"
            }
            return "Response blocked by safety settings."
        }
    }
}

/// Calls the Gemini API directly from the app, using whatever key the
/// injected `GeminiKeyProviding` has fetched (Firestore today — see
/// FirestoreKeyService.swift). No backend involved; GeminiClient itself
/// doesn't know or care where the key came from.
@Observable
final class GeminiClient {
    /// Configurable — check https://ai.google.dev/gemini-api/docs/latest-model
    /// before shipping in case a newer/cheaper recommended model has
    /// replaced this default since.
    var model = "gemini-3.6-flash"

    private let keyService: any GeminiKeyProviding
    private let apiBase = "https://generativelanguage.googleapis.com/v1beta/models"

    init(keyService: any GeminiKeyProviding) {
        self.keyService = keyService
    }

    // MARK: - Solve (non-streaming, structured JSON)

    func solve(expression: String) async throws -> MathSolution {
        let parts: [[String: Any]] = [["text": "Solve this expression: \(expression)"]]
        return try await solve(parts: parts)
    }

    func solve(imageData: Data, mimeType: String = "image/jpeg") async throws -> MathSolution {
        let base64 = imageData.base64EncodedString()
        let parts: [[String: Any]] = [
            ["inlineData": ["mimeType": mimeType, "data": base64]],
            ["text": "Read and solve the math expression in this image."],
        ]
        return try await solve(parts: parts)
    }

    private func solve(parts: [[String: Any]]) async throws -> MathSolution {
        let text = try await generateContent(
            systemInstruction: GeminiPrompts.solve,
            parts: parts,
            responseMimeType: "application/json"
        )
        guard let data = text.data(using: .utf8) else { throw GeminiClientError.decoding }
        do {
            return try JSONDecoder().decode(MathSolution.self, from: data)
        } catch {
            throw GeminiClientError.decoding
        }
    }

    // MARK: - Tutor (streaming)

    /// Streams the tutor's reply as text deltas via `AsyncThrowingStream`,
    /// so the caller can append each piece to a chat bubble as it arrives.
    func streamTutorReply(messages: [TutorMessage], mode: TutorMode = .mathTutor) -> AsyncThrowingStream<String, Error> {
        let systemInstruction = GeminiPrompts.tutorSystemInstruction(for: mode)
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    guard let apiKey = keyService.geminiAPIKey else {
                        throw GeminiClientError.missingAPIKey
                    }
                    guard let url = URL(string: "\(apiBase)/\(model):streamGenerateContent?alt=sse") else {
                        throw GeminiClientError.decoding
                    }

                    let contents = messages.map { message -> [String: Any] in
                        ["role": message.role.rawValue, "parts": Self.tutorParts(for: message)]
                    }
                    let body: [String: Any] = [
                        "contents": contents,
                        "systemInstruction": ["parts": [["text": systemInstruction]]],
                        "safetySettings": GeminiSafety.settings,
                        "generationConfig": ["maxOutputTokens": 1024],
                    ]

                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")
                    request.httpBody = try JSONSerialization.data(withJSONObject: body)

                    let (bytes, response) = try await URLSession.shared.bytes(for: request)
                    try Self.validate(response)

                    for try await line in bytes.lines {
                        guard line.hasPrefix("data:") else { continue }
                        let payloadString = line.dropFirst("data:".count)
                            .trimmingCharacters(in: .whitespaces)
                        guard payloadString != "[DONE]",
                              let payloadData = payloadString.data(using: .utf8) else { continue }
                        if let delta = Self.extractText(from: payloadData) {
                            continuation.yield(delta)
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    // MARK: - Core request (non-streaming)

    private func generateContent(
        systemInstruction: String,
        parts: [[String: Any]],
        responseMimeType: String?
    ) async throws -> String {
        guard let apiKey = keyService.geminiAPIKey else {
            throw GeminiClientError.missingAPIKey
        }
        guard let url = URL(string: "\(apiBase)/\(model):generateContent") else {
            throw GeminiClientError.decoding
        }

        var generationConfig: [String: Any] = ["maxOutputTokens": 2048]
        if let responseMimeType {
            generationConfig["responseMimeType"] = responseMimeType
        }

        let body: [String: Any] = [
            "contents": [["role": "user", "parts": parts]],
            "systemInstruction": ["parts": [["text": systemInstruction]]],
            "safetySettings": GeminiSafety.settings,
            "generationConfig": generationConfig,
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw GeminiClientError.network(error)
        }
        try Self.validate(response, data: data)

        struct GeminiResponse: Decodable {
            struct Candidate: Decodable {
                struct Content: Decodable {
                    struct Part: Decodable { let text: String? }
                    let parts: [Part]?
                }
                let content: Content?
            }
            struct PromptFeedback: Decodable { let blockReason: String? }
            let candidates: [Candidate]?
            let promptFeedback: PromptFeedback?
        }

        let decoded: GeminiResponse
        do {
            decoded = try JSONDecoder().decode(GeminiResponse.self, from: data)
        } catch {
            throw GeminiClientError.decoding
        }

        guard let candidate = decoded.candidates?.first else {
            throw GeminiClientError.blocked(decoded.promptFeedback?.blockReason)
        }

        let textParts = candidate.content?.parts ?? []
        return textParts.compactMap { $0.text }.joined()
    }

    // MARK: - Helpers

    private static func tutorParts(for message: TutorMessage) -> [[String: Any]] {
        var parts: [[String: Any]] = []

        if let imageData = message.imageJPEGData {
            parts.append([
                "inlineData": [
                    "mimeType": "image/jpeg",
                    "data": imageData.base64EncodedString(),
                ],
            ])
        }

        let text = message.content.trimmingCharacters(in: .whitespacesAndNewlines)
        if !text.isEmpty {
            parts.append(["text": text])
        } else if message.imageJPEGData != nil {
            parts.append([
                "text": "The user sent a photo of a math equation or problem. Read it and help according to your tutor role.",
            ])
        } else if !message.content.isEmpty {
            parts.append(["text": message.content])
        }

        return parts
    }

    private static func validate(_ response: URLResponse, data: Data? = nil) throws {
        guard let http = response as? HTTPURLResponse else { return }
        guard (200..<300).contains(http.statusCode) else {
            let message = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Unknown error"
            throw GeminiClientError.server(status: http.statusCode, message: message)
        }
    }

    /// Pulls `candidates[0].content.parts[].text` out of one SSE chunk's
    /// JSON payload from Gemini's streamGenerateContent endpoint.
    private static func extractText(from data: Data) -> String? {
        struct Chunk: Decodable {
            struct Candidate: Decodable {
                struct Content: Decodable {
                    struct Part: Decodable { let text: String? }
                    let parts: [Part]?
                }
                let content: Content?
            }
            let candidates: [Candidate]?
        }
        guard let chunk = try? JSONDecoder().decode(Chunk.self, from: data) else { return nil }
        return chunk.candidates?.first?.content?.parts?.first?.text
    }
}
