import SwiftUI
import Combine

/// Owns the player's chosen subscription tier and persists it across launches.
///
/// Today this uses a mock purchase flow that completes immediately and writes
/// the choice to UserDefaults. Real StoreKit 2 wiring (Product.products(for:),
/// Product.purchase(), Transaction.updates) lands in a follow-up session
/// alongside App Store Connect product registration.
///
/// `GameSettings.shared.isSubscribed` reads from this manager so existing
/// gates (TTSService, SpeakerButton) keep working through the migration.
@MainActor
final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    @Published private(set) var tier: SubscriptionTier?
    @Published private(set) var plan: SubscriptionPlan?
    @Published private(set) var purchasedAt: Date?

    private static let tierKey = "subscription_tier"
    private static let planKey = "subscription_plan"
    private static let dateKey = "subscription_purchasedAt"

    private init() {
        load()
    }

    /// Whether the user has chosen a tier. False means the picker should fire.
    var hasChosenTier: Bool { tier != nil }

    // MARK: - Purchase (mock)

    /// Mock purchase. Returns true immediately; persists the choice. Replace
    /// the body with a StoreKit 2 `Product.purchase()` call once products are
    /// registered in App Store Connect.
    @discardableResult
    func purchase(tier: SubscriptionTier, plan: SubscriptionPlan) async -> Bool {
        // TODO: StoreKit 2
        //   guard let product = try? await Product.products(for: [productID(for: tier, plan: plan)]).first
        //   else { return false }
        //   let result = try await product.purchase()
        //   guard case .success(.verified(let tx)) = result else { return false }
        //   await tx.finish()

        self.tier = tier
        self.plan = plan
        self.purchasedAt = Date()
        save()
        syncLegacyFlag()
        return true
    }

    /// Restore a previous purchase. Mock path: returns whatever was last saved
    /// to UserDefaults. Real StoreKit 2 path: iterate `Transaction.currentEntitlements`
    /// and resolve the highest-tier active entitlement.
    @discardableResult
    func restorePurchase() async -> Bool {
        // TODO: StoreKit 2 — iterate Transaction.currentEntitlements
        load()
        syncLegacyFlag()
        return tier != nil
    }

    /// Mirrors the active tier into `GameSettings.isSubscribed` so existing
    /// gates (TTSService, SpeakerButton) keep working through the migration.
    /// Plus/Premium → true. Apprentice or unset → false.
    private func syncLegacyFlag() {
        let isPaidSubscription = (tier == .plus || tier == .premium)
        if GameSettings.shared.isSubscribed != isPaidSubscription {
            GameSettings.shared.isSubscribed = isPaidSubscription
        }
    }

    // MARK: - Product ID lookup

    func productID(for tier: SubscriptionTier, plan: SubscriptionPlan) -> String {
        switch (tier, plan) {
        case (.apprentice, _):       return SubscriptionProductID.apprentice
        case (.plus, .monthly):      return SubscriptionProductID.plusMonthly
        case (.plus, .annual):       return SubscriptionProductID.plusAnnual
        case (.plus, .oneTime):      return SubscriptionProductID.plusMonthly
        case (.premium, .monthly):   return SubscriptionProductID.premiumMonthly
        case (.premium, .annual):    return SubscriptionProductID.premiumAnnual
        case (.premium, .oneTime):   return SubscriptionProductID.premiumMonthly
        }
    }

    // MARK: - Persistence

    private func save() {
        UserDefaults.standard.set(tier?.rawValue, forKey: Self.tierKey)
        UserDefaults.standard.set(plan?.rawValue, forKey: Self.planKey)
        UserDefaults.standard.set(purchasedAt, forKey: Self.dateKey)
    }

    private func load() {
        if let raw = UserDefaults.standard.string(forKey: Self.tierKey),
           let t = SubscriptionTier(rawValue: raw) {
            tier = t
        }
        if let raw = UserDefaults.standard.string(forKey: Self.planKey),
           let p = SubscriptionPlan(rawValue: raw) {
            plan = p
        }
        purchasedAt = UserDefaults.standard.object(forKey: Self.dateKey) as? Date
    }

    // MARK: - Dev helpers

    #if DEBUG
    /// Resets the tier choice — useful for re-testing the onboarding picker.
    func devReset() {
        tier = nil
        plan = nil
        purchasedAt = nil
        UserDefaults.standard.removeObject(forKey: Self.tierKey)
        UserDefaults.standard.removeObject(forKey: Self.planKey)
        UserDefaults.standard.removeObject(forKey: Self.dateKey)
    }
    #endif
}
