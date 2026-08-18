import SwiftUI

enum CalculatorKeyStyle {
    case digit
    case operatorKey
    case function
    case equals
    case destructive
}

/// One calculator key. Sizing is left to the parent grid (LazyVGrid +
/// GridItem.flexible) so keys stay responsive across device widths and
/// landscape/portrait — this view only owns its own look and press feel.
struct CalculatorButton: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.colorScheme) private var colorScheme

    let label: String
    let style: CalculatorKeyStyle
    let height: CGFloat?
    let action: () -> Void

    init(label: String, style: CalculatorKeyStyle, height: CGFloat? = nil, action: @escaping () -> Void) {
        self.label = label
        self.style = style
        self.height = height
        self.action = action
    }

    var body: some View {
        Button {
            Haptic.light()
            action()
        } label: {
            Text(label)
                .font(AppFont.display(fontSize, weight: .medium))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .padding(.horizontal, 2)
                .frame(maxWidth: .infinity)
                .frame(height: effectiveHeight)
                .background(background)
                .foregroundStyle(foreground)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
        .buttonStyle(.bouncy)
        .accessibilityLabel(accessibilityLabel)
    }

    private var effectiveHeight: CGFloat {
        height ?? 64
    }

    private var cornerRadius: CGFloat {
        min(AppRadius.medium, max(8, effectiveHeight * 0.32))
    }

    private var fontSize: CGFloat {
        if effectiveHeight < 50 {
            return label.count > 2 ? 13 : (label.count > 1 ? 15 : 19)
        } else if effectiveHeight < 58 {
            return label.count > 2 ? 16 : (label.count > 1 ? 18 : 22)
        } else {
            return label.count > 2 ? 20 : 26
        }
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .digit:
            AppColor.backgroundElevated(colorScheme)
        case .operatorKey:
            AppColor.backgroundElevated(colorScheme).opacity(0.6)
        case .function:
            Color.clear
        case .equals:
            themeManager.accent.gradient
        case .destructive:
            AppColor.warning.opacity(0.15)
        }
    }

    private var foreground: Color {
        switch style {
        case .digit, .function: return AppColor.textPrimary(colorScheme)
        case .operatorKey: return themeManager.accent.accent
        case .equals: return .white
        case .destructive: return AppColor.warning
        }
    }

    private var accessibilityLabel: String {
        switch label {
        case "÷": return "Divide"
        case "×": return "Multiply"
        case "−": return "Subtract"
        case "+": return "Add"
        case "=": return "Equals"
        case "±": return "Plus or minus"
        case "AC": return "All clear"
        default: return label
        }
    }
}

#Preview {
    HStack {
        CalculatorButton(label: "7", style: .digit) {}
        CalculatorButton(label: "÷", style: .operatorKey) {}
        CalculatorButton(label: "AC", style: .destructive) {}
        CalculatorButton(label: "=", style: .equals) {}
    }
    .padding()
    .environment(ThemeManager())
}
