import SwiftUI

struct CalculatorDisplayView: View {
    @Environment(\.colorScheme) private var colorScheme
    let viewModel: CalculatorViewModel
    var isCompact: Bool = false

    var body: some View {
        VStack(alignment: .trailing, spacing: isCompact ? 2 : AppSpacing.xs) {
            ScrollView(.horizontal, showsIndicators: false) {
                Text(viewModel.smallDisplay)
                    .font(isCompact ? AppFont.display(16, weight: .medium) : AppFont.expressionText)
                    .foregroundStyle(AppColor.textSecondary(colorScheme))
                    .tabularNumerals()
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .frame(minHeight: isCompact ? 20 : 28)

            Text(viewModel.bigDisplay)
                .font(isCompact ? AppFont.display(48, weight: .bold) : AppFont.displayLarge)
                .tabularNumerals()
                .minimumScaleFactor(0.4)
                .lineLimit(1)
                .foregroundStyle(
                    viewModel.errorMessage != nil
                        ? AppColor.warning
                        : AppColor.textPrimary(colorScheme)
                )
                .contentTransition(.numericText())
                .animation(AppAnimation.smooth, value: viewModel.bigDisplay)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, isCompact ? AppSpacing.xs : AppSpacing.md)
        .shake(trigger: viewModel.shakeTrigger)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Light") {
    CalculatorDisplayView(viewModel: {
        let vm = CalculatorViewModel()
        vm.tapDigit("2"); vm.tapDigit("2")
        vm.tapOperator(.add)
        vm.tapDigit("1"); vm.tapDigit("8")
        return vm
    }())
    .environment(ThemeManager())
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    CalculatorDisplayView(viewModel: {
        let vm = CalculatorViewModel()
        vm.tapDigit("2"); vm.tapDigit("2")
        vm.tapOperator(.add)
        vm.tapDigit("1"); vm.tapDigit("8")
        return vm
    }())
    .environment(ThemeManager())
    .preferredColorScheme(.dark)
    .background(Color.black)
}
