import SwiftData
import SwiftUI

// MARK: - Environment Key for Replaying Onboarding

private struct ShowOnboardingKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

private struct ShowPaywallKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var showOnboarding: () -> Void {
        get { self[ShowOnboardingKey.self] }
        set { self[ShowOnboardingKey.self] = newValue }
    }

    var showPaywall: () -> Void {
        get { self[ShowPaywallKey.self] }
        set { self[ShowPaywallKey.self] = newValue }
    }
}

// MARK: - App Root Container View

/// Root view of CalcMind. Coordinates the launch flow:
/// 1. Animated Splash Screen
/// 2. Animated Onboarding Flow (on first launch or when triggered)
/// 3. Main Navigation RootTabView
struct AppRootContainerView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(NotificationManager.self) private var notificationManager
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var isShowingSplash = true
    @State private var isShowingOnboardingSheet = false
    @State private var isShowingPaywallSheet = false

    var body: some View {
        ZStack {
            if isShowingSplash {
                SplashScreenView {
                    withAnimation(AppAnimation.smooth) {
                        isShowingSplash = false
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 1.04)))
                .zIndex(2)
            } else if !hasCompletedOnboarding {
                OnboardingView {
                    withAnimation(AppAnimation.smooth) {
                        hasCompletedOnboarding = true
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .zIndex(1)
            } else {
                RootTabView()
                    .transition(.opacity)
                    .zIndex(0)
            }
        }
        .sheet(isPresented: $isShowingOnboardingSheet) {
            OnboardingView {
                isShowingOnboardingSheet = false
            }
            .environment(themeManager)
            .environment(subscriptionManager)
            .environment(notificationManager)
        }
        .sheet(isPresented: $isShowingPaywallSheet) {
            PaywallView()
                .environment(themeManager)
                .environment(subscriptionManager)
                .environment(notificationManager)
        }
        .environment(\.showOnboarding, {
            isShowingOnboardingSheet = true
        })
        .environment(\.showPaywall, {
            isShowingPaywallSheet = true
        })
    }
}

#Preview("Root Container") {
    AppRootContainerView()
        .environment(ThemeManager())
        .environment(SubscriptionManager())
        .environment(NotificationManager())
        .environment(FirestoreKeyService())
        .environment(GeminiClient(keyService: FirestoreKeyService()))
        .modelContainer(for: CalculationRecord.self, inMemory: true)
}
