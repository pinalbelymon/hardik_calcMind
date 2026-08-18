import Foundation

/// Turns a raw Double into the string the calculator actually displays —
/// whole numbers show without a trailing ".0", long decimals get trimmed,
/// non-finite values become readable error text.
enum DisplayFormatter {
    static func format(_ value: Double) -> String {
        if value.isNaN { return "Error" }
        if value.isInfinite { return value > 0 ? "∞" : "-∞" }

        if value == value.rounded() && abs(value) < 1e15 {
            return String(format: "%.0f", value)
        }

        var formatted = String(format: "%.10f", value)
        while formatted.hasSuffix("0") { formatted.removeLast() }
        if formatted.hasSuffix(".") { formatted.removeLast() }
        return formatted
    }
}
