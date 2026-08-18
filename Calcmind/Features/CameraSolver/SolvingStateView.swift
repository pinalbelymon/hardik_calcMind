import SwiftUI

/// Shown while Gemini is reading and solving the captured photo. The
/// thumbnail sits up top as a small "morphed" chip while a pulsing
/// skeleton stands in for the steps that are about to appear.
struct SolvingStateView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let image: UIImage?

    @State private var isPulsing = false

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 88, height: 88)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                            .stroke(themeManager.accent.gradient, lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 12, y: 6)
            }

            Text("Reading your equation…")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppColor.textSecondary(colorScheme))

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                skeletonLine(widthFraction: 0.9)
                skeletonLine(widthFraction: 0.75)
                skeletonLine(widthFraction: 0.5)
            }
            .frame(width: 260)
            .opacity(isPulsing ? 0.4 : 1.0)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background(colorScheme).ignoresSafeArea())
        .onAppear {
            // Reduce Motion: skeleton stays fully opaque and static — the
            // shape alone still reads as "placeholder content loading."
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }

    private func skeletonLine(widthFraction: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous)
            .fill(AppColor.backgroundElevated(colorScheme))
            .frame(width: 260 * widthFraction, height: 16)
    }
}

#Preview("Light") {
    SolvingStateView(image: nil)
        .environment(ThemeManager())
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    SolvingStateView(image: nil)
        .environment(ThemeManager())
        .preferredColorScheme(.dark)
}
