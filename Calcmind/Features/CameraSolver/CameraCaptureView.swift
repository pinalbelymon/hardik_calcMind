import SwiftUI
import UIKit

/// The live capture screen only — purely responsible for showing the
/// preview and producing a captured UIImage via `onCapture`. What happens
/// after capture (solving, results, errors) is owned by the parent
/// `CameraSolverFlowView`, keeping this view's job small and testable.
struct CameraCaptureView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss

    @State private var cameraSession = CameraSession()
    @State private var permissionState: CameraSession.PermissionState = .notDetermined
    @State private var isCapturing = false

    let onCapture: (UIImage) -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch permissionState {
            case .authorized:
                CameraPreviewView(session: cameraSession.captureSession)
                    .ignoresSafeArea()
            case .denied:
                permissionDeniedState
            case .notDetermined:
                ProgressView()
                    .tint(.white)
            }

            VStack {
                topBar
                Spacer()
                if permissionState == .authorized {
                    shutterBar
                }
            }
            .padding(AppSpacing.md)
        }
        .task {
            permissionState = await cameraSession.requestPermissionAndStart()
        }
        .onDisappear {
            cameraSession.stop()
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(.thinMaterial, in: Circle())
            }
            .accessibilityLabel("Close camera")

            Spacer()

            Text("Point at an equation")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(.thinMaterial, in: Capsule())
                // This overlay chip sits between a close button and a
                // fixed balancer in a tight HStack — capped rather than
                // left to scale freely, so it can't grow into either at
                // the largest accessibility text sizes on a narrow phone.
                .dynamicTypeSize(...DynamicTypeSize.large)

            Spacer()

            // Balances the close button so the title stays visually centered.
            Color.clear.frame(width: 40, height: 40)
        }
    }

    private var shutterBar: some View {
        shutterButton
            .padding(.bottom, AppSpacing.xl)
    }

    private var shutterButton: some View {
        Button {
            Task { await capture() }
        } label: {
            ZStack {
                Circle()
                    .stroke(.white, lineWidth: 4)
                    .frame(width: 78, height: 78)
                Circle()
                    .fill(themeManager.accent.gradient)
                    .frame(width: 64, height: 64)
                    .scaleEffect(isCapturing ? 0.85 : 1.0)
            }
        }
        .disabled(isCapturing)
        .buttonStyle(.bouncy)
        .accessibilityLabel("Capture photo")
    }

    private var permissionDeniedState: some View {
        VStack(spacing: AppSpacing.md) {
            Spacer()

            Image(systemName: "camera.fill")
                .font(.system(size: 40))
                .foregroundStyle(.white.opacity(0.6))
                .accessibilityHidden(true)

            Text("Camera access is off")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)

            Text("Turn on camera access in Settings to solve equations by photo.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)

            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Open Settings")
                    .fontWeight(.semibold)
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.sm)
                    .background(themeManager.accent.gradient, in: Capsule())
                    .foregroundStyle(.white)
            }
            .buttonStyle(.bouncy)
            .padding(.top, AppSpacing.sm)

            Spacer()
            Spacer()
        }
    }

    private func capture() async {
        guard !isCapturing else { return }
        isCapturing = true
        Haptic.light()
        if let image = await cameraSession.capturePhoto() {
            onCapture(image)
        }
        isCapturing = false
    }
}

#Preview {
    CameraCaptureView(onCapture: { _ in })
        .environment(ThemeManager())
}
