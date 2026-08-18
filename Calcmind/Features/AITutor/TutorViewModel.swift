import Foundation
import Observation
import SwiftUI
import UIKit

@Observable
final class TutorViewModel {
    private static let modeStorageKey = "com.calcmind.tutor.selectedMode"

    private(set) var messages: [TutorMessage] = []
    private(set) var isStreaming = false
    var errorMessage: String?
    var selectedMode: TutorMode

    private let geminiClient: GeminiClient
    private var streamTask: Task<Void, Never>?

    init(geminiClient: GeminiClient) {
        self.geminiClient = geminiClient
        if let savedID = UserDefaults.standard.string(forKey: Self.modeStorageKey) {
            self.selectedMode = TutorMode.mode(for: savedID)
        } else {
            self.selectedMode = .mathTutor
        }
    }

    var isEmpty: Bool { messages.isEmpty }

    func selectMode(_ mode: TutorMode, beginChat: Bool = false) {
        selectedMode = mode
        UserDefaults.standard.set(mode.id, forKey: Self.modeStorageKey)
        if beginChat && isEmpty && !isStreaming {
            send(mode.starterPrompt)
        }
    }

    func send(_ text: String, image: UIImage? = nil) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let jpegData = image.flatMap { $0.jpegData(compressionQuality: 0.85) }

        guard trimmed.isEmpty == false || jpegData != nil, !isStreaming else { return }

        if jpegData == nil && image != nil {
            errorMessage = "Couldn't process that photo — please try again."
            return
        }

        errorMessage = nil
        let userMessage = TutorMessage(role: .user, content: trimmed, imageJPEGData: jpegData)
        let modelMessage = TutorMessage(role: .model, content: "")

        withAnimation(AppAnimation.bouncy) {
            messages.append(userMessage)
            messages.append(modelMessage)
        }

        let modelMessageID = modelMessage.id
        let mode = selectedMode
        isStreaming = true

        streamTask = Task {
            do {
                let history = Array(messages.dropLast())
                for try await delta in geminiClient.streamTutorReply(messages: history, mode: mode) {
                    appendDelta(delta, toMessageID: modelMessageID)
                }
                finalizeIfEmpty(messageID: modelMessageID)
            } catch {
                removeIfEmpty(messageID: modelMessageID)
                errorMessage = error.localizedDescription
            }
            isStreaming = false
        }
    }

    func cancelStreaming() {
        streamTask?.cancel()
        isStreaming = false
    }

    private func appendDelta(_ delta: String, toMessageID id: UUID) {
        guard let index = messages.firstIndex(where: { $0.id == id }) else { return }
        messages[index].content += delta
    }

    private func finalizeIfEmpty(messageID: UUID) {
        guard let index = messages.firstIndex(where: { $0.id == messageID }) else { return }
        if messages[index].content.isEmpty {
            messages[index].content = "Sorry, I didn't catch that — could you try rephrasing?"
        }
    }

    private func removeIfEmpty(messageID: UUID) {
        guard let index = messages.firstIndex(where: { $0.id == messageID }),
              messages[index].content.isEmpty else { return }
        messages.remove(at: index)
    }
}
