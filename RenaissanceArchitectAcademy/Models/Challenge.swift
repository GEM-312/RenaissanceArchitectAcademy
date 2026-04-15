import Foundation

// Note: Science enum is defined in Building.swift and is already Codable

// MARK: - Hint System Models

/// Data for the 3-tier hint system (riddle → craft/earn → detailed hint scroll)
struct HintData {
    let riddle: String           // Free vague clue (always available)
    let detailedHint: String     // Full hint shown on scroll after craft/earn
    let activityType: HintActivityType
}

/// Activity types for earning a hint
enum HintActivityType {
    case trueFalse(statement: String, isTrue: Bool, explanation: String)
}

// MARK: - Molecule Diagram Models

/// Bond type between atoms in a molecule diagram
enum BondType {
    case single
    case double
    case triple
    case ionic      // Dotted line for ionic/coordinate bonds
}

/// An atom in a 2D molecule diagram
struct MoleculeAtom {
    let symbol: String        // "Ca", "O", "H", etc.
    let position: CGPoint     // Normalized 0-1 coordinates
    let charge: String?       // Superscript charge: "2+", "−", "+", "2−", etc.

    init(symbol: String, position: CGPoint, charge: String? = nil) {
        self.symbol = symbol
        self.position = position
        self.charge = charge
    }
}

/// A bond connecting two atoms
struct MoleculeBond {
    let fromAtomIndex: Int
    let toAtomIndex: Int
    let bondType: BondType
}

/// Complete molecule diagram data
struct MoleculeData {
    let name: String              // "Water"
    let formula: String           // "H₂O"
    let atoms: [MoleculeAtom]
    let bonds: [MoleculeBond]
    let educationalText: String

    // MARK: - Pre-defined Molecules

    /// H₂O — Water
    static let water = MoleculeData(
        name: "Water",
        formula: "H\u{2082}O",
        atoms: [
            MoleculeAtom(symbol: "O", position: CGPoint(x: 0.5, y: 0.3), charge: "2\u{2212}"),
            MoleculeAtom(symbol: "H", position: CGPoint(x: 0.2, y: 0.7), charge: "+"),
            MoleculeAtom(symbol: "H", position: CGPoint(x: 0.8, y: 0.7), charge: "+"),
        ],
        bonds: [
            MoleculeBond(fromAtomIndex: 0, toAtomIndex: 1, bondType: .single),
            MoleculeBond(fromAtomIndex: 0, toAtomIndex: 2, bondType: .single),
        ],
        educationalText: "Water's bent shape (104.5\u{00B0}) gives it unique properties that made Roman aqueducts possible."
    )

    /// Ca(OH)₂ — Calcium Hydroxide (Lime Mortar)
    static let calciumHydroxide = MoleculeData(
        name: "Calcium Hydroxide",
        formula: "Ca(OH)\u{2082}",
        atoms: [
            MoleculeAtom(symbol: "H", position: CGPoint(x: 0.05, y: 0.2)),
            MoleculeAtom(symbol: "O", position: CGPoint(x: 0.25, y: 0.35), charge: "\u{2212}"),
            MoleculeAtom(symbol: "Ca", position: CGPoint(x: 0.5, y: 0.65), charge: "2+"),
            MoleculeAtom(symbol: "O", position: CGPoint(x: 0.75, y: 0.35), charge: "\u{2212}"),
            MoleculeAtom(symbol: "H", position: CGPoint(x: 0.95, y: 0.2)),
        ],
        bonds: [
            MoleculeBond(fromAtomIndex: 0, toAtomIndex: 1, bondType: .single),
            MoleculeBond(fromAtomIndex: 1, toAtomIndex: 2, bondType: .ionic),
            MoleculeBond(fromAtomIndex: 2, toAtomIndex: 3, bondType: .ionic),
            MoleculeBond(fromAtomIndex: 3, toAtomIndex: 4, bondType: .single),
        ],
        educationalText: "Lime mortar held Roman buildings together for millennia \u{2014} Ca(OH)\u{2082} slowly absorbs CO\u{2082} and turns back into limestone!"
    )

    /// SiO₂ — Silicon Dioxide (Glass)
    static let siliconDioxide = MoleculeData(
        name: "Silicon Dioxide",
        formula: "SiO\u{2082}",
        atoms: [
            MoleculeAtom(symbol: "O", position: CGPoint(x: 0.15, y: 0.5), charge: "2\u{2212}"),
            MoleculeAtom(symbol: "Si", position: CGPoint(x: 0.5, y: 0.5), charge: "4+"),
            MoleculeAtom(symbol: "O", position: CGPoint(x: 0.85, y: 0.5), charge: "2\u{2212}"),
        ],
        bonds: [
            MoleculeBond(fromAtomIndex: 0, toAtomIndex: 1, bondType: .double),
            MoleculeBond(fromAtomIndex: 1, toAtomIndex: 2, bondType: .double),
        ],
        educationalText: "SiO\u{2082} is the main ingredient of Venetian glass \u{2014} heated to 1700\u{00B0}C, it becomes transparent!"
    )

    /// CaCO₃ — Calcium Carbonate (Limestone)
    static let calciumCarbonate = MoleculeData(
        name: "Calcium Carbonate",
        formula: "CaCO\u{2083}",
        atoms: [
            MoleculeAtom(symbol: "Ca", position: CGPoint(x: 0.12, y: 0.5), charge: "2+"),
            MoleculeAtom(symbol: "O", position: CGPoint(x: 0.35, y: 0.75), charge: "\u{2212}"),
            MoleculeAtom(symbol: "C", position: CGPoint(x: 0.5, y: 0.45)),
            MoleculeAtom(symbol: "O", position: CGPoint(x: 0.5, y: 0.15), charge: "\u{2212}"),
            MoleculeAtom(symbol: "O", position: CGPoint(x: 0.78, y: 0.6), charge: "\u{2212}"),
        ],
        bonds: [
            MoleculeBond(fromAtomIndex: 0, toAtomIndex: 1, bondType: .ionic),
            MoleculeBond(fromAtomIndex: 1, toAtomIndex: 2, bondType: .single),
            MoleculeBond(fromAtomIndex: 2, toAtomIndex: 3, bondType: .double),
            MoleculeBond(fromAtomIndex: 2, toAtomIndex: 4, bondType: .single),
        ],
        educationalText: "Limestone (CaCO\u{2083}) was the Romans' favorite building stone \u{2014} heat it to get quicklime for mortar!"
    )

    /// Na₂O — Sodium Oxide
    static let sodiumOxide = MoleculeData(
        name: "Sodium Oxide",
        formula: "Na\u{2082}O",
        atoms: [
            MoleculeAtom(symbol: "Na", position: CGPoint(x: 0.15, y: 0.5), charge: "+"),
            MoleculeAtom(symbol: "O", position: CGPoint(x: 0.5, y: 0.5), charge: "2\u{2212}"),
            MoleculeAtom(symbol: "Na", position: CGPoint(x: 0.85, y: 0.5), charge: "+"),
        ],
        bonds: [
            MoleculeBond(fromAtomIndex: 0, toAtomIndex: 1, bondType: .ionic),
            MoleculeBond(fromAtomIndex: 1, toAtomIndex: 2, bondType: .ionic),
        ],
        educationalText: "Sodium oxide (Na\u{2082}O) lowers glass melting temperature \u{2014} a secret Venetian glassmakers guarded for centuries!"
    )

    /// CO₂ — Carbon Dioxide
    static let carbonDioxide = MoleculeData(
        name: "Carbon Dioxide",
        formula: "CO\u{2082}",
        atoms: [
            MoleculeAtom(symbol: "O", position: CGPoint(x: 0.15, y: 0.5)),
            MoleculeAtom(symbol: "C", position: CGPoint(x: 0.5, y: 0.5)),
            MoleculeAtom(symbol: "O", position: CGPoint(x: 0.85, y: 0.5)),
        ],
        bonds: [
            MoleculeBond(fromAtomIndex: 0, toAtomIndex: 1, bondType: .double),
            MoleculeBond(fromAtomIndex: 1, toAtomIndex: 2, bondType: .double),
        ],
        educationalText: "CO\u{2082} is released when limestone is heated \u{2014} Renaissance builders saw this gas without knowing what it was!"
    )

    /// C₆H₆ — Benzene (ring structure)
    static let benzene = MoleculeData(
        name: "Benzene",
        formula: "C\u{2086}H\u{2086}",
        atoms: [
            MoleculeAtom(symbol: "C", position: CGPoint(x: 0.5, y: 0.15)),
            MoleculeAtom(symbol: "C", position: CGPoint(x: 0.76, y: 0.3)),
            MoleculeAtom(symbol: "C", position: CGPoint(x: 0.76, y: 0.6)),
            MoleculeAtom(symbol: "C", position: CGPoint(x: 0.5, y: 0.75)),
            MoleculeAtom(symbol: "C", position: CGPoint(x: 0.24, y: 0.6)),
            MoleculeAtom(symbol: "C", position: CGPoint(x: 0.24, y: 0.3)),
            MoleculeAtom(symbol: "H", position: CGPoint(x: 0.5, y: 0.02)),
            MoleculeAtom(symbol: "H", position: CGPoint(x: 0.93, y: 0.2)),
            MoleculeAtom(symbol: "H", position: CGPoint(x: 0.93, y: 0.7)),
            MoleculeAtom(symbol: "H", position: CGPoint(x: 0.5, y: 0.88)),
            MoleculeAtom(symbol: "H", position: CGPoint(x: 0.07, y: 0.7)),
            MoleculeAtom(symbol: "H", position: CGPoint(x: 0.07, y: 0.2)),
        ],
        bonds: [
            MoleculeBond(fromAtomIndex: 0, toAtomIndex: 1, bondType: .double),
            MoleculeBond(fromAtomIndex: 1, toAtomIndex: 2, bondType: .single),
            MoleculeBond(fromAtomIndex: 2, toAtomIndex: 3, bondType: .double),
            MoleculeBond(fromAtomIndex: 3, toAtomIndex: 4, bondType: .single),
            MoleculeBond(fromAtomIndex: 4, toAtomIndex: 5, bondType: .double),
            MoleculeBond(fromAtomIndex: 5, toAtomIndex: 0, bondType: .single),
            MoleculeBond(fromAtomIndex: 0, toAtomIndex: 6, bondType: .single),
            MoleculeBond(fromAtomIndex: 1, toAtomIndex: 7, bondType: .single),
            MoleculeBond(fromAtomIndex: 2, toAtomIndex: 8, bondType: .single),
            MoleculeBond(fromAtomIndex: 3, toAtomIndex: 9, bondType: .single),
            MoleculeBond(fromAtomIndex: 4, toAtomIndex: 10, bondType: .single),
            MoleculeBond(fromAtomIndex: 5, toAtomIndex: 11, bondType: .single),
        ],
        educationalText: "Benzene's ring structure was a mystery until Kekul\u{00E9} dreamed of a snake eating its tail in 1865!"
    )

    /// All pre-defined molecules
    static let all: [MoleculeData] = [water, calciumHydroxide, siliconDioxide, calciumCarbonate, sodiumOxide, carbonDioxide, benzene]

    /// Lookup molecule by formula name (matches MaterialFormula pattern)
    static func molecule(forFormula formulaName: String) -> MoleculeData? {
        switch formulaName.lowercased() {
        case "lime mortar":
            return .calciumHydroxide
        case "roman concrete":
            return .calciumCarbonate
        case "venetian glass":
            return .siliconDioxide
        default:
            return nil
        }
    }
}
