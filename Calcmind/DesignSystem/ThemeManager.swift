import SwiftUI
import Observation

/// Single source of truth for the user's chosen accent theme, appearance,
/// and sound preference. Injected into the environment once at the app
/// root via `.environment(themeManager)`.
///
/// Naming debt, flagged rather than silently left: this class started as
/// just the accent theme in Phase 0 and has picked up appearance (Phase 2)
/// and now sound (Phase 7) — it's really "app preferences" at this point,
/// not just theming. Not renamed here since it'd touch every environment
/// injection across the project for a purely mechanical change with no
/// behavior difference; `AppPreferences` would be the honest name if this
/// ever gets a dedicated pass.
@Observable
final class ThemeManager {
    private static let accentStorageKey = "com.calcmind.selectedAccentTheme"
    private static let appearanceStorageKey = "com.calcmind.selectedAppearance"
    private static let soundEffectsStorageKey = "com.calcmind.soundEffectsEnabled"

    var accent: AccentTheme {
        didSet {
            UserDefaults.standard.set(accent.rawValue, forKey: Self.accentStorageKey)
        }
    }

    var appearance: AppAppearance {
        didSet {
            UserDefaults.standard.set(appearance.rawValue, forKey: Self.appearanceStorageKey)
        }
    }

    /// Defaults to on — matches the "premium, playful" direction from the
    /// original brief — with an easy Settings toggle for anyone who'd
    /// rather it was quiet.
    var soundEffectsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(soundEffectsEnabled, forKey: Self.soundEffectsStorageKey)
        }
    }

    init() {
        let savedAccent = UserDefaults.standard.string(forKey: Self.accentStorageKey)
        self.accent = AccentTheme(rawValue: savedAccent ?? "") ?? .indigo

        let savedAppearance = UserDefaults.standard.string(forKey: Self.appearanceStorageKey)
        self.appearance = AppAppearance(rawValue: savedAppearance ?? "") ?? .system

        if UserDefaults.standard.object(forKey: Self.soundEffectsStorageKey) == nil {
            self.soundEffectsEnabled = true
        } else {
            self.soundEffectsEnabled = UserDefaults.standard.bool(forKey: Self.soundEffectsStorageKey)
        }
    }
}
