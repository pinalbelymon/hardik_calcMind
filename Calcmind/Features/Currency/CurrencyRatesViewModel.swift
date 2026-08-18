import Foundation
import Observation

@Observable
final class CurrencyRatesViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded([CurrencyRate])
        case failed(String)
    }

    private(set) var state: State = .idle
    private(set) var lastUpdated: Date?

    func load() async {
        state = .loading
        do {
            let rates = try await CurrencyRateFetcher.fetchRates()
            state = .loaded(rates)
            lastUpdated = .now
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
