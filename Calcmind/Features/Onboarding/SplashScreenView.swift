import SwiftUI

/// Animated Splash Screen for CalcMind.
/// Displays an animated Liquid Glass brand mark with rotating & floating math symbols,
/// shimmering progress bar, and smooth transition to the main app or onboarding.
struct SplashScreenView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(ThemeManager.self) private var themeManager

    let onFinish: () -> Void

    @State private var isAnimatingLogo = false
    @State private var isAnimatingTitle = false
    @State private var isAnimatingProgress = false
    @State private var rotationAngle: Double = 0
    @State private var orbOffset: CGFloat = -10

    var body: some View {
        ZStack {
            // Background with ambient glowing gradient orbs
            AppColor.background(colorScheme)
                .ignoresSafeArea()

            ZStack {
                // Top-left ambient orb
                Circle()
                    .fill(themeManager.accent.gradient)
                    .frame(width: 260, height: 260)
                    .blur(radius: 70)
                    .opacity(colorScheme == .dark ? 0.35 : 0.25)
                    .offset(x: -80, y: orbOffset - 120)

                // Bottom-right ambient orb
                Circle()
                    .fill(themeManager.accent.gradientStops[1])
                    .frame(width: 220, height: 220)
                    .blur(radius: 60)
                    .opacity(colorScheme == .dark ? 0.3 : 0.2)
                    .offset(x: 100, y: -orbOffset + 140)
            }

            VStack(spacing: AppSpacing.xl) {
                Spacer()

                // Animated Brand Emblem & Floating Math Symbols
                ZStack {
                    // Outer glowing glass ring
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 140, height: 140)
                        .overlay(
                            Circle()
                                .stroke(themeManager.accent.gradient, lineWidth: 2)
                                .opacity(0.6)
                        )
                        .shadow(color: themeManager.accent.accent.opacity(0.4), radius: 24, x: 0, y: 12)
                        .scaleEffect(isAnimatingLogo ? 1.0 : 0.7)
                        .opacity(isAnimatingLogo ? 1.0 : 0.0)

                    // Central math symbols grid
                    VStack(spacing: 8) {
                        HStack(spacing: 12) {
                            Text("+")
                                .font(AppFont.display(24, weight: .bold))
                                .foregroundStyle(themeManager.accent.accent)
                            Text("−")
                                .font(AppFont.display(24, weight: .bold))
                                .foregroundStyle(AppColor.textPrimary(colorScheme))
                        }
                        HStack(spacing: 12) {
                            Text("×")
                                .font(AppFont.display(24, weight: .bold))
                                .foregroundStyle(AppColor.textPrimary(colorScheme))
                            Text("÷")
                                .font(AppFont.display(24, weight: .bold))
                                .foregroundStyle(themeManager.accent.accent)
                        }
                    }
                    .rotationEffect(.degrees(rotationAngle))

                    // Floating orbiting math chips
                    OrbitingSymbol(symbol: "π", offset: CGPoint(x: -65, y: -45), delay: 0.1, isAnimating: isAnimatingLogo)
                    OrbitingSymbol(symbol: "√", offset: CGPoint(x: 65, y: -40), delay: 0.2, isAnimating: isAnimatingLogo)
                    OrbitingSymbol(symbol: "ƒ(x)", offset: CGPoint(x: -60, y: 50), delay: 0.3, isAnimating: isAnimatingLogo)
                    OrbitingSymbol(symbol: "✨", offset: CGPoint(x: 60, y: 45), delay: 0.4, isAnimating: isAnimatingLogo)
                }

                // App Title & Tagline
                VStack(spacing: AppSpacing.xs) {
                    Text("CalcMind")
                        .font(AppFont.display(40, weight: .bold))
                        .foregroundStyle(AppColor.textPrimary(colorScheme))

                    Text("AI MATH & CALCULATOR")
                        .font(AppFont.display(12, weight: .semibold))
                        .tracking(3)
                        .foregroundStyle(themeManager.accent.gradient)
                }
                .offset(y: isAnimatingTitle ? 0 : 20)
                .opacity(isAnimatingTitle ? 1.0 : 0.0)

                Spacer()

                // Bottom Loading Progress Bar
                VStack(spacing: AppSpacing.sm) {
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(AppColor.hairline(colorScheme))
                            .frame(width: 140, height: 4)

                        Capsule()
                            .fill(themeManager.accent.gradient)
                            .frame(width: isAnimatingProgress ? 140 : 0, height: 4)
                    }
                    .clipShape(Capsule())

                    Text("Initializing AI Core...")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(AppColor.textSecondary(colorScheme))
                }
                .padding(.bottom, AppSpacing.xl)
            }
            .padding(AppSpacing.lg)
        }
        .onAppear {
            // Motion setup
            if !reduceMotion {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    orbOffset = 10
                }
                withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: false)) {
                    rotationAngle = 360
                }
            }

            // Entrance animations
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isAnimatingLogo = true
            }

            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                isAnimatingTitle = true
            }

            withAnimation(.easeInOut(duration: 1.6).delay(0.3)) {
                isAnimatingProgress = true
            }

            // Auto-dismiss splash screen after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                Haptic.light()
                onFinish()
            }
        }
    }
}

/// Floating orbiting badge symbol on splash screen
private struct OrbitingSymbol: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(ThemeManager.self) private var themeManager

    let symbol: String
    let offset: CGPoint
    let delay: Double
    let isAnimating: Bool

    var body: some View {
        Text(symbol)
            .font(.headline.weight(.bold))
            .foregroundStyle(AppColor.textPrimary(colorScheme))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.thinMaterial)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(themeManager.accent.accent.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
            .offset(x: offset.x, y: offset.y)
            .scaleEffect(isAnimating ? 1.0 : 0.2)
            .opacity(isAnimating ? 0.9 : 0.0)
            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(delay), value: isAnimating)
    }
}

#Preview("Splash Screen - Light") {
    SplashScreenView(onFinish: {})
        .environment(ThemeManager())
        .preferredColorScheme(.light)
}

#Preview("Splash Screen - Dark") {
    SplashScreenView(onFinish: {})
        .environment(ThemeManager())
        .preferredColorScheme(.dark)
}
