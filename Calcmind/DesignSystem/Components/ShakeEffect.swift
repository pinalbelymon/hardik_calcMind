import SwiftUI

/// A horizontal "no" shake. Increment an Int trigger value to fire it —
/// used for calculator errors here, and reusable later for other error
/// states without duplicating the effect.
private struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 8
    var shakesPerUnit: CGFloat = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = amount * sin(animatableData * .pi * shakesPerUnit)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

private struct ShakeViewModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let trigger: Int
    @State private var animatableValue: CGFloat = 0
    @State private var flashOpacity: Double = 0

    func body(content: Content) -> some View {
        Group {
            if reduceMotion {
                // Reduce Motion is on: substitute the spatial shake with a
                // brief warning-color flash instead of removing the error
                // feedback entirely — it still needs to register as
                // "something's wrong," just without side-to-side movement.
                content
                    .overlay(
                        AppColor.warning
                            .opacity(flashOpacity)
                            .blendMode(.multiply)
                            .allowsHitTesting(false)
                    )
                    .onChange(of: trigger) { _, _ in
                        withAnimation(.easeOut(duration: 0.15)) {
                            flashOpacity = 0.25
                        }
                        withAnimation(.easeIn(duration: 0.25).delay(0.15)) {
                            flashOpacity = 0
                        }
                    }
            } else {
                content
                    .modifier(ShakeEffect(animatableData: animatableValue))
                    .onChange(of: trigger) { _, _ in
                        animatableValue = 0
                        withAnimation(AppAnimation.shake) {
                            animatableValue = 1
                        }
                    }
            }
        }
    }
}

extension View {
    /// Shakes the view whenever `trigger` changes value — or, with Reduce
    /// Motion on, flashes it with the warning color instead.
    func shake(trigger: Int) -> some View {
        modifier(ShakeViewModifier(trigger: trigger))
    }
}
