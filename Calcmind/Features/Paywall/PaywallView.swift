import SwiftUI

/// Animated Premium Paywall View for CalcMind.
/// Presents Weekly, Monthly, and Yearly subscription options with feature highlights,
/// interactive plan selection, purchasing state, and required Apple legal links (Privacy, Terms, EULA, Restore).
struct PaywallView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(ThemeManager.self) private var themeManager
    @Environment(SubscriptionManager.self) private var subscriptionManager

    @State private var selectedPlan: SubscriptionPlan = .yearly
    @State private var isAnimatingBanner = false
    @State private var isPurchasing = false
    @State private var showRestoreSuccessAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background with ambient glowing gradient orbs
                AppColor.background(colorScheme)
                    .ignoresSafeArea()

                ZStack {
                    Circle()
                        .fill(themeManager.accent.gradient)
                        .frame(width: 300, height: 300)
                        .blur(radius: 80)
                        .opacity(colorScheme == .dark ? 0.35 : 0.22)
                        .offset(x: -90, y: -160)

                    Circle()
                        .fill(themeManager.accent.gradientStops[1])
                        .frame(width: 260, height: 260)
                        .blur(radius: 70)
                        .opacity(colorScheme == .dark ? 0.3 : 0.18)
                        .offset(x: 110, y: 160)
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppSpacing.lg) {
                        // Header Badge & Title
                        VStack(spacing: AppSpacing.xs) {
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                Text("CALCMIND PRO")
                            }
                            .font(AppFont.display(12, weight: .bold))
                            .tracking(2)
                            .foregroundStyle(themeManager.accent.accent)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(themeManager.accent.accent.opacity(0.12))
                            .clipShape(Capsule())
                            .scaleEffect(isAnimatingBanner ? 1.05 : 1.0)

                            Text("Unlock Unlimited AI Math")
                                .font(AppFont.display(30, weight: .bold))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(AppColor.textPrimary(colorScheme))

                            Text("Snap any math problem for instant photo solutions & chat with your 24/7 AI tutor.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(AppColor.textSecondary(colorScheme))
                                .padding(.horizontal, AppSpacing.sm)
                        }
                        .padding(.top, AppSpacing.sm)

                        // Feature Highlights Card
                        VStack(alignment: .leading, spacing: 12) {
                            FeatureRow(icon: "camera.viewfinder", title: "Unlimited Photo Math Solving", description: "Snap handwritten or printed equations")
                            FeatureRow(icon: "wand.and.stars", title: "24/7 AI Math Tutor Chat", description: "Step-by-step explanations & proofs")
                            FeatureRow(icon: "list.number", title: "Detailed Step Breakdown", description: "Clear intermediate steps and formulas")
                            FeatureRow(icon: "brain.head.profile", title: "Instant Smart Solutions", description: "Solve algebra, calculus & word problems")
                        }
                        .padding(AppSpacing.md)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                                .stroke(AppColor.hairline(colorScheme), lineWidth: 1)
                        )

                        // Subscription Options Selector (Weekly, Monthly, Yearly)
                        VStack(spacing: AppSpacing.sm) {
                            PlanOptionCard(
                                plan: .yearly,
                                selectedPlan: $selectedPlan,
                                subtitle: "Billed annually • Cancel anytime"
                            )

                            PlanOptionCard(
                                plan: .monthly,
                                selectedPlan: $selectedPlan,
                                subtitle: "Billed monthly • Cancel anytime"
                            )

                            PlanOptionCard(
                                plan: .weekly,
                                selectedPlan: $selectedPlan,
                                subtitle: "Billed weekly • Cancel anytime"
                            )
                        }

                        // Primary Action CTA Button
                        Button {
                            Task { await handlePurchase() }
                        } label: {
                            HStack(spacing: AppSpacing.xs) {
                                if isPurchasing {
                                    ProgressView()
                                        .tint(.white)
                                        .padding(.trailing, 4)
                                }

                                Text(ctaButtonTitle)
                                    .font(AppFont.display(18, weight: .bold))

                                Image(systemName: "arrow.right")
                                    .font(.body.weight(.bold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(themeManager.accent.gradient)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
                            .shadow(color: themeManager.accent.accent.opacity(0.4), radius: 14, x: 0, y: 7)
                        }
                        .disabled(isPurchasing)
                        .buttonStyle(.bouncy)

                        // Restore Purchases Button
                        Button {
                            Task { await handleRestore() }
                        } label: {
                            Text("Restore Purchases")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(themeManager.accent.accent)
                        }
                        .padding(.top, 2)

                        // Apple App Store Required Legal Links & Disclaimers (Privacy, Terms, Apple EULA)
                        VStack(spacing: AppSpacing.xs) {
                            HStack(spacing: 12) {
                                Link("Privacy Policy", destination: URL(string: "https://belymoninfotech.com/app/calcmind/privacypolicy.html")!)
                                Text("•")
                                Link("Terms of Use", destination: URL(string: "https://belymoninfotech.com/app/calcmind/termsofuse.html")!)
                                Text("•")
                                Link("Apple EULA", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                            }
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(AppColor.textSecondary(colorScheme))

                            Text("Subscriptions auto-renew unless cancelled in Apple ID Settings at least 24h before current period ends.")
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(AppColor.textSecondary(colorScheme).opacity(0.8))
                                .padding(.horizontal, AppSpacing.sm)
                        }
                        .padding(.top, AppSpacing.xs)
                    }
                    .padding(AppSpacing.md)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Haptic.light()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(AppColor.textSecondary(colorScheme))
                    }
                }
            }
            .alert("Purchases Restored", isPresented: $showRestoreSuccessAlert) {
                Button("OK", role: .cancel) { dismiss() }
            } message: {
                Text("Your CalcMind Pro subscription has been successfully restored!")
            }
            .alert("Subscription Notice", isPresented: Binding(
                get: { subscriptionManager.errorMessage != nil },
                set: { if !$0 { subscriptionManager.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {
                    subscriptionManager.errorMessage = nil
                }
            } message: {
                Text(subscriptionManager.errorMessage ?? "An error occurred with StoreKit.")
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isAnimatingBanner = true
                }
            }
        }
    }

    private var ctaButtonTitle: String {
        if isPurchasing {
            return "Processing..."
        }
        switch selectedPlan {
        case .yearly:
            return "Subscribe"
        case .monthly:
            return "Subscribe"
        case .weekly:
            return "Subscribe"
        default:
            return "Unlock Pro Now"
        }
    }

    private func handlePurchase() async {
        Haptic.light()
        isPurchasing = true
        let success = await subscriptionManager.purchase(plan: selectedPlan)
        isPurchasing = false
        if success {
            dismiss()
        }
    }

    private func handleRestore() async {
        Haptic.light()
        isPurchasing = true
        let success = await subscriptionManager.restorePurchases()
        isPurchasing = false
        if success {
            showRestoreSuccessAlert = true
        }
    }
}

// MARK: - Feature Highlight Row

private struct FeatureRow: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(ThemeManager.self) private var themeManager

    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            ZStack {
                Circle()
                    .fill(themeManager.accent.accent.opacity(0.14))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.body.weight(.bold))
                    .foregroundStyle(themeManager.accent.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFont.display(15, weight: .bold))
                    .foregroundStyle(AppColor.textPrimary(colorScheme))

                Text(description)
                    .font(.caption)
                    .foregroundStyle(AppColor.textSecondary(colorScheme))
            }
            Spacer()
        }
    }
}

// MARK: - Plan Selection Option Card

private struct PlanOptionCard: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(ThemeManager.self) private var themeManager
    @Environment(SubscriptionManager.self) private var subscriptionManager

    let plan: SubscriptionPlan
    @Binding var selectedPlan: SubscriptionPlan
    let subtitle: String

    private var isSelected: Bool {
        selectedPlan == plan
    }

    var body: some View {
        Button {
            Haptic.light()
            withAnimation(AppAnimation.bouncy) {
                selectedPlan = plan
            }
        } label: {
            HStack(spacing: AppSpacing.sm) {
                // Radio Check Circle
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(isSelected ? themeManager.accent.accent : AppColor.textSecondary(colorScheme))

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(plan.displayName)
                            .font(AppFont.display(16, weight: .bold))
                            .foregroundStyle(AppColor.textPrimary(colorScheme))

                        if let badge = plan.badgeText {
                            Text(badge)
                                .font(AppFont.display(10, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(themeManager.accent.gradient)
                                .clipShape(Capsule())
                        }
                    }

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(AppColor.textSecondary(colorScheme))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(subscriptionManager.displayPrice(for: plan))
                        .font(AppFont.display(20, weight: .bold))
                        .foregroundStyle(AppColor.textPrimary(colorScheme))

                    Text(plan.fallbackEquivalentWeeklyText)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(themeManager.accent.accent)
                }
            }
            .padding(AppSpacing.md)
            .background(isSelected ? themeManager.accent.accent.opacity(0.1) : AppColor.backgroundElevated(colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                    .stroke(isSelected ? themeManager.accent.accent : AppColor.hairline(colorScheme), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview("Paywall - Light") {
    PaywallView()
        .environment(ThemeManager())
        .environment(SubscriptionManager())
        .preferredColorScheme(.light)
}

#Preview("Paywall - Dark") {
    PaywallView()
        .environment(ThemeManager())
        .environment(SubscriptionManager())
        .preferredColorScheme(.dark)
}
