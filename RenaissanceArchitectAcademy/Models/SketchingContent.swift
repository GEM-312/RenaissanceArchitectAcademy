import Foundation

/// Static sketching challenge data per building.
///
/// AI-validated redesign (2026-04-23):
/// - `referencePlanImageName` — full orthographic blueprint (plan + elevation + section).
///   Shown in Study Mode before sketching, revealed under the canvas on Peek, and sent
///   to Claude Haiku vision for scoring the student's plan-only sketch.
///
/// Convention: imageset names are `{BuildingCamelCase}Blueprint`.
/// If the imageset is missing from Assets.xcassets, the canvas shows a "Blueprint coming soon"
/// placeholder for that building — Marina adds the art over time.
enum SketchingContent {

    static func sketchingChallenge(for buildingName: String) -> SketchingChallenge? {
        switch buildingName {
        // Rome
        case "Aqueduct":        return aqueductSketching
        case "Colosseum":       return colosseumSketching
        case "Roman Baths":     return romanBathsSketching
        case "Pantheon":        return pantheonSketching
        case "Roman Roads":     return romanRoadsSketching
        case "Harbor":          return harborSketching
        case "Siege Workshop":  return siegeWorkshopSketching
        case "Insula":          return insulaSketching
        // Renaissance
        case "Duomo", "Il Duomo":    return duomoSketching
        case "Botanical Garden":      return botanicalGardenSketching
        case "Glassworks":            return glassworksSketching
        case "Arsenal":               return arsenalSketching
        case "Anatomy Theater":       return anatomyTheaterSketching
        case "Leonardo's Workshop":   return leonardoWorkshopSketching
        case "Flying Machine":        return flyingMachineSketching
        case "Vatican Observatory":   return vaticanObservatorySketching
        case "Printing Press":        return printingPressSketching
        default:
            return nil
        }
    }

    // MARK: - Helper

    private static func pianta(
        blueprint: String,
        gridSize: Int = 12,
        hint: String?,
        educationalText: String,
        historicalContext: String
    ) -> SketchingPhaseContent {
        .pianta(PiantaPhaseData(
            gridSize: gridSize,
            hint: hint,
            educationalText: educationalText,
            historicalContext: historicalContext,
            referencePlanImageName: blueprint
        ))
    }

    // MARK: - Pantheon

    static let pantheonSketching = SketchingChallenge(
        buildingName: "Pantheon",
        introduction: "The Pantheon is one of the most perfectly preserved Roman buildings. Its rotunda is a perfect circle — the dome's diameter equals the building's interior height. Emperor Hadrian's architects used the simplest ratio in nature: 1:1.\n\nStudy the orthographic blueprint, then sketch the floor plan (pianta) of this masterpiece.",
        phases: [
            SketchingPhase(
                phaseType: .pianta,
                title: "Pianta: Floor Plan",
                introduction: "The Pantheon's rotunda is a perfect circle — the dome sits on a cylindrical drum. In front sits the iconic portico: sixteen granite columns in three rows, crowned by a triangular pediment.\n\nStudy the blueprint, then sketch the floor plan on the grid. Hold Peek to see the engineering plan through your sketch.",
                sciencesFocused: [.geometry, .mathematics, .architecture],
                phaseData: pianta(
                    blueprint: "PantheonBlueprint",
                    hint: "Circular rotunda in the center. Rectangular portico abutting it. 8 columns across the front, two more rows of 4 behind — 16 total.",
                    educationalText: "The Pantheon's dome spans 43.3 meters — the same as its height from floor to oculus. This 1:1 ratio creates a perfect sphere that could fit inside the building. The portico's sixteen granite columns were quarried in Egypt, floated down the Nile, and shipped across the Mediterranean — each weighing 60 tonnes.",
                    historicalContext: "Emperor Hadrian rebuilt the Pantheon around 126 AD. The original was built by Marcus Agrippa in 27 BC but burned down twice. The portico inscription still reads 'M·AGRIPPA·L·F·COS·TERTIVM·FECIT' — crediting Agrippa, though Hadrian designed the current building."
                )
            )
        ],
        educationalSummary: "You've designed the floor plan of one of history's most influential buildings. The Pantheon's proportional system — a perfect sphere inscribed in a cylinder — influenced architects for 2000 years, from Brunelleschi's Duomo to the US Capitol."
    )

    // MARK: - Colosseum

    static let colosseumSketching = SketchingChallenge(
        buildingName: "Colosseum",
        introduction: "The Flavian Amphitheater — the Colosseum — is an engineering marvel. Its elliptical shape was calculated using geometry to give 50,000 spectators optimal sightlines.\n\nStudy the blueprint and sketch the floor plan of this iconic arena.",
        phases: [
            SketchingPhase(
                phaseType: .pianta,
                title: "Pianta: Floor Plan",
                introduction: "The Colosseum is an ellipse: an outer wall ring, an inner arena floor, and a trap-door grid (hypogeum) beneath. Four main entrances sit at the cardinal directions.\n\nStudy the blueprint and sketch your version.",
                sciencesFocused: [.geometry, .architecture, .engineering],
                phaseData: pianta(
                    blueprint: "ColosseumBlueprint",
                    hint: "Two concentric ovals — outer wall and inner arena. Four entrance gaps at N, S, E, W.",
                    educationalText: "The Colosseum's 80 entrance arches (vomitoria) were precisely calculated so 50,000 spectators could exit in 15 minutes. Each arch was numbered — spectators received tokens with their arch number, like modern stadium tickets.",
                    historicalContext: "Construction began under Vespasian in 72 AD and was completed by his son Titus in 80 AD. The inauguration featured 100 days of games. Its real name is 'Amphitheatrum Flavium' — 'Colosseum' came from a colossal statue of Nero nearby."
                )
            )
        ],
        educationalSummary: "The Colosseum's design influenced every stadium built since. Its system of numbered entrances, tiered seating with optimal sightlines, and the hypogeum's underground machinery represent the peak of Roman engineering."
    )

    // MARK: - Aqueduct

    static let aqueductSketching = SketchingChallenge(
        buildingName: "Aqueduct",
        introduction: "Roman aqueducts carried water across valleys using precisely calculated gradients. The Pont du Gard drops just 2.5 cm per kilometer — a slope so gentle it's nearly invisible.\n\nStudy the blueprint and sketch the plan of an aqueduct section.",
        phases: [
            SketchingPhase(
                phaseType: .pianta,
                title: "Pianta: Floor Plan",
                introduction: "From above, an aqueduct is a long narrow channel on top of a row of arched piers.\n\nStudy the blueprint. Draw the channel and the pier row.",
                sciencesFocused: [.engineering, .hydraulics, .mathematics],
                phaseData: pianta(
                    blueprint: "AqueductBlueprint",
                    hint: "A long horizontal rectangle (the channel) with evenly spaced piers beneath it.",
                    educationalText: "Roman engineers achieved gradients of 1:4000 (25cm drop per kilometer). They used the chorobates — a 6-meter wooden frame with a water level — to measure this tiny slope across miles of terrain.",
                    historicalContext: "Rome had 11 major aqueducts supplying over 1 million cubic meters of water daily — more per capita than many modern cities. The Aqua Claudia ran 69 km, mostly underground, with 15 km of visible arched bridges."
                )
            )
        ],
        educationalSummary: "Roman aqueducts demonstrate that great engineering is often invisible. Gentle gradients, waterproof mortar, and settling tanks show how Roman engineers combined hydraulics, mathematics, and materials science."
    )

    // MARK: - Duomo

    static let duomoSketching = SketchingChallenge(
        buildingName: "Duomo",
        introduction: "Brunelleschi's dome for Florence Cathedral is the largest masonry dome ever built — 42 meters across, rising 114 meters from the ground. He won the commission in a 1418 competition against his rival Ghiberti.\n\nStudy the blueprint and sketch the Duomo's floor plan.",
        phases: [
            SketchingPhase(
                phaseType: .pianta,
                title: "Pianta: Floor Plan",
                introduction: "The Duomo has a cruciform (cross-shaped) plan typical of Gothic cathedrals, but Brunelleschi's octagonal dome sits at the crossing.\n\nStudy the blueprint and sketch the nave, transept, and the famous octagonal crossing.",
                sciencesFocused: [.geometry, .architecture, .physics],
                phaseData: pianta(
                    blueprint: "DuomoBlueprint",
                    hint: "A long nave running west-to-east with a cross-arm transept. At the crossing: a distinctive octagon where the dome sits.",
                    educationalText: "Brunelleschi built the dome without scaffolding — an impossible feat that required new construction techniques. He used a herringbone brick pattern that made each ring self-supporting, and a double-shell design that reduced the dome's weight by 25%.",
                    historicalContext: "The Florence Cathedral was begun in 1296 but the dome opening sat uncovered for over 100 years — no one knew how to span it. In 1418 the city held a competition with a 200-florin prize. Brunelleschi, a goldsmith by training, won with his daring double-shell design."
                )
            )
        ],
        educationalSummary: "Brunelleschi's dome proved that innovation comes from understanding both ancient wisdom and new thinking. By studying the Pantheon's concrete dome and inventing new brick techniques, he created the defining symbol of the Renaissance."
    )

    // MARK: - Roman Baths

    static let romanBathsSketching = SketchingChallenge(
        buildingName: "Roman Baths",
        introduction: "A Roman bath complex moved bathers through a carefully sequenced set of rooms: apodyterium (changing), tepidarium (warm), caldarium (hot), frigidarium (cold), with a palaestra (exercise yard) attached.\n\nStudy the blueprint and sketch the axial layout.",
        phases: [
            SketchingPhase(
                phaseType: .pianta,
                title: "Pianta: Floor Plan",
                introduction: "Bath complexes follow a symmetrical, axial plan: rooms arranged along a central spine with matching pairs on either side. Sketch the four main chambers plus the palaestra.",
                sciencesFocused: [.architecture, .hydraulics, .engineering],
                phaseData: pianta(
                    blueprint: "RomanBathsBlueprint",
                    hint: "A row of rectangular rooms along a central axis, with a large rectangular palaestra beside them.",
                    educationalText: "A typical Roman bath used a hypocaust — a raised floor with furnace-heated air circulating beneath. Hot rooms (caldaria) had the furnace directly underneath; temperature dropped progressively as you moved away.",
                    historicalContext: "The Baths of Caracalla (216 AD) served 1,600 bathers at once across a 25-hectare complex. Roman baths were free or cost a quadrans (1/64 of a denarius) — accessible to almost everyone."
                )
            )
        ],
        educationalSummary: "Roman baths were civic centers, gyms, libraries, and social clubs combined. Their axial plan and hypocaust heating became the template for public building design for two millennia."
    )

    // MARK: - Roman Roads

    static let romanRoadsSketching = SketchingChallenge(
        buildingName: "Roman Roads",
        introduction: "Roman roads were built in layers, with drainage ditches on each side and a crown (camber) to shed water. From above, a road is a long strip bordered by parallel ditches.\n\nStudy the blueprint and sketch the plan of a Roman road segment.",
        phases: [
            SketchingPhase(
                phaseType: .pianta,
                title: "Pianta: Plan View",
                introduction: "Sketch a straight road running the length of the canvas. Include the two parallel drainage ditches that flanked every major road.",
                sciencesFocused: [.engineering, .geology, .materials],
                phaseData: pianta(
                    blueprint: "RomanRoadsBlueprint",
                    hint: "Three parallel strips: ditch, road, ditch. Wider in the middle than on the sides.",
                    educationalText: "A proper Roman road had four layers: the statumen (large stones), rudus (crushed stone in mortar), nucleus (concrete), and summum dorsum (polished paving stones). Total thickness: about 1 meter.",
                    historicalContext: "At its peak the Roman road network spanned 400,000 km — roughly the distance from Earth to Moon. The phrase 'all roads lead to Rome' reflects reality: the miliarium aureum (golden milestone) in the Forum was the official origin point."
                )
            )
        ],
        educationalSummary: "Roman roads prioritized durability and drainage. Their layered construction is still the blueprint for modern highways."
    )

    // MARK: - Harbor

    static let harborSketching = SketchingChallenge(
        buildingName: "Harbor",
        introduction: "A Roman harbor combined engineered breakwaters, stepped docks, and a ring of warehouses. Rome's own Portus had a hexagonal basin dug from the soil — a massive engineering undertaking.\n\nStudy the blueprint and sketch the harbor's plan.",
        phases: [
            SketchingPhase(
                phaseType: .pianta,
                title: "Pianta: Harbor Plan",
                introduction: "Sketch an enclosed basin (the hexagonal inner port), breakwaters extending into the sea, and the ring of warehouses around the dock.",
                sciencesFocused: [.engineering, .physics, .hydraulics],
                phaseData: pianta(
                    blueprint: "HarborBlueprint",
                    hint: "A hexagonal or curved basin with a narrow entrance channel. Warehouses ring the outer edge.",
                    educationalText: "Romans invented underwater concrete (opus caementicium with volcanic ash) that set hard in seawater. They could build breakwaters anywhere along a coast — a superpower their rivals lacked.",
                    historicalContext: "Trajan's hexagonal harbor at Portus (113 AD) was 33 hectares and could hold 200 ships at once. Unloaded grain from Egypt and Africa fed Rome's 1 million residents."
                )
            )
        ],
        educationalSummary: "The Roman harbor is a masterclass in combining civil engineering with economic planning. Hydraulic concrete made it possible."
    )

    // MARK: - Siege Workshop

    static let siegeWorkshopSketching = SketchingChallenge(
        buildingName: "Siege Workshop",
        introduction: "A Roman military workshop was an open-sided shed where engineers assembled ballistae, onagers, and siege towers. Workbenches lined the walls; finished engines occupied the central floor.\n\nStudy the blueprint and sketch the workshop plan.",
        phases: [
            SketchingPhase(
                phaseType: .pianta,
                title: "Pianta: Workshop Plan",
                introduction: "Sketch a rectangular open shed with workbenches on 3 sides and central floor space for assembling the siege engines.",
                sciencesFocused: [.engineering, .physics, .mathematics],
                phaseData: pianta(
                    blueprint: "SiegeWorkshopBlueprint",
                    hint: "Rectangular shed with workbenches lining 3 walls and open central floor space.",
                    educationalText: "A legion's ballista could throw 5kg stones 500m. Onagers (mule-kickers) used torsion-twisted rope — the same principle as a catapult spring.",
                    historicalContext: "Every Roman legion had an assigned fabrica (workshop) and a corps of fabri (engineers) — typically 60 men per legion trained in woodworking, metalsmithing, and mechanical assembly."
                )
            )
        ],
        educationalSummary: "Roman siege workshops industrialized warfare 1,900 years before factories — assembly lines, standardized parts, and specialist crews."
    )

    // MARK: - Insula

    static let insulaSketching = SketchingChallenge(
        buildingName: "Insula",
        introduction: "An insula was a Roman apartment block — 3 to 7 stories of ground-floor shops (tabernae) opening onto the street and apartments (cenacula) above. A central stair or atrium served all floors.\n\nStudy the blueprint and sketch the plan.",
        phases: [
            SketchingPhase(
                phaseType: .pianta,
                title: "Pianta: Ground Floor",
                introduction: "Sketch the outer rectangular walls, the small shop spaces lining the street frontage, and the central stair/atrium.",
                sciencesFocused: [.architecture, .materials, .mathematics],
                phaseData: pianta(
                    blueprint: "InsulaBlueprint",
                    hint: "A rectangular block with small shop cells along the street edge and a stair/courtyard in the middle.",
                    educationalText: "Insulae typically measured 40m × 40m. The ground-floor tabernae had their own stone barrel vaults supporting the apartments above. Fires were common — Juvenal wrote that Romans fled 'falling tiles' constantly.",
                    historicalContext: "By 300 AD, Rome had 46,000 insulae but only 1,800 domus (single-family houses). Insulae were dense: up to 200 residents per block, paying rent quarterly."
                )
            )
        ],
        educationalSummary: "The insula is the ancestor of the modern apartment block. Stacked housing, ground-floor retail, shared stairs — all Roman."
    )

    // MARK: - Botanical Garden

    static let botanicalGardenSketching = SketchingChallenge(
        buildingName: "Botanical Garden",
        introduction: "Renaissance botanical gardens were laid out as geometric demonstrations — circles divided into quadrants, each quadrant subdivided again, each cell growing a different medicinal plant family.\n\nStudy the blueprint and sketch the garden's geometric plan.",
        phases: [
            SketchingPhase(
                phaseType: .pianta,
                title: "Pianta: Garden Plan",
                introduction: "Sketch a circular or square outer boundary divided into four quadrants, each quadrant divided into smaller beds.",
                sciencesFocused: [.biology, .geometry, .mathematics],
                phaseData: pianta(
                    blueprint: "BotanicalGardenBlueprint",
                    hint: "Outer shape divided by a cross into four quadrants; each quadrant split into smaller garden beds.",
                    educationalText: "The Padua Orto Botanico (1545) organized plants by medicinal use: the four quadrants represented the four humors of Galenic medicine — blood, phlegm, yellow bile, black bile.",
                    historicalContext: "The first university botanical garden was founded at Padua in 1545 and remains in operation today — a UNESCO site. It's the oldest continuously-functioning scientific garden in the world."
                )
            )
        ],
        educationalSummary: "Renaissance botanical gardens were living libraries. Their geometric layouts made classification visual — students walked through knowledge."
    )

    // MARK: - Glassworks

    static let glassworksSketching = SketchingChallenge(
        buildingName: "Glassworks",
        introduction: "A Venetian glass furnace was a circular brick kiln with crucibles of molten glass inside. Glassblowers worked at benches radiating outward from the furnace, each station holding pipes and shaping tools.\n\nStudy the blueprint and sketch the glassworks floor plan.",
        phases: [
            SketchingPhase(
                phaseType: .pianta,
                title: "Pianta: Floor Plan",
                introduction: "Sketch the central circular furnace with 4–6 radial workstations around it, plus raw material storage along one wall.",
                sciencesFocused: [.chemistry, .materials, .optics],
                phaseData: pianta(
                    blueprint: "GlassworksBlueprint",
                    hint: "A circle (furnace) in the center with small rectangles (benches) arranged around it.",
                    educationalText: "Venetian glass reached 1,400°C using seasoned beechwood. Murano glassmakers were legally forbidden from leaving the island — their techniques were state secrets, and emigration was punishable by death.",
                    historicalContext: "In 1291 the Republic of Venice relocated all glassmaking to the island of Murano to reduce fire risk to the city. Murano glass dominated European luxury markets for 300 years."
                )
            )
        ],
        educationalSummary: "The glassworks' radial plan optimizes for the furnace — the center of heat is the center of work. A medieval factory organized around its most valuable resource."
    )

    // MARK: - Arsenal

    static let arsenalSketching = SketchingChallenge(
        buildingName: "Arsenal",
        introduction: "The Venetian Arsenal was the world's first industrial complex — a walled shipyard where galleys were assembled on an assembly line 400 years before Henry Ford. At its peak it could launch one warship per day.\n\nStudy the blueprint and sketch the Arsenal plan.",
        phases: [
            SketchingPhase(
                phaseType: .pianta,
                title: "Pianta: Arsenal Plan",
                introduction: "Sketch the outer walls, the long parallel covered slips (where hulls were built), and the central dock basin.",
                sciencesFocused: [.engineering, .materials, .physics],
                phaseData: pianta(
                    blueprint: "ArsenalBlueprint",
                    hint: "A large walled rectangle. Inside: long narrow parallel sheds (slips) facing a central water basin.",
                    educationalText: "The Arsenal employed 16,000 workers (arsenalotti) — roughly 10% of Venice's entire population. Ships were built in 60 specialized stations: one station shaped keels, another cut planks, another caulked hulls — true assembly line.",
                    historicalContext: "Founded 1104 AD. When Henry III of France visited in 1574 he watched a fully-rigged galley launched in under an hour. Dante used the Arsenal's bubbling pitch cauldrons as the setting for one of his Inferno's circles."
                )
            )
        ],
        educationalSummary: "The Arsenal was the first factory. Industrial organization, standardized parts, specialist labor — all Venetian, 400 years before the Industrial Revolution."
    )

    // MARK: - Anatomy Theater

    static let anatomyTheaterSketching = SketchingChallenge(
        buildingName: "Anatomy Theater",
        introduction: "The Padua Anatomy Theater (1594) is a cylindrical wooden amphitheater with six concentric tiers of standing room for students looking down at a central dissection table.\n\nStudy the blueprint and sketch the theater's plan.",
        phases: [
            SketchingPhase(
                phaseType: .pianta,
                title: "Pianta: Theater Plan",
                introduction: "Sketch six concentric circles — the viewing tiers — around a central rectangular dissection table.",
                sciencesFocused: [.biology, .geometry, .architecture],
                phaseData: pianta(
                    blueprint: "AnatomyTheaterBlueprint",
                    hint: "Concentric circles (tiers of standing room) with a small rectangle at the center (the dissection table).",
                    educationalText: "The tiers narrow upward so that every viewer, no matter how high, had a clear sightline to the table. The design is funnel-shaped: 300 students could observe a single corpse.",
                    historicalContext: "Built 1594 at the University of Padua by Fabricius ab Aquapendente. His student William Harvey used this theater while studying the circulation of the blood — published 1628."
                )
            )
        ],
        educationalSummary: "The anatomy theater is pure geometry in service of observation. Concentric circles and sightlines — democratic access to knowledge built into architecture."
    )

    // MARK: - Leonardo's Workshop

    static let leonardoWorkshopSketching = SketchingChallenge(
        buildingName: "Leonardo's Workshop",
        introduction: "Leonardo's Milan workshop was a working bottega: a long room with drawing tables, mechanical models, and apprentices. Windows ran along one wall for north light; storage lined the opposite wall.\n\nStudy the blueprint and sketch the workshop layout.",
        phases: [
            SketchingPhase(
                phaseType: .pianta,
                title: "Pianta: Workshop Plan",
                introduction: "Sketch a long rectangular room. Drawing tables along the bright window wall, storage shelves and models along the opposite wall.",
                sciencesFocused: [.engineering, .materials, .architecture],
                phaseData: pianta(
                    blueprint: "LeonardoWorkshopBlueprint",
                    hint: "Long rectangle. One long wall has windows (drawing tables beneath). The other has storage.",
                    educationalText: "Leonardo's workshop operated on a patronage model: the Sforza paid, Leonardo produced. An active bottega might have 10–15 apprentices at various stages — grinding pigment, mixing gesso, copying the master's drawings, preparing panels.",
                    historicalContext: "Leonardo worked for Duke Ludovico Sforza in Milan from 1482 to 1499. His workshop produced paintings, sculpture, stage sets, weapons, canal systems, and architectural designs. Only about 15 completed paintings survive."
                )
            )
        ],
        educationalSummary: "A Renaissance bottega was half factory, half academy. Apprentices learned by doing — the modern studio inherits from this model."
    )

    // MARK: - Flying Machine

    static let flyingMachineSketching = SketchingChallenge(
        buildingName: "Flying Machine",
        introduction: "Leonardo's ornithopter was a human-powered flying machine with flapping wings, based on bat and bird anatomy. From above it's a symmetrical H-shape: wings extending left and right, harness in the middle.\n\nStudy the blueprint and sketch the machine's top view.",
        phases: [
            SketchingPhase(
                phaseType: .pianta,
                title: "Pianta: Top View",
                introduction: "Sketch the two wings extending horizontally and the pilot harness (a small rectangle) in the center.",
                sciencesFocused: [.physics, .engineering, .mathematics],
                phaseData: pianta(
                    blueprint: "FlyingMachineBlueprint",
                    hint: "Two large wing shapes (like bat wings) extending left and right from a central body.",
                    educationalText: "Leonardo correctly identified lift, but he underestimated how much power flight requires. A human can sustain ~75 watts; powered flight needs ~500 watts. He came back to the problem with gliders late in life — closer to the true solution.",
                    historicalContext: "The ornithopter drawings are in Codex Atlanticus (1490s). Leonardo studied bat flight by dissecting bats and mapping their wing musculature — centuries before aerodynamics was a science."
                )
            )
        ],
        educationalSummary: "The ornithopter is Leonardo's most famous failure — and a lesson in what science is. He was wrong about the solution but right to pursue the question."
    )

    // MARK: - Vatican Observatory

    static let vaticanObservatorySketching = SketchingChallenge(
        buildingName: "Vatican Observatory",
        introduction: "A Renaissance observatory combined a circular dome (rotatable to follow stars) with a fixed observation floor. The telescope mounted on a pier rising through the floor's center.\n\nStudy the blueprint and sketch the observatory's plan.",
        phases: [
            SketchingPhase(
                phaseType: .pianta,
                title: "Pianta: Observatory Plan",
                introduction: "Sketch the outer circle (dome), the central pier (telescope mount), and any side chambers for instruments and logbooks.",
                sciencesFocused: [.astronomy, .optics, .mathematics],
                phaseData: pianta(
                    blueprint: "VaticanObservatoryBlueprint",
                    hint: "A circle (dome) with a small central square (telescope pier).",
                    educationalText: "The Gregorian calendar reform (1582) was calculated at the Vatican's Tower of the Winds observatory. Astronomers used a solar meridian line to measure the solar year's length to within seconds.",
                    historicalContext: "The Vatican has operated astronomical observatories since 1582, when Gregory XIII reformed the calendar. Today the Vatican Observatory has a research station in Arizona — the Church still watches the sky."
                )
            )
        ],
        educationalSummary: "A Renaissance observatory is geometry made useful: circular dome, axial telescope, fixed reference lines. Instruments for measuring a universe."
    )

    // MARK: - Printing Press

    static let printingPressSketching = SketchingChallenge(
        buildingName: "Printing Press",
        introduction: "Gutenberg's press (c.1450) was a wooden frame with a moving platen that pressed paper onto an inked type bed. From above you see the bed, the platen's swing arc, and the operator's position.\n\nStudy the blueprint and sketch the press's top view.",
        phases: [
            SketchingPhase(
                phaseType: .pianta,
                title: "Pianta: Top View",
                introduction: "Sketch the type bed (rectangle with text blocks), the platen's position above it, and the operator's work area.",
                sciencesFocused: [.engineering, .chemistry, .physics],
                phaseData: pianta(
                    blueprint: "PrintingPressBlueprint",
                    hint: "A rectangular type bed with the platen directly above. Operator stations on one side.",
                    educationalText: "The press's key innovation was oil-based ink that stuck to metal type — earlier Asian block printing used water-based inks suited to wood. A skilled crew could print 240 pages per hour.",
                    historicalContext: "Gutenberg's 42-line Bible (1455) was the first major European book printed with movable type. Within 50 years, 20 million books had been printed in Europe — more than all the hand-copied books of the previous thousand years."
                )
            )
        ],
        educationalSummary: "The printing press was the internet of its age. A wooden frame and metal type changed the world by making ideas copyable at the speed of industry."
    )
}
