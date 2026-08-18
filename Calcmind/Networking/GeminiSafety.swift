import Foundation

/// Safety thresholds sent with every Gemini call. Blocking at a strict
/// threshold since responses here are shown directly to a user who may be
/// a student. See https://ai.google.dev/gemini-api/docs/safety-settings
/// for the current list of categories if you want to add more.
enum GeminiSafety {
    static let settings: [[String: String]] = [
        ["category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_LOW_AND_ABOVE"],
        ["category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_LOW_AND_ABOVE"],
        ["category": "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold": "BLOCK_LOW_AND_ABOVE"],
        ["category": "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold": "BLOCK_LOW_AND_ABOVE"],
    ]
}
