import SwiftData
import SwiftUI

/// The app's real navigation root (replaces the single-screen root used in
/// Phases 0–1). Deliberately plain — a stock `TabView` built from `Tab`
/// items. On iOS 26 this renders with the system's native Liquid Glass tab
/// bar automatically; we never hand-roll tab bar chrome, since a custom
/// reimplementation would both fight the system style and risk falling out
/// of date the next time Apple updates it.
struct RootTabView: View {
    /// The currency widget deep-links to calcmind://currency — handled
    /// here since there's no dedicated Currency tab, just this sheet.
    @State private var isShowingCurrencyRates = false

    var body: some View {
        TabView {
            Tab("Calculator", systemImage: "plusminus") {
                CalculatorView()
            }

            Tab("AI Tutor", systemImage: "wand.and.stars") {
                TutorChatView()
            }

            Tab("History", systemImage: "clock.arrow.circlepath") {
                HistoryView()
            }

            Tab("Settings", systemImage: "gearshape") {
                SettingsView()
            }
        }
        .sheet(isPresented: $isShowingCurrencyRates) {
            CurrencyRatesView()
        }
        .onOpenURL { url in
            if url.host == "currency" {
                isShowingCurrencyRates = true
            }
        }
    }
}

#Preview("Light") {
    RootTabView()
        .environment(ThemeManager())
        .environment(FirestoreKeyService())
        .environment(GeminiClient(keyService: FirestoreKeyService()))
        .modelContainer(for: CalculationRecord.self, inMemory: true)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    RootTabView()
        .environment(ThemeManager())
        .environment(FirestoreKeyService())
        .environment(GeminiClient(keyService: FirestoreKeyService()))
        .modelContainer(for: CalculationRecord.self, inMemory: true)
        .preferredColorScheme(.dark)
}
