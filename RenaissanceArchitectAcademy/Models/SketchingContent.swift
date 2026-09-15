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

    // MARK: - Helpers

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

    private static func sezione(
        blueprint: String,
        gridSize: Int = 12,
        hint: String?,
        educationalText: String,
        historicalContext: String
    ) -> SketchingPhaseContent {
        .sezione(SezionePhaseData(
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
        introduction: "The Pantheon is one of the most perfectly preserved Roman buildings. Its rotunda is a perfect circle — the dome's diameter equals the building's interior height. Emperor Hadrian's architects used the simplest ratio in nature: 1:1.\n\nStudy the orthographic blueprint, then sketch the floor plan and cross-section of this masterpiece.",
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
            ),
            SketchingPhase(
                phaseType: .sezione,
                title: "Sezione: Cross-Section",
                introduction: "Slice the Pantheon in half and you see its genius: 6-meter-thick walls at the base taper to just 1.2 meters at the oculus. Hidden relieving arches inside the walls channel weight downward. The dome is a perfect hemisphere — its curve, wall thickness, and concrete recipe all vary with height.",
                sciencesFocused: [.engineering, .physics, .architecture],
                phaseData: sezione(
                    blueprint: "PantheonSectionBlueprint",
                    hint: "Thick walls at the base tapering upward. The dome is a hemisphere with the oculus at top. Relieving arches are hidden inside the walls.",
                    educationalText: "The Pantheon's dome uses five concrete recipes that get progressively lighter with height: heavy basalt aggregate at the base, then brick, then tufa, then pumice near the oculus. The walls contain hidden relieving arches that redirect the dome's outward thrust downward into the foundations.",
                    historicalContext: "The 8.7-meter oculus at the dome's apex removes 3% of the dome's weight while flooding the interior with a rotating column of light. Rain enters but drains through 22 nearly invisible floor drains — the floor slopes 30cm from center to edge."
                )
            )
        ],
        educationalSummary: "You've designed both the floor plan and cross-section of one of history's most influential buildings. The Pantheon's proportional system — a perfect sphere inscribed in a cylinder — influenced architects for 2000 years, from Brunelleschi's Duomo to the US Capitol."
    )

    // MARK: - Colosseum

    static let colosseumSketching = SketchingChallenge(
        buildingName: "Colosseum",
        introduction: "The Flavian Amphitheater — the Colosseum — is an engineering marvel. Its elliptical shape was calculated using geometry to give 50,000 spectators optimal sightlines.\n\nStudy the blueprint, then sketch the floor plan and cross-section of this iconic arena.",
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
            ),
            SketchingPhase(
                phaseType: .sezione,
                title: "Sezione: Cross-Section",
                introduction: "Slice the Colosseum in half and its tiered structure reveals itself: four levels of arched corridors, each using a different column order — Doric at the base, then Ionic, then Corinthian, with Corinthian pilasters at the top. Below the arena floor lies the hypogeum, a two-story underground maze of tunnels, cages, and mechanical lifts.",
                sciencesFocused: [.geometry, .architecture, .engineering],
                phaseData: sezione(
                    blueprint: "ColosseumSectionBlueprint",
                    hint: "Four levels of arched tiers rising from the ground, each level slightly smaller. Below the arena floor, draw the underground hypogeum chambers.",
                    educationalText: "Each of the four levels uses a different column order — Doric (strongest, plainest) at the bottom, Ionic in the middle, Corinthian (most decorative) at the top. This wasn't just aesthetic: the visual progression makes the building appear taller and lighter as it rises. The arches distribute weight efficiently — 100,000 cubic meters of travertine held together without mortar, using iron clamps.",
                    historicalContext: "The hypogeum contained 36 trap doors and an elaborate system of pulleys, ramps, and elevators that could raise wild animals and scenery to the arena floor in seconds. A velarium — a retractable awning operated by 1,000 sailors — could shade the entire seating area."
                )
            )
        ],
        educationalSummary: "You've designed both the floor plan and cross-section of the Colosseum. Its system of numbered entrances, tiered arched structure, optimal sightlines, and the hypogeum's underground machinery represent the peak of Roman engineering."
    )

    // MARK: - Aqueduct

    static let aqueductSketching = SketchingChallenge(
        buildingName: "Aqueduct",
        introduction: "Roman aqueducts carried water across valleys using precisely calculated gradients. The Pont du Gard drops just 2.5 cm per kilometer — a slope so gentle it's nearly invisible.\n\nStudy the blueprint, then sketch the plan and cross-section of an aqueduct section.",
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
            ),
            SketchingPhase(
                phaseType: .sezione,
                title: "Sezione: Cross-Section",
                introduction: "Slice through the aqueduct and you see the engineering: a narrow water channel (specus) perched atop one, two, or even three tiers of arches. The channel is lined with opus signinum — waterproof concrete — and the arches taper upward, each tier lighter than the one below.",
                sciencesFocused: [.engineering, .hydraulics, .mathematics],
                phaseData: sezione(
                    blueprint: "AqueductSectionBlueprint",
                    hint: "Stacked tiers of arches with the narrow specus (water channel) running across the top. The channel is lined and slightly sloped.",
                    educationalText: "The specus was lined with opus signinum, a waterproof mortar of crushed terracotta mixed into lime concrete. The channel's cross-section was typically 0.9m wide by 1.5m tall — just large enough for a worker to walk inside for maintenance.",
                    historicalContext: "The Pont du Gard near Nimes stands 49 meters tall with three tiers of arches. Its top tier carries the specus across a 275-meter valley. Built without mortar — the stones are precision-cut and held by friction and gravity alone."
                )
            )
        ],
        educationalSummary: "You've designed both the plan and cross-section of a Roman aqueduct. These structures demonstrate that great engineering is often invisible — gentle gradients, waterproof mortar, and stacked arches show how Roman engineers combined hydraulics, mathematics, and materials science."
    )

    // MARK: - Duomo

    static let duomoSketching = SketchingChallenge(
        buildingName: "Duomo",
        introduction: "Brunelleschi's dome for Florence Cathedral is the largest masonry dome ever built — 42 meters across, rising 114 meters from the ground. He won the commission in a 1418 competition against his rival Ghiberti.\n\nStudy the blueprint, then sketch the floor plan and cross-section of this masterpiece.",
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
            ),
            SketchingPhase(
                phaseType: .sezione,
                title: "Sezione: Cross-Section",
                introduction: "Slice through Brunelleschi's dome and its revolutionary engineering is revealed: two concentric shells — an inner dome and an outer dome — connected by ribs and horizontal rings. At the very top sits the lantern, and below, the octagonal drum rests on the cathedral's crossing piers.",
                sciencesFocused: [.geometry, .architecture, .physics],
                phaseData: sezione(
                    blueprint: "DuomoSectionBlueprint",
                    hint: "Two concentric dome shells (inner and outer) rising from an octagonal drum. Connecting ribs between the shells. A lantern structure crowns the top.",
                    educationalText: "The double-shell design saved 25% of the weight of a solid dome. Between the shells, eight major stone ribs and sixteen minor ribs carry the load down to the drum. Brunelleschi's herringbone brick pattern — alternating horizontal bricks with vertical ones — made each ring self-supporting during construction, eliminating the need for centering scaffolds.",
                    historicalContext: "The dome's inner shell is 2.2 meters thick and the outer shell is 0.8 meters — the gap between them contains a stairway of 463 steps to the lantern. Brunelleschi invented a new ox-driven hoist to lift 37,000 tonnes of material to heights no crane had reached before."
                )
            )
        ],
        educationalSummary: "You've designed both the floor plan and cross-section of Brunelleschi's dome. By studying the Pantheon's concrete dome and inventing new brick techniques, he created the defining symbol of the Renaissance."
    )

    // MARK: - Roman Baths

    static let romanBathsSketching = SketchingChallenge(
        buildingName: "Roman Baths",
        introduction: "A Roman bath complex moved bathers through a carefully sequenced set of rooms: apodyterium (changing), tepidarium (warm), caldarium (hot), frigidarium (cold), with a palaestra (exercise yard) attached.\n\nStudy the blueprint, then sketch the floor plan and cross-section of these thermal engineering marvels.",
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
            ),
            SketchingPhase(
                phaseType: .sezione,
                title: "Sezione: Cross-Section",
                introduction: "Cut through a Roman bath and the hidden engineering appears: barrel vaults span the frigidarium, a grand dome caps the caldarium, and beneath the floor lies the hypocaust — a forest of brick pillars (pilae) supporting a raised floor so furnace-heated air circulates underneath.",
                sciencesFocused: [.architecture, .hydraulics, .engineering],
                phaseData: sezione(
                    blueprint: "RomanBathsSectionBlueprint",
                    hint: "Barrel vaults over the main halls, a dome over the caldarium. Below the floor, draw the raised hypocaust system with small pillars supporting the floor slab.",
                    educationalText: "The hypocaust system used pilae — stacks of square brick tiles — to raise the floor 60-90cm. Furnace-heated air flowed beneath the raised floor and up through hollow walls (tubuli). The caldarium floor could reach 50 degrees Celsius — bathers wore wooden sandals.",
                    historicalContext: "The Baths of Caracalla consumed 10 tonnes of wood daily to fuel the furnaces. Aqueducts delivered 80,000 liters per day. The barrel vaults spanning the frigidarium were among the widest in the Roman world — 25 meters clear span."
                )
            )
        ],
        educationalSummary: "You've designed both the floor plan and cross-section of a Roman bath complex. Their axial plan, barrel vaults, and hypocaust heating became the template for public building design for two millennia."
    )

    // MARK: - Roman Roads

    static let romanRoadsSketching = SketchingChallenge(
        buildingName: "Roman Roads",
        introduction: "Roman roads were built in layers, with drainage ditches on each side and a crown (camber) to shed water. From above, a road is a long strip bordered by parallel ditches.\n\nStudy the blueprint, then sketch the plan and cross-section of a Roman road segment.",
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
            ),
            SketchingPhase(
                phaseType: .sezione,
                title: "Sezione: Cross-Section",
                introduction: "Slice through a Roman road and you see its four construction layers stacked like a cake: large foundation stones (statumen) at the bottom, then crushed stone in mortar (rudus), then a concrete layer (nucleus), and finally the polished paving stones on top (summa crusta). The road surface is crowned — higher in the center — so water runs off to the drainage ditches.",
                sciencesFocused: [.engineering, .geology, .materials],
                phaseData: sezione(
                    blueprint: "RomanRoadsSectionBlueprint",
                    hint: "Four distinct horizontal layers stacked from bottom to top: large stones, crushed stone, concrete, and paving slabs. The top surface curves up slightly in the center (crowned camber). Drainage ditches on both sides.",
                    educationalText: "The four layers each serve a purpose: the statumen (large stones, 25cm) provides drainage and a stable base. The rudus (crushed stone in lime mortar, 23cm) distributes load. The nucleus (fine gravel concrete, 30cm) creates a waterproof core. The summa crusta (polygonal stone slabs) provides a durable wearing surface. Total depth: about 1 meter.",
                    historicalContext: "Roman surveyors (gromatici) used a groma — a cross-shaped sighting instrument — to lay roads in perfectly straight lines. The Via Appia ran 563km from Rome to Brindisi, completed in stages from 312 BC. Sections of the original stone surface survive after 2,300 years."
                )
            )
        ],
        educationalSummary: "You've designed both the plan and cross-section of a Roman road. Their layered construction — prioritizing durability and drainage — is still the blueprint for modern highways."
    )

    // MARK: - Harbor

    static let harborSketching = SketchingChallenge(
        buildingName: "Harbor",
        introduction: "A Roman harbor combined engineered breakwaters, stepped docks, and a ring of warehouses. Rome's own Portus had a hexagonal basin dug from the soil — a massive engineering undertaking.\n\nStudy the blueprint, then sketch the harbor's plan and cross-section.",
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
            ),
            SketchingPhase(
                phaseType: .sezione,
                title: "Sezione: Cross-Section",
                introduction: "Cut through a Roman harbor and you see the breakwater's secret: massive concrete blocks poured underwater using volcanic ash (pozzolana) that sets in seawater. The breakwater tapers from a wide base to a narrow crest, and behind it, barrel-vaulted warehouses line the quay.",
                sciencesFocused: [.engineering, .physics, .hydraulics],
                phaseData: sezione(
                    blueprint: "HarborSectionBlueprint",
                    hint: "A tapered breakwater cross-section — wide at the base, narrow at the top — made of underwater concrete blocks. Behind it, barrel-vaulted warehouse structures along the dock.",
                    educationalText: "Roman marine concrete used pozzolana — volcanic ash from Pozzuoli — that reacts with seawater to form aluminum tobermorite crystals, actually growing stronger over centuries. Modern concrete degrades in seawater; Roman harbor concrete from 2,000 years ago is harder than when it was poured.",
                    historicalContext: "At Caesarea Maritima, Herod's engineers sank wooden forms into the sea, filled them with pozzolanic concrete, and waited for the mix to set underwater — creating breakwaters in deep water where no dry foundation existed. The technique was Rome's maritime superpower."
                )
            )
        ],
        educationalSummary: "You've designed both the plan and cross-section of a Roman harbor. Combining civil engineering with hydraulic concrete, these ports made Rome's maritime empire possible."
    )

    // MARK: - Siege Workshop

    static let siegeWorkshopSketching = SketchingChallenge(
        buildingName: "Siege Workshop",
        introduction: "A Roman military workshop was an open-sided shed where engineers assembled ballistae, onagers, and siege towers. Workbenches lined the walls; finished engines occupied the central floor.\n\nStudy the blueprint, then sketch the floor plan and cross-section of this military workshop.",
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
            ),
            SketchingPhase(
                phaseType: .sezione,
                title: "Sezione: Cross-Section",
                introduction: "Cut through the siege workshop and you see its timber frame: heavy vertical posts supporting a pitched roof truss with diagonal cross-bracing. The open-sided design lets large siege engines roll in and out, while the roof protects workers and materials from weather.",
                sciencesFocused: [.engineering, .physics, .mathematics],
                phaseData: sezione(
                    blueprint: "SiegeWorkshopSectionBlueprint",
                    hint: "Vertical timber posts supporting a triangular pitched roof truss. Diagonal cross-bracing between the posts. Open sides at ground level for moving siege engines.",
                    educationalText: "Roman military engineers understood the triangle as the strongest structural shape — roof trusses used triangulated timber frames that distributed load to the walls. Cross-bracing (diagonal members) prevented the frame from racking sideways under wind or impact loads.",
                    historicalContext: "Roman fabri could erect a field workshop in hours using standardized timber joinery. Vitruvius documented the truss designs in De Architectura (30 BC) — the same triangulated principles used in modern roof engineering."
                )
            )
        ],
        educationalSummary: "You've designed both the floor plan and cross-section of a Roman siege workshop. These fabricae industrialized warfare 1,900 years before factories — assembly lines, standardized parts, and specialist crews."
    )

    // MARK: - Insula

    static let insulaSketching = SketchingChallenge(
        buildingName: "Insula",
        introduction: "An insula was a Roman apartment block — 3 to 7 stories of ground-floor shops (tabernae) opening onto the street and apartments (cenacula) above. A central stair or atrium served all floors.\n\nStudy the blueprint, then sketch the floor plan and cross-section of this Roman apartment block.",
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
            ),
            SketchingPhase(
                phaseType: .sezione,
                title: "Sezione: Cross-Section",
                introduction: "Slice through a Roman insula and you see how the structure changes with height: thick stone walls and barrel-vaulted ground-floor shops at the base, transitioning to progressively thinner timber-framed upper stories. The ground floor is stone and concrete; by the fifth story, it's all wood and plaster.",
                sciencesFocused: [.architecture, .materials, .mathematics],
                phaseData: sezione(
                    blueprint: "InsulaSectionBlueprint",
                    hint: "Five to six stories tall. Thick stone walls at the base with arched ground-floor shops. Upper floors have thinner walls, transitioning from stone to timber framing. Each floor is slightly recessed from the one below.",
                    educationalText: "The progressive load-bearing system was practical engineering: stone walls 60cm thick at the base carried the entire building's weight. Each upper floor used thinner, lighter materials — by the top story, walls were 15cm timber and plaster. Augustus limited insulae to 21 meters (about 6 stories) after collapses.",
                    historicalContext: "Insulae were Rome's solution to housing 1 million people in a walled city. Ground-floor apartments with running water cost 30 times more than top-floor walkups. The poet Martial complained of climbing 200 stairs to his tiny sixth-floor room."
                )
            )
        ],
        educationalSummary: "You've designed both the floor plan and cross-section of a Roman insula. The ancestor of the modern apartment block — stacked housing, ground-floor retail, shared stairs — all Roman."
    )

    // MARK: - Botanical Garden

    static let botanicalGardenSketching = SketchingChallenge(
        buildingName: "Botanical Garden",
        introduction: "Renaissance botanical gardens were laid out as geometric demonstrations — circles divided into quadrants, each quadrant subdivided again, each cell growing a different medicinal plant family.\n\nStudy the blueprint, then sketch the garden's geometric plan and a cross-section of the greenhouse structure.",
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
            ),
            SketchingPhase(
                phaseType: .sezione,
                title: "Sezione: Cross-Section",
                introduction: "Cut through a Renaissance greenhouse and you see the elegant structure: slender iron arches supporting a glass roof that lets in maximum sunlight. The glass panels are angled to shed rain and snow, while ventilation openings at the ridge allow hot air to escape.",
                sciencesFocused: [.biology, .chemistry, .geology],
                phaseData: sezione(
                    blueprint: "BotanicalGardenSectionBlueprint",
                    hint: "Arched iron ribs supporting angled glass roof panels. Ventilation openings at the top ridge. Stone or brick base walls below the glass.",
                    educationalText: "Early greenhouses combined iron arch technology with glass panels — iron provided the strength to span wide without thick walls that would block light. The glass was angled to maximize winter sun penetration while shedding rain and snow.",
                    historicalContext: "The first heated greenhouses appeared in Padua and Leiden in the 1590s, protecting exotic specimens brought back from New World expeditions. The Padua garden's circular design influenced every botanical garden built in the next 200 years."
                )
            )
        ],
        educationalSummary: "You've designed both the garden plan and greenhouse cross-section of a Renaissance botanical garden. These living libraries made classification visual — students walked through knowledge."
    )

    // MARK: - Glassworks

    static let glassworksSketching = SketchingChallenge(
        buildingName: "Glassworks",
        introduction: "A Venetian glass furnace was a circular brick kiln with crucibles of molten glass inside. Glassblowers worked at benches radiating outward from the furnace, each station holding pipes and shaping tools.\n\nStudy the blueprint, then sketch the floor plan and cross-section of this Venetian furnace.",
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
            ),
            SketchingPhase(
                phaseType: .sezione,
                title: "Sezione: Cross-Section",
                introduction: "Slice through a Murano glassworks and you see the furnace's engineering: thick fireproof brick walls enclosing a domed combustion chamber, with a tall chimney flue drawing air upward. The crucibles of molten glass sit inside the dome, heated to 1,400 degrees by the roaring fire below.",
                sciencesFocused: [.chemistry, .materials, .optics],
                phaseData: sezione(
                    blueprint: "GlassworksSectionBlueprint",
                    hint: "Thick brick walls enclosing a domed furnace chamber. Crucibles of molten glass inside the dome. A tall chimney flue rising from the top to draw the fire upward.",
                    educationalText: "The furnace dome shape was critical: it reflected radiant heat back down onto the crucibles, creating an even temperature throughout the chamber. The chimney flue created a natural draft — hot air rising pulled fresh air in through vents at the base, feeding the fire without bellows.",
                    historicalContext: "Murano furnaces ran 24 hours a day for months — shutting down and restarting cracked the refractory bricks. Glassmakers worked in shifts, and the furnace master (maestro) held the highest-paid position on the island."
                )
            )
        ],
        educationalSummary: "You've designed both the floor plan and cross-section of a Venetian glassworks. The radial plan optimizes for the furnace — the center of heat is the center of work."
    )

    // MARK: - Arsenal

    static let arsenalSketching = SketchingChallenge(
        buildingName: "Arsenal",
        introduction: "The Venetian Arsenal was the world's first industrial complex — a walled shipyard where galleys were assembled on an assembly line 400 years before Henry Ford. At its peak it could launch one warship per day.\n\nStudy the blueprint, then sketch the floor plan and cross-section of this industrial complex.",
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
            ),
            SketchingPhase(
                phaseType: .sezione,
                title: "Sezione: Cross-Section",
                introduction: "Cut through an Arsenal shipbuilding shed and you see the engineering challenge: a wide-span roof with no interior columns, because the hull of a galley needs unobstructed floor space. The solution is a king-post timber truss — a triangulated roof frame that spans the full width.",
                sciencesFocused: [.engineering, .materials, .physics],
                phaseData: sezione(
                    blueprint: "ArsenalSectionBlueprint",
                    hint: "A wide timber king-post truss spanning the full width — a triangular frame with a central vertical post. No interior columns. The galley hull sits on the floor below.",
                    educationalText: "The king-post truss uses a central vertical timber (the king post) hanging from the ridge, with angled struts bracing it to the horizontal tie beam. This creates a rigid triangle that can span 15+ meters without interior supports — essential for fitting a 40-meter galley hull inside.",
                    historicalContext: "The Arsenal's covered slips were among the widest clear-span timber structures in medieval Europe. At its peak, the Arsenal had 60+ covered sheds, each large enough to house a galley under construction. The complex covered 45 hectares — a city within a city."
                )
            )
        ],
        educationalSummary: "You've designed both the floor plan and cross-section of the Venetian Arsenal. The first factory — industrial organization, standardized parts, and specialist labor, 400 years before the Industrial Revolution."
    )

    // MARK: - Anatomy Theater

    static let anatomyTheaterSketching = SketchingChallenge(
        buildingName: "Anatomy Theater",
        introduction: "The Padua Anatomy Theater (1594) is a cylindrical wooden amphitheater with six concentric tiers of standing room for students looking down at a central dissection table.\n\nStudy the blueprint, then sketch the floor plan and cross-section of this unique theater.",
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
            ),
            SketchingPhase(
                phaseType: .sezione,
                title: "Sezione: Cross-Section",
                introduction: "Slice through the anatomy theater vertically and its inverted cone shape is revealed: six tiers of standing galleries narrow as they descend toward the central dissection table. Each tier is cantilevered — projecting inward without columns — so every viewer has an unobstructed line of sight.",
                sciencesFocused: [.biology, .geometry, .architecture],
                phaseData: sezione(
                    blueprint: "AnatomyTheaterSectionBlueprint",
                    hint: "An inverted cone (funnel) shape: wide at the top, narrowing toward the bottom. Six cantilevered tiers step inward. A small dissection table sits at the very bottom center.",
                    educationalText: "The cantilevered tiers project inward without any supporting columns — each tier's railing doubles as the structural beam for the one above. This funnel geometry means a student on the sixth tier, 12 meters above the table, is only 3 meters horizontally from the specimen. The steep angle gives every viewer a near-vertical sightline.",
                    historicalContext: "The theater held 300 standing viewers in a room only 7.5 meters in diameter. Dissections were performed in winter (to slow decomposition) by candlelight. A trapdoor beneath the table allowed the corpse to be lowered and replaced between sessions."
                )
            )
        ],
        educationalSummary: "You've designed both the floor plan and cross-section of the Padua Anatomy Theater. Pure geometry in service of observation — concentric circles and cantilevered sightlines that gave 300 students equal access to knowledge."
    )

    // MARK: - Leonardo's Workshop

    static let leonardoWorkshopSketching = SketchingChallenge(
        buildingName: "Leonardo's Workshop",
        introduction: "Leonardo's Milan workshop was a working bottega: a long room with drawing tables, mechanical models, and apprentices. Windows ran along one wall for north light; storage lined the opposite wall.\n\nStudy the blueprint, then sketch the floor plan and cross-section of this Renaissance bottega.",
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
            ),
            SketchingPhase(
                phaseType: .sezione,
                title: "Sezione: Cross-Section",
                introduction: "Cut through Leonardo's workshop and the two spaces become clear: the main studio covered by a barrel vault — a half-cylinder of brick that spans the full width without columns — and the side laboratories under flat timber ceilings supported by heavy beams.",
                sciencesFocused: [.engineering, .materials, .architecture],
                phaseData: sezione(
                    blueprint: "LeonardoWorkshopSectionBlueprint",
                    hint: "The main studio has a curved barrel vault ceiling spanning the full width. Adjacent side rooms have flat timber beam-and-joist ceilings at a lower height.",
                    educationalText: "A barrel vault is a continuous arch extruded along a length — it pushes outward at its base (thrust), so the walls must be thick or buttressed. The flat timber ceilings of the side labs act as lean-to structures that brace the barrel vault's walls, an elegant structural symbiosis.",
                    historicalContext: "Large barrel-vaulted workshops were common in Renaissance Milan — the vault provided a grand, column-free space for painting large canvases and assembling full-scale mechanical models. Leonardo's Last Supper was painted in a barrel-vaulted refectory at Santa Maria delle Grazie."
                )
            )
        ],
        educationalSummary: "You've designed both the floor plan and cross-section of a Renaissance bottega. Half factory, half academy — apprentices learned by doing, and the modern studio inherits from this model."
    )

    // MARK: - Flying Machine

    static let flyingMachineSketching = SketchingChallenge(
        buildingName: "Flying Machine",
        introduction: "Leonardo's ornithopter was a human-powered flying machine with flapping wings, based on bat and bird anatomy. From above it's a symmetrical H-shape: wings extending left and right, harness in the middle.\n\nStudy the blueprint, then sketch the top view and wing cross-section of this flying machine.",
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
            ),
            SketchingPhase(
                phaseType: .sezione,
                title: "Sezione: Cross-Section",
                introduction: "Slice through the ornithopter's wing and you see the airfoil: a lightweight frame of willow ribs covered with starched linen, curved on top and flatter beneath — the shape that generates lift. Leonardo studied bird wings and understood that the curved upper surface forces air to travel faster, creating lower pressure above.",
                sciencesFocused: [.physics, .engineering, .mathematics],
                phaseData: sezione(
                    blueprint: "FlyingMachineSectionBlueprint",
                    hint: "A wing cross-section (airfoil shape): curved on top, flatter on the bottom. Internal willow ribs provide the frame. Linen skin stretched over the frame.",
                    educationalText: "Leonardo's wing cross-section anticipated the modern airfoil by 400 years. The curved upper surface forces air to accelerate (Bernoulli's principle), creating lower pressure above the wing than below — this pressure difference is lift. His error was believing human muscles could generate enough flapping force.",
                    historicalContext: "Leonardo filled Codex on the Flight of Birds (1505) with observations of how birds angle their wings in turns, stall in gusts, and adjust camber in flight. He proposed testing his machine from Monte Ceceri near Florence — a hill whose name means 'Swan Mountain.'"
                )
            )
        ],
        educationalSummary: "You've designed both the top view and wing cross-section of Leonardo's ornithopter. His most famous failure — and a lesson in what science is. Wrong about the solution, but right to pursue the question."
    )

    // MARK: - Vatican Observatory

    static let vaticanObservatorySketching = SketchingChallenge(
        buildingName: "Vatican Observatory",
        introduction: "A Renaissance observatory combined a circular dome (rotatable to follow stars) with a fixed observation floor. The telescope mounted on a pier rising through the floor's center.\n\nStudy the blueprint, then sketch the floor plan and cross-section of this observation tower.",
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
            ),
            SketchingPhase(
                phaseType: .sezione,
                title: "Sezione: Cross-Section",
                introduction: "Slice through the observatory tower and you see its vertical stack: a tall brick tower with thick walls, observation floors at intervals, and a rotatable dome at the top with a narrow meridian slit — an opening that can be aligned with any point on the sky's meridian arc.",
                sciencesFocused: [.astronomy, .optics, .mathematics],
                phaseData: sezione(
                    blueprint: "VaticanObservatorySectionBlueprint",
                    hint: "A tall brick tower with thick walls. Multiple floor levels inside. A dome at the top with a narrow vertical slit opening (the meridian slit). A telescope pier rises from the ground floor through all levels to the dome.",
                    educationalText: "The telescope pier is structurally independent — it rises from its own foundation through the tower floors without touching them, so that footsteps and wind vibrations in the building don't shake the instrument. The meridian slit is a narrow opening in the dome aligned north-south, letting astronomers track stars as they cross the meridian.",
                    historicalContext: "The Tower of the Winds (1580) in the Vatican used a pinhole in the south wall to project a spot of sunlight onto a meridian line on the floor — measuring the exact length of the solar year. This data drove Pope Gregory XIII's calendar reform of 1582, which corrected the Julian calendar by 10 days."
                )
            )
        ],
        educationalSummary: "You've designed both the floor plan and cross-section of a Renaissance observatory. Geometry made useful: circular dome, axial telescope, meridian slit — instruments for measuring a universe."
    )

    // MARK: - Printing Press

    static let printingPressSketching = SketchingChallenge(
        buildingName: "Printing Press",
        introduction: "Gutenberg's press (c.1450) was a wooden frame with a moving platen that pressed paper onto an inked type bed. From above you see the bed, the platen's swing arc, and the operator's position.\n\nStudy the blueprint, then sketch the top view and cross-section of this revolutionary machine.",
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
            ),
            SketchingPhase(
                phaseType: .sezione,
                title: "Sezione: Cross-Section",
                introduction: "Cut through a Gutenberg-era print shop and you see the pitched roof with dormer windows lighting the workspace, the heavy timber frame supporting the building, and at the center, the press mechanism itself — a large screw press that drives the platen down onto the inked type bed.",
                sciencesFocused: [.engineering, .chemistry, .physics],
                phaseData: sezione(
                    blueprint: "PrintingPressSectionBlueprint",
                    hint: "A pitched roof with dormers above. Timber frame structure with posts and beams. The press mechanism at center: a vertical screw driving a flat platen down onto the type bed below.",
                    educationalText: "The press mechanism adapted the wine or olive screw press — a familiar technology repurposed for precision work. The heavy timber frame absorbed the enormous force of the screw without flexing. Even pressure across the entire type bed was critical: uneven pressure meant uneven ink transfer and illegible text.",
                    historicalContext: "Gutenberg's workshop in Mainz had multiple presses, each requiring a crew of three: one to ink the type, one to position the paper, and one to pull the lever. A single press could produce 240 impressions per hour — one sheet every 15 seconds."
                )
            )
        ],
        educationalSummary: "You've designed both the top view and cross-section of Gutenberg's press. The internet of its age — a wooden frame and metal type changed the world by making ideas copyable."
    )
}
