import SwiftUI

/// Row of accent-theme swatches. Used in Settings, and previewed here in the
/// Design System showcase. Selection ring animates between swatches with
/// matchedGeometryEffect rather than just appearing/disappearing.
struct AccentThemePicker: View {
    @Environment(ThemeManager.self) private var themeManager
    @Namespace private var selectionNamespace

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ForEach(AccentTheme.allCases) { theme in
                swatch(for: theme)
            }
        }
    }

    @ViewBuilder
    private func swatch(for theme: AccentTheme) -> some View {
        let isSelected = themeManager.accent == theme

        Circle()
            .fill(theme.gradient)
            .frame(width: 36, height: 36)
            .overlay {
                if isSelected {
                    Circle()
                        .strokeBorder(.white, lineWidth: 2.5)
                        .matchedGeometryEffect(id: "accentSelection", in: selectionNamespace)
                }
            }
            .overlay {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .scaleEffect(isSelected ? 1.08 : 1.0)
            .onTapGesture {
                withAnimation(AppAnimation.bouncy) {
                    themeManager.accent = theme
                }
                Haptic.light()
            }
            .accessibilityLabel(theme.displayName)
            .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    AccentThemePicker()
        .environment(ThemeManager())
        .padding()
}
