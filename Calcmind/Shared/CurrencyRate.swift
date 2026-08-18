import Foundation

/// One currency's rate against the base currency. Deliberately has no
/// WidgetKit dependency — this file is added to both the main app target
/// (for CurrencyRatesView) and the CurrencyWidget extension target, and
/// keeping it plain Foundation makes that dual membership trivial.
struct CurrencyRate: Identifiable, Equatable {
    var id: String { code }
    let code: String
    let value: Double
}
