import SwiftUI

// MARK: - Animation
// One shared vocabulary of motion so every screen feels like the same app.
// Prefer these over ad-hoc `.animation(.spring(...))` calls scattered around views.

enum AppAnimation {
    /// Default interactive bounce — button taps, selection changes.
    static let bouncy = Animation.spring(response: 0.35, dampingFraction: 0.75)

    /// Tighter spring for very small elements (keypad digits, chips).
    static let snappy = Animation.spring(response: 0.25, dampingFraction: 0.8)

    /// Cross-fades, layout reflows (e.g. Standard ↔ Scientific keypad switch).
    static let smooth = Animation.easeInOut(duration: 0.3)

    /// Error/shake feedback.
    static let shake = Animation.spring(response: 0.2, dampingFraction: 0.3)
}

// MARK: - Reduce Motion
// Small element press feedback (button scale bounces) is left alone
// everywhere in this app — Apple's own guidance treats brief, small
// feedback like that as fine either way. These helpers are specifically
// for the two categories Reduce Motion is actually meant to address:
// continuous/repeating decorative motion, and large spatial movement
// (things sliding or shaking across the screen).

extension AnyTransition {
    /// A slide-and-fade transition normally; falls back to a plain
    /// cross-fade when Reduce Motion is on. Use for anything that
    /// currently slides in from an edge (chat bubbles, revealed steps,
    /// the scientific keypad panel).
    static func revealFromEdge(_ edge: Edge, reduceMotion: Bool) -> AnyTransition {
        guard !reduceMotion else { return .opacity }
        return .asymmetric(
            insertion: .move(edge: edge).combined(with: .opacity),
            removal: .opacity
        )
    }
}

// MARK: - Reduce Motion, continuous/decorative loops
// No helper type for this one — the correct pattern turned out to be
// gating whether the loop *starts* at all, not nulling out its Animation:
//
//     @Environment(\.accessibilityReduceMotion) private var reduceMotion
//     @State private var isPulsing = false
//     ...
//     .onAppear {
//         guard !reduceMotion else { return }
//         withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
//             isPulsing = true
//         }
//     }
//
// Passing `nil` as the Animation instead would still flip `isPulsing` to
// true instantly and leave the view frozen at its "mid-pulse" value
// (e.g. permanently 40% opacity) rather than its intended resting state.
// Gating the trigger itself means Reduce Motion users just see the view
// at rest, which is what they actually want. Used in TypingIndicatorView,
// SolvingStateView, and TutorEmptyStateView.

// MARK: - Reduce Transparency
// No helper needed here, unlike the two above — this app only ever uses
// system Material tokens (.thinMaterial, .ultraThinMaterial), never a
// hand-rolled blur/opacity effect. Apple's Materials already adjust their
// own opacity automatically when Reduce Transparency is on, so standard
// usage gets this for free. Verified by construction: search this project
// for "Material" and every hit is one of the two system tokens above.

// MARK: - Radius

enum AppRadius {
    static let small: CGFloat = 12
    static let medium: CGFloat = 20
    static let large: CGFloat = 28
    static let pill: CGFloat = 999
}

// MARK: - Spacing

enum AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}
