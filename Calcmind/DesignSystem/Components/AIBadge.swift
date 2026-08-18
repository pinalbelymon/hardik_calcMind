import SwiftUI

/// Small disclosure badge for AI-generated content (App Store §9 requirement).
struct AIBadge: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Label("AI", systemImage: "sparkles")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(AppColor.textSecondary(colorScheme))
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(AppColor.backgroundElevated(colorScheme))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(AppColor.textSecondary(colorScheme).opacity(0.25), lineWidth: 0.5)
            )
            .accessibilityLabel("AI-generated")
    }
}

#Preview {
    AIBadge()
        .padding()
}
