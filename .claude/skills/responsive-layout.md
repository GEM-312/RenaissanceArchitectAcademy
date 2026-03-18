---
name: responsive-layout
description: Audit and fix layout sizing across all Apple device sizes (iPhone SE to iPad Pro)
---

Audit and fix responsive layout issues in the specified view(s). If the user doesn't specify a view, ask which one.

## Device Size Reference
- **iPhone SE**: 375×667 (smallest supported)
- **iPhone 15**: 393×852 (standard)
- **iPhone 15 Pro Max**: 430×932 (large phone)
- **iPad Mini**: 744×1133
- **iPad Air/Pro 11"**: 820×1180
- **iPad Pro 12.9"**: 1024×1366
- **Mac (Designed for iPad)**: variable window, typically 1200+ wide

## What to Check & Fix

1. **Read the target view file(s) fully** before making any changes

2. **Common issues to fix:**
   - Hard-coded widths/heights → use `GeometryReader`, `.frame(maxWidth:)`, or relative sizing
   - Fixed font sizes → use `@ScaledMetric` or Dynamic Type sizes
   - Fixed padding/spacing → scale with `min()` or GeometryReader proportions
   - Overlapping elements on small screens → use `ViewThatFits` or size classes
   - Wasted space on large screens → use `maxWidth` constraints or multi-column layouts
   - SpriteKit scenes → ensure camera and mapSize scale properly

3. **SwiftUI best practices for this project:**
   - Use `@Environment(\.horizontalSizeClass)` for compact vs regular layouts
   - Use `GeometryReader` sparingly — prefer relative modifiers when possible
   - Use `.frame(minWidth:, idealWidth:, maxWidth:)` for flexible containers
   - For text: `@ScaledMetric(relativeTo:)` with the project's custom fonts
   - For overlays/modals: cap width with `.frame(maxWidth: 600)` on iPad, full width on iPhone
   - For grids: `LazyVGrid` with `adaptive(minimum:)` columns
   - For SpriteKit wrappers: scene.size should match mapSize (3500×2500), scaleMode `.aspectFill`

4. **Project-specific patterns:**
   - This project targets iOS 17+ and macOS 14+
   - Uses `#if os(iOS)` / `#else` for platform conditionals
   - Custom fonts: Cinzel-Bold (titles), EBGaramond-Regular (body), PetitFormalScript (tagline)
   - Color palette in `RenaissanceColors.swift`
   - SpriteKit scenes use 3500×2500 mapSize with camera zoom 0.5–3.5

5. **After fixing:** List all changes made and which device sizes they address.
