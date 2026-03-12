import Foundation

// MARK: - PubChem API Response Models

/// Raw JSON structure from PubChem PUG REST API
struct PubChemResponse: Codable {
    let PC_Compounds: [PubChemCompound]

    enum CodingKeys: String, CodingKey {
        case PC_Compounds = "PC_Compounds"
    }
}

struct PubChemCompound: Codable {
    let atoms: PubChemAtoms
    let bonds: PubChemBonds?
    let coords: [PubChemCoords]
}

struct PubChemAtoms: Codable {
    let aid: [Int]       // atom IDs (1-indexed)
    let element: [Int]   // atomic numbers
}

struct PubChemBonds: Codable {
    let aid1: [Int]      // first atom in bond
    let aid2: [Int]      // second atom in bond
    let order: [Int]     // bond order: 1=single, 2=double, 3=triple
}

struct PubChemCoords: Codable {
    let conformers: [PubChemConformer]
}

struct PubChemConformer: Codable {
    let x: [Double]
    let y: [Double]
}

// MARK: - Parsed Compound (game-ready)

/// A compound parsed from PubChem, ready for rendering
struct PubChemMolecule: Identifiable {
    let id = UUID()
    let name: String
    let formula: String
    let atoms: [PCAtom]
    let bonds: [PCBond]
    let educationalText: String

    struct PCAtom: Identifiable {
        let id: Int
        let symbol: String
        let element: ChemElement
        let x: CGFloat       // normalized 0-1
        let y: CGFloat       // normalized 0-1
    }

    struct PCBond: Identifiable {
        let id = UUID()
        let from: Int         // index into atoms array
        let to: Int           // index into atoms array
        let order: Int        // 1, 2, or 3
    }
}

// MARK: - Chemical Element Lookup

/// Common elements with colors and symbols
enum ChemElement: String {
    case hydrogen = "H"
    case carbon = "C"
    case nitrogen = "N"
    case oxygen = "O"
    case sulfur = "S"
    case phosphorus = "P"
    case calcium = "Ca"
    case silicon = "Si"
    case aluminum = "Al"
    case iron = "Fe"
    case sodium = "Na"
    case chlorine = "Cl"
    case potassium = "K"
    case magnesium = "Mg"
    case fluorine = "F"
    case copper = "Cu"
    case zinc = "Zn"
    case tin = "Sn"
    case lead = "Pb"
    case mercury = "Hg"
    case gold = "Au"
    case silver = "Ag"
    case unknown = "?"

    /// Atomic number → element
    static func from(atomicNumber: Int) -> ChemElement {
        switch atomicNumber {
        case 1:  return .hydrogen
        case 6:  return .carbon
        case 7:  return .nitrogen
        case 8:  return .oxygen
        case 9:  return .fluorine
        case 11: return .sodium
        case 12: return .magnesium
        case 13: return .aluminum
        case 14: return .silicon
        case 15: return .phosphorus
        case 16: return .sulfur
        case 17: return .chlorine
        case 19: return .potassium
        case 20: return .calcium
        case 26: return .iron
        case 29: return .copper
        case 30: return .zinc
        case 47: return .silver
        case 50: return .tin
        case 79: return .gold
        case 80: return .mercury
        case 82: return .lead
        default: return .unknown
        }
    }

    var symbol: String { rawValue }
}

// MARK: - PubChem Service

/// Fetches and parses molecular structure data from the PubChem PUG REST API
/// Endpoint: https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/{name}/record/JSON?record_type=2d
actor PubChemService {

    /// In-memory cache to avoid repeat fetches
    private var cache: [String: PubChemMolecule] = [:]

    /// Fetch a compound by name from PubChem
    func fetchCompound(name: String, formula: String = "", educationalText: String = "") async throws -> PubChemMolecule {
        let key = name.lowercased()
        if let cached = cache[key] { return cached }

        let encoded = name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? name
        let urlString = "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/\(encoded)/record/JSON?record_type=2d"
        guard let url = URL(string: urlString) else {
            throw PubChemError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw PubChemError.notFound(name)
        }

        let decoded = try JSONDecoder().decode(PubChemResponse.self, from: data)
        guard let compound = decoded.PC_Compounds.first else {
            throw PubChemError.noCompound
        }

        let molecule = parse(compound: compound, name: name, formula: formula, educationalText: educationalText)
        cache[key] = molecule
        return molecule
    }

    // MARK: - Parsing

    private func parse(compound: PubChemCompound, name: String, formula: String, educationalText: String) -> PubChemMolecule {
        // Parse atoms with positions
        let coords = compound.coords.first?.conformers.first
        let xs = coords?.x ?? []
        let ys = coords?.y ?? []

        // Find bounds for normalization
        let minX = xs.min() ?? 0
        let maxX = xs.max() ?? 1
        let minY = ys.min() ?? 0
        let maxY = ys.max() ?? 1
        let rangeX = max(maxX - minX, 0.001)
        let rangeY = max(maxY - minY, 0.001)
        // Add padding so atoms don't sit on the edge
        let pad = 0.1

        // Build atoms (convert 1-indexed IDs to 0-indexed)
        var atoms: [PubChemMolecule.PCAtom] = []
        let aidToIndex: [Int: Int] = Dictionary(uniqueKeysWithValues: compound.atoms.aid.enumerated().map { ($1, $0) })

        for (i, atomicNum) in compound.atoms.element.enumerated() {
            let element = ChemElement.from(atomicNumber: atomicNum)
            let rawX = i < xs.count ? xs[i] : 0
            let rawY = i < ys.count ? ys[i] : 0
            // Normalize to 0-1 with padding
            let nx = pad + (rawX - minX) / rangeX * (1 - 2 * pad)
            let ny = pad + (rawY - minY) / rangeY * (1 - 2 * pad)

            atoms.append(.init(
                id: compound.atoms.aid[i],
                symbol: element.symbol,
                element: element,
                x: CGFloat(nx),
                y: CGFloat(ny)
            ))
        }

        // Build bonds
        var bonds: [PubChemMolecule.PCBond] = []
        if let b = compound.bonds {
            for i in 0..<b.aid1.count {
                let fromIdx = aidToIndex[b.aid1[i]] ?? 0
                let toIdx = aidToIndex[b.aid2[i]] ?? 0
                let order = i < b.order.count ? b.order[i] : 1
                bonds.append(.init(from: fromIdx, to: toIdx, order: order))
            }
        }

        return PubChemMolecule(
            name: name,
            formula: formula.isEmpty ? name : formula,
            atoms: atoms,
            bonds: bonds,
            educationalText: educationalText
        )
    }
}

// MARK: - Errors

enum PubChemError: LocalizedError {
    case invalidURL
    case notFound(String)
    case noCompound

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid PubChem URL"
        case .notFound(let name): return "Compound '\(name)' not found on PubChem"
        case .noCompound: return "No compound data in response"
        }
    }
}
