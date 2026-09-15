import Foundation
import CoreGraphics

/// Teaching data for the 5 remaining Ancient Rome buildings.
/// Extension on `SketchTeachingContent` — routed by the switch in SketchTeachingData.swift.
extension SketchTeachingContent {

    // MARK: - Roman Baths

    static let romanBathsTeaching = SketchTeachingData(
        observeSketchID: 403393,
        observeQuestion: "This 1583 engraving shows the Baths of Agrippa laid out from above. Tap on the symmetrical axis — the central spine that organizes every room.",
        observeAnswer: "Roman baths follow a strict axial plan: rooms mirror each other across a central line. This symmetry ensured equal heating, equal water flow, and a logical circulation path from cold to hot and back.",
        observeHint: "Look for the line that divides the building into two matching halves. Every room on the left has a twin on the right.",
        observeTapTarget: CGPoint(x: 0.50, y: 0.50),
        observeTapRadius: 0.18,
        engineeringAnnotations: [
            EngineeringAnnotation(label: "Hypocaust: raised floor with furnace-heated air beneath", icon: "flame.fill", science: .engineering),
            EngineeringAnnotation(label: "Water flowed by gravity from aqueducts through lead pipes", icon: "drop.fill", science: .hydraulics),
            EngineeringAnnotation(label: "Barrel vaults span the large rooms without columns", icon: "archivebox", science: .architecture),
            EngineeringAnnotation(label: "Axial symmetry: every room mirrors across the center", icon: "arrow.left.and.right", science: .geometry),
        ],
        gridPreviewHint: "Your floor plan shows the baths from above. Draw the axial row of rooms — frigidarium, tepidarium, caldarium — with the palaestra alongside."
    )

    // MARK: - Roman Roads

    static let romanRoadsTeaching = SketchTeachingData(
        observeSketchID: 416047,
        observeQuestion: "Piranesi drew the Appian Way's ancient stone pavement. Tap on the interlocking paving stones — the road surface that survived 2,000 years.",
        observeAnswer: "The summum dorsum (top surface) used polygonal basalt stones fitted together without mortar. Their irregular interlocking shapes distributed load like a jigsaw puzzle, preventing any single stone from sinking.",
        observeHint: "Look at the road surface itself — the large, irregular stones that fit together like puzzle pieces.",
        observeTapTarget: CGPoint(x: 0.50, y: 0.60),
        observeTapRadius: 0.20,
        engineeringAnnotations: [
            EngineeringAnnotation(label: "Four construction layers totaling ~1 meter thick", icon: "square.stack.3d.up", science: .engineering),
            EngineeringAnnotation(label: "Crowned camber sheds rainwater to drainage ditches", icon: "arrow.down.left.and.arrow.up.right", science: .hydraulics),
            EngineeringAnnotation(label: "Basalt paving stones interlock without mortar", icon: "rectangle.split.3x3", science: .geology),
            EngineeringAnnotation(label: "400,000 km of roads — Earth to Moon distance", icon: "globe.americas", science: .mathematics),
        ],
        gridPreviewHint: "From above, a Roman road is three parallel strips: drainage ditch, road surface, drainage ditch. Draw them running the length of the canvas."
    )

    // MARK: - Harbor

    static let harborTeaching = SketchTeachingData(
        observeSketchID: 338737,
        observeQuestion: "Piranesi imagined a Roman port in the ancient style. Tap on the breakwater — the long arm of stone reaching into the sea that shelters the basin from waves.",
        observeAnswer: "Roman breakwaters used opus caementicium — underwater concrete made with volcanic ash (pozzolana) that hardened in seawater. No other ancient civilization had this technology. It allowed Romans to build harbors anywhere along a coast.",
        observeHint: "Look for the long curving wall that separates the calm harbor water from the open sea.",
        observeTapTarget: CGPoint(x: 0.35, y: 0.45),
        observeTapRadius: 0.18,
        engineeringAnnotations: [
            EngineeringAnnotation(label: "Underwater concrete (opus caementicium) with volcanic ash", icon: "water.waves", science: .materials),
            EngineeringAnnotation(label: "Hexagonal inner basin for 200 ships simultaneously", icon: "hexagon", science: .engineering),
            EngineeringAnnotation(label: "Lighthouse at the harbor mouth for navigation", icon: "light.beacon.max", science: .optics),
            EngineeringAnnotation(label: "Warehouses ring the dock — 33 hectares of storage", icon: "building.2", science: .architecture),
        ],
        gridPreviewHint: "Your plan shows the harbor from above: an enclosed basin with a narrow entrance, breakwaters extending into the sea, and warehouses around the dock."
    )

    // MARK: - Siege Workshop

    static let siegeWorkshopTeaching = SketchTeachingData(
        observeSketchID: 358276,
        observeQuestion: "This 1472 woodcut from De Re Militari shows Roman siege machines. Tap on the wooden frame structure that holds the throwing arm — the torsion mechanism.",
        observeAnswer: "The torsion mechanism uses twisted rope bundles (usually animal sinew or horsehair) as springs. When wound and released, they snap a wooden arm forward with enough force to throw 5 kg stones 500 meters.",
        observeHint: "Look for the wooden frame with the throwing arm attached — the main structural part of the catapult.",
        observeTapTarget: CGPoint(x: 0.50, y: 0.55),
        observeTapRadius: 0.22,
        engineeringAnnotations: [
            EngineeringAnnotation(label: "Torsion springs: twisted sinew stores and releases energy", icon: "arrow.triangle.2.circlepath", science: .physics),
            EngineeringAnnotation(label: "Cross-braced timber frame resists firing recoil", icon: "square.grid.2x2", science: .engineering),
            EngineeringAnnotation(label: "60 fabri (engineers) assigned per legion", icon: "person.3", science: .engineering),
            EngineeringAnnotation(label: "Standardized parts — siege machines were field-repairable", icon: "wrench.and.screwdriver", science: .materials),
        ],
        gridPreviewHint: "Your plan shows the workshop from above: a rectangular shed with workbenches along three walls and open floor space for assembling engines."
    )

    // MARK: - Insula

    static let insulaTeaching = SketchTeachingData(
        observeSketchID: 408021,
        observeQuestion: "Francesco Piranesi drew cross-sections of Pompeii buildings. Tap on the ground-floor arched openings — the tabernae (shops) that faced the street.",
        observeAnswer: "Ground-floor tabernae had thick stone walls and barrel-vaulted ceilings to support 4-6 stories of apartments above. These vaults transferred the building's weight to the foundation, allowing the upper floors to use lighter timber framing.",
        observeHint: "Look at the bottom level of the building — the arched openings facing the street where merchants sold their goods.",
        observeTapTarget: CGPoint(x: 0.50, y: 0.75),
        observeTapRadius: 0.18,
        engineeringAnnotations: [
            EngineeringAnnotation(label: "Stone ground floor supports 4-6 timber upper stories", icon: "square.stack.3d.up", science: .engineering),
            EngineeringAnnotation(label: "Walls get thinner at each floor — progressive loading", icon: "triangle", science: .architecture),
            EngineeringAnnotation(label: "46,000 insulae in Rome vs. only 1,800 single-family houses", icon: "building", science: .mathematics),
            EngineeringAnnotation(label: "Barrel vaults on ground floor transfer weight to foundations", icon: "archivebox", science: .engineering),
        ],
        gridPreviewHint: "Your floor plan shows one block from above: rectangular outer walls, small shop cells along the street edge, a stairwell, and a central courtyard."
    )
}
