import WidgetKit

struct CurrencyEntry: TimelineEntry {
    let date: Date
    let baseCurrency: String
    let rates: [CurrencyRate]
    /// True when this entry is placeholder/fallback data (first-ever
    /// render, or a failed network fetch) rather than a real result —
    /// lets the view show a subtly different state if useful later.
    let isPlaceholder: Bool
}
