import SwiftUI
import WidgetKit

/// Deliberately styled with system colors (.primary, .secondary) rather
/// than the app's custom Theme system — widgets sit on the Home Screen
/// alongside everything else, and Apple's own guidance favors restraint
/// there over full in-app branding. Pulling in the whole DesignSystem
/// would also mean adding those files to this target too, for no real
/// visual benefit at this size.
struct CurrencyWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: CurrencyEntry

    var body: some View {
        content
            .widgetURL(URL(string: "calcmind://currency"))
            .containerBackground(for: .widget) {
                Color(.systemBackground)
            }
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .systemSmall:
            smallView
        default:
            mediumView
        }
    }

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(entry.baseCurrency, systemImage: "dollarsign.circle.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Spacer(minLength: 4)

            if let first = entry.rates.first {
                VStack(alignment: .leading, spacing: 2) {
                    Text(first.code)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text(first.value, format: .number.precision(.fractionLength(2)))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                }
            }

            Spacer(minLength: 4)

            Text("Updated \(entry.date.formatted(date: .omitted, time: .shortened))")
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var mediumView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("\(entry.baseCurrency) Exchange Rates", systemImage: "arrow.left.arrow.right.circle.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                ForEach(entry.rates) { rate in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(rate.code)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.secondary)
                        Text(rate.value, format: .number.precision(.fractionLength(2)))
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Spacer(minLength: 4)

            Text("Updated \(entry.date.formatted(date: .abbreviated, time: .shortened))")
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

#Preview(as: .systemSmall) {
    CurrencyWidget()
} timeline: {
    CurrencyEntry(
        date: .now,
        baseCurrency: "USD",
        rates: [CurrencyRate(code: "EUR", value: 0.92), CurrencyRate(code: "GBP", value: 0.79)],
        isPlaceholder: false
    )
}

#Preview(as: .systemMedium) {
    CurrencyWidget()
} timeline: {
    CurrencyEntry(
        date: .now,
        baseCurrency: "USD",
        rates: [
            CurrencyRate(code: "EUR", value: 0.92),
            CurrencyRate(code: "GBP", value: 0.79),
            CurrencyRate(code: "JPY", value: 149.32),
        ],
        isPlaceholder: false
    )
}
