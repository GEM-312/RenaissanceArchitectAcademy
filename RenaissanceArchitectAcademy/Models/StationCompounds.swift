import Foundation

/// Maps workshop stations to the chemical compounds found there.
/// Each station reveals real chemistry through PubChem molecular structures.
struct StationCompound {
    let pubchemName: String       // Name used to query PubChem API
    let formula: String           // Display formula (with subscripts)
    let displayName: String       // Human-readable name
    let educationalText: String   // Short educational blurb

    /// All compounds for a station — player discovers one per visit
    static func compounds(for station: ResourceStationType) -> [StationCompound] {
        switch station {
        case .quarry:
            return [
                StationCompound(
                    pubchemName: "calcium carbonate",
                    formula: "CaCO\u{2083}",
                    displayName: "Calcium Carbonate",
                    educationalText: "The main mineral in limestone and marble. Romans carved entire temples from it."
                ),
                StationCompound(
                    pubchemName: "silicon dioxide",
                    formula: "SiO\u{2082}",
                    displayName: "Silicon Dioxide",
                    educationalText: "Quartz — the hardest common mineral. Found in granite and sandstone."
                ),
                StationCompound(
                    pubchemName: "calcium sulfate",
                    formula: "CaSO\u{2084}",
                    displayName: "Calcium Sulfate",
                    educationalText: "Gypsum — when heated it becomes plaster of Paris, used for Renaissance sculptures."
                )
            ]
        case .volcano:
            return [
                StationCompound(
                    pubchemName: "silicon dioxide",
                    formula: "SiO\u{2082}",
                    displayName: "Silicon Dioxide",
                    educationalText: "Volcanic glass (obsidian) is pure SiO\u{2082} cooled too fast to crystallize."
                ),
                StationCompound(
                    pubchemName: "aluminum oxide",
                    formula: "Al\u{2082}O\u{2083}",
                    displayName: "Aluminum Oxide",
                    educationalText: "Found in volcanic ash — the secret ingredient that makes Roman concrete set underwater."
                ),
                StationCompound(
                    pubchemName: "sulfur dioxide",
                    formula: "SO\u{2082}",
                    displayName: "Sulfur Dioxide",
                    educationalText: "The sharp smell near volcanoes. Romans collected sulfur for medicine and bleaching."
                )
            ]
        case .river:
            return [
                StationCompound(
                    pubchemName: "water",
                    formula: "H\u{2082}O",
                    displayName: "Water",
                    educationalText: "The universal solvent. Roman aqueducts carried 300 million gallons daily."
                ),
                StationCompound(
                    pubchemName: "calcium hydroxide",
                    formula: "Ca(OH)\u{2082}",
                    displayName: "Calcium Hydroxide",
                    educationalText: "Slaked lime — mix with water and sand to make mortar. Still used in construction today."
                )
            ]
        case .clayPit:
            return [
                StationCompound(
                    pubchemName: "aluminum silicate",
                    formula: "Al\u{2082}SiO\u{2085}",
                    displayName: "Aluminum Silicate",
                    educationalText: "Kaolinite — the mineral in clay. When fired at 1000°C it becomes ceramic."
                ),
                StationCompound(
                    pubchemName: "iron oxide",
                    formula: "Fe\u{2082}O\u{2083}",
                    displayName: "Iron Oxide",
                    educationalText: "Gives terracotta its red-orange color. More iron = deeper red."
                )
            ]
        case .mine:
            return [
                StationCompound(
                    pubchemName: "iron",
                    formula: "Fe",
                    displayName: "Iron",
                    educationalText: "Pure iron is soft. Add carbon (0.2-2%) and you get steel — Rome's strongest metal."
                ),
                StationCompound(
                    pubchemName: "copper",
                    formula: "Cu",
                    displayName: "Copper",
                    educationalText: "Mix copper with tin and you get bronze — the alloy that built civilizations."
                ),
                StationCompound(
                    pubchemName: "galena",
                    formula: "PbS",
                    displayName: "Galena (Lead Sulfide)",
                    educationalText: "Romans mined galena for lead pipes. The word 'plumbing' comes from plumbum (lead)."
                )
            ]
        case .forest:
            return [
                StationCompound(
                    pubchemName: "cellulose",
                    formula: "(C\u{2086}H\u{2081}\u{2080}O\u{2085})n",
                    displayName: "Cellulose",
                    educationalText: "The molecule that makes wood strong. Chains of glucose locked into rigid fibers."
                ),
                StationCompound(
                    pubchemName: "tannin",
                    formula: "C\u{2087}\u{2086}H\u{2085}\u{2082}O\u{2084}\u{2086}",
                    displayName: "Tannin",
                    educationalText: "Oak bark tannins cure leather and preserve wood. The word 'tan' comes from tannin."
                )
            ]
        case .market:
            return [
                StationCompound(
                    pubchemName: "gold",
                    formula: "Au",
                    displayName: "Gold",
                    educationalText: "Gold never rusts or tarnishes. A single ounce can be hammered into 300 square feet of leaf."
                ),
                StationCompound(
                    pubchemName: "sodium chloride",
                    formula: "NaCl",
                    displayName: "Sodium Chloride",
                    educationalText: "Salt — so valuable that Roman soldiers were paid in it. The word 'salary' comes from sal."
                )
            ]
        case .pigmentTable:
            return [
                StationCompound(
                    pubchemName: "lapis lazuli",
                    formula: "Na\u{2086}Ca\u{2082}Al\u{2086}Si\u{2086}O\u{2082}\u{2084}S\u{2082}",
                    displayName: "Lapis Lazuli",
                    educationalText: "Ultramarine blue — ground from lapis lazuli. Worth more than gold in the Renaissance."
                ),
                StationCompound(
                    pubchemName: "mercury sulfide",
                    formula: "HgS",
                    displayName: "Cinnabar (Mercury Sulfide)",
                    educationalText: "Vermillion red pigment. Beautiful but toxic — Renaissance painters risked their health."
                )
            ]
        case .farm:
            return [
                StationCompound(
                    pubchemName: "urea",
                    formula: "CO(NH\u{2082})\u{2082}",
                    displayName: "Urea",
                    educationalText: "Found in animal manure. The first organic compound ever synthesized in a lab (1828)."
                ),
                StationCompound(
                    pubchemName: "potassium nitrate",
                    formula: "KNO\u{2083}",
                    displayName: "Potassium Nitrate (Saltpeter)",
                    educationalText: "Forms in manure piles. One of three ingredients in gunpowder — changed warfare forever."
                )
            ]
        default:
            return []
        }
    }

    /// Get a compound for this visit number (cycles through available compounds)
    static func compoundForVisit(station: ResourceStationType, visitNumber: Int) -> StationCompound? {
        let all = compounds(for: station)
        guard !all.isEmpty else { return nil }
        return all[visitNumber % all.count]
    }
}
