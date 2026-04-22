# Subscription Design — Renaissance Architect Academy

**Author:** Marina Pollak
**Date:** 2026-04-22
**Status:** Pre-submission design doc
**Target ship:** mid-May 2026

## 1. Market research summary

- **Duolingo** (freemium, ages 8+): core lessons free, Super Duolingo $6.99/mo or $83.99/yr removes ads, adds unlimited hearts. Conversion trick: daily streak pressure + hearts as a soft paywall, not a hard feature gate. Family plan at $119.99/yr for 6.
- **Khan Academy Kids** (fully free, nonprofit): sets parent expectations that educational content can be free. Commercial apps must show distinct paid value vs "just content."
- **Prodigy Math** ($8.95/mo, $74.95/yr premium membership, ages 6–14): pets, member-only worlds, cosmetics. Demonstrates that mechanical *progression items* (not core math) convert best with kids.
- **Lightbot Jr / Lightbot: Code Hour** (one-time $4.99–$9.99): no subscription. Parents of 10–16 remember the pre-subscription era and appreciate one-time options.
- **Toca Boca, Sago Mini, Swift Playgrounds**: Apple's "Made for Kids" expectations — parent gate, no behavioral ads, transparent pricing.

**Takeaway for RAA:** parents buying for ages 10–16 are comfortable with $5–$10/mo or $30–$50/yr for genuine educational tools, but convert best when free tier is substantive (not a 10-min demo), paid tier offers distinct *creative* value (not just "more levels"), and a one-time buy option exists as a trust signal.

## 2. Tier structure

RAA's features map naturally to three tiers. Pianta sketching must stay free (it is the core promise and already free to operate after Haiku validation at $0.005/call). fal.ai watercolor rendering ($0.04/call) and Claude bird tutoring ($1.99/mo value slot) are the premium hooks.

| Feature | Free "Visitor" | **Apprentice** $4.99/mo, $29.99/yr | **Architect** $9.99/mo, $59.99/yr, $99 one-time |
|---|---|---|---|
| 17 building lessons (Read-to-Earn) | All 17 | All 17 | All 17 |
| Vocabulary, knowledge cards | All | All | All |
| Workshop crafting (8 stations, 4 furniture) | Full | Full | Full |
| Forest, Goldsmith bottega | Full | Full | Full |
| Quizzes, material puzzle | All | All | All |
| **Pianta sketch (Phase 1)** | All 17 buildings | All 17 | All 17 |
| **Haiku AI sketch validation** | 3/day | Unlimited | Unlimited |
| **Watercolor blueprint bloom (fal.ai)** | Pantheon only (demo) | All 17 (cached) | All 17 + re-renders |
| **Alzato (Phase 2 — elevation)** | Preview on Pantheon | **Unlocked, all 17** | Unlocked, all 17 |
| **Sezione (Phase 3 — cross-section)** | Locked | Locked | **Unlocked, all 17** |
| **Prospettiva (Phase 4 — perspective)** | Locked | Locked | **Unlocked, all 17** |
| **AI Bird tutor (Claude)** | Apple on-device only | Claude Haiku, 30 msgs/day | Claude Haiku unlimited |
| **Narration (ElevenLabs)** | 10-sec preview | Full lesson/card narration | Full + historical figure voices |
| Achievements, leaderboards, wax seals | **Yes** (engagement) | Yes | Yes |
| Family Sharing | n/a | Enabled | Enabled |
| Child profiles (up to 4 kids/device) | 1 | Up to 4 | Up to 4 |

**Rationale for split:** Apprentice = "see your drawings come alive as watercolor" (the magical, conversion-driving feature). Architect = "master all four Renaissance drawing traditions" (depth-buyer tier). One-time $99 Architect exists because parents of older teens often balk at recurring charges. Achievements remain free because kids quit when they can't level up.

## 3. Pricing rationale

- **Monthly $4.99 / $9.99** — below Duolingo Super, above Prodigy monthly ($8.95). Credibly priced below the "serious app" mental anchor of $10/mo.
- **Annual $29.99 / $59.99** — 50% savings on monthly, hits the "under $60" parental sweet spot. Annual introduces a 7-day free trial (Apple's `introductoryPeriod`) — industry standard, drops cart abandonment ~40%.
- **One-time $99 Architect Forever** — satisfies the Lightbot demographic, reduces refund/churn exposure. No recurring billing complaints.
- **International tiering:** use Apple's auto price tiers. Tier 5 (US $4.99) maps to €5.99, £4.99, ₹399, MXN 99, BRL 24.90. Tier 10 for $9.99. Apple handles VAT.
- **Education bulk licensing:** out of scope for launch. Apple School Manager's Volume Purchases is the correct path later — requires a separate `.edu` price or a free VPP SKU. Flag as post-launch v1.1.
- **No ads, ever** — Apple's "Kids" category bans third-party ads; and parent-purchaser audience punishes advertised-to kids.

## 4. StoreKit 2 architecture

Use StoreKit 2 (iOS 15+, target iOS 17+ anyway). StoreKit 2 is `async/await`, `Transaction`-based, replaces the legacy receipt-validation dance.

**Product IDs (reverse-DNS + role + period):**
- `com.marinapollak.raa.apprentice.monthly`
- `com.marinapollak.raa.apprentice.yearly`
- `com.marinapollak.raa.architect.monthly`
- `com.marinapollak.raa.architect.yearly`
- `com.marinapollak.raa.architect.lifetime` (non-consumable, not in group)

**Subscription groups:** single group `raa_main` with two levels — Apprentice (level 2, cheaper) and Architect (level 1, expensive). Apple handles upgrade proration automatically when kids upgrade mid-cycle.

**Receipt validation strategy:** client-side first via StoreKit 2's `Transaction.currentEntitlements` + `Transaction.updates`. These are JWS-signed by Apple; `verificationResult.payload` proves authenticity without a server. For launch, this is sufficient — matches what Duolingo shipped for years. Add server-side verification only if piracy becomes material.

**Family Sharing:** enable for both subscription tiers (App Store Connect checkbox per product). The lifetime Architect purchase is also family-sharable. Enables the "one parent buys, 4 kids share" story.

**Grace period:** enable 16-day billing grace in ASC (default). When a renewal fails, `Transaction.expirationReason` = `.billingError` gives a 16-day window where `isSubscribed` stays true and a non-blocking banner nudges the parent to update payment.

**Restore purchases:** `AppStore.sync()` on tap. Required button per Apple Guideline 3.1.1.

## 5. Code architecture plan

**`Services/SubscriptionManager.swift`** — new `@MainActor @Observable` singleton.
- Load products, listen to `Transaction.updates`, publish `currentTier: Tier` and `isSubscribed: Bool`, handle purchase/restore flows, detect grace period.
- On init: `Task { for await update in Transaction.updates { ... } }` to catch background renewals.
- `func refreshEntitlements() async` — called on app foreground.

**`GameSettings.isSubscribed` → computed, not stored.** Delete the UserDefaults-backed flag. Replace with:
```swift
var isSubscribed: Bool { SubscriptionManager.shared.isSubscribed }
var currentTier: SubscriptionManager.Tier { SubscriptionManager.shared.currentTier }
```
Every callsite keeps working unchanged.

**`Views/Paywall/PaywallView.swift`** — new sheet. Three product cards (monthly / yearly / lifetime), "Start 7-day free trial" CTA for yearly, "Restore Purchases" link (required), "Terms" and "Privacy" links (required), small print disclosing auto-renewal (required by Apple 3.1.2(a)).

**`Views/Paywall/PaywallTrigger.swift`** — view modifier `.paywallOnPremium(feature:)`.

**Parent gate:** required for kids-category apps before IAP UI. `Views/Paywall/ParentGateOverlay.swift` — classic approach: math problem no 10-year-old will fail but requires intent ("Type the year 1506" or "Tap all 4 Corinthian columns").

**Integration points:**
- `RenaissanceArchitectAcademyApp.swift` — `.task { await SubscriptionManager.shared.refreshEntitlements() }` at app root, inject into environment.
- `ProfileView` — keep DEBUG toggle behind `#if DEBUG`. Add release-build "Manage Subscription" row (`URL(string: "itms-apps://apps.apple.com/account/subscriptions")`).
- `SketchingChallengeView` — phase-gate: if `phase == .alzato && tier < .apprentice`, show paywall. Same for Sezione/Prospettiva at Architect.
- `NotebookView` — bloom card checks subscription via `FalSketchService`; add paywall sheet on "Render my sketch" tap when not subscribed.

## 6. UX decisions

- **Where does the paywall appear?** Not on first launch (Apple rejects aggressive up-front paywalls for kids apps — Guideline 5.1.1(i)). Three natural touch points: (1) tapping the locked "Alzato" phase button, (2) tapping "Render as watercolor" after 3rd free Haiku validation used, (3) a single Profile row "Upgrade to Apprentice" always visible.
- **How do subscribers see they're subscribed?** Apprentice badge on avatar card in ProfileView (wax seal style). Name color shifts to ochre for Apprentice, gold for Architect. Notebook shows small "Apprentice" ribbon on renderable sketches.
- **Parent gate:** required by Review Guideline 5.1.1 when category is "Kids." If Marina picks "Education" without the Kids category, gate is optional but strongly recommended.

## 7. Edge cases

- **Student without sub tries to sketch Alzato** → paywall sheet; "Not now" returns to Pianta canvas; no gameplay loss.
- **Subscription lapses mid-sketch** → in-progress sketch auto-saves every 2s (existing). `SubscriptionManager` fires on expiry, grace-period banner appears but canvas stays open for current session. On next launch, premium phases lock; completed renders remain visible (you bought them, you keep them). Never mid-session yank.
- **Family Sharing: one parent, 4 kids** → each child uses separate iPad user or in-app child profile. `PersistenceManager` scopes by `playerId + appleAccountToken` so siblings retain distinct progress.
- **Refund after completing 3 buildings** → Apple processes; app respects `Transaction.revocationDate`. Graceful: tier drops to Visitor, Pianta stays free, cached watercolor PNGs stay on disk (no retroactive deletion).

## 8. Implementation phasing

| Phase | Deliverable | Days | Gates launch? |
|---|---|---|---|
| **1. Foundation** | Cloudflare Worker proxy live (`docs/proxy-migration.md`); API keys out of binary | 1–2 | **Yes** |
| **2. StoreKit config** | ASC: app record, paid agreement, tax/banking, 5 products, subscription group, localized metadata, intro offer, Family Sharing | 1 | **Yes** |
| **3. SubscriptionManager + Paywall** | `SubscriptionManager.swift`, `PaywallView`, `ParentGateOverlay`, integration with `FalSketchService` and `BirdChatViewModel` | 3–4 | **Yes** |
| **4. Tier gating** | `GameSettings.isSubscribed` → computed, Alzato/Sezione/Prospettiva locks, badge UI | 2 | **Yes** |
| **5. Polish** | Restore flow, grace-period banner, Manage Subscription link, parent gate, analytics events | 2 | **Yes** |
| **6. Testing** | Sandbox test account, Family Sharing child account, intro offer, renewal, refund, grace period | 2 | **Yes** |
| **7. Post-launch** | VPP education bundle, 2nd/3rd language, server-side receipt validation | — | No |

Total: ~11–13 working days. Fits mid-May ship with current 3.5-week runway.

## 9. App Store Connect pre-submission checklist

- [ ] Paid Apps Agreement signed, banking/tax filled in ASC
- [ ] App privacy policy URL live (required for subscription apps)
- [ ] Terms of Use URL (required for all subscription apps)
- [ ] 5 products created, attached to subscription group `raa_main`, localized for English
- [ ] Subscription display names and descriptions localized
- [ ] Promotional artwork for each subscription (1024×1024)
- [ ] Introductory offer: 7-day free trial configured on yearly SKUs
- [ ] Family Sharing enabled on all 5 products
- [ ] Age rating re-evaluated (IAP triggers question cascade)
- [ ] Content descriptors: "Digital Purchases"
- [ ] App Privacy questionnaire: Purchases (linked to user)
- [ ] Screenshots showing paywall, subscriber badge, Alzato unlock
- [ ] Review notes mentioning sandbox credentials, Pianta fully free, parent gate flow, Family Sharing
- [ ] Test all 5 purchase paths via StoreKit Configuration file AND real sandbox account
- [ ] Review Guideline self-audit:
  - 3.1.1 (IAP for digital goods only)
  - 3.1.2 (subscription disclosure)
  - 5.1.1 (data collection, parent gate for kids)
  - 5.1.4 (Kids category: no third-party analytics, no behavioral ads)

## 10. Risk table

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| App Store rejection on first submission | High | 3–7 day delay | Pre-flight with Apple checklist; submit 10 days before May 15 |
| Paywall too early → kids-category rejection | Medium | Reject | Only trigger on premium feature tap, not launch |
| fal.ai API key leaked from binary | High if proxy not done | Account drain | **Cloudflare Worker before submission** (blocks release) |
| Parents chargeback "my kid bought this" | Medium | 1-star reviews | Parent gate, "7-day free trial, cancel anytime" wording, honor all refunds silently |
| Family Sharing misconfigured | Medium | Angry 1-star | Test with real Family Sharing (2 Apple IDs) before submission |
| StoreKit 2 race on launch | Low | Brief `isSubscribed = false` flicker | Show "Checking subscription..." splash until first refresh completes |
| Claude/fal.ai costs exceed revenue | Low at scale | Margin pressure | Cache watercolor renders per (building, phase); rate-limit Bird to 30 msgs/day on Apprentice |
| Teens pirate by modifying UserDefaults | Low | Minimal | Don't store `isSubscribed` in UserDefaults — compute from JWS-signed `Transaction.currentEntitlements` |
| Currency tier wrong internationally | Low | Revenue miss | Use Apple's auto tiers for launch; adjust post-launch |
| Marina's banking/tax forms incomplete | Medium | Launch blocked | Complete in ASC week of Apr 28, not last minute |

## 11. Apple documentation references

- StoreKit 2 guide: https://developer.apple.com/documentation/storekit/in-app_purchase
- Subscriptions and offers: https://developer.apple.com/documentation/storekit/original_api_for_in-app_purchase/subscriptions_and_offers
- StoreKit testing in Xcode: https://developer.apple.com/documentation/xcode/setting-up-storekit-testing-in-xcode
- Family Sharing: https://developer.apple.com/app-store/subscriptions/#family-sharing
- App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- WWDC 2021 "Meet StoreKit 2": https://developer.apple.com/videos/play/wwdc2021/10114/
- App Attest (post-launch hardening): https://developer.apple.com/documentation/devicecheck/establishing-your-app-s-integrity

## Notes

- The Cloudflare Worker (`docs/proxy-migration.md`) is a hard prerequisite; do it in week 1. An `.ipa` with `APIKeys.falAI` visible will get scraped within days of public TestFlight.
- The Bird-tutor pricing promise in `AIProvider.swift` (`"$1.99/mo"`) is inconsistent with this doc's $4.99 Apprentice tier. Delete that string when wiring SubscriptionManager.
- Consider gating Foundation Models bird responses (free) vs Claude bird responses (Apprentice+) rather than hard-gating the bird entirely — keeps free tier feeling alive.
