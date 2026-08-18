import SwiftUI

// MARK: - Hex Color Helper

extension Color {
    /// Creates a Color from a 6-digit hex string, e.g. "6D5DF6"
    init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: "#", with: "")

        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0

        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1.0)
    }
}

// MARK: - Semantic Color Tokens
// Base neutrals stay fixed across accent themes; only the accent gradient changes.
// Everything here is resolved against the current ColorScheme — never hardcode
// .black / .white anywhere else in the app.

enum AppColor {
    static func background(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: "0E0B1A") : Color(hex: "F5F3FF")
    }

    static func backgroundElevated(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: "17132A") : Color(hex: "FFFFFF")
    }

    static func textPrimary(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: "F3F0FF") : Color(hex: "1B1730")
    }

    static func textSecondary(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: "A79FC7") : Color(hex: "6E6A85")
    }

    static func hairline(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.06)
    }

    static let success = Color(hex: "34D399")
    static let warning = Color(hex: "FB7185")
}

// MARK: - Accent Theme

/// A user-selectable accent theme. Base neutrals (AppColor) never change;
/// only the accent gradient swaps, so every theme still passes light/dark contrast.
enum AccentTheme: String, CaseIterable, Identifiable {
    case indigo
    case coral
    case teal
    case sunset
    case mono

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .indigo: return "Indigo"
        case .coral: return "Coral"
        case .teal: return "Teal"
        case .sunset: return "Sunset"
        case .mono: return "Mono"
        }
    }

    /// Two-stop gradient used for primary buttons, active states, and result highlights.
    var gradientStops: [Color] {
        switch self {
        case .indigo: return [Color(hex: "6D5DF6"), Color(hex: "A78BFA")]
        case .coral: return [Color(hex: "FB7185"), Color(hex: "FDA4AF")]
        case .teal: return [Color(hex: "14B8A6"), Color(hex: "5EEAD4")]
        case .sunset: return [Color(hex: "F97316"), Color(hex: "FBBF24")]
        case .mono: return [Color(hex: "52525B"), Color(hex: "A1A1AA")]
        }
    }

    var accent: Color { gradientStops[0] }

    var gradient: LinearGradient {
        LinearGradient(colors: gradientStops, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
