import Foundation
import StoreKit

@Observable
final class StoreKitService {
    static let shared = StoreKitService()

    static let monthlyID = "com.mindchime.premium.monthly"
    static let annualID = "com.mindchime.premium.annual"

    var isPremium: Bool = false
    var products: [Product] = []
    var isLoading: Bool = false
    var purchaseError: String?

    var monthlyProduct: Product? {
        products.first { $0.id == Self.monthlyID }
    }

    var annualProduct: Product? {
        products.first { $0.id == Self.annualID }
    }

    private init() {
        Task {
            await loadProducts()
            await updatePurchaseStatus()
        }
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: [Self.monthlyID, Self.annualID])
            // Sort: annual first (best value)
            products.sort { $0.id == Self.annualID && $1.id != Self.annualID }
        } catch {
            print("StoreKit: Failed to load products: \(error)")
        }
    }

    func purchase(_ product: Product) async {
        isLoading = true
        purchaseError = nil
        defer { isLoading = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    isPremium = true
                case .unverified:
                    purchaseError = "Purchase verification failed. Please try again."
                }
            case .pending:
                break
            case .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            purchaseError = "Purchase failed: \(error.localizedDescription)"
        }
    }

    func restorePurchases() async {
        isLoading = true
        purchaseError = nil
        defer { isLoading = false }
        do {
            try await AppStore.sync()
            await updatePurchaseStatus()
        } catch {
            purchaseError = "Restore failed: \(error.localizedDescription)"
        }
    }

    func updatePurchaseStatus() async {
        var hasPremium = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if (transaction.productID == Self.monthlyID || transaction.productID == Self.annualID),
                   transaction.revocationDate == nil {
                    hasPremium = true
                    break
                }
            }
        }
        isPremium = hasPremium
    }
}
