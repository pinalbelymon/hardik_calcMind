import SwiftUI

/// Onboarding item data model
struct OnboardingItem: Identifiable {
    let id: Int
    let badge: String
    let title: String
    let subtitle: String
}

/// Animated 4-Step Onboarding Flow for CalcMind.
/// Interactive cards highlight Precision Calculator, AI Photo Solver, 24/7 AI Tutor, and Custom Themes.
struct OnboardingView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager

    let onComplete: () -> Void

    @State private var currentPage = 0

    private let pages: [OnboardingItem] = [
        OnboardingItem(
            id: 0,
            badge: "CALCULATOR CORE",
            title: "Precision Meets Elegance",
            subtitle: "Fast standard and scientific modes with responsive keypads, continuous curve radius, and haptic feedback."
        ),
        OnboardingItem(
            id: 1,
            badge: "AI VISION",
            title: "Snap & Solve Instantly",
            subtitle: "Point your camera at any printed or handwritten math problem to receive immediate step-by-step breakdown."
        ),
        OnboardingItem(
            id: 2,
            badge: "AI MATH TUTOR",
            title: "Your 24/7 Study Companion",
            subtitle: "Ask questions, explore concepts, verify proofs, and get friendly explanations whenever you get stuck."
        ),
        OnboardingItem(
            id: 3,
            badge: "PERSONALIZED & LOCAL",
            title: "Themes & History",
            subtitle: "On-device SwiftData history keep your data safe, paired with vibrant Liquid Glass color themes."
        )
    ]

    var body: some View {
        ZStack {
            AppColor.background(colorScheme)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header Bar: Badge & Skip Button
                HStack {
                    Text(pages[currentPage].badge)
                        .font(AppFont.display(11, weight: .bold))
                        .tracking(1.5)
                        .foregroundStyle(themeManager.accent.accent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(themeManager.accent.accent.opacity(0.12))
                        .clipShape(Capsule())

                    Spacer()

                    if currentPage < pages.count - 1 {
                        Button {
                            Haptic.light()
                            finishOnboarding()
                        } label: {
                            Text("Skip")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(AppColor.textSecondary(colorScheme))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.md)

                // Swipeable Page View
                TabView(selection: $currentPage) {
                    ForEach(pages) { page in
                        VStack(spacing: AppSpacing.lg) {
                            Spacer(minLength: 0)

                            // Animated Interactive Visual Card for each feature
                            OnboardingGraphicView(pageIndex: page.id)
                                .frame(maxWidth: 340)
                                .frame(height: 280)

                            // Title & Subtitle Copy
                            VStack(spacing: AppSpacing.xs) {
                                Text(page.title)
                                    .font(AppFont.display(28, weight: .bold))
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(AppColor.textPrimary(colorScheme))

                                Text(page.subtitle)
                                    .font(.subheadline)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(AppColor.textSecondary(colorScheme))
                                    .lineSpacing(4)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.horizontal, AppSpacing.md)
                            }

                            Spacer(minLength: 0)
                        }
                        .tag(page.id)
                        .padding(.horizontal, AppSpacing.md)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Bottom Navigation Controls
                VStack(spacing: AppSpacing.lg) {
                    // Custom Liquid Glass Page Indicator
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule()
                                .fill(currentPage == index ? themeManager.accent.accent : AppColor.textSecondary(colorScheme).opacity(0.3))
                                .frame(width: currentPage == index ? 24 : 8, height: 8)
                                .animation(AppAnimation.bouncy, value: currentPage)
                        }
                    }

                    // Main Action Button
                    Button {
                        Haptic.light()
                        if currentPage < pages.count - 1 {
                            withAnimation(AppAnimation.bouncy) {
                                currentPage += 1
                            }
                        } else {
                            finishOnboarding()
                        }
                    } label: {
                        HStack(spacing: AppSpacing.xs) {
                            Text(currentPage == pages.count - 1 ? "Get Started" : "Continue")
                                .font(AppFont.display(18, weight: .bold))

                            Image(systemName: currentPage == pages.count - 1 ? "sparkles" : "arrow.right")
                                .font(.body.weight(.bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(themeManager.accent.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
                        .shadow(color: themeManager.accent.accent.opacity(0.35), radius: 12, x: 0, y: 6)
                    }
                    .buttonStyle(.bouncy)
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, AppSpacing.xl)
            }
        }
    }

    private func finishOnboarding() {
        onComplete()
        dismiss()
    }
}

// MARK: - Interactive Onboarding Visual Cards

private struct OnboardingGraphicView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(ThemeManager.self) private var themeManager
    let pageIndex: Int

    @State private var isScanning = false
    @State private var demoExpression = "12 × 8"
    @State private var demoResult = "96"
    @State private var chatStep = 0

    var body: some View {
        ZStack {
            // Glass backdrop card
            RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                .fill(AppColor.backgroundElevated(colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                        .stroke(AppColor.hairline(colorScheme), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.06), radius: 16, x: 0, y: 8)

            switch pageIndex {
            case 0:
                // Page 1: Interactive Keypad Preview
                VStack(spacing: AppSpacing.sm) {
                    // Preview Display
                    HStack {
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(demoExpression)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(AppColor.textSecondary(colorScheme))
                            Text(demoResult)
                                .font(AppFont.display(32, weight: .bold))
                                .foregroundStyle(AppColor.textPrimary(colorScheme))
                        }
                    }
                    .padding(AppSpacing.md)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous))

                    // Mini interactive buttons
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 4), spacing: 6) {
                        MiniDemoButton(label: "sin", isAccent: false) {
                            demoExpression = "sin(30°)"
                            demoResult = "0.5"
                        }
                        MiniDemoButton(label: "√", isAccent: false) {
                            demoExpression = "√144"
                            demoResult = "12"
                        }
                        MiniDemoButton(label: "AC", isAccent: false) {
                            demoExpression = "0"
                            demoResult = "0"
                        }
                        MiniDemoButton(label: "÷", isAccent: true) {
                            demoExpression = "84 ÷ 4"
                            demoResult = "21"
                        }
                        MiniDemoButton(label: "7", isAccent: false) {
                            demoExpression = "7 × 7"
                            demoResult = "49"
                        }
                        MiniDemoButton(label: "8", isAccent: false) {
                            demoExpression = "8³"
                            demoResult = "512"
                        }
                        MiniDemoButton(label: "9", isAccent: false) {
                            demoExpression = "9²"
                            demoResult = "81"
                        }
                        MiniDemoButton(label: "=", isEquals: true) {
                            Haptic.light()
                        }
                    }
                }
                .padding(AppSpacing.md)

            case 1:
                // Page 2: Animated Camera Scanner Preview
                ZStack {
                    VStack(spacing: AppSpacing.md) {
                        // Camera viewfinder header
                        HStack {
                            Image(systemName: "camera.viewfinder")
                                .foregroundStyle(themeManager.accent.accent)
                            Text("Camera Solver")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(AppColor.textPrimary(colorScheme))
                            Spacer()
                            Circle()
                                .fill(Color.red)
                                .frame(width: 6, height: 6)
                        }

                        // Simulated math equation line
                        VStack(spacing: 8) {
                            Text("3x + 15 = 45")
                                .font(AppFont.display(24, weight: .bold))
                                .foregroundStyle(AppColor.textPrimary(colorScheme))

                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppColor.success)
                                Text("Step: 3x = 30 ➔ x = 10")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(AppColor.success)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(AppColor.success.opacity(0.12))
                            .clipShape(Capsule())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
                    }
                    .padding(AppSpacing.md)

                    // Moving laser scanner line
                    Rectangle()
                        .fill(themeManager.accent.gradient)
                        .frame(height: 3)
                        .shadow(color: themeManager.accent.accent, radius: 8, x: 0, y: 0)
                        .offset(y: isScanning ? 60 : -60)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                                isScanning = true
                            }
                        }
                }

            case 2:
                // Page 3: Animated AI Tutor Chat Preview
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    HStack(spacing: 8) {
                        Image(systemName: "wand.and.stars")
                            .foregroundStyle(themeManager.accent.accent)
                        Text("AI Math Tutor")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppColor.textPrimary(colorScheme))
                    }

                    // User Bubble
                    HStack {
                        Spacer()
                        Text("How to solve 2x² - 8 = 0?")
                            .font(.caption.weight(.medium))
                            .padding(10)
                            .background(themeManager.accent.gradient)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    // Tutor Bubble
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(themeManager.accent.accent.opacity(0.2))
                            .frame(width: 24, height: 24)
                            .overlay(
                                Image(systemName: "sparkles")
                                    .font(.caption2)
                                    .foregroundStyle(themeManager.accent.accent)
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            Text("1. Add 8 to both sides: 2x² = 8")
                                .font(.caption.weight(.medium))
                            Text("2. Divide by 2: x² = 4")
                                .font(.caption.weight(.medium))
                            Text("3. Take square root: x = ±2 ✨")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(themeManager.accent.accent)
                        }
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
                .padding(AppSpacing.md)

            case 3:
                // Page 4: Interactive Theme Switcher Preview
                VStack(spacing: AppSpacing.md) {
                    Text("Select Accent Theme")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppColor.textSecondary(colorScheme))

                    AccentThemePicker()
                        .padding(.vertical, 4)

                    // Theme preview chip
                    HStack(spacing: 8) {
                        Image(systemName: "paintpalette.fill")
                            .foregroundStyle(themeManager.accent.accent)
                        Text("Active: \(themeManager.accent.displayName)")
                            .font(AppFont.display(14, weight: .bold))
                            .foregroundStyle(AppColor.textPrimary(colorScheme))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(themeManager.accent.accent.opacity(0.12))
                    .clipShape(Capsule())
                }
                .padding(AppSpacing.md)

            default:
                EmptyView()
            }
        }
    }
}

/// Mini interactive keypad button for onboarding demo
private struct MiniDemoButton: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(ThemeManager.self) private var themeManager

    let label: String
    var isAccent: Bool = false
    var isEquals: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(AppFont.display(14, weight: .bold))
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(buttonBackground)
                .foregroundStyle(
                    isEquals
                        ? Color.white
                        : (isAccent ? themeManager.accent.accent : AppColor.textPrimary(colorScheme))
                )
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.bouncy)
    }

    @ViewBuilder
    private var buttonBackground: some View {
        if isEquals {
            themeManager.accent.gradient
        } else if isAccent {
            themeManager.accent.accent.opacity(0.15)
        } else {
            AppColor.background(colorScheme)
        }
    }
}

#Preview("Onboarding - Light") {
    OnboardingView(onComplete: {})
        .environment(ThemeManager())
        .preferredColorScheme(.light)
}

#Preview("Onboarding - Dark") {
    OnboardingView(onComplete: {})
        .environment(ThemeManager())
        .preferredColorScheme(.dark)
}
