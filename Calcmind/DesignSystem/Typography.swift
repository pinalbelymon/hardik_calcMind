import SwiftUI

/// Central font scale. Rounded design for anything numeric/display,
/// system default for UI copy so Dynamic Type behaves normally.
enum AppFont {
    static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    /// The big calculator result number.
    static var displayLarge: Font { display(64, weight: .bold) }

    /// Secondary/preview result sizes (e.g. history rows).
    static var displayMedium: Font { display(34, weight: .semibold) }

    /// The running expression above the result ("22 + 18"). Deliberately
    /// fixed-size, not a scaling text style — same intentional exception
    /// as `displayLarge` below. See PHASE7-NOTES.md: a calculator's core
    /// numeric readout doesn't scale with Dynamic Type in any mainstream
    /// calculator app (including Apple's own), since the keypad layout it
    /// sits above depends on stable sizing. This was previously
    /// `.title3` (a scaling text style) sitting inside a hardcoded
    /// `.frame(height: 28)` — a real clipping bug at large accessibility
    /// text sizes, fixed here by making the whole display consistently
    /// fixed-size instead.
    static var expressionText: Font {
        display(20, weight: .medium)
    }

    /// Step-by-step solution body text.
    static var stepText: Font {
        .system(.body, design: .rounded, weight: .regular)
    }
}

extension View {
    /// Locks digit widths so numbers don't jitter horizontally as they change.
    func tabularNumerals() -> some View {
        self.monospacedDigit()
    }
}
