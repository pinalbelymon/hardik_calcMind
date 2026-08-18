import SwiftUI
import UIKit

struct ChatMessageBubble: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let message: TutorMessage

    var body: some View {
        HStack {
            if message.role == .user { Spacer(minLength: 40) }

            Group {
                if message.role == .model && message.content.isEmpty {
                    TypingIndicatorView()
                } else {
                    bubbleContent
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(bubbleBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))

            if message.role == .model { Spacer(minLength: 40) }
        }
        .transition(.revealFromEdge(
            message.role == .user ? .trailing : .leading,
            reduceMotion: reduceMotion
        ))
    }

    @ViewBuilder
    private var bubbleContent: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            if message.role == .model && !message.content.isEmpty {
                AIBadge()
            }

            if let imageData = message.imageJPEGData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 220, maxHeight: 160)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous))
                    .accessibilityLabel("Photo of equation")
            }

            if !message.content.isEmpty {
                Text(LocalizedStringKey(MathFormatter.format(message.content)))
                    .font(AppFont.stepText)
                    .foregroundStyle(bubbleForeground)
                    .textSelection(.enabled)
            }
        }
    }

    @ViewBuilder
    private var bubbleBackground: some View {
        if message.role == .user {
            themeManager.accent.gradient
        } else {
            AppColor.backgroundElevated(colorScheme)
        }
    }

    private var bubbleForeground: Color {
        message.role == .user ? .white : AppColor.textPrimary(colorScheme)
    }
}

#Preview("Light") {
    VStack(alignment: .leading, spacing: AppSpacing.md) {
        ChatMessageBubble(message: TutorMessage(role: .user, content: "What is the Pythagorean theorem?"))
        ChatMessageBubble(message: TutorMessage(role: .model, content: "It relates the sides of a right triangle: a² + b² = c²."))
        ChatMessageBubble(message: TutorMessage(role: .model, content: ""))
    }
    .padding()
    .environment(ThemeManager())
    .preferredColorScheme(.light)
}
