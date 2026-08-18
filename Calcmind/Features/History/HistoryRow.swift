import SwiftUI

struct HistoryRow: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(ThemeManager.self) private var themeManager
    let record: CalculationRecord

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            VStack(alignment: .leading, spacing: 2) {
                Text(record.expression)
                    .font(.subheadline)
                    .foregroundStyle(AppColor.textSecondary(colorScheme))
                    .lineLimit(2)
                Text(record.result)
                    .font(AppFont.display(20, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary(colorScheme))
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                if record.isAISolved {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundStyle(themeManager.accent.gradient)
                        .accessibilityLabel("AI solved")
                }
                Text(timeLabel)
                    .font(.caption2)
                    .foregroundStyle(AppColor.textSecondary(colorScheme))
            }
        }
        .padding(.vertical, AppSpacing.xs)
    }

    private var timeLabel: String {
        record.date.formatted(date: .omitted, time: .shortened)
    }
}

#Preview {
    List {
        HistoryRow(record: CalculationRecord(expression: "22 + 18", result: "40"))
        HistoryRow(record: CalculationRecord(expression: "14√x + 15 = 71", result: "x = 16", isAISolved: true))
    }
    .environment(ThemeManager())
}
