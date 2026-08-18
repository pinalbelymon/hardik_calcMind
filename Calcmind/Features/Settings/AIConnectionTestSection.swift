import SwiftUI

/// Verifies the Gemini key fetched from Firestore works end-to-end.
struct AIConnectionTestSection: View {
    @Environment(GeminiClient.self) private var geminiClient
    @Environment(FirestoreKeyService.self) private var keyService
    @Environment(\.colorScheme) private var colorScheme

    @State private var input = "14√x + 15 = 71"
    @State private var isLoading = false
    @State private var result: MathSolution?
    @State private var errorText: String?

    var body: some View {
        Section {
            statusRow

            TextField("Expression to solve", text: $input)
                .textFieldStyle(.roundedBorder)
                .disabled(keyService.state != .ready)

            Button {
                Task { await runTest() }
            } label: {
                HStack {
                    if isLoading { ProgressView().padding(.trailing, AppSpacing.xs) }
                    Text(isLoading ? "Solving…" : "Test AI Solve")
                }
            }
            .disabled(keyService.state != .ready || isLoading || input.isEmpty)
            .accessibilityHint("Runs a test solve against the AI Engine")

            if let result {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    HStack {
                        Text(result.equation)
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        AIBadge()
                    }
                    ForEach(result.steps, id: \.self) { step in
                        Text("• \(step)")
                            .font(.caption)
                            .foregroundStyle(AppColor.textSecondary(colorScheme))
                    }
                    Text("Answer: \(result.answer)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColor.success)
                }
                .padding(.vertical, AppSpacing.xs)
            }

            if let errorText {
                Text(errorText)
                    .font(.caption)
                    .foregroundStyle(AppColor.warning)
            }
        } header: {
            Text("AI Connection")
        } footer: {
            Text("Confirms a working AI connection. Useful if camera solve or AI tutor stop responding.")
        }
    }

    @ViewBuilder
    private var statusRow: some View {
        switch keyService.state {
        case .idle, .loading:
            Label("Fetching AI connection status…", systemImage: "arrow.triangle.2.circlepath")
                .foregroundStyle(AppColor.textSecondary(colorScheme))
                .font(.subheadline)
        case .ready:
            Label("AI connection ready", systemImage: "checkmark.circle.fill")
                .foregroundStyle(AppColor.success)
                .font(.subheadline)
        case .failed(let message):
            Label(message, systemImage: "exclamationmark.triangle")
                .foregroundStyle(AppColor.warning)
                .font(.subheadline)

            Button("Retry connection") {
                Task { await keyService.fetchGeminiKey() }
            }
            .font(.subheadline.weight(.semibold))
        }
    }

    private func runTest() async {
        isLoading = true
        errorText = nil
        result = nil
        defer { isLoading = false }
        do {
            result = try await geminiClient.solve(expression: input)
        } catch {
            errorText = error.localizedDescription
        }
    }
}
