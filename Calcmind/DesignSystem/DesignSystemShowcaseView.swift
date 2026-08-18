import SwiftUI

/// Internal-only screen (Phase 0) — not shown to end users. Every design
/// token and shared component gets previewed here first, in both color
/// schemes, before any real feature screen consumes it. This is the fastest
/// way to catch a contrast problem or an inconsistent radius before it's
/// copy-pasted into five different features.
struct DesignSystemShowcaseView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.colorScheme) private var colorScheme

    @State private var samplePressed = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {

                    section("Accent Theme") {
                        AccentThemePicker()
                    }

                    section("Typography") {
                        GlassCard {
                            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                Text("128")
                                    .font(AppFont.displayLarge)
                                    .tabularNumerals()
                                    .foregroundStyle(AppColor.textPrimary(colorScheme))
                                Text("22 + 18 × 6")
                                    .font(AppFont.expressionText)
                                    .foregroundStyle(AppColor.textSecondary(colorScheme))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    section("Primary Button") {
                        PrimaryButton("Solve Equation", systemImage: "sparkles") {}
                    }

                    section("Glass Card") {
                        GlassCard {
                            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                Label("AI Tutor", systemImage: "wand.and.stars")
                                    .font(.headline)
                                    .foregroundStyle(themeManager.accent.gradient)
                                Text("Ask me anything about math.")
                                    .font(.subheadline)
                                    .foregroundStyle(AppColor.textSecondary(colorScheme))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    section("Keypad Buttons") {
                        HStack(spacing: AppSpacing.sm) {
                            ForEach(["7", "8", "9", "÷"], id: \.self) { key in
                                keyPreview(key)
                            }
                        }
                    }

                    section("Success / Warning") {
                        HStack(spacing: AppSpacing.md) {
                            statusChip("Solved", color: AppColor.success, icon: "checkmark.circle.fill")
                            statusChip("Error", color: AppColor.warning, icon: "exclamationmark.triangle.fill")
                        }
                    }
                }
                .padding(AppSpacing.md)
            }
            .background(AppColor.background(colorScheme).ignoresSafeArea())
            .navigationTitle("Design System")
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title.uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(AppColor.textSecondary(colorScheme))
            content()
        }
        .padding(.top, AppSpacing.sm)
    }

    private func keyPreview(_ label: String) -> some View {
        Button {
            Haptic.light()
        } label: {
            Text(label)
                .font(AppFont.display(24, weight: .medium))
                .frame(width: 64, height: 64)
                .background(AppColor.backgroundElevated(colorScheme))
                .foregroundStyle(AppColor.textPrimary(colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
        }
        .buttonStyle(.bouncy)
    }

    private func statusChip(_ label: String, color: Color, icon: String) -> some View {
        Label(label, systemImage: icon)
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .foregroundStyle(color)
            .background(color.opacity(0.15), in: Capsule())
    }
}

#Preview("Light") {
    DesignSystemShowcaseView()
        .environment(ThemeManager())
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    DesignSystemShowcaseView()
        .environment(ThemeManager())
        .preferredColorScheme(.dark)
}
