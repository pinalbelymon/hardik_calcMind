import SwiftUI

struct CurrencyRatesView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(ThemeManager.self) private var themeManager
    @State private var viewModel = CurrencyRatesViewModel()

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle, .loading:
                    ProgressView("Fetching rates…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .loaded(let rates):
                    ratesList(rates)
                case .failed(let message):
                    errorState(message)
                }
            }
            .background(AppColor.background(colorScheme).ignoresSafeArea())
            .navigationTitle("Currency Rates")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await viewModel.load() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .accessibilityLabel("Refresh rates")
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }

    private func ratesList(_ rates: [CurrencyRate]) -> some View {
        List {
            Section {
                ForEach(rates) { rate in
                    HStack {
                        Text(rate.code)
                            .font(.headline)
                            .foregroundStyle(AppColor.textPrimary(colorScheme))
                        Spacer()
                        Text(rate.value.formatted(.number.precision(.fractionLength(2...4))))
                            .font(AppFont.display(18, weight: .semibold))
                            .foregroundStyle(themeManager.accent.gradient)
                    }
                }
            } header: {
                Text("1 \(CurrencyRateFetcher.baseCurrency) equals")
            } footer: {
                if let lastUpdated = viewModel.lastUpdated {
                    Text("Updated \(lastUpdated.formatted(date: .abbreviated, time: .shortened)) · Rates from the European Central Bank via Frankfurter, once daily.")
                }
            }
        }
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: AppSpacing.md) {
            Spacer()
            Image(systemName: "wifi.slash")
                .font(.system(size: 32))
                .foregroundStyle(AppColor.warning)
                .accessibilityHidden(true)
            Text("Couldn't load rates")
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppColor.textPrimary(colorScheme))
            Text(message)
                .font(.subheadline)
                .foregroundStyle(AppColor.textSecondary(colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)
            Button {
                Task { await viewModel.load() }
            } label: {
                Text("Try Again")
                    .fontWeight(.semibold)
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.sm)
                    .background(themeManager.accent.gradient, in: Capsule())
                    .foregroundStyle(.white)
            }
            .buttonStyle(.bouncy)
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Light") {
    CurrencyRatesView()
        .environment(ThemeManager())
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    CurrencyRatesView()
        .environment(ThemeManager())
        .preferredColorScheme(.dark)
}
