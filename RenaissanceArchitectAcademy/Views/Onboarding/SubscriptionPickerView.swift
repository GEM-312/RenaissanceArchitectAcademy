import SwiftUI

/// Tier picker shown at the end of onboarding. Three standalone options:
/// Apprentice (one-time), Plus (subscription with bird chat + storyteller voice),
/// Premium (subscription with bird voice on chat replies).
struct SubscriptionPickerView: View {
    @Bindable var onboardingState: OnboardingState
    var onComplete: () -> Void

    @ObservedObject private var manager = SubscriptionManager.shared
    @State private var selectedPlan: [SubscriptionTier: SubscriptionPlan] = [
        .plus: .annual,
        .premium: .annual,
    ]
    @State private var purchasing: SubscriptionTier?
    @State private var errorMessage: String?

    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        ZStack {
            RenaissanceColors.parchment
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.xl) {
                    header
                    tierCards
                    restoreLink
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.xl)
                .frame(maxWidth: 1100)
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: Spacing.sm) {
            Text("Choose Your Path")
                .font(RenaissanceFont.hero)
                .foregroundStyle(RenaissanceColors.sepiaInk)
                .multilineTextAlignment(.center)

            Text(headerSubtitle)
                .font(RenaissanceFont.italic)
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.75))
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.lg)
        }
    }

    private var headerSubtitle: String {
        let name = onboardingState.apprenticeName.isEmpty ? "apprentice" : onboardingState.apprenticeName
        return "Lorenzo awaits, \(name). How will you accept his invitation?"
    }

    // MARK: - Tier cards

    @ViewBuilder
    private var tierCards: some View {
        if sizeClass == .compact {
            VStack(spacing: Spacing.lg) {
                ForEach(SubscriptionTier.allCases) { tier in
                    tierCard(for: tier)
                }
            }
        } else {
            HStack(alignment: .top, spacing: Spacing.lg) {
                ForEach(SubscriptionTier.allCases) { tier in
                    tierCard(for: tier)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func tierCard(for tier: SubscriptionTier) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Name + italian
            VStack(alignment: .leading, spacing: 2) {
                Text(tier.displayName)
                    .font(RenaissanceFont.title)
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                Text(tier.italianName)
                    .font(RenaissanceFont.italic)
                    .foregroundStyle(RenaissanceColors.warmBrown)
            }

            // Tagline
            Text(tier.tagline)
                .font(RenaissanceFont.bodyMedium)
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)

            ThematicDivider()

            // Features
            VStack(alignment: .leading, spacing: Spacing.xs) {
                ForEach(tier.features, id: \.self) { feature in
                    featureRow(feature)
                }
            }

            Spacer(minLength: Spacing.md)

            // Plan toggle (Plus + Premium only)
            if tier != .apprentice {
                planToggle(for: tier)
            }

            // Price
            priceLabel(for: tier)

            // CTA
            ctaButton(for: tier)
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .fill(RenaissanceColors.parchment)
        )
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .stroke(accentColor(for: tier).opacity(0.6), lineWidth: 1.5)
        )
        .renaissanceShadow(.elevated)
    }

    private func featureRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: Spacing.xs) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(RenaissanceColors.sageGreen)
                .padding(.top, 2)
            Text(text)
                .font(RenaissanceFont.bodySmall)
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func planToggle(for tier: SubscriptionTier) -> some View {
        HStack(spacing: 0) {
            planSegment(tier: tier, plan: .annual, label: "Annual")
            planSegment(tier: tier, plan: .monthly, label: "Monthly")
        }
        .background(
            Capsule().fill(RenaissanceColors.warmBrown.opacity(0.08))
        )
        .overlay(
            Capsule().stroke(RenaissanceColors.warmBrown.opacity(0.2), lineWidth: 1)
        )
    }

    private func planSegment(tier: SubscriptionTier, plan: SubscriptionPlan, label: String) -> some View {
        let isSelected = selectedPlan[tier] == plan
        return Button {
            selectedPlan[tier] = plan
        } label: {
            Text(label)
                .font(RenaissanceFont.buttonSmall)
                .foregroundStyle(isSelected ? .white : RenaissanceColors.sepiaInk)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.xs)
                .background(
                    Capsule().fill(isSelected ? accentColor(for: tier) : .clear)
                )
        }
        .buttonStyle(.plain)
    }

    private func priceLabel(for tier: SubscriptionTier) -> some View {
        let (price, period) = priceText(for: tier)
        return HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(price)
                .font(RenaissanceFont.title2Bold)
                .foregroundStyle(RenaissanceColors.sepiaInk)
            Text(period)
                .font(RenaissanceFont.caption)
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
        }
    }

    private func priceText(for tier: SubscriptionTier) -> (price: String, period: String) {
        switch tier {
        case .apprentice:
            return (SubscriptionPricing.apprenticeOneTime, "one-time")
        case .plus:
            switch selectedPlan[.plus] ?? .annual {
            case .annual:  return (SubscriptionPricing.plusAnnual, "/ year")
            case .monthly: return (SubscriptionPricing.plusMonthly, "/ month")
            case .oneTime: return (SubscriptionPricing.plusMonthly, "/ month")
            }
        case .premium:
            switch selectedPlan[.premium] ?? .annual {
            case .annual:  return (SubscriptionPricing.premiumAnnual, "/ year")
            case .monthly: return (SubscriptionPricing.premiumMonthly, "/ month")
            case .oneTime: return (SubscriptionPricing.premiumMonthly, "/ month")
            }
        }
    }

    private func ctaButton(for tier: SubscriptionTier) -> some View {
        Button {
            Task { await purchase(tier) }
        } label: {
            HStack(spacing: Spacing.xs) {
                if purchasing == tier {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .scaleEffect(0.8)
                }
                Text(ctaLabel(for: tier))
            }
            .font(RenaissanceFont.button)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.sm)
        }
        .buttonStyle(.plain)
        .disabled(purchasing != nil)
        .parchmentButton(color: accentColor(for: tier), radius: CornerRadius.md)
    }

    private func ctaLabel(for tier: SubscriptionTier) -> String {
        switch tier {
        case .apprentice: return "Begin Apprenticeship"
        case .plus, .premium: return "Subscribe"
        }
    }

    // MARK: - Restore link

    private var restoreLink: some View {
        VStack(spacing: Spacing.xs) {
            if let errorMessage {
                Text(errorMessage)
                    .font(RenaissanceFont.caption)
                    .foregroundStyle(RenaissanceColors.errorRed)
            }
            Button {
                Task { await restore() }
            } label: {
                Text("Restore Purchase")
                    .font(RenaissanceFont.caption)
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                    .underline()
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Actions

    private func purchase(_ tier: SubscriptionTier) async {
        purchasing = tier
        errorMessage = nil
        let plan: SubscriptionPlan = (tier == .apprentice) ? .oneTime : (selectedPlan[tier] ?? .annual)
        let success = await manager.purchase(tier: tier, plan: plan)
        purchasing = nil
        if success {
            onComplete()
        } else {
            errorMessage = "Purchase did not complete. Try again or restore a previous purchase."
        }
    }

    private func restore() async {
        errorMessage = nil
        let restored = await manager.restorePurchase()
        if restored {
            onComplete()
        } else {
            errorMessage = "No previous purchase found on this Apple ID."
        }
    }

    // MARK: - Per-tier accent color

    private func accentColor(for tier: SubscriptionTier) -> Color {
        switch tier {
        case .apprentice: return RenaissanceColors.warmBrown
        case .plus:       return RenaissanceColors.terracotta
        case .premium:    return RenaissanceColors.ochre
        }
    }
}
