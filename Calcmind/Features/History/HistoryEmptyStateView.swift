import SwiftUI

struct HistoryEmptyStateView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            ZStack {
                Circle()
                    .fill(.thinMaterial)
                    .frame(width: 88, height: 88)
                    .overlay(
                        Circle()
                            .stroke(themeManager.accent.gradient, lineWidth: 1.5)
                            .opacity(0.6)
                    )
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(themeManager.accent.gradient)
                    .accessibilityHidden(true)
            }

            VStack(spacing: AppSpacing.xs) {
                Text("No calculations yet")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppColor.textPrimary(colorScheme))
                Text("Anything you solve in the calculator or by camera shows up here.")
                    .font(.subheadline)
                    .foregroundStyle(AppColor.textSecondary(colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.xl)
            }

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("Light") {
    HistoryEmptyStateView()
        .environment(ThemeManager())
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    HistoryEmptyStateView()
        .environment(ThemeManager())
        .preferredColorScheme(.dark)
}
