import SwiftUI

struct KeypadView: View {
    let viewModel: CalculatorViewModel
    var buttonHeight: CGFloat? = nil
    var spacing: CGFloat = AppSpacing.sm

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: spacing), count: 4)
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            CalculatorButton(label: "AC", style: .destructive, height: buttonHeight) { viewModel.tapAllClear() }
            CalculatorButton(label: "±", style: .function, height: buttonHeight) { viewModel.tapPlusMinus() }
            CalculatorButton(label: "%", style: .function, height: buttonHeight) { viewModel.tapPercent() }
            CalculatorButton(label: "÷", style: .operatorKey, height: buttonHeight) { viewModel.tapOperator(.divide) }

            CalculatorButton(label: "7", style: .digit, height: buttonHeight) { viewModel.tapDigit("7") }
            CalculatorButton(label: "8", style: .digit, height: buttonHeight) { viewModel.tapDigit("8") }
            CalculatorButton(label: "9", style: .digit, height: buttonHeight) { viewModel.tapDigit("9") }
            CalculatorButton(label: "×", style: .operatorKey, height: buttonHeight) { viewModel.tapOperator(.multiply) }

            CalculatorButton(label: "4", style: .digit, height: buttonHeight) { viewModel.tapDigit("4") }
            CalculatorButton(label: "5", style: .digit, height: buttonHeight) { viewModel.tapDigit("5") }
            CalculatorButton(label: "6", style: .digit, height: buttonHeight) { viewModel.tapDigit("6") }
            CalculatorButton(label: "−", style: .operatorKey, height: buttonHeight) { viewModel.tapOperator(.subtract) }

            CalculatorButton(label: "1", style: .digit, height: buttonHeight) { viewModel.tapDigit("1") }
            CalculatorButton(label: "2", style: .digit, height: buttonHeight) { viewModel.tapDigit("2") }
            CalculatorButton(label: "3", style: .digit, height: buttonHeight) { viewModel.tapDigit("3") }
            CalculatorButton(label: "+", style: .operatorKey, height: buttonHeight) { viewModel.tapOperator(.add) }

            CalculatorButton(label: "⌫", style: .function, height: buttonHeight) { viewModel.tapBackspace() }
            CalculatorButton(label: "0", style: .digit, height: buttonHeight) { viewModel.tapDigit("0") }
            CalculatorButton(label: ".", style: .digit, height: buttonHeight) { viewModel.tapDigit(".") }
            CalculatorButton(label: "=", style: .equals, height: buttonHeight) { viewModel.tapEquals() }
        }
    }
}

#Preview {
    KeypadView(viewModel: CalculatorViewModel())
        .environment(ThemeManager())
        .padding()
}
