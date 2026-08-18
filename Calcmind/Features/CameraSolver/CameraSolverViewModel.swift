import UIKit
import Observation

@Observable
final class CameraSolverViewModel {
    enum Stage: Equatable {
        case capturing
        case solving
        case result(MathSolution)
        case error(String)
    }

    private(set) var stage: Stage = .capturing
    private(set) var capturedImage: UIImage?

    private let geminiClient: GeminiClient

    /// Called once a photo is successfully solved, with the equation and
    /// answer, so a view can persist it to history without this view
    /// model needing to know anything about SwiftData.
    var onSolutionSaved: ((_ expression: String, _ result: String) -> Void)?

    init(geminiClient: GeminiClient) {
        self.geminiClient = geminiClient
    }

    func handleCapturedImage(_ image: UIImage) {
        capturedImage = image
        stage = .solving
        Task { await solve(image: image) }
    }

    func retake() {
        capturedImage = nil
        stage = .capturing
    }

    private func solve(image: UIImage) async {
        guard let data = image.jpegData(compressionQuality: 0.85) else {
            stage = .error("Couldn't process that photo — please try again.")
            return
        }
        do {
            let solution = try await geminiClient.solve(imageData: data)
            if solution.isEmpty {
                stage = .error("Couldn't find a math expression in that photo. Try getting closer, reducing glare, or improving the lighting.")
            } else {
                stage = .result(solution)
                onSolutionSaved?(solution.equation, solution.answer)
            }
        } catch {
            stage = .error(error.localizedDescription)
        }
    }
}
