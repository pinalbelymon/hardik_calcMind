import Foundation
import Observation
import StoreKit
import SwiftUI

/// Subscription plans available in CalcMind
enum SubscriptionPlan: String, CaseIterable, Identifiable {
    case none
    case weekly
    case monthly
    case yearly

    var id: String { rawValue }

    var productID: String? {
        switch self {
        case .none: return nil
        case .weekly: return "com.calcmind.weekly"
        case .monthly: return "com.calcmind.monthly"
        case .yearly: return "com.calcmind.yearly"
        }
    }

    static func plan(for productID: String) -> SubscriptionPlan? {
        switch productID {
        case "com.calcmind.weekly": return .weekly
        case "com.calcmind.monthly": return .monthly
        case "com.calcmind.yearly": return .yearly
        default: return nil
        }
    }

    var displayName: String {
        switch self {
        case .none: return "Free Plan"
        case .weekly: return "Weekly Plan"
        case .monthly: return "Monthly Plan"
        case .yearly: return "Yearly Plan"
        }
    }

    var fallbackPriceText: String {
        switch self {
        case .none: return "Free"
        case .weekly: return ""
        case .monthly: return ""
        case .yearly: return ""
        }
    }

    var periodText: String {
        switch self {
        case .none: return ""
        case .weekly: return "/ week"
        case .monthly: return "/ month"
        case .yearly: return "/ year"
        }
    }

    var fallbackEquivalentWeeklyText: String {
        switch self {
        case .none: return ""
        case .weekly: return ""
        case .monthly: return ""
        case .yearly: return ""
        }
    }

    var badgeText: String? {
        switch self {
        case .yearly: return "SAVE 60%"
        case .monthly: return "POPULAR"
        default: return nil
        }
    }
}

/// Production StoreKit 2 Subscription Manager for CalcMind.
/// Strictly relies on verified StoreKit 2 entitlements and transactions. Zero fake fallbacks or mock simulation.
@Observable
final class SubscriptionManager {
    private let productIDs: Set<String> = [
        "com.calcmind.weekly",
        "com.calcmind.monthly",
        "com.calcmind.yearly"
    ]

    /// Pro user entitlement state determined strictly by verified StoreKit 2 active transactions
    var isPro: Bool = false
    var activePlan: SubscriptionPlan = .none

    /// StoreKit 2 Product objects fetched from App Store
    var products: [Product] = []
    var isPurchasing = false
    var errorMessage: String?

    @ObservationIgnored
    private var updateListenerTask: Task<Void, Never>? = nil

    init() {
        // Start background transaction update listener
        updateListenerTask = listenForTransactionUpdates()

        Task { @MainActor in
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    /// Loads products directly from StoreKit
    @MainActor
    func loadProducts() async {
        do {
            let fetchedProducts = try await Product.products(for: productIDs)
            self.products = fetchedProducts.sorted { $0.price < $1.price }
        } catch {
            print("StoreKit: Product load error: \(error.localizedDescription)")
            self.errorMessage = "Failed to load StoreKit products: \(error.localizedDescription)"
        }
    }

    /// Gets loaded StoreKit Product for a plan
    func product(for plan: SubscriptionPlan) -> Product? {
        guard let productID = plan.productID else { return nil }
        return products.first { $0.id == productID }
    }

    /// Returns actual localized display price from StoreKit
    func displayPrice(for plan: SubscriptionPlan) -> String {
        if let product = product(for: plan) {
            return product.displayPrice
        }
        return plan.fallbackPriceText
    }

    /// Strictly updates `isPro` and `activePlan` based on verified active StoreKit 2 entitlements
    @MainActor
    func updateSubscriptionStatus() async {
        var hasActiveEntitlement = false
        var activeSubPlan: SubscriptionPlan = .none

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }

            // Verify active subscription (not revoked and not expired)
            if transaction.revocationDate == nil {
                if let expirationDate = transaction.expirationDate, expirationDate < Date() {
                    // Expired subscription
                    continue
                }
                if let plan = SubscriptionPlan.plan(for: transaction.productID) {
                    hasActiveEntitlement = true
                    activeSubPlan = plan
                }
            }
        }

        self.isPro = hasActiveEntitlement
        self.activePlan = hasActiveEntitlement ? activeSubPlan : .none
    }

    /// Listens for real-time StoreKit background updates
    private func listenForTransactionUpdates() -> Task<Void, Never> {
        Task.detached {
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }
                await self.updateSubscriptionStatus()
                await transaction.finish()
            }
        }
    }

    /// Real StoreKit 2 Purchase flow. Throws or returns false with error if StoreKit product missing or purchase fails.
    @MainActor
    func purchase(plan: SubscriptionPlan) async -> Bool {
        guard plan != .none else { return false }
        isPurchasing = true
        errorMessage = nil
        defer { isPurchasing = false }

        // Must have loaded StoreKit product
        guard let storeProduct = product(for: plan) else {
            errorMessage = "StoreKit product not loaded for \(plan.displayName). Please check internet connection."
            return false
        }

        do {
            let result = try await storeProduct.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await updateSubscriptionStatus()
                    await transaction.finish()
                    Haptic.success()
                    return true
                case .unverified(_, let error):
                    errorMessage = "Transaction verification failed: \(error.localizedDescription)"
                    return false
                }

            case .userCancelled:
                return false

            case .pending:
                errorMessage = "Purchase is pending approval."
                return false

            @unknown default:
                errorMessage = "Unknown StoreKit purchase result."
                return false
            }
        } catch {
            errorMessage = "StoreKit purchase failed: \(error.localizedDescription)"
            return false
        }
    }

    /// Real StoreKit 2 Restore flow via AppStore.sync()
    @MainActor
    func restorePurchases() async -> Bool {
        isPurchasing = true
        errorMessage = nil
        defer { isPurchasing = false }

        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
            if isPro {
                Haptic.success()
                return true
            } else {
                errorMessage = "No active StoreKit subscription found to restore."
                return false
            }
        } catch {
            errorMessage = "StoreKit restore sync failed: \(error.localizedDescription)"
            return false
        }
    }

    /// Opens iOS system Manage Subscriptions page
    func openManageSubscriptions(openURL: OpenURLAction) {
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            openURL(url)
        }
    }
}
