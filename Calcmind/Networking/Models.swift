import Foundation

/// A solved equation, as returned by the backend's /solve endpoint.
/// Mirrors the JSON contract defined in backend/lib/prompts.js —
/// keep those two in sync if you ever change one.
struct MathSolution: Codable, Equatable {
    let equation: String
    let steps: [String]
    let answer: String

    /// The backend returns this shape (all empty strings/arrays) when the
    /// image didn't contain a readable math expression, or the request
    /// wasn't math at all.
    var isEmpty: Bool {
        equation.isEmpty && steps.isEmpty && answer.isEmpty
    }
}

/// One message in an AI Tutor conversation.
struct TutorMessage: Codable, Equatable, Identifiable {
    enum Role: String, Codable {
        case user
        case model
    }

    let id: UUID
    let role: Role
    var content: String
    /// JPEG bytes when the user attached a photo of an equation.
    var imageJPEGData: Data?

    init(id: UUID = UUID(), role: Role, content: String, imageJPEGData: Data? = nil) {
        self.id = id
        self.role = role
        self.content = content
        self.imageJPEGData = imageJPEGData
    }

    var hasImage: Bool { imageJPEGData != nil }
}
