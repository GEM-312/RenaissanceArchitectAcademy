import Foundation
import CoreGraphics

/// Teaching data for the 9 Renaissance buildings.
/// Extension on `SketchTeachingContent` — routed by the switch in SketchTeachingData.swift.
extension SketchTeachingContent {

    // MARK: - Botanical Garden

    static let botanicalGardenTeaching = SketchTeachingData(
        observeSketchID: 347243,
        observeQuestion: "This 1640 engraving shows a formal Renaissance garden. Tap on the geometric division — the cross-shaped paths that split the garden into quadrants.",
        observeAnswer: "Renaissance botanical gardens used geometry to classify nature: four quadrants represented the four humors of Galenic medicine. Each quadrant was subdivided into beds for different plant families — a living encyclopedia organized by shape.",
        observeHint: "Look for the paths that divide the garden into four equal sections, meeting at the center.",
        observeTapTarget: CGPoint(x: 0.50, y: 0.50),
        observeTapRadius: 0.20,
        engineeringAnnotations: [
            EngineeringAnnotation(label: "Four quadrants = four humors (blood, phlegm, bile, bile)", icon: "square.split.2x2", science: .biology),
            EngineeringAnnotation(label: "Geometric layout makes classification visible and walkable", icon: "grid", science: .geometry),
            EngineeringAnnotation(label: "The first botanical garden (Padua 1545) still operates today", icon: "leaf", science: .biology),
            EngineeringAnnotation(label: "Central fountain provides irrigation to all quadrants", icon: "drop.fill", science: .hydraulics),
        ],
        gridPreviewHint: "Your plan shows the garden from above: an outer boundary divided by a cross into four quadrants, each quadrant split into smaller beds."
    )

    // MARK: - Glassworks

    static let glassworksTeaching = SketchTeachingData(
        observeSketchID: 372592,
        observeQuestion: "Whistler drew the Murano glass furnace interior. Tap on the central furnace — the fiery heart of the glassworks that every workstation orbits around.",
        observeAnswer: "The glass furnace reached 1,400°C using seasoned beechwood. Crucibles of molten glass sat inside. Glassblowers worked at benches radiating outward — each station held pipes, paddles, and shaping tools. The radial layout minimized travel time from furnace to bench.",
        observeHint: "Look for the bright, glowing structure at the center of the room — all the workers face it.",
        observeTapTarget: CGPoint(x: 0.45, y: 0.50),
        observeTapRadius: 0.20,
        engineeringAnnotations: [
            EngineeringAnnotation(label: "Furnace reaches 1,400°C — thick brick walls for insulation", icon: "flame.fill", science: .chemistry),
            EngineeringAnnotation(label: "Radial workstations minimize travel from furnace to bench", icon: "circle", science: .architecture),
            EngineeringAnnotation(label: "Glassblowers were state secrets — emigration = death penalty", icon: "lock.fill", science: .materials),
            EngineeringAnnotation(label: "Silica + soda ash + lime → transparent soda-lime glass", icon: "flask.fill", science: .chemistry),
        ],
        gridPreviewHint: "Your plan shows the glassworks from above: a central circular furnace with small rectangular workbenches arranged around it, plus storage along one wall."
    )

    // MARK: - Arsenal

    static let arsenalTeaching = SketchTeachingData(
        observeSketchID: 397540,
        observeQuestion: "Carlevaris drew the gate of the Venetian Arsenal. Tap on the massive gate structure — the fortified entrance to the world's first industrial complex.",
        observeAnswer: "The Arsenal gate (1460) was the first Renaissance triumphal arch in Venice. Behind it lay 60 acres of covered shipbuilding slips, rope walks, and warehouses — 16,000 workers producing one warship per day at peak capacity.",
        observeHint: "Look at the decorated archway entrance — the grand structure you'd pass through to enter the shipyard.",
        observeTapTarget: CGPoint(x: 0.50, y: 0.55),
        observeTapRadius: 0.20,
        engineeringAnnotations: [
            EngineeringAnnotation(label: "Assembly line: 60 specialized stations, one ship per day", icon: "arrow.right.square", science: .engineering),
            EngineeringAnnotation(label: "Wide-span timber trusses — no columns blocking the slips", icon: "triangle", science: .architecture),
            EngineeringAnnotation(label: "16,000 workers — 10% of Venice's entire population", icon: "person.3.fill", science: .engineering),
            EngineeringAnnotation(label: "Standardized parts: any oar fit any galley", icon: "equal.circle", science: .materials),
        ],
        gridPreviewHint: "Your plan shows the Arsenal from above: a walled rectangle with long parallel covered slips facing a central water basin."
    )

    // MARK: - Anatomy Theater

    static let anatomyTheaterTeaching = SketchTeachingData(
        observeSketchID: 358129,
        observeQuestion: "This is the famous frontispiece from Vesalius's De Humani Corporis Fabrica (1555). Tap on the circular arrangement of spectators — the crowd pressed together around the dissection.",
        observeAnswer: "The scene shows the ideal Vesalius imagined: hundreds of observers crowded around a single body. The real Padua Anatomy Theater (1594) made this possible by stacking 6 concentric standing tiers in a funnel shape — 300 students, every one with a clear sightline.",
        observeHint: "Look at the crowd surrounding the central table — they form a ring around the demonstration.",
        observeTapTarget: CGPoint(x: 0.50, y: 0.40),
        observeTapRadius: 0.22,
        engineeringAnnotations: [
            EngineeringAnnotation(label: "Six concentric tiers narrow upward for clear sightlines", icon: "circle.circle", science: .geometry),
            EngineeringAnnotation(label: "Entirely carved walnut wood — no windows, candlelit only", icon: "lamp.desk", science: .materials),
            EngineeringAnnotation(label: "Inverted cone shape: wide at top, narrow at the table", icon: "triangle", science: .architecture),
            EngineeringAnnotation(label: "Built 1594 — Harvey studied circulation of blood here", icon: "heart.fill", science: .biology),
        ],
        gridPreviewHint: "Your plan shows the theater from above: six concentric circles (standing tiers) surrounding a small rectangular dissection table at the center."
    )

    // MARK: - Leonardo's Workshop

    static let leonardoWorkshopTeaching = SketchTeachingData(
        observeSketchID: 336656,
        observeQuestion: "This woodcut from Divina Proportione (1509) shows Leonardo's geometric studies. Tap on the complex polyhedron — a solid where geometry meets three dimensions.",
        observeAnswer: "Leonardo drew 60 illustrations of polyhedra for Luca Pacioli's book on divine proportion. His innovation was showing them as hollow skeletal frames so readers could see the internal structure — the first use of transparent technical illustration.",
        observeHint: "Look for the three-dimensional geometric solid — the multi-faced shape that Leonardo drew.",
        observeTapTarget: CGPoint(x: 0.50, y: 0.50),
        observeTapRadius: 0.22,
        engineeringAnnotations: [
            EngineeringAnnotation(label: "Bottega model: 10-15 apprentices at various stages", icon: "person.3", science: .engineering),
            EngineeringAnnotation(label: "North-facing windows for consistent, shadowless light", icon: "sun.max", science: .optics),
            EngineeringAnnotation(label: "Workshop produced paintings, sculpture, stage sets, weapons", icon: "hammer.fill", science: .materials),
            EngineeringAnnotation(label: "Only ~15 completed paintings survive from Leonardo", icon: "paintbrush.pointed", science: .architecture),
        ],
        gridPreviewHint: "Your plan shows the workshop from above: a long rectangle with drawing tables along the bright window wall and storage shelves along the opposite wall."
    )

    // MARK: - Flying Machine

    static let flyingMachineTeaching = SketchTeachingData(
        observeSketchID: 659646,
        observeQuestion: "This engraving from Nova Reperta shows inventions of the modern age. Tap on any flying or aerial element — the dream of human flight that Leonardo pursued.",
        observeAnswer: "Leonardo studied bat flight by dissecting bats and mapping their wing musculature. He correctly identified lift as the key force, but underestimated the power needed: humans produce ~75 watts, flight requires ~500 watts. He returned to gliders late in life — closer to the real solution.",
        observeHint: "Look for anything in the sky or related to aviation — a flying device or winged figure.",
        observeTapTarget: CGPoint(x: 0.50, y: 0.25),
        observeTapRadius: 0.22,
        engineeringAnnotations: [
            EngineeringAnnotation(label: "Bat-inspired wings: wooden frame + stretched silk membrane", icon: "wind", science: .physics),
            EngineeringAnnotation(label: "Human power: ~75W sustained; flight needs ~500W", icon: "bolt.fill", science: .physics),
            EngineeringAnnotation(label: "Airfoil shape: curved top, flat bottom creates lift", icon: "arrow.up", science: .engineering),
            EngineeringAnnotation(label: "Pine + bamboo frame minimizes weight while keeping strength", icon: "scalemass", science: .materials),
        ],
        gridPreviewHint: "Your plan shows the ornithopter from above: two wing shapes extending left and right from a central body harness."
    )

    // MARK: - Vatican Observatory

    static let vaticanObservatoryTeaching = SketchTeachingData(
        observeSketchID: 393278,
        observeQuestion: "Claude Mellan engraved this extraordinary lunar map in 1635 using a single continuous spiral line. Tap on the detailed surface features — craters and mountains observed through a telescope.",
        observeAnswer: "Mellan's engraving was made from direct telescopic observation at the Vatican observatory. The single-line technique (one unbroken spiral from center to edge) was both artistic tour de force and scientific illustration — showing shadow and depth through line thickness alone.",
        observeHint: "Look at the Moon's surface details — the craters, ridges, and dark regions that were only visible through a telescope.",
        observeTapTarget: CGPoint(x: 0.50, y: 0.50),
        observeTapRadius: 0.25,
        engineeringAnnotations: [
            EngineeringAnnotation(label: "Solar meridian line measured the year's length to seconds", icon: "sun.min", science: .astronomy),
            EngineeringAnnotation(label: "Gregorian calendar reform (1582) calculated here", icon: "calendar", science: .mathematics),
            EngineeringAnnotation(label: "Dome rotates to follow stars across the sky", icon: "arrow.triangle.2.circlepath", science: .engineering),
            EngineeringAnnotation(label: "Meridian slit: narrow opening aligned precisely north-south", icon: "line.diagonal", science: .optics),
        ],
        gridPreviewHint: "Your plan shows the observatory from above: a circle (the dome) with a small central square (the telescope pier) and side chambers for instruments."
    )

    // MARK: - Printing Press

    static let printingPressTeaching = SketchTeachingData(
        observeSketchID: 659683,
        observeQuestion: "This engraving from Nova Reperta shows the invention of book printing. Tap on the press mechanism itself — the wooden frame that applies pressure to paper against type.",
        observeAnswer: "Gutenberg's innovation was combining three existing technologies: the screw press (from winemaking), oil-based ink (from painting), and movable metal type (from goldsmithing). A skilled crew could print 240 pages per hour — a single monk could copy only 2-3 pages per day.",
        observeHint: "Look for the large wooden frame structure with the flat pressing surface — the heart of the printing operation.",
        observeTapTarget: CGPoint(x: 0.45, y: 0.50),
        observeTapRadius: 0.20,
        engineeringAnnotations: [
            EngineeringAnnotation(label: "Screw press borrowed from winemaking — mechanical advantage", icon: "gearshape.2", science: .engineering),
            EngineeringAnnotation(label: "Oil-based ink sticks to metal type (water-based won't)", icon: "drop.fill", science: .chemistry),
            EngineeringAnnotation(label: "Lead-tin-antimony alloy for durable, precise letterforms", icon: "text.justify.left", science: .materials),
            EngineeringAnnotation(label: "240 pages/hour vs. 2-3 pages/day by hand copying", icon: "bolt.fill", science: .physics),
        ],
        gridPreviewHint: "Your plan shows the press room from above: the rectangular type bed, the platen position above it, and the operator's work area alongside."
    )
}
