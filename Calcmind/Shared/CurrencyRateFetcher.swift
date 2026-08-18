import Foundation

/// Fetches exchange rates from Frankfurter (api.frankfurter.dev) — free,
/// no API key, ECB reference rates updated once daily around 16:00 CET.
/// No key to manage here, unlike the Gemini side of this app.
///
/// v1 scope: a fixed base currency and a fixed set of target currencies,
/// no in-app configuration UI. See PHASE6-NOTES.md for what a
/// user-configurable version would need.
enum CurrencyRateFetcher {
    static let baseCurrency = "USD"
    static let targetCurrencies = ["EUR", "GBP", "JPY"]

    private struct FrankfurterResponse: Decodable {
        let base: String
        let rates: [String: Double]
    }

    static func fetchRates() async throws -> [CurrencyRate] {
        let symbols = targetCurrencies.joined(separator: ",")
        guard let url = URL(
            string: "https://api.frankfurter.dev/v1/latest?base=\(baseCurrency)&symbols=\(symbols)"
        ) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(FrankfurterResponse.self, from: data)

        // Preserve targetCurrencies' order rather than dictionary order.
        return targetCurrencies.compactMap { code in
            guard let value = decoded.rates[code] else { return nil }
            return CurrencyRate(code: code, value: value)
        }
    }
}
