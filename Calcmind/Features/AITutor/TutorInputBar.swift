import PhotosUI
import SwiftUI
import UIKit

struct TutorInputBar: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(ThemeManager.self) private var themeManager

    @Binding var text: String
    @Binding var pendingImage: UIImage?
    @Binding var selectedPhotoItem: PhotosPickerItem?
    let isSending: Bool
    var isAIReady: Bool = true
    let onCameraTap: () -> Void
    let onSend: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            if let pendingImage {
                pendingImagePreview(pendingImage)
            }

            HStack(alignment: .bottom, spacing: AppSpacing.xs) {
                // Camera Capture Button
                Button {
                    onCameraTap()
                } label: {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(themeManager.accent.gradient)
                        .frame(width: 36, height: 36)
                        .background(AppColor.backgroundElevated(colorScheme))
                        .clipShape(Circle())
                }
                .buttonStyle(.bouncy)
                .disabled(!isAIReady || isSending)
                .accessibilityLabel("Take photo of equation")
                .accessibilityHint("Opens camera to photograph a math problem")

                // Photo Library Picker Button
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(themeManager.accent.gradient)
                        .frame(width: 36, height: 36)
                        .background(AppColor.backgroundElevated(colorScheme))
                        .clipShape(Circle())
                }
                .buttonStyle(.bouncy)
                .disabled(!isAIReady || isSending)
                .accessibilityLabel("Choose photo from library")
                .accessibilityHint("Selects an existing photo from your library")

                TextField("Ask a math question…", text: $text, axis: .vertical)
                    .lineLimit(1...4)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.sm)
                    .background(AppColor.backgroundElevated(colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.pill, style: .continuous))
                    .disabled(!isAIReady)

                sendButton
            }
        }
        .padding(AppSpacing.md)
        .background(.thinMaterial)
    }

    private func pendingImagePreview(_ image: UIImage) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous))
                .accessibilityLabel("Attached equation photo")

            VStack(alignment: .leading, spacing: 2) {
                Text("Equation photo")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColor.textPrimary(colorScheme))
                Text("Add a question or tap send")
                    .font(.caption2)
                    .foregroundStyle(AppColor.textSecondary(colorScheme))
            }

            Spacer()

            Button {
                pendingImage = nil
                selectedPhotoItem = nil
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(AppColor.textSecondary(colorScheme))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Remove photo")
        }
        .padding(AppSpacing.sm)
        .background(AppColor.backgroundElevated(colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
    }

    private var sendButton: some View {
        Button {
            onSend()
        } label: {
            Group {
                if isSending {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .foregroundStyle(.white)
            .frame(width: 36, height: 36)
            .background(sendButtonBackground)
            .clipShape(Circle())
        }
        .disabled(!canSend)
        .buttonStyle(.bouncy)
        .accessibilityLabel("Send message")
        .accessibilityHint(canSend ? "Sends your message to the AI tutor" : sendDisabledHint)
    }

    private var sendButtonBackground: AnyShapeStyle {
        canSend
            ? AnyShapeStyle(themeManager.accent.gradient)
            : AnyShapeStyle(AppColor.textSecondary(colorScheme).opacity(0.3))
    }

    private var canSend: Bool {
        isAIReady
            && !isSending
            && (!text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || pendingImage != nil)
    }

    private var sendDisabledHint: String {
        if !isAIReady {
            return "AI tutor needs an internet connection"
        }
        if isSending {
            return "Waiting for the current reply"
        }
        return "Type a question or add a photo first"
    }
}

#Preview {
    VStack {
        Spacer()
        TutorInputBar(
            text: .constant(""),
            pendingImage: .constant(nil),
            selectedPhotoItem: .constant(nil),
            isSending: false,
            isAIReady: true,
            onCameraTap: {},
            onSend: {}
        )
    }
    .environment(ThemeManager())
}
