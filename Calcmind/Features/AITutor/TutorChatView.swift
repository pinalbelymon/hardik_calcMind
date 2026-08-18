import PhotosUI
import StoreKit
import SwiftData
import SwiftUI

struct TutorChatView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Environment(GeminiClient.self) private var geminiClient
    @Environment(FirestoreKeyService.self) private var keyService
    @Environment(ThemeManager.self) private var themeManager
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(\.showPaywall) private var showPaywall
    @Environment(\.requestReview) private var requestReview
    @State private var viewModel: TutorViewModel?
    @State private var inputText = ""
    @State private var pendingImage: UIImage?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isShowingActions = false
    @State private var isShowingCamera = false

    private var isAIReady: Bool {
        keyService.state == .ready
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !subscriptionManager.isPro {
                    proBanner
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.top, AppSpacing.sm)
                } else {
                    AIConnectionBanner()
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.top, AppSpacing.sm)
                }

                if let viewModel, !viewModel.isEmpty {
                    TutorModeBanner(mode: viewModel.selectedMode) {
                        isShowingActions = true
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.bottom, AppSpacing.xs)
                }

                Group {
                    if let viewModel {
                        if viewModel.isEmpty {
                            TutorEmptyStateView(
                                mode: viewModel.selectedMode,
                                onSelectPrompt: { prompt in
                                    if !subscriptionManager.isPro {
                                        showPaywall()
                                    } else {
                                        viewModel.send(prompt)
                                    }
                                },
                                onOpenActions: {
                                    isShowingActions = true
                                }
                            )
                        } else {
                            messageList(viewModel: viewModel)
                        }
                    } else {
                        Color.clear
                    }
                }
            }
            .background(AppColor.background(colorScheme).ignoresSafeArea())
            .navigationTitle("AI Tutor")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingActions = true
                    } label: {
                        Image(systemName: "square.grid.2x2")
                    }
                    .accessibilityLabel("Actions")
                    .accessibilityHint("Choose a study mode for more relevant answers")
                }
            }
            .sheet(isPresented: $isShowingActions) {
                if let viewModel {
                    TutorActionsSheet(
                        selectedModeID: viewModel.selectedMode.id,
                        onSelectMode: { mode, beginChat in
                            viewModel.selectMode(mode, beginChat: beginChat)
                        }
                    )
                    .presentationDetents([.large])
                }
            }
            .fullScreenCover(isPresented: $isShowingCamera) {
                CameraCaptureView { image in
                    pendingImage = image
                    isShowingCamera = false
                }
                .environment(ThemeManager())
            }
            .safeAreaInset(edge: .bottom) {
                if let viewModel {
                    TutorInputBar(
                        text: $inputText,
                        pendingImage: $pendingImage,
                        selectedPhotoItem: $selectedPhotoItem,
                        isSending: viewModel.isStreaming,
                        isAIReady: isAIReady,
                        onCameraTap: {
                            if !subscriptionManager.isPro {
                                showPaywall()
                            } else if isAIReady {
                                isShowingCamera = true
                            }
                        },
                        onSend: {
                            if !subscriptionManager.isPro {
                                showPaywall()
                            } else {
                                send(viewModel: viewModel)
                            }
                        }
                    )
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = TutorViewModel(geminiClient: geminiClient)
            }
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            if !subscriptionManager.isPro {
                showPaywall()
                selectedPhotoItem = nil
                return
            }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        pendingImage = image
                        selectedPhotoItem = nil
                    }
                }
            }
        }
        .onChange(of: viewModel?.isStreaming) { oldValue, newValue in
            if oldValue == true && newValue == false, let viewModel {
                // Save AI Tutor chat Q&A session into SwiftData Calculation History
                if let lastModelMsg = viewModel.messages.last(where: { $0.role == .model }),
                   !lastModelMsg.content.isEmpty {
                    let userMsg = viewModel.messages.last(where: { $0.role == .user })?.content ?? "AI Tutor Session"
                    let cleanAnswer = MathFormatter.format(lastModelMsg.content)
                    modelContext.insert(CalculationRecord(
                        expression: userMsg,
                        result: cleanAnswer,
                        isAISolved: true
                    ))
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    requestReview()
                }
            }
        }
    }

    private func send(viewModel: TutorViewModel) {
        let text = inputText
        let image = pendingImage
        inputText = ""
        pendingImage = nil
        viewModel.send(text, image: image)
    }

    private var proBanner: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "sparkles")
                .foregroundStyle(themeManager.accent.accent)

            VStack(alignment: .leading, spacing: 2) {
                Text("AI Tutor is a CalcMind Pro Feature")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppColor.textPrimary(colorScheme))
                Text("Unlock 24/7 unlimited math help & camera solving")
                    .font(.caption2)
                    .foregroundStyle(AppColor.textSecondary(colorScheme))
            }

            Spacer()

            Button {
                Haptic.light()
                showPaywall()
            } label: {
                Text("Unlock")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(themeManager.accent.gradient)
                    .clipShape(Capsule())
            }
        }
        .padding(AppSpacing.sm)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
    }

    private func messageList(viewModel: TutorViewModel) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: AppSpacing.md) {
                    ForEach(viewModel.messages) { message in
                        ChatMessageBubble(message: message)
                    }

                    if let errorMessage = viewModel.errorMessage {
                        TutorErrorRow(message: errorMessage)
                    }

                    Color.clear.frame(height: 1).id("bottom")
                }
                .padding(AppSpacing.md)
            }
            .onChange(of: viewModel.messages.last?.content) { _, _ in
                withAnimation(AppAnimation.smooth) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                withAnimation(AppAnimation.smooth) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
        }
    }
}

/// Shows the active mode while chatting; tap to switch.
private struct TutorModeBanner: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(ThemeManager.self) private var themeManager

    let mode: TutorMode
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: mode.icon)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(themeManager.accent.gradient)
                Text(mode.title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColor.textPrimary(colorScheme))
                Text("· \(mode.subtitle)")
                    .font(.caption)
                    .foregroundStyle(AppColor.textSecondary(colorScheme))
                    .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(AppColor.textSecondary(colorScheme))
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(AppColor.backgroundElevated(colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(mode.title) mode")
        .accessibilityHint("Double tap to change study mode")
    }
}

#Preview("Light") {
    TutorChatView()
        .environment(ThemeManager())
        .environment(GeminiClient(keyService: FirestoreKeyService()))
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    TutorChatView()
        .environment(ThemeManager())
        .environment(GeminiClient(keyService: FirestoreKeyService()))
        .preferredColorScheme(.dark)
}
