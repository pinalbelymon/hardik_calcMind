import SwiftData
import SwiftUI

/// Detail view for a saved calculation or AI Tutor session record.
/// Shows full equation/question, complete step-by-step answer or calculation result,
/// copy to clipboard tools, and delete functionality.
struct HistoryDetailView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var themeManager

    let record: CalculationRecord

    @State private var showCopiedAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                // Type Badge & Timestamp Header
                headerCard

                // Question / Expression Section
                GlassCard {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        HStack {
                            Text("QUESTION / EXPRESSION")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(AppColor.textSecondary(colorScheme))

                            Spacer()

                            Button {
                                UIPasteboard.general.string = record.expression
                                Haptic.light()
                                showCopiedAlert = true
                            } label: {
                                Image(systemName: "doc.on.doc")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(themeManager.accent.accent)
                            }
                            .accessibilityLabel("Copy question")
                        }

                        Text(record.expression)
                            .font(AppFont.expressionText)
                            .foregroundStyle(AppColor.textPrimary(colorScheme))
                            .textSelection(.enabled)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Solution / Answer Section
                GlassCard {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        HStack {
                            Text(record.isAISolved ? "AI SOLUTION & BREAKDOWN" : "CALCULATION RESULT")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(AppColor.textSecondary(colorScheme))

                            Spacer()

                            Button {
                                UIPasteboard.general.string = record.result
                                Haptic.light()
                                showCopiedAlert = true
                            } label: {
                                Image(systemName: "doc.on.doc")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(themeManager.accent.accent)
                            }
                            .accessibilityLabel("Copy solution")
                        }

                        Text(LocalizedStringKey(MathFormatter.format(record.result)))
                            .font(AppFont.stepText)
                            .foregroundStyle(AppColor.textPrimary(colorScheme))
                            .textSelection(.enabled)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Action Buttons (Copy & Delete)
                VStack(spacing: AppSpacing.md) {
                    PrimaryButton("Copy Full Answer", systemImage: "doc.on.doc.fill") {
                        UIPasteboard.general.string = record.result
                        Haptic.success()
                        showCopiedAlert = true
                    }

                    Button(role: .destructive) {
                        Haptic.light()
                        modelContext.delete(record)
                        dismiss()
                    } label: {
                        HStack(spacing: AppSpacing.xs) {
                            Image(systemName: "trash")
                            Text("Delete Record")
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                        .background(Color.red.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
                    }
                    .buttonStyle(.bouncy)
                }
                .padding(.top, AppSpacing.sm)
            }
            .padding(AppSpacing.md)
        }
        .background(AppColor.background(colorScheme).ignoresSafeArea())
        .navigationTitle(record.isAISolved ? "AI Solve Detail" : "Calculation Detail")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottom) {
            if showCopiedAlert {
                Text("Copied to Clipboard")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.85))
                    .clipShape(Capsule())
                    .padding(.bottom, AppSpacing.lg)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                            withAnimation { showCopiedAlert = false }
                        }
                    }
            }
        }
    }

    private var headerCard: some View {
        HStack(spacing: AppSpacing.sm) {
            if record.isAISolved {
                AIBadge()
            } else {
                Text("Standard Math")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppColor.textSecondary(colorScheme))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColor.backgroundElevated(colorScheme))
                    .clipShape(Capsule())
            }

            Spacer()

            Text(record.date.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(AppColor.textSecondary(colorScheme))
        }
        .padding(.horizontal, AppSpacing.xs)
    }
}

#Preview {
    NavigationStack {
        HistoryDetailView(
            record: CalculationRecord(
                expression: "x² + 4x + 3 = 0",
                result: "Step 1: Factor the quadratic into (x + 1)(x + 3) = 0.\nStep 2: Solve x + 1 = 0 ⟹ x = -1.\nStep 3: Solve x + 3 = 0 ⟹ x = -3.\nFinal Answer: x = -1 or x = -3",
                isAISolved: true
            )
        )
    }
    .environment(ThemeManager())
}
