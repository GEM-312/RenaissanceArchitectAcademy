# UI/UX Review Skill

When asked to review or create UI, apply these rules BEFORE writing any layout code. Check every rule against your output. If a rule is violated, fix it before presenting the code.

## 1. Space Management — NEVER Leave Empty Space

- **Fill available space**: Content must expand to use all available room. A visual that takes 35% of a card when 70% is available is WRONG.
- **No orphan space**: If more than 30% of a container is empty, something is undersized or missing.
- **Use `Spacer()` intentionally**: Spacers push content apart — don't use them to "center" content that should fill.
- **SwiftUI rule**: Prefer `.frame(maxWidth: .infinity)` or `.frame(maxHeight: .infinity)` over fixed sizes. Use GeometryReader when you need proportional sizing.

## 2. The 8pt Grid — All Spacing in Multiples of 4/8

All padding, margins, gaps, and sizes must be multiples of 4pt (preferably 8pt):

| Token | Value | Use |
|-------|-------|-----|
| xxs | 4pt | Icon-to-label gaps |
| xs | 8pt | Tight padding, divider margins |
| sm | 12pt | Button padding, compact spacing |
| md | 16pt | Default content spacing |
| lg | 20pt | Section spacing |
| xl | 24pt | Card/modal padding |
| xxl | 32pt | Major section breaks |

**NEVER use arbitrary values** like 5, 7, 10, 13, 15, 17pt. Round to the nearest 4pt multiple.

## 3. Typography Scale — Major Third (1.25 ratio)

Use this hierarchy. Font sizes must create clear visual distinction between levels:

| Level | Size | Font | Use |
|-------|------|------|-----|
| Display | 28pt | Cinzel-Bold | Screen titles |
| Title | 22pt | Cinzel-Bold | Card/section headers |
| Title 2 | 18pt | Cinzel-Bold | Sub-headers |
| Body Large | 17pt | EBGaramond-Regular | Primary reading text |
| Body | 15pt | EBGaramond-Regular | Secondary text |
| Caption | 13pt | EBGaramond-Regular | Labels, metadata |
| Caption Small | 11pt | EBGaramond-Italic | Hints, timestamps |
| Micro | 9pt | EBGaramond-Regular | Badges, tags (minimum size) |

**Rules:**
- NEVER use text smaller than 9pt
- Body text line-height: 1.4-1.6x the font size (e.g., 15pt font → 21-24pt line height)
- Line spacing for reading: 6-8pt
- Letter spacing for titles: 1-2pt tracking
- **Minimum 2 steps between hierarchy levels** (don't use 15pt and 16pt together — not distinct enough)

## 4. Touch Targets — Minimum 44×44pt

- Every tappable element: minimum 44×44pt touch area
- Use `.contentShape(Rectangle())` to extend touch areas on small visuals
- Buttons: minimum padding 12pt vertical, 16pt horizontal
- Icon buttons: minimum 44×44pt frame even if icon is 16pt

## 5. Visual Hierarchy — Size Communicates Importance

- **Primary element**: Largest, most prominent (the science visual on a card)
- **Secondary**: Supporting content (text, labels)
- **Tertiary**: Controls, navigation (step dots, back/next)

**The primary element should take 50-70% of the container.**
If your diagram is tiny and your text fills 60% of the card, the hierarchy is inverted.

## 6. Card Layout Rules

- **Content padding**: Minimum 16pt (xl: 24pt for modal cards)
- **Element spacing**: Minimum 8pt between elements, 16pt between sections
- **Border radius**: Consistent per level (cards: 12-16pt, buttons: 8-10pt, badges: 4-6pt)
- **One primary action per card** (e.g., "Done Reading")
- **Max 3-5 interactive elements** per card to avoid cognitive overload
- **Images/visuals fill their container width** — never float small in the center

## 7. Color Usage

- **Max 3 colors per view** (1 primary, 1 accent, 1 neutral)
- **Text on color**: Ensure contrast ratio ≥ 4.5:1 for body, ≥ 3:1 for large text
- **Semantic colors**: Green = success/complete, Red = error/danger, Orange = warning, Blue = info/link
- **Use opacity for hierarchy**: Primary text 100%, secondary 70%, disabled 40%
- Always use `RenaissanceColors` palette — never invent colors

## 8. Responsive Sizing

- Use **percentages or proportional sizing** instead of fixed pixel values
- Test on: iPad landscape, iPad portrait, iPhone SE, iPhone Pro Max
- Critical content must be visible **without scrolling** on iPad
- Use `.minimumScaleFactor(0.8)` on text that might overflow
- Use `@Environment(\.horizontalSizeClass)` to adapt layout

## 9. Checklist Before Submitting UI Code

Run through this mentally for every view you create or modify:

- [ ] Does the primary content fill 50%+ of the container?
- [ ] Is all spacing a multiple of 4pt?
- [ ] Are font sizes from the typography scale (not arbitrary)?
- [ ] Is there at least 2-step size difference between text hierarchy levels?
- [ ] Are all touch targets ≥ 44pt?
- [ ] Is there no empty space > 30% of the container?
- [ ] Does it use RenaissanceColors (not custom colors)?
- [ ] Does it use Spacing tokens (not magic numbers)?
- [ ] Is the layout tested at multiple screen sizes?

## 10. SwiftUI Anti-Patterns to Avoid

- **Fixed height on content that should grow**: Use `.frame(maxHeight: .infinity)` instead
- **Nested ScrollViews**: Never put a ScrollView inside a ScrollView
- **`.frame(width: 300)`**: Almost always wrong — use `.frame(maxWidth: .infinity)` or percentage
- **Text truncation without scaleFactor**: Always add `.minimumScaleFactor(0.8)` or `.lineLimit()`
- **Hardcoded positions**: Use layout containers (VStack/HStack/ZStack), not `.position(x:y:)`
- **`.padding()` without direction**: Be explicit — `.padding(.horizontal, 16)` not `.padding(16)`

## How To Use This Skill

Invoke with `/ui-review` after writing UI code. It will check your most recent changes against all rules above and flag violations.

You can also invoke BEFORE writing UI code to remind yourself of the rules.
