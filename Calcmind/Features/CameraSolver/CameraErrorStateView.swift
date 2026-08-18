import SwiftUI

struct CameraErrorStateView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(ThemeManager.self) private var themeManager

    let message: String
    let image: UIImage?
    let onRetake: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 88, height: 88)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
                    .opacity(0.5)
            }

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 32))
                .foregroundStyle(AppColor.warning)
                .accessibilityHidden(true)

            Text("Couldn't solve that one")
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppColor.textPrimary(colorScheme))

            Text(message)
                .font(.subheadline)
                .foregroundStyle(AppColor.textSecondary(colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)

            Spacer()
            Spacer()

            HStack(spacing: AppSpacing.md) {
                Button {
                    onClose()
                } label: {
                    Text("Close")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                        .background(AppColor.backgroundElevated(colorScheme))
                        .foregroundStyle(AppColor.textPrimary(colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
                }
                .buttonStyle(.bouncy)

                PrimaryButton("Try Again", systemImage: "camera.fill") {
                    onRetake()
                }
            }
            .padding(AppSpacing.md)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background(colorScheme).ignoresSafeArea())
    }
}

#Preview("Light") {
    CameraErrorStateView(
        message: "Couldn't find a math expression in that photo. Try getting closer, reducing glare, or improving the lighting.",
        image: nil,
        onRetake: {},
        onClose: {}
    )
    .environment(ThemeManager())
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    CameraErrorStateView(
        message: "Couldn't find a math expression in that photo. Try getting closer, reducing glare, or improving the lighting.",
        image: nil,
        onRetake: {},
        onClose: {}
    )
    .environment(ThemeManager())
    .preferredColorScheme(.dark)
}
