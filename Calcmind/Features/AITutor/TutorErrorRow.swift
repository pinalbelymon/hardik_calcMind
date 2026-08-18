import SwiftUI

struct TutorErrorRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let message: String

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(AppColor.warning)
            Text(message)
                .font(.caption)
                .foregroundStyle(AppColor.warning)
        }
        .padding(AppSpacing.sm)
        .background(
            AppColor.warning.opacity(0.1),
            in: RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous)
        )
    }
}

#Preview {
    TutorErrorRow(message: "AI engine key hasn't loaded yet — try again in a moment.")
        .padding()
}
