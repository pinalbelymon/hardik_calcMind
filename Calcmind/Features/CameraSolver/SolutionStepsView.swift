import StoreKit
import SwiftUI

/// The payoff screen: equation, steps revealed one at a time with a small
/// stagger (rather than all appearing at once), then the answer.
struct SolutionStepsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.requestReview) private var requestReview

    let image: UIImage
    let solution: MathSolution
    let onRetake: () -> Void
    let onDone: () -> Void

    @State private var visibleStepCount = 0

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    GlassCard {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("EQUATION")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppColor.textSecondary(colorScheme))
                            Text(solution.equation)
                                .font(AppFont.expressionText)
                                .foregroundStyle(AppColor.textPrimary(colorScheme))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text("STEPS")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppColor.textSecondary(colorScheme))

                        ForEach(Array(solution.steps.enumerated()), id: \.offset) { index, step in
                            if index < visibleStepCount {
                                stepRow(index: index, text: step)
                                    .transition(.revealFromEdge(.leading, reduceMotion: reduceMotion))
                            }
                        }
                    }

                    GlassCard {
                        HStack {
                            Text("Answer")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(AppColor.textSecondary(colorScheme))
                            Spacer()
                            Text(solution.answer)
                                .font(AppFont.display(22, weight: .bold))
                                .foregroundStyle(themeManager.accent.gradient)
                        }
                    }
                    .opacity(visibleStepCount >= solution.steps.count ? 1 : 0)
                    .animation(AppAnimation.smooth, value: visibleStepCount)
                }
                .padding(AppSpacing.md)
            }

            footerButtons
        }
        .background(AppColor.background(colorScheme).ignoresSafeArea())
        .onAppear { revealStepsSequentially() }
    }

    private var header: some View {
        HStack(spacing: AppSpacing.md) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text("Solved")
                    .font(.headline)
                    .foregroundStyle(AppColor.textPrimary(colorScheme))
                AIBadge()
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(AppColor.success)
                .font(.title3)
                .accessibilityLabel("Solution complete")
        }
        .padding(AppSpacing.md)
    }

    private func stepRow(index: Int, text: String) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Text("\(index + 1)")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 20, height: 20)
                .background(themeManager.accent.gradient, in: Circle())
            Text(text)
                .font(AppFont.stepText)
                .foregroundStyle(AppColor.textPrimary(colorScheme))
        }
    }

    private var footerButtons: some View {
        HStack(spacing: AppSpacing.md) {
            Button {
                onRetake()
            } label: {
                Text("Retake")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
                    .background(AppColor.backgroundElevated(colorScheme))
                    .foregroundStyle(AppColor.textPrimary(colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
            }
            .buttonStyle(.bouncy)

            PrimaryButton("Done", systemImage: "checkmark") {
                requestReview()
                onDone()
            }
        }
        .padding(AppSpacing.md)
    }

    /// Reveals steps one at a time with a small stagger, then triggers StoreKit rate popup.
    private func revealStepsSequentially() {
        let totalSteps = solution.steps.count
        for index in 0..<totalSteps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.35) {
                withAnimation(AppAnimation.bouncy) {
                    visibleStepCount = index + 1
                }
                if index == totalSteps - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        requestReview()
                    }
                }
            }
        }
    }
}

#Preview("Light") {
    SolutionStepsView(
        image: UIImage(systemName: "function") ?? UIImage(),
        solution: MathSolution(
            equation: "14√x + 15 = 71",
            steps: ["14√x = 56", "√x = 4", "x = 16"],
            answer: "x = 16"
        ),
        onRetake: {},
        onDone: {}
    )
    .environment(ThemeManager())
    .preferredColorScheme(.light)
}
