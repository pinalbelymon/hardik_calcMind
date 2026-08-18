import SwiftUI
import AVFoundation

/// SwiftUI has no native live camera preview, so this is the standard
/// bridge: a UIView whose backing layer IS an AVCaptureVideoPreviewLayer.
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewUIView, context: Context) {}

    final class PreviewUIView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }

        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            // Force-cast is safe here — layerClass above guarantees the
            // backing layer is always this exact type.
            layer as! AVCaptureVideoPreviewLayer
        }
    }
}
