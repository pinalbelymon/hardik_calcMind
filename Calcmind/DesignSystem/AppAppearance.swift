import SwiftUI

/// User's chosen color-scheme preference. `.system` means "follow the
/// device setting" — the default, and the recommended choice for most
/// users, since it's the one that requires no maintenance from them.
enum AppAppearance: String, CaseIterable, Identifiable, Equatable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "Auto"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    /// `nil` tells SwiftUI's `.preferredColorScheme` to defer to the system.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
