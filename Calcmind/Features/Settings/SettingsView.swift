import StoreKit
import SwiftUI

/// Settings view for CalcMind.
/// Manages Subscription status card, Appearance/Themes, Daily Math Reminders (notifications),
/// Sound effects, Tools & Welcome, Support & Legal (mail, rating, privacy, terms), and About info.
struct SettingsView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(NotificationManager.self) private var notificationManager
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.showOnboarding) private var showOnboarding
    @Environment(\.showPaywall) private var showPaywall
    @Environment(\.openURL) private var openURL
    @Environment(\.requestReview) private var requestReview

    @State private var isShowingPermissionAlert = false

    var body: some View {
        @Bindable var themeManager = themeManager
        @Bindable var notificationManager = notificationManager

        NavigationStack {
            List {
                subscriptionSection

                Section {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Accent Theme")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(AppColor.textSecondary(colorScheme))
                        AccentThemePicker()
                    }
                    .padding(.vertical, AppSpacing.xs)

                    Picker("Appearance", selection: $themeManager.appearance) {
                        ForEach(AppAppearance.allCases) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, AppSpacing.xs)
                } header: {
                    Text("Appearance")
                }

                Section {
                    Toggle("Daily Math Reminders", isOn: Binding(
                        get: { notificationManager.isEnabled },
                        set: { newValue in
                            if newValue {
                                notificationManager.requestPermission { granted in
                                    if !granted {
                                        isShowingPermissionAlert = true
                                    }
                                }
                            } else {
                                notificationManager.isEnabled = false
                                notificationManager.cancelAllNotifications()
                            }
                        }
                    ))

                    if notificationManager.isEnabled {
                        DatePicker("Reminder Time", selection: $notificationManager.reminderDate, displayedComponents: .hourAndMinute)
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text(notificationManager.isEnabled
                         ? "You will receive a daily motivational reminder to practice math or check in with AI Tutor."
                         : "Turn on to get a daily reminder to practice math and keep your study streak alive.")
                }

                Section {
                    Toggle("Sound Effects", isOn: $themeManager.soundEffectsEnabled)
                } footer: {
                    Text("A subtle sound when a calculation or photo solve completes.")
                }

                Section {
                    NavigationLink {
                        CurrencyRatesView()
                    } label: {
                        Label("Currency Rates", systemImage: "arrow.left.arrow.right.circle")
                    }

                    Button {
                        Haptic.light()
                        showOnboarding()
                    } label: {
                        Label("Replay Welcome Tour", systemImage: "sparkles.tv")
                    }
                } header: {
                    Text("Tools & Welcome")
                } footer: {
                    Text("Also available as a Home Screen widget (search CalcMind when adding widgets).")
                }

                Section {
                    Button {
                        Haptic.light()
                        openSupportMail()
                    } label: {
                        Label("Contact Support", systemImage: "envelope.fill")
                    }

                    Button {
                        Haptic.light()
                        requestReview()
                    } label: {
                        Label("Rate & Review CalcMind", systemImage: "star.fill")
                    }

                    Link(destination: URL(string: "https://belymoninfotech.com/app/calcmind/privacypolicy.html")!) {
                        Label("Privacy Policy", systemImage: "lock.shield.fill")
                    }

                    Link(destination: URL(string: "https://belymoninfotech.com/app/calcmind/termsofuse.html")!) {
                        Label("Terms of Use", systemImage: "doc.text.fill")
                    }
                } header: {
                    Text("Support & Legal")
                } footer: {
                    Text("Have feedback or need assistance? Email us at vaghasiyabhavin590@gmail.com")
                }

                Section {
                    Text("Photo solve and AI Tutor process images and math questions to generate step-by-step answers. Calculation history stays securely on your device.")
                        .font(.subheadline)
                        .foregroundStyle(AppColor.textSecondary(colorScheme))
                } header: {
                    Text("Privacy & AI")
                } footer: {
                    Text("AI-generated content may contain mistakes. The calculator works fully offline without sending any data.")
                }

                Section {
                    LabeledContent("Version", value: appVersion)
                    LabeledContent("Calculator Core", value: "Live (Offline)")
                    LabeledContent("AI Tutor", value: "Live")
                    LabeledContent("Camera Solve", value: "Live")
                    LabeledContent("History", value: "Live")
                } header: {
                    Text("About")
                }

            }
            .navigationTitle("Settings")
            .alert("Notifications Disabled", isPresented: $isShowingPermissionAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Notification permission was not granted. Please enable notifications for CalcMind in iOS Settings to receive daily math reminders.")
            }
        }
    }

    private var subscriptionSection: some View {
        Section {
            Button {
                Haptic.light()
                showPaywall()
            } label: {
                HStack(spacing: AppSpacing.sm) {
                    ZStack {
                        Circle()
                            .fill(themeManager.accent.accent.opacity(0.15))
                            .frame(width: 44, height: 44)

                        Image(systemName: subscriptionManager.isPro ? "crown.fill" : "sparkles")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(themeManager.accent.accent)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(subscriptionManager.isPro ? "CalcMind Pro Active" : "CalcMind Free")
                                .font(AppFont.display(16, weight: .bold))
                                .foregroundStyle(AppColor.textPrimary(colorScheme))

                            if subscriptionManager.isPro {
                                Text("PRO")
                                    .font(AppFont.display(10, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(themeManager.accent.gradient)
                                    .clipShape(Capsule())
                            }
                        }

                        Text(
                            subscriptionManager.isPro
                                ? "Active plan: \(subscriptionManager.activePlan.displayName) • Tap to view"
                                : "Unlock Unlimited AI Math Solving & 24/7 Tutor"
                        )
                        .font(.caption)
                        .foregroundStyle(AppColor.textSecondary(colorScheme))
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColor.textSecondary(colorScheme))
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
        } header: {
            Text("Subscription Status")
        } footer: {
            if subscriptionManager.isPro {
                Text("Tap anytime to view options or manage your subscription.")
            } else {
                Text("Upgrade to Pro to unlock unlimited photo math solving & 24/7 AI Tutor.")
            }
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private func openSupportMail() {
        let subject = "CalcMind Support Request (v\(appVersion))"
        let body = """
        Hi CalcMind Support,

        [Please describe your request, feedback, or issue here]

        --------------------------------
        App Version: \(appVersion)
        iOS System: \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)
        Device: \(UIDevice.current.model)
        """

        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        if let mailURL = URL(string: "mailto:vaghasiyabhavin590@gmail.com?subject=\(encodedSubject)&body=\(encodedBody)") {
            openURL(mailURL)
        }
    }
}

#Preview("Light") {
    SettingsView()
        .environment(ThemeManager())
        .environment(SubscriptionManager())
        .environment(NotificationManager())
        .environment(FirestoreKeyService())
        .environment(GeminiClient(keyService: FirestoreKeyService()))
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    SettingsView()
        .environment(ThemeManager())
        .environment(SubscriptionManager())
        .environment(NotificationManager())
        .environment(FirestoreKeyService())
        .environment(GeminiClient(keyService: FirestoreKeyService()))
        .preferredColorScheme(.dark)
}
