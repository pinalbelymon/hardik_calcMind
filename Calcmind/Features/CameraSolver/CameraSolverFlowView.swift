import SwiftUI

/// Presented as a fullScreenCover from the Calculator screen. Owns nothing
/// but which stage to show — each stage is its own small, focused view.
struct CameraSolverFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: CameraSolverViewModel

    var body: some View {
        Group {
            switch viewModel.stage {
            case .capturing:
                CameraCaptureView { image in
                    viewModel.handleCapturedImage(image)
                }

            case .solving:
                SolvingStateView(image: viewModel.capturedImage)

            case .result(let solution):
                if let image = viewModel.capturedImage {
                    SolutionStepsView(
                        image: image,
                        solution: solution,
                        onRetake: { viewModel.retake() },
                        onDone: { dismiss() }
                    )
                }

            case .error(let message):
                CameraErrorStateView(
                    message: message,
                    image: viewModel.capturedImage,
                    onRetake: { viewModel.retake() },
                    onClose: { dismiss() }
                )
            }
        }
        .animation(AppAnimation.smooth, value: viewModel.stage)
    }
}
