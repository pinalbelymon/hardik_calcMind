import FirebaseCore
import SwiftData
import SwiftUI

@main
struct CalcmindApp: App {
    @State private var themeManager = ThemeManager()
    @State private var subscriptionManager = SubscriptionManager()
    @State private var notificationManager = NotificationManager()
    @State private var keyService: FirestoreKeyService
    @State private var geminiClient: GeminiClient

    init() {
        // Must run before any Firebase API is touched. Requires
        // GoogleService-Info.plist to be added to the project —
        // see FIREBASE-SETUP.md.
            FirebaseApp.configure()

        let keyService = FirestoreKeyService()
        _keyService = State(initialValue: keyService)
        _geminiClient = State(initialValue: GeminiClient(keyService: keyService))

        AppMetrics.shared.register()
    }

    var body: some Scene {
        WindowGroup {
            // Phase 2: full TabView root (Calculator, AI Tutor, History,
            // Settings). preferredColorScheme reads the user's Appearance
            // choice from Settings — nil (Auto) defers to the system.
            // Phase 3: no backend — keyService and geminiClient are
            // available to every screen via the environment, ready for
            // Phase 4 (camera solve) and Phase 5 (tutor chat) to consume
            // without any replumbing.
            AppRootContainerView()
                .environment(themeManager)
                .environment(subscriptionManager)
                .environment(notificationManager)
                .environment(keyService)
                .environment(geminiClient)
                .preferredColorScheme(themeManager.appearance.colorScheme)
                .task {
                    // Fetch the Gemini key from Firestore as soon as the
                    // app opens.
                    await keyService.fetchGeminiKey()
                }
        }
        // Phase 6: SwiftData persistence for calculation history. Scoped
        // to the whole Scene, not a View modifier, so every screen (and
        // Xcode's own SwiftData tooling) sees the same container.
        .modelContainer(for: CalculationRecord.self)
    }
}
