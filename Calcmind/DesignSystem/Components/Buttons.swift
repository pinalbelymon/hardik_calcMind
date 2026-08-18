import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Bouncy Button Style
// Applies the app-wide "press and settle" feel to any button.

struct BouncyButtonStyle: ButtonStyle {
    var pressedScale: CGFloat = 0.94

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1.0)
            .animation(AppAnimation.snappy, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == BouncyButtonStyle {
    static var bouncy: BouncyButtonStyle { BouncyButtonStyle() }
}

// MARK: - Haptic Helper

enum Haptic {
    static func light() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }

    static func success() {
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }

    static func error() {
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        #endif
    }
}

// MARK: - Primary Button
// The one gradient, filled, full-width action button used app-wide
// (e.g. "Solve Equation", "Send", "New Chat").

struct PrimaryButton: View {
    @Environment(ThemeManager.self) private var themeManager

    let title: String
    var systemImage: String?
    let action: () -> Void

    init(_ title: String, systemImage: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button {
            Haptic.light()
            action()
        } label: {
            HStack(spacing: AppSpacing.sm) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .font(.body.weight(.semibold))
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            .frame(maxWidth: .infinity)
            .background(themeManager.accent.gradient)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
        }
        .buttonStyle(.bouncy)
    }
}

#Preview {
    VStack(spacing: AppSpacing.md) {
        PrimaryButton("Solve Equation", systemImage: "sparkles") {}
        PrimaryButton("Send") {}
    }
    .padding()
    .environment(ThemeManager())
}
