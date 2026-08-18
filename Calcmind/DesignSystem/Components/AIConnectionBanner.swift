import SwiftUI

/// Surfaces when Gemini isn't reachable — calculator still works offline.
struct AIConnectionBanner: View {
    @Environment(FirestoreKeyService.self) private var keyService
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        switch keyService.state {
        case .idle, .loading:
            banner(
                icon: "arrow.triangle.2.circlepath",
                message: "Connecting AI features…",
                style: .info
            )
        case .ready:
            EmptyView()
        case .failed(let message):
            banner(
                icon: "wifi.slash",
                message: offlineMessage(fallback: message),
                style: .warning
            )
        }
    }

    private enum BannerStyle {
        case info, warning
    }

    private func offlineMessage(fallback: String) -> String {
        "AI features need an internet connection. The calculator still works offline. \(fallback)"
    }

    private func banner(icon: String, message: String, style: BannerStyle) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(style == .warning ? AppColor.warning : AppColor.textSecondary(colorScheme))
            Text(message)
                .font(.caption)
                .foregroundStyle(AppColor.textSecondary(colorScheme))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.backgroundElevated(colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

#Preview("Loading") {
    AIConnectionBanner()
        .environment(FirestoreKeyService())
        .padding()
}
