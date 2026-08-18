import AVFoundation
import UIKit

/// Wraps AVCaptureSession setup, permission handling, and photo capture.
///
/// Deliberately a plain NSObject with all session work dispatched to its
/// own serial queue — the classic, long-established AVFoundation pattern
/// (same shape as Apple's own AVCam sample) — rather than annotating this
/// with Swift Concurrency actors. Mixing AVFoundation's queue-based
/// delegate callbacks with actor isolation is a common source of subtle
/// data-race warnings; keeping this class actor-agnostic and only
/// returning plain values from its async methods sidesteps that
/// entirely. Callers (SwiftUI views) are what's actor-isolated, and they
/// only ever see this class's async return values, never reach into its
/// internals directly.
final class CameraSession: NSObject {
    enum PermissionState: Equatable {
        case notDetermined
        case authorized
        case denied
    }

    private let captureSessionInternal = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "com.calcmind.camera.session")
    private var isConfigured = false
    private var photoCaptureContinuation: CheckedContinuation<UIImage?, Never>?

    /// Safe to hand to `CameraPreviewView` on the main actor — only ever
    /// *started/stopped* on `sessionQueue` internally; SwiftUI just reads
    /// this reference once to wire up the preview layer.
    var captureSession: AVCaptureSession { captureSessionInternal }

    /// Requests camera permission if needed, configures and starts the
    /// session if granted, and reports back what actually happened.
    func requestPermissionAndStart() async -> PermissionState {
        let resolvedState: PermissionState
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            resolvedState = .authorized
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            resolvedState = granted ? .authorized : .denied
        default:
            resolvedState = .denied
        }

        if resolvedState == .authorized {
            await start()
        }
        return resolvedState
    }

    private func start() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            sessionQueue.async { [weak self] in
                guard let self else {
                    continuation.resume()
                    return
                }
                if !self.isConfigured {
                    self.configureSession()
                }
                if !self.captureSessionInternal.isRunning {
                    self.captureSessionInternal.startRunning()
                }
                continuation.resume()
            }
        }
    }

    /// Fire-and-forget stop — safe to call from `onDisappear`, no need to
    /// await a screen dismissal on the session actually finishing.
    func stop() {
        sessionQueue.async { [captureSessionInternal] in
            if captureSessionInternal.isRunning {
                captureSessionInternal.stopRunning()
            }
        }
    }

    /// Runs on `sessionQueue` — only ever called from inside `start()`'s
    /// queue closure above.
    private func configureSession() {
        captureSessionInternal.beginConfiguration()
        captureSessionInternal.sessionPreset = .photo
        defer { captureSessionInternal.commitConfiguration() }

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              captureSessionInternal.canAddInput(input) else {
            return
        }
        captureSessionInternal.addInput(input)

        guard captureSessionInternal.canAddOutput(photoOutput) else { return }
        captureSessionInternal.addOutput(photoOutput)

        isConfigured = true
    }

    /// Captures one photo and returns it (or nil on failure) once
    /// processing finishes.
    func capturePhoto() async -> UIImage? {
        await withCheckedContinuation { continuation in
            photoCaptureContinuation = continuation
            let settings = AVCapturePhotoSettings()
            settings.flashMode = .auto
            sessionQueue.async { [weak self, photoOutput] in
                guard let self else { return }
                photoOutput.capturePhoto(with: settings, delegate: self)
            }
        }
    }
}

extension CameraSession: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let image: UIImage?
        if error == nil, let data = photo.fileDataRepresentation() {
            image = UIImage(data: data)
        } else {
            image = nil
        }
        photoCaptureContinuation?.resume(returning: image)
        photoCaptureContinuation = nil
    }
}
