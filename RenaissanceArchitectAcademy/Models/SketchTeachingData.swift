import Foundation
import CoreGraphics

// MARK: - Teaching Steps

/// The three observation/understanding steps before drawing
enum SketchTeachingStep: Int, CaseIterable {
    case observe = 0    // Met Museum sketch study
    case understand = 1 // Wolfram engineering + annotations
    case plan = 2       // Grid preview before drawing

    var title: String {
        switch self {
        case .observe: return "Observe"
        case .understand: return "Understand"
        case .plan: return "Plan"
        }
    }

    var italianTitle: String {
        switch self {
        case .observe: return "Osservare"
        case .understand: return "Capire"
        case .plan: return "Pianificare"
        }
    }

    var iconName: String {
        switch self {
        case .observe: return "eye"
        case .understand: return "gearshape.2"
        case .plan: return "square.grid.3x3"
        }
    }
}

// MARK: - Engineering Annotation

/// A callout highlighting an engineering feature on the floor plan
struct EngineeringAnnotation: Identifiable {
    let id = UUID()
    let label: String
    let icon: String        // SF Symbol name
    let science: Science
}

// MARK: - Teaching Data

/// All data needed for the 3-step teaching experience before sketching
struct SketchTeachingData {
    let observeSketchID: Int                               // Met Museum object ID
    let observeQuestion: String                            // Bird's question about the sketch
    let observeAnswer: String                              // Revealed after player responds
    let observeHint: String                                // Hint if player is stuck
    let observeTapTarget: CGPoint                          // Normalized 0-1 position of feature to find
    let observeTapRadius: CGFloat                          // Normalized radius for correct tap zone
    let engineeringAnnotations: [EngineeringAnnotation]    // Floor-plan callouts
    let gridPreviewHint: String                            // Bird's instruction before drawing
}

// MARK: - Teaching Content

/// Static teaching content per building (same pattern as SketchingContent)
enum SketchTeachingContent {

    static func teachingData(for buildingName: String) -> SketchTeachingData? {
        switch buildingName {
        case "Pantheon":
            return pantheonTeaching
        case "Colosseum":
            return colosseumTeaching
        case "Aqueduct":
            return aqueductTeaching
        case "Duomo", "Il Duomo":
            return duomoTeaching
        default:
            return nil
        }
    }

    // MARK: - Pantheon

    static let pantheonTeaching = SketchTeachingData(
        observeSketchID: 399993,
        observeQuestion: "This 1553 engraving shows the Pantheon sliced open. Tap on the thickest part of the walls — the structural foundation that carries the dome's entire weight.",
        observeAnswer: "The walls are 6 meters thick at the base! They carry 4,535 tonnes of concrete dome. As the dome rises, Romans mixed in lighter volcanic pumice to reduce weight.",
        observeHint: "Look at the very bottom of the building where it meets the ground. The walls are much thicker there than at the top.",
        observeTapTarget: CGPoint(x: 0.22, y: 0.72),   // Thick wall base, lower-left
        observeTapRadius: 0.18,
        engineeringAnnotations: [
            EngineeringAnnotation(
                label: "6-meter walls carry 4,535 tonnes of dome weight",
                icon: "square.stack.3d.up",
                science: .engineering
            ),
            EngineeringAnnotation(
                label: "Hidden relief arches distribute stress through the walls",
                icon: "archivebox",
                science: .architecture
            ),
            EngineeringAnnotation(
                label: "Height equals diameter: 43.3m — a perfect 1:1 ratio",
                icon: "equal.circle",
                science: .geometry
            ),
            EngineeringAnnotation(
                label: "The 8.7m oculus removes 3% of the dome's weight",
                icon: "circle.dashed",
                science: .mathematics
            ),
        ],
        gridPreviewHint: "Now you'll draw the Pantheon's floor plan. The rotunda is a perfect circle in the center — the dome sits right on top. The rectangular portico extends from the front with columns at the entrance."
    )

    // MARK: - Colosseum

    static let colosseumTeaching = SketchTeachingData(
        observeSketchID: 400018,
        observeQuestion: "This cross-section reveals the Colosseum's skeleton. Tap on the repeating arched structure that holds everything up.",
        observeAnswer: "Each arch distributes weight to the piers below, like a chain of hands passing a heavy stone. 80 arched entrances (vomitoria) let 50,000 people exit in just 15 minutes — the same principle modern stadiums use.",
        observeHint: "Look at the curved openings that repeat across each level. They form the building's structural rhythm.",
        observeTapTarget: CGPoint(x: 0.45, y: 0.55),   // Arched structure in center
        observeTapRadius: 0.20,
        engineeringAnnotations: [
            EngineeringAnnotation(
                label: "Elliptical shape: 188m x 156m (5:4 ratio)",
                icon: "oval",
                science: .geometry
            ),
            EngineeringAnnotation(
                label: "80 entrance arches: 15-minute evacuation for 50,000",
                icon: "figure.walk.motion",
                science: .engineering
            ),
            EngineeringAnnotation(
                label: "Three column orders: Doric, Ionic, Corinthian",
                icon: "building.columns",
                science: .architecture
            ),
            EngineeringAnnotation(
                label: "Hypogeum tunnels below arena for staging animals",
                icon: "arrow.down.square",
                science: .engineering
            ),
        ],
        gridPreviewHint: "Your floor plan shows the Colosseum from above. Draw the large outer wall first — it's nearly square on our grid. Then place the smaller arena rectangle inside it, and mark the four main entrances with columns."
    )

    // MARK: - Aqueduct

    static let aqueductTeaching = SketchTeachingData(
        observeSketchID: 728104,
        observeQuestion: "This is the Pont du Gard — a Roman aqueduct bridge. Tap on the water channel at the very top where the water actually flows.",
        observeAnswer: "The top tier carries the specus (water channel) — a narrow stone trough lined with waterproof mortar. The two lower tiers are purely structural, built to lift the channel to the perfect height for gravity to work.",
        observeHint: "The water doesn't flow through the big arches. Look at the very top row — the smallest arches carry something narrow on top.",
        observeTapTarget: CGPoint(x: 0.50, y: 0.12),   // Water channel at top
        observeTapRadius: 0.15,
        engineeringAnnotations: [
            EngineeringAnnotation(
                label: "Gradient: only 2.5 cm drop per kilometer",
                icon: "arrow.right.and.line.vertical.and.arrow.left",
                science: .hydraulics
            ),
            EngineeringAnnotation(
                label: "Water channel (specus) lined with waterproof mortar",
                icon: "drop.fill",
                science: .materials
            ),
            EngineeringAnnotation(
                label: "Piers repeat at regular intervals for uniform load",
                icon: "rectangle.split.3x1",
                science: .engineering
            ),
            EngineeringAnnotation(
                label: "Gravity alone moves 300M gallons daily — no pumps",
                icon: "arrow.down.right",
                science: .physics
            ),
        ],
        gridPreviewHint: "Your floor plan shows the aqueduct from above — a long, narrow water channel with piers below. Draw the channel running horizontally across the grid, then place columns where the support piers stand."
    )

    // MARK: - Duomo

    static let duomoTeaching = SketchTeachingData(
        observeSketchID: 341618,
        observeQuestion: "This is a study for painting INSIDE Brunelleschi's dome. Tap on the curved surface where the figures are stretched and distorted.",
        observeAnswer: "The artist had to distort every figure so it would look correct when viewed from 100 feet below. Near the bottom of the dome, figures are stretched vertically. The dome's curve acts like a funhouse mirror — the painter reversed the distortion.",
        observeHint: "Look at where the dome surface curves most steeply. The figures there look stretched compared to the center.",
        observeTapTarget: CGPoint(x: 0.50, y: 0.35),   // Curved dome surface
        observeTapRadius: 0.20,
        engineeringAnnotations: [
            EngineeringAnnotation(
                label: "Double-shell dome reduces weight by 25%",
                icon: "circle.circle",
                science: .engineering
            ),
            EngineeringAnnotation(
                label: "Herringbone brick pattern: each ring self-supporting",
                icon: "chevron.up.chevron.down",
                science: .architecture
            ),
            EngineeringAnnotation(
                label: "44m span — largest masonry dome ever built",
                icon: "ruler",
                science: .geometry
            ),
            EngineeringAnnotation(
                label: "Built without ground scaffolding — a first in history",
                icon: "hammer",
                science: .physics
            ),
        ],
        gridPreviewHint: "The Duomo has a cross-shaped plan (cruciform) with the great dome at the crossing. Draw the square crossing first — that's where Brunelleschi's dome sits. Then extend the nave to the left and the apse to the right."
    )
}
