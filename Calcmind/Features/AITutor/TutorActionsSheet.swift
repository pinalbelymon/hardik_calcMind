import SwiftUI

/// Mode picker sheet — Basics & Practice contexts for more relevant tutor replies.
struct TutorActionsSheet: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss

    let selectedModeID: String
    let onSelectMode: (TutorMode, Bool) -> Void

    @State private var searchText = ""

    private var filteredModes: [TutorMode] {
        guard !searchText.isEmpty else { return TutorMode.allModes }
        return TutorMode.allModes.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
                || $0.subtitle.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(TutorModeSection.allCases, id: \.self) { section in
                    let modes = filteredModes.filter { $0.section == section }
                    if !modes.isEmpty {
                        Section(section.rawValue) {
                            ForEach(modes) { mode in
                                modeRow(mode)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $searchText, prompt: "Search modes")
            .navigationTitle("Actions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func modeRow(_ mode: TutorMode) -> some View {
        HStack(alignment: .center, spacing: AppSpacing.md) {
            Image(systemName: mode.icon)
                .font(.title3)
                .foregroundStyle(themeManager.accent.gradient)
                .frame(width: 36, height: 36)
                .background(AppColor.backgroundElevated(colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(mode.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColor.textPrimary(colorScheme))
                Text(mode.subtitle)
                    .font(.caption)
                    .foregroundStyle(AppColor.textSecondary(colorScheme))
            }

            Spacer(minLength: AppSpacing.sm)

            Button {
                Haptic.light()
                onSelectMode(mode, true)
                dismiss()
            } label: {
                Text("GO")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(themeManager.accent.gradient, in: Capsule())
            }
            .buttonStyle(.bouncy)
            .accessibilityLabel("Start \(mode.title)")
            .accessibilityHint(mode.subtitle)
        }
        .padding(.vertical, AppSpacing.xs)
        .listRowBackground(
            mode.id == selectedModeID
                ? AppColor.backgroundElevated(colorScheme)
                : nil
        )
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    TutorActionsSheet(selectedModeID: TutorMode.mathTutor.id) { _, _ in }
        .environment(ThemeManager())
}
