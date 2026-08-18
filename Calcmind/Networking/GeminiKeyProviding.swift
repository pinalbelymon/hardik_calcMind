import Foundation

/// Anything that can supply a Gemini API key, fetched however it likes.
/// `GeminiClient` only depends on this protocol, never a concrete fetch
/// mechanism — worth having as its own seam now that the fetch source has
/// already changed twice (a backend proxy, then Firebase Remote Config,
/// now Cloud Firestore). Swapping the source again later only means
/// writing a new conformer, not touching `GeminiClient` at all.
protocol GeminiKeyProviding: AnyObject {
    var geminiAPIKey: String? { get }
}
