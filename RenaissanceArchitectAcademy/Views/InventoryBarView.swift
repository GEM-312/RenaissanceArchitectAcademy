import SwiftUI

/// Unified inventory bar — shows tools, raw materials, and crafted items.
///
/// Used across Workshop, Crafting Room, Forest, and any future map view.
/// Theme-aware (light/dark mode), consistent styling, single source of truth.
struct InventoryBarView: View {
    let workshop: WorkshopState
    private var settings: GameSettings { GameSettings.shared }

    var body: some View {
        HStack(spacing: 0) {
            // Tools (ochre badges)
            let ownedTools = Tool.allCases.filter { (workshop.tools[$0] ?? 0) > 0 }
            if !ownedTools.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(ownedTools) { tool in
                            ToolIconView(tool: tool, size: 56)
                                .padding(.horizontal, 5)
                                .padding(.vertical, Spacing.xxs)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(RenaissanceColors.ochre.opacity(0.15))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .strokeBorder(RenaissanceColors.ochre.opacity(0.4), lineWidth: 1)
                                        )
                                )
                        }
                    }
                }

                Divider()
                    .frame(height: 30)
                    .padding(.horizontal, 6)
            }

            // Raw materials
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Material.allCases) { material in
                        let count = workshop.rawMaterials[material] ?? 0
                        if count > 0 {
                            HStack(spacing: 3) {
                                MaterialIconView(material: material, size: 20)
                                Text("\(count)")
                                    .font(.custom("EBGaramond-Regular", size: 12))
                                    .foregroundStyle(settings.cardTextColor)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, Spacing.xxs)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(settings.itemBadgeBackground)
                            )
                        }
                    }
                }
            }

            Divider()
                .frame(height: 30)
                .padding(.horizontal, Spacing.xs)

            // Crafted items
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(CraftedItem.allCases) { item in
                        let count = workshop.craftedMaterials[item] ?? 0
                        if count > 0 {
                            HStack(spacing: 3) {
                                Text(item.icon)
                                    .font(.caption)
                                Text("\(count)")
                                    .font(.custom("EBGaramond-Regular", size: 12))
                                    .foregroundStyle(RenaissanceColors.sageGreen)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, Spacing.xxs)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(RenaissanceColors.goldSuccess.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .strokeBorder(RenaissanceColors.goldSuccess.opacity(0.4), lineWidth: 1)
                                    )
                            )
                        }
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .fill(settings.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .strokeBorder(settings.cardBorderColor, lineWidth: 1)
        )
    }
}
