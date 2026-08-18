import SwiftUI

struct TypingIndicatorView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(AppColor.textSecondary(colorScheme))
                    .frame(width: 6, height: 6)
                    .offset(y: isAnimating ? -3 : 0)
                    .animation(
                        .easeInOut(duration: 0.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.15),
                        value: isAnimating
                    )
            }
        }
        .padding(.vertical, 4)
        .onAppear {
            // Reduce Motion: dots just sit still. Three static dots still
            // reads as "typing" on its own — the bounce is a nice-to-have,
            // not the only thing carrying that meaning.
            guard !reduceMotion else { return }
            isAnimating = true
        }
    }
}

#Preview {
    TypingIndicatorView()
        .padding()
}
