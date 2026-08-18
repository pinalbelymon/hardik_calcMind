import SwiftData
import SwiftUI

struct CalculatorView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Environment(GeminiClient.self) private var geminiClient
    @Environment(FirestoreKeyService.self) private var keyService
    @Environment(ThemeManager.self) private var themeManager
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(\.showPaywall) private var showPaywall
    @State private var viewModel = CalculatorViewModel()
    @State private var isShowingCamera = false
    @State private var isShowingAIUnavailableAlert = false

    private var isAIReady: Bool {
        keyService.state == .ready
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let isLandscape = geo.size.width > geo.size.height

                let outerPadding: CGFloat = isLandscape ? AppSpacing.sm : (viewModel.isScientificMode ? AppSpacing.sm : AppSpacing.md)
                let itemSpacing: CGFloat = isLandscape ? AppSpacing.xs : (viewModel.isScientificMode ? AppSpacing.xs : AppSpacing.sm)

                let totalHeight = geo.size.height - (outerPadding * 2)
                let estimatedDisplayHeight: CGFloat = (viewModel.isScientificMode || isLandscape) ? 64 : 96
                let availableKeypadHeight = max(100, totalHeight - estimatedDisplayHeight - itemSpacing)

                let calculatedButtonHeight: CGFloat = {
                    if isLandscape {
                        let rows: CGFloat = 5
                        let gaps: CGFloat = rows - 1
                        return min(64, max(32, (availableKeypadHeight - (gaps * itemSpacing)) / rows))
                    } else if viewModel.isScientificMode {
                        let rows: CGFloat = 9
                        let gaps: CGFloat = rows
                        return min(64, max(36, (availableKeypadHeight - (gaps * itemSpacing)) / rows))
                    } else {
                        let rows: CGFloat = 5
                        let gaps: CGFloat = rows - 1
                        return min(64, max(44, (availableKeypadHeight - (gaps * itemSpacing)) / rows))
                    }
                }()

                VStack(spacing: itemSpacing) {
                    Spacer(minLength: (viewModel.isScientificMode || isLandscape) ? 0 : AppSpacing.xs)

                    CalculatorDisplayView(viewModel: viewModel, isCompact: viewModel.isScientificMode || isLandscape)

                    if isLandscape {
                        HStack(alignment: .top, spacing: AppSpacing.md) {
                            ScientificKeypadView(viewModel: viewModel, buttonHeight: calculatedButtonHeight, spacing: itemSpacing)
                            KeypadView(viewModel: viewModel, buttonHeight: calculatedButtonHeight, spacing: itemSpacing)
                        }
                    } else {
                        VStack(spacing: itemSpacing) {
                            if viewModel.isScientificMode {
                                ScientificKeypadView(viewModel: viewModel, buttonHeight: calculatedButtonHeight, spacing: itemSpacing)
                            }
                            KeypadView(viewModel: viewModel, buttonHeight: calculatedButtonHeight, spacing: itemSpacing)
                        }
                    }
                }
                .padding(outerPadding)
                .animation(AppAnimation.smooth, value: viewModel.isScientificMode)
            }
            .background(AppColor.background(colorScheme).ignoresSafeArea())
            .navigationTitle("Calculator")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        if !subscriptionManager.isPro {
                            showPaywall()
                        } else if isAIReady {
                            isShowingCamera = true
                        } else {
                            isShowingAIUnavailableAlert = true
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "camera.viewfinder")
                            if !subscriptionManager.isPro {
                                Image(systemName: "lock.fill")
                                    .font(.caption2)
                            }
                        }
                    }
                    .accessibilityLabel("Solve by photo")
                    .accessibilityHint(isAIReady ? "Opens the camera to solve an equation with AI" : "Requires an internet connection for AI features")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation(AppAnimation.bouncy) {
                            viewModel.isScientificMode.toggle()
                        }
                        Haptic.light()
                    } label: {
                        Image(systemName: "function")
                            .symbolVariant(viewModel.isScientificMode ? .fill : .none)
                    }
                    .accessibilityLabel(
                        viewModel.isScientificMode ? "Switch to standard mode" : "Switch to scientific mode"
                    )
                }
            }
            .fullScreenCover(isPresented: $isShowingCamera) {
                CameraSolverFlowView(viewModel: makeCameraViewModel())
            }
            .alert("AI features unavailable", isPresented: $isShowingAIUnavailableAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Photo solve needs an internet connection and loaded AI service. The standard calculator still works offline.")
            }
        }
        .onAppear {
            // Wired here rather than inside CalculatorViewModel itself, so
            // the view model stays free of any SwiftData/ModelContext
            // knowledge — it only knows it can call a closure.
            viewModel.onCalculationCompleted = { expression, result in
                modelContext.insert(CalculationRecord(expression: expression, result: result, isAISolved: false))
                SoundPlayer.playCompletion(enabled: themeManager.soundEffectsEnabled)
            }
        }
    }

    private func makeCameraViewModel() -> CameraSolverViewModel {
        let cameraViewModel = CameraSolverViewModel(geminiClient: geminiClient)
        cameraViewModel.onSolutionSaved = { expression, result in
            modelContext.insert(CalculationRecord(expression: expression, result: result, isAISolved: true))
            SoundPlayer.playCompletion(enabled: themeManager.soundEffectsEnabled)
        }
        return cameraViewModel
    }
}

#Preview("Light") {
    CalculatorView()
        .environment(ThemeManager())
        .environment(GeminiClient(keyService: FirestoreKeyService()))
        .modelContainer(for: CalculationRecord.self, inMemory: true)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    CalculatorView()
        .environment(ThemeManager())
        .environment(GeminiClient(keyService: FirestoreKeyService()))
        .modelContainer(for: CalculationRecord.self, inMemory: true)
        .preferredColorScheme(.dark)
}
