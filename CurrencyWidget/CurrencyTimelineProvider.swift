import WidgetKit

struct CurrencyTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> CurrencyEntry {
        CurrencyEntry(
            date: .now,
            baseCurrency: CurrencyRateFetcher.baseCurrency,
            rates: placeholderRates,
            isPlaceholder: true
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (CurrencyEntry) -> Void) {
        if context.isPreview {
            completion(placeholder(in: context))
            return
        }
        Task {
            completion(await makeEntry())
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CurrencyEntry>) -> Void) {
        Task {
            let entry = await makeEntry()
            // Frankfurter's underlying ECB rates update once a day — every
            // 6 hours is more than enough headroom and keeps this well
            // within any reasonable request budget.
            let nextUpdate = Calendar.current.date(byAdding: .hour, value: 6, to: .now)
                ?? Date().addingTimeInterval(6 * 3600)
            completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
        }
    }

    private func makeEntry() async -> CurrencyEntry {
        do {
            let rates = try await CurrencyRateFetcher.fetchRates()
            return CurrencyEntry(
                date: .now,
                baseCurrency: CurrencyRateFetcher.baseCurrency,
                rates: rates,
                isPlaceholder: false
            )
        } catch {
            // Fall back to placeholder-shaped data rather than showing
            // nothing if the system refreshes this in the background with
            // no connectivity.
            return CurrencyEntry(
                date: .now,
                baseCurrency: CurrencyRateFetcher.baseCurrency,
                rates: placeholderRates,
                isPlaceholder: true
            )
        }
    }

    private var placeholderRates: [CurrencyRate] {
        CurrencyRateFetcher.targetCurrencies.map { CurrencyRate(code: $0, value: 0) }
    }
}
