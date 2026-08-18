import SwiftUI

/// Extra rows revealed in Scientific mode. Always visible in landscape
/// (see CalculatorView), toggled with an animated reveal in portrait.
struct ScientificKeypadView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let viewModel: CalculatorViewModel
    var buttonHeight: CGFloat? = nil
    var spacing: CGFloat = AppSpacing.sm

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: spacing), count: 4)
    }

    var body: some View {
        VStack(spacing: spacing) {
            LazyVGrid(columns: columns, spacing: spacing) {
                CalculatorButton(label: "(", style: .function, height: buttonHeight) { viewModel.tapParen() }
                CalculatorButton(label: ")", style: .function, height: buttonHeight) { viewModel.tapParen() }
                CalculatorButton(label: "MC", style: .function, height: buttonHeight) { viewModel.memoryClear() }
                CalculatorButton(label: "MR", style: .function, height: buttonHeight) { viewModel.memoryRecall() }
            }
            LazyVGrid(columns: columns, spacing: spacing) {
                CalculatorButton(label: "x²", style: .function, height: buttonHeight) { viewModel.tapPostfix(.square) }
                CalculatorButton(label: "x³", style: .function, height: buttonHeight) { viewModel.tapPostfix(.cube) }
                CalculatorButton(label: "1/x", style: .function, height: buttonHeight) { viewModel.tapFunction(.reciprocal) }
                CalculatorButton(label: "x!", style: .function, height: buttonHeight) { viewModel.tapPostfix(.factorial) }
            }
            LazyVGrid(columns: columns, spacing: spacing) {
                CalculatorButton(label: "sin", style: .function, height: buttonHeight) { viewModel.tapFunction(.sin) }
                CalculatorButton(label: "cos", style: .function, height: buttonHeight) { viewModel.tapFunction(.cos) }
                CalculatorButton(label: "tan", style: .function, height: buttonHeight) { viewModel.tapFunction(.tan) }
                CalculatorButton(label: "√", style: .function, height: buttonHeight) { viewModel.tapFunction(.sqrt) }
            }
            LazyVGrid(columns: columns, spacing: spacing) {
                CalculatorButton(label: "ln", style: .function, height: buttonHeight) { viewModel.tapFunction(.ln) }
                CalculatorButton(label: "log", style: .function, height: buttonHeight) { viewModel.tapFunction(.log) }
                CalculatorButton(label: "π", style: .function, height: buttonHeight) { viewModel.tapConstant(.pi) }
                CalculatorButton(label: viewModel.angleUnit.displayLabel, style: .function, height: buttonHeight) {
                    viewModel.angleUnit = viewModel.angleUnit == .degrees ? .radians : .degrees
                }
            }
        }
        .transition(reduceMotion ? .opacity : .asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        ))
    }
}

#Preview {
    ScientificKeypadView(viewModel: CalculatorViewModel())
        .environment(ThemeManager())
        .padding()
}
