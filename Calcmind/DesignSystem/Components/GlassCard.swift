import SwiftUI

/// A translucent surface for floating/overlay content (cards, chips, sheets).
/// Per iOS 26 HIG guidance, glass is reserved for surfaces that float above
/// content — NOT used as the primary background of a whole screen.
struct GlassCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme

    private let content: Content
    private var padding: CGFloat = AppSpacing.md

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                .thinMaterial,
                in: RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                    .stroke(AppColor.hairline(colorScheme), lineWidth: 1)
            )
    }

    func padding(_ value: CGFloat) -> GlassCard {
        var copy = self
        copy.padding = value
        return copy
    }
}

#Preview("Light") {
    GlassCard {
        Text("Glass surface preview")
    }
    .padding()
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    GlassCard {
        Text("Glass surface preview")
    }
    .padding()
    .preferredColorScheme(.dark)
    .background(Color.black)
}
