import FirebaseFirestore
import Observation

/// Fetches the Gemini API key from Cloud Firestore when the app launches.
/// Reads a single field from a single document:
///
///     app_config (collection)
///       └── gemini (document)
///             apiKey: "<your Gemini API key>"
///
/// See FIREBASE-SETUP.md for how to create this and — importantly — the
/// Firestore security rule that has to exist for this read to succeed at
/// all, since Firestore denies all reads by default.
///
/// Same trade-off as any client-side key fetch: once retrieved, the key
/// lives in the app's memory and travels in the app's own requests to
/// Gemini. Documented once, in FIREBASE-SETUP.md, rather than repeated in
/// every file that touches the key.
@Observable
final class FirestoreKeyService: GeminiKeyProviding {
    enum KeyState: Equatable {
        case idle
        case loading
        case ready
        case failed(String)
    }

    private(set) var state: KeyState = .idle
    private(set) var geminiAPIKey: String?

    /// Must match exactly what you create in the Firebase Console.
    private static let collectionPath = "app_config"
    private static let documentPath = "gemini"
    private static let fieldName = "apiKey"

    /// Call once at app launch — see CalcMindApp.swift's `.task`.
    func fetchGeminiKey() async {
        state = .loading
        do {
            let snapshot = try await Firestore.firestore()
                .collection(Self.collectionPath)
                .document(Self.documentPath)
                .getDocument()

            guard snapshot.exists else {
                state = .failed("No document found at \(Self.collectionPath)/\(Self.documentPath) in Firestore. See FIREBASE-SETUP.md.")
                return
            }

            guard let value = snapshot.get(Self.fieldName) as? String, !value.isEmpty else {
                state = .failed("Document \(Self.collectionPath)/\(Self.documentPath) has no \"\(Self.fieldName)\" field. See FIREBASE-SETUP.md.")
                return
            }

            geminiAPIKey = value
            state = .ready
        } catch {
            // Most commonly a permission-denied error if the Firestore
            // security rule from FIREBASE-SETUP.md hasn't been published.
            state = .failed(error.localizedDescription)
        }
    }
}
