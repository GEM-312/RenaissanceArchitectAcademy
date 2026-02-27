import Foundation

/// A single step in a building's construction sequence
struct ConstructionStep: Identifiable, Equatable {
    let id = UUID()
    let order: Int              // Correct position (1-based)
    let name: String
    let italianName: String
    let description: String     // Why this step comes here
    let science: Science        // Primary science involved
    let icon: String            // SF Symbol

    static func == (lhs: ConstructionStep, rhs: ConstructionStep) -> Bool {
        lhs.id == rhs.id
    }
}

/// Construction sequence data for a building
struct ConstructionSequence {
    let buildingName: String
    let introduction: String    // Renaissance context
    let steps: [ConstructionStep]
    let completionText: String  // What the master architect says when done
}

// MARK: - Content per Building

enum ConstructionSequenceContent {

    static func sequence(for buildingName: String) -> ConstructionSequence? {
        switch buildingName {
        case "Aqueduct":       return aqueduct
        case "Colosseum":      return colosseum
        case "Pantheon":       return pantheon
        case "Roman Baths":    return romanBaths
        case "Roman Roads":    return romanRoads
        case "Harbor":         return harbor
        case "Siege Workshop": return siegeWorkshop
        case "Insula":         return insula
        case "Duomo", "Il Duomo": return duomo
        case "Botanical Garden": return botanicalGarden
        case "Glassworks":     return glassworks
        case "Arsenal":        return arsenal
        case "Anatomy Theater": return anatomyTheater
        case "Leonardo's Workshop": return leonardoWorkshop
        case "Flying Machine": return flyingMachine
        case "Vatican Observatory": return vaticanObservatory
        case "Printing Press": return printingPress
        default: return nil
        }
    }

    // MARK: - Ancient Rome

    private static let aqueduct = ConstructionSequence(
        buildingName: "Aqueduct",
        introduction: "The Roman aqueduct is an engineering marvel — water must flow downhill across miles of terrain using only gravity. Every step must be precise.",
        steps: [
            ConstructionStep(order: 1, name: "Survey the Route", italianName: "Rilevamento del Percorso",
                description: "Engineers walk the entire route from water source to city, measuring elevation changes with a chorobates (leveling instrument). The gradient must fall exactly 1-3 meters per kilometer.",
                science: .engineering, icon: "map.fill"),
            ConstructionStep(order: 2, name: "Calculate the Gradient", italianName: "Calcolo della Pendenza",
                description: "Mathematicians compute the precise slope needed. Too steep and the water erodes the channel; too shallow and it stagnates. The ratio must be perfect.",
                science: .mathematics, icon: "function"),
            ConstructionStep(order: 3, name: "Excavate Foundations", italianName: "Scavo delle Fondazioni",
                description: "Workers dig trenches down to bedrock or stable clay. The foundation must support stone arches up to 50 meters tall. Geologists test soil bearing capacity.",
                science: .geology, icon: "mountain.2.fill"),
            ConstructionStep(order: 4, name: "Lay Stone Foundation", italianName: "Posa della Fondazione",
                description: "Massive stone blocks are set in lime mortar, creating a stable base. Roman concrete (opus caementicium) binds everything together — a chemistry of volcanic ash, lime, and water.",
                science: .chemistry, icon: "square.stack.3d.up.fill"),
            ConstructionStep(order: 5, name: "Build the Arches", italianName: "Costruzione degli Archi",
                description: "Semicircular arches rise on wooden centering (temporary support frames). Each voussoir stone is precisely cut to transfer weight downward through the arch to the piers.",
                science: .architecture, icon: "archivebox.fill"),
            ConstructionStep(order: 6, name: "Construct the Channel", italianName: "Costruzione del Canale",
                description: "The specus (water channel) is built atop the arches. It must maintain the calculated gradient perfectly — hydraulic engineers check the slope constantly.",
                science: .hydraulics, icon: "drop.fill"),
            ConstructionStep(order: 7, name: "Apply Waterproof Lining", italianName: "Impermeabilizzazione",
                description: "Opus signinum — a special waterproof plaster made from crushed terracotta mixed with lime mortar — coats the inside of the channel. Chemistry keeps every drop flowing.",
                science: .chemistry, icon: "paintbrush.fill"),
            ConstructionStep(order: 8, name: "Test the Water Flow", italianName: "Prova del Flusso",
                description: "Water is released from the source. Engineers walk the entire length, checking for leaks, flow rate, and pressure. Physics ensures the water arrives at the city fountains.",
                science: .physics, icon: "waveform.path")
        ],
        completionText: "Magnifico! You have built an aqueduct worthy of Rome itself. Water flows from mountain to city — pure engineering triumph."
    )

    private static let colosseum = ConstructionSequence(
        buildingName: "Colosseum",
        introduction: "The Flavian Amphitheatre must hold 50,000 spectators, channel their voices, and withstand earthquakes. Emperor Vespasian demands perfection.",
        steps: [
            ConstructionStep(order: 1, name: "Drain the Lake", italianName: "Drenaggio del Lago",
                description: "Nero's artificial lake must be drained and the lakebed excavated. Hydraulic engineers design drainage channels to redirect water away from the foundation site.",
                science: .hydraulics, icon: "drop.triangle.fill"),
            ConstructionStep(order: 2, name: "Pour the Foundation Ring", italianName: "Fondazione Anulare",
                description: "A massive oval ring of Roman concrete, 12 meters deep, is poured in sections. The concrete must cure properly — too fast and it cracks, too slow and the project stalls.",
                science: .chemistry, icon: "oval.fill"),
            ConstructionStep(order: 3, name: "Raise the Outer Wall", italianName: "Muro Esterno",
                description: "Four stories of travertine limestone rise 48 meters. Each level uses a different classical order: Doric, Ionic, Corinthian, and Composite — architecture encoding status.",
                science: .architecture, icon: "building.columns.fill"),
            ConstructionStep(order: 4, name: "Build the Vaulted Corridors", italianName: "Corridoi a Volta",
                description: "76 numbered entrance arches lead to an intricate network of barrel vaults. Engineers calculate load paths so each vault supports the seating above while allowing crowd flow.",
                science: .engineering, icon: "door.left.hand.open"),
            ConstructionStep(order: 5, name: "Install the Seating Tiers", italianName: "Gradinate",
                description: "Marble and stone seats are arranged in precise tiers. Mathematics determines the sight lines — every spectator must see the arena floor from any seat.",
                science: .mathematics, icon: "person.3.fill"),
            ConstructionStep(order: 6, name: "Shape the Acoustic Bowl", italianName: "Acustica dell'Arena",
                description: "The elliptical shape naturally focuses sound waves toward the audience. Acoustic engineers fine-tune surfaces — hard stone reflects sound, rough surfaces absorb echoes.",
                science: .acoustics, icon: "waveform"),
            ConstructionStep(order: 7, name: "Build the Hypogeum", italianName: "Costruzione dell'Ipogeo",
                description: "The underground level with 36 trap doors, animal cages, and mechanical lifts. Engineering creates a hidden world of pulleys and counterweights beneath the arena floor.",
                science: .engineering, icon: "gearshape.2.fill"),
            ConstructionStep(order: 8, name: "Rig the Velarium", italianName: "Montaggio del Velario",
                description: "A retractable canvas awning shades spectators. 240 wooden masts around the top support ropes controlled by sailors from the Roman navy. Physics of tension and wind load.",
                science: .physics, icon: "umbrella.fill")
        ],
        completionText: "Ave! The Colosseum stands as the greatest amphitheatre ever built. Fifty thousand voices will echo through your engineering for two millennia."
    )

    private static let pantheon = ConstructionSequence(
        buildingName: "Pantheon",
        introduction: "Emperor Hadrian's temple to all the gods demands the largest unreinforced concrete dome in history — 43.3 meters across. No one has attempted this before.",
        steps: [
            ConstructionStep(order: 1, name: "Lay the Ring Foundation", italianName: "Fondazione Anulare",
                description: "A massive circular foundation of concrete, 7.3 meters wide and 4.5 meters deep, is poured. The dome's enormous weight must be distributed evenly to prevent settling.",
                science: .engineering, icon: "circle.circle"),
            ConstructionStep(order: 2, name: "Build the Rotunda Walls", italianName: "Muri della Rotonda",
                description: "Walls 6 meters thick rise in courses, with hidden relieving arches inside to channel weight downward. Geometry determines where internal voids reduce weight without weakening.",
                science: .geometry, icon: "square.stack.fill"),
            ConstructionStep(order: 3, name: "Construct the Coffers", italianName: "Costruzione dei Cassettoni",
                description: "28 sunken panels (coffers) in 5 rings reduce dome weight by 30%. Each coffer is precisely sized using geometric ratios — larger at the bottom, smaller toward the oculus.",
                science: .geometry, icon: "rectangle.grid.2x2.fill"),
            ConstructionStep(order: 4, name: "Grade the Concrete Mix", italianName: "Gradazione del Calcestruzzo",
                description: "The concrete changes composition as the dome rises: heavy basalt aggregate at the base, lighter tufa in the middle, and volcanic pumice at the top. Materials science makes the impossible possible.",
                science: .materials, icon: "circle.hexagongrid.fill"),
            ConstructionStep(order: 5, name: "Pour the Dome in Rings", italianName: "Getto a Anelli",
                description: "The dome is poured in horizontal rings, each curing before the next is added. No centering (wooden support) is used — the concrete is self-supporting as it rises. A revolutionary technique.",
                science: .architecture, icon: "circle.dashed"),
            ConstructionStep(order: 6, name: "Open the Oculus", italianName: "Apertura dell'Oculo",
                description: "The 8.2-meter eye at the dome's apex is left open to the sky. It compresses the dome's crown ring, actually strengthening the structure. Physics of compression rings.",
                science: .physics, icon: "sun.max.fill"),
            ConstructionStep(order: 7, name: "Install the Bronze Doors", italianName: "Porte di Bronzo",
                description: "The massive entrance doors, 7 meters tall and cast in bronze, are hung on bronze pivots. Each door weighs several tons yet swings on its axis with surprising ease.",
                science: .engineering, icon: "door.sliding.left.hand.closed"),
            ConstructionStep(order: 8, name: "Finish the Marble Floor", italianName: "Pavimento in Marmo",
                description: "Geometric patterns of colored marble — porphyry, giallo antico, granite — cover the floor. The slightly convex surface slopes toward drainage channels. Beauty meets function.",
                science: .architecture, icon: "diamond.fill")
        ],
        completionText: "Divinum! The dome of the Pantheon will stand for two thousand years — the greatest feat of concrete engineering in all of history."
    )

    private static let romanBaths = ConstructionSequence(
        buildingName: "Roman Baths",
        introduction: "The thermae must heat water to three temperatures, move it through rooms, and create spaces for social gathering. Hydraulics meets chemistry meets architecture.",
        steps: [
            ConstructionStep(order: 1, name: "Build the Hypocaust", italianName: "Costruzione dell'Ipocausto",
                description: "Raised floor on brick pillars (pilae) creates a hollow space beneath. Hot air from the furnace circulates under the floors and through hollow wall tiles (tubuli).",
                science: .engineering, icon: "flame.fill"),
            ConstructionStep(order: 2, name: "Lay the Water Supply", italianName: "Approvvigionamento Idrico",
                description: "Lead and terracotta pipes connect to the aqueduct system. A castellum (distribution tank) regulates water flow to cold, warm, and hot pools separately.",
                science: .hydraulics, icon: "drop.fill"),
            ConstructionStep(order: 3, name: "Build the Furnace Room", italianName: "Costruzione del Praefurnium",
                description: "The praefurnium (furnace) is positioned downhill from the baths. Wood fuel heats air that flows under floors. Chemistry of combustion: fuel + oxygen = heat + carbon dioxide.",
                science: .chemistry, icon: "fireplace.fill"),
            ConstructionStep(order: 4, name: "Construct the Cold Room", italianName: "Costruzione del Frigidarium",
                description: "The frigidarium is the largest room with a cold plunge pool. High vaulted ceilings keep the air cool. Architecture determines room proportions for comfort.",
                science: .architecture, icon: "snowflake"),
            ConstructionStep(order: 5, name: "Build the Warm Room", italianName: "Costruzione del Tepidarium",
                description: "The tepidarium bridges hot and cold. Moderate underfloor heating creates a comfortable transition. The temperature gradient must be carefully managed.",
                science: .physics, icon: "thermometer.medium"),
            ConstructionStep(order: 6, name: "Create the Hot Room", italianName: "Costruzione del Caldarium",
                description: "The caldarium sits directly over the furnace. Thick walls retain heat, and large windows face south to capture solar warmth. Materials must withstand thermal expansion.",
                science: .materials, icon: "thermometer.sun.fill"),
            ConstructionStep(order: 7, name: "Waterproof All Pools", italianName: "Impermeabilizzazione",
                description: "Opus signinum (crushed terracotta mortar) lines every pool and water channel. This waterproof plaster prevents leaks and withstands both hot and cold temperatures.",
                science: .chemistry, icon: "paintbrush.fill"),
            ConstructionStep(order: 8, name: "Install the Drainage", italianName: "Sistema di Drenaggio",
                description: "Overflow channels and underground drains carry used water to the sewer system. Gravity-fed drainage requires precise slope calculations — hydraulics at its finest.",
                science: .hydraulics, icon: "arrow.down.to.line")
        ],
        completionText: "Splendido! Your thermae will be the heart of Roman social life — where citizens bathe, debate philosophy, and conduct business in comfort."
    )

    private static let romanRoads = ConstructionSequence(
        buildingName: "Roman Roads",
        introduction: "All roads lead to Rome — but only if they are built to last. Roman road engineering created a network that endured for centuries.",
        steps: [
            ConstructionStep(order: 1, name: "Survey and Mark the Route", italianName: "Rilevamento del Tracciato",
                description: "Roman surveyors (agrimensores) use the groma — a cross-shaped sighting instrument — to plot perfectly straight roads across the landscape.",
                science: .engineering, icon: "point.topleft.down.to.point.bottomright.curvepath.fill"),
            ConstructionStep(order: 2, name: "Clear and Excavate", italianName: "Scavo e Preparazione",
                description: "Vegetation is cleared and a trench dug to stable subsoil. The excavation depth depends on soil type — deeper in clay, shallower on rock.",
                science: .geology, icon: "shovel.fill"),
            ConstructionStep(order: 3, name: "Lay the Statumen", italianName: "Posa dello Statumen",
                description: "Large stones form the first layer (statumen), creating drainage and a stable foundation. Stone selection matters — porous stones drain, dense stones support.",
                science: .materials, icon: "rectangle.stack.fill"),
            ConstructionStep(order: 4, name: "Add the Rudus Layer", italianName: "Strato di Rudus",
                description: "Crushed stone mixed with lime mortar forms the second layer. This concrete-like material binds the foundation and distributes load evenly across the road width.",
                science: .chemistry, icon: "square.3.layers.3d.middle.filled"),
            ConstructionStep(order: 5, name: "Spread the Nucleus", italianName: "Strato del Nucleus",
                description: "Fine gravel and sand mixed with cement creates a smooth, dense third layer. Mathematics determines the cambered (curved) profile — higher in the center for drainage.",
                science: .mathematics, icon: "chart.line.uptrend.xyaxis"),
            ConstructionStep(order: 6, name: "Set the Paving Stones", italianName: "Posa del Summa Crusta",
                description: "Polygonal basalt blocks (silex) are fitted together like a jigsaw puzzle on top. Each stone is shaped to lock with its neighbors, creating an almost indestructible surface.",
                science: .engineering, icon: "rectangle.split.3x3.fill"),
            ConstructionStep(order: 7, name: "Build the Curbs and Drains", italianName: "Marciapiedi e Scarichi",
                description: "Raised curbs define the road edge, and drainage ditches run alongside. Water must flow away from the road surface to prevent erosion and frost damage.",
                science: .hydraulics, icon: "arrow.left.and.right"),
            ConstructionStep(order: 8, name: "Place the Milestones", italianName: "Pietre Miliari",
                description: "Stone columns mark every Roman mile (1,480 meters). Each milestone records the distance to Rome, the emperor who commissioned the road, and the year of construction.",
                science: .mathematics, icon: "signpost.right.fill")
        ],
        completionText: "Via completata! Your road will carry legions, merchants, and ideas across the empire. Some of these stones will still be walked upon two thousand years hence."
    )

    private static let harbor = ConstructionSequence(
        buildingName: "Harbor",
        introduction: "A great harbor must shelter ships from storms, allow easy loading of goods, and withstand the relentless power of the sea.",
        steps: [
            ConstructionStep(order: 1, name: "Study Currents and Tides", italianName: "Studio delle Correnti",
                description: "Engineers observe wave patterns, tidal ranges, and prevailing winds for months. The harbor mouth must face away from the strongest storms.",
                science: .physics, icon: "water.waves"),
            ConstructionStep(order: 2, name: "Sink the Cofferdams", italianName: "Costruzione dei Cassoni",
                description: "Wooden box structures are sunk and filled with hydraulic concrete that sets underwater. Roman pozzolanic cement (volcanic ash + lime) is one of the few materials that hardens in seawater.",
                science: .chemistry, icon: "square.dashed"),
            ConstructionStep(order: 3, name: "Build the Breakwater", italianName: "Costruzione del Molo",
                description: "Massive concrete and stone walls extend into the sea, creating a sheltered basin. Engineering must resist wave forces that can exceed 30 tons per square meter in storms.",
                science: .engineering, icon: "water.waves.and.arrow.up"),
            ConstructionStep(order: 4, name: "Dredge the Basin", italianName: "Dragaggio del Bacino",
                description: "The inner harbor is deepened to accommodate large merchant vessels. Hydraulic engineers calculate the draft depth needed for different ship classes.",
                science: .hydraulics, icon: "arrow.down.circle.fill"),
            ConstructionStep(order: 5, name: "Build the Quays", italianName: "Costruzione delle Banchine",
                description: "Stone loading platforms line the inner harbor. Each quay must support heavy cargo — grain, marble, timber. The height matches the deck level of standard merchant ships.",
                science: .engineering, icon: "shippingbox.fill"),
            ConstructionStep(order: 6, name: "Construct the Warehouses", italianName: "Costruzione dei Magazzini",
                description: "Storage buildings (horrea) with thick walls keep goods cool and dry. Architecture must balance ventilation with protection from rain and theft.",
                science: .architecture, icon: "building.fill"),
            ConstructionStep(order: 7, name: "Install the Lighthouse", italianName: "Costruzione del Faro",
                description: "A tall tower with a fire beacon guides ships at night. The height and position are calculated so the light is visible from maximum distance at sea.",
                science: .physics, icon: "light.beacon.max.fill"),
            ConstructionStep(order: 8, name: "Mark the Channel", italianName: "Segnalazione del Canale",
                description: "Stone markers and buoys define the safe passage into the harbor. Mathematics determines the minimum channel width for two ships to pass safely.",
                science: .mathematics, icon: "mappin.and.ellipse")
        ],
        completionText: "Porto completato! Ships from across the Mediterranean will find safe harbor here. Your engineering tames the sea itself."
    )

    private static let siegeWorkshop = ConstructionSequence(
        buildingName: "Siege Workshop",
        introduction: "The siege workshop must produce machines of war — catapults, battering rams, siege towers. Each device applies the laws of physics to devastating effect.",
        steps: [
            ConstructionStep(order: 1, name: "Build the Workshop Frame", italianName: "Struttura dell'Officina",
                description: "A large covered workspace with high ceilings for assembling tall siege towers. The roof truss must span the full width without interior columns blocking the work area.",
                science: .architecture, icon: "house.fill"),
            ConstructionStep(order: 2, name: "Install the Forge", italianName: "Installazione della Forgia",
                description: "A charcoal forge for heating and shaping iron fittings. Bellows increase air flow to reach the 1,100°C needed to work iron. Chemistry of metals and heat.",
                science: .chemistry, icon: "flame.fill"),
            ConstructionStep(order: 3, name: "Build the Catapult Frame", italianName: "Telaio della Catapulta",
                description: "The onager frame must be rigid yet absorb recoil. Engineers select dense hardwoods — oak or ash — that resist splitting under repeated stress.",
                science: .materials, icon: "hammer.fill"),
            ConstructionStep(order: 4, name: "Calculate Launch Angles", italianName: "Calcolo degli Angoli",
                description: "Mathematics determines the optimal launch angle (45° for maximum range). Engineers calculate projectile trajectories based on counterweight mass and arm length.",
                science: .mathematics, icon: "angle"),
            ConstructionStep(order: 5, name: "Wind the Torsion Springs", italianName: "Molle a Torsione",
                description: "Twisted sinew or horsehair rope stores enormous energy. Physics of elastic potential energy: the more twists, the more force — but too many and the bundle snaps.",
                science: .physics, icon: "tornado"),
            ConstructionStep(order: 6, name: "Assemble the Battering Ram", italianName: "Montaggio dell'Ariete",
                description: "A massive timber beam tipped with iron, suspended from a wheeled frame. Engineering determines the pendulum length for maximum impact force at the swing point.",
                science: .engineering, icon: "arrow.right.circle.fill"),
            ConstructionStep(order: 7, name: "Build the Siege Tower", italianName: "Torre d'Assedio",
                description: "A multi-story wooden tower on wheels, tall enough to match enemy walls. Each floor must support armed soldiers. Structural engineering prevents collapse during movement.",
                science: .engineering, icon: "building.2.fill"),
            ConstructionStep(order: 8, name: "Test All Machines", italianName: "Collaudo delle Macchine",
                description: "Each siege engine is tested at a practice range. Physics measurements: range, accuracy, reload time. Adjustments are made until performance meets military specifications.",
                science: .physics, icon: "target")
        ],
        completionText: "Arsenale completato! Your siege engines will breach any wall. The physics of force and motion serve the ambitions of Rome."
    )

    private static let insula = ConstructionSequence(
        buildingName: "Insula",
        introduction: "The insula — Rome's apartment building — must house hundreds of citizens on a small footprint. Rising 5-7 stories, it pushes ancient construction to its limits.",
        steps: [
            ConstructionStep(order: 1, name: "Pour Deep Foundations", italianName: "Fondazioni Profonde",
                description: "Tall buildings need deep foundations. Concrete footings extend down to stable clay or bedrock. The wider the base, the more weight the soil can support.",
                science: .engineering, icon: "square.stack.3d.down.right.fill"),
            ConstructionStep(order: 2, name: "Build Ground-Floor Shops", italianName: "Tabernae al Piano Terra",
                description: "The ground floor houses shops (tabernae) with wide openings to the street. Thick walls at the base support all floors above — architecture must balance commerce with structure.",
                science: .architecture, icon: "storefront.fill"),
            ConstructionStep(order: 3, name: "Lay the Floor Beams", italianName: "Travi del Solaio",
                description: "Timber beams span between walls to create upper floors. Mathematics determines beam spacing — too far apart and the floor sags, too close wastes expensive wood.",
                science: .mathematics, icon: "line.3.horizontal"),
            ConstructionStep(order: 4, name: "Raise the Upper Walls", italianName: "Muri Superiori",
                description: "Walls thin as they rise — 60cm at the base, 30cm at the top. Lighter brick replaces heavy stone to reduce weight. Materials science determines what each floor can bear.",
                science: .materials, icon: "rectangle.portrait.arrowtriangle.2.inward"),
            ConstructionStep(order: 5, name: "Install Water Supply", italianName: "Approvvigionamento Idrico",
                description: "Lead pipes bring water to ground-floor fountains. Upper floors rely on hand-carried water. Hydraulics determines the pressure needed to push water to each level.",
                science: .hydraulics, icon: "drop.fill"),
            ConstructionStep(order: 6, name: "Build Internal Stairs", italianName: "Scale Interne",
                description: "Narrow staircases connect all floors. Each flight must fit within the wall thickness while providing comfortable rise-to-run ratios. Geometry of spiral versus straight layouts.",
                science: .geometry, icon: "stairs"),
            ConstructionStep(order: 7, name: "Add Windows and Balconies", italianName: "Finestre e Balconi",
                description: "Wooden shutters and small balconies pierce the upper walls. Each opening weakens the wall — engineering determines maximum window width versus wall stability.",
                science: .engineering, icon: "window.vertical.open"),
            ConstructionStep(order: 8, name: "Tile the Roof", italianName: "Copertura del Tetto",
                description: "Terracotta tiles (tegulae and imbrices) overlap to shed rain. The roof pitch must balance rain drainage with wind resistance. Physics of water flow and wind load.",
                science: .physics, icon: "house.and.flag.fill")
        ],
        completionText: "Insula completata! Your apartment block will house Roman families for generations. Living stacked to the sky — the first true urban architecture."
    )

    // MARK: - Renaissance Italy

    private static let duomo = ConstructionSequence(
        buildingName: "Duomo",
        introduction: "Filippo Brunelleschi must build the largest dome since the Pantheon — 45 meters across — without centering (temporary wooden support). No one knows how.",
        steps: [
            ConstructionStep(order: 1, name: "Study the Octagonal Drum", italianName: "Studio del Tamburo",
                description: "The existing octagonal drum, built decades earlier, defines the dome's base. Brunelleschi must measure every angle precisely — geometry determines the entire dome's shape.",
                science: .geometry, icon: "octagon.fill"),
            ConstructionStep(order: 2, name: "Design the Double Shell", italianName: "Progetto della Doppia Calotta",
                description: "Two nested domes — inner and outer — connected by ribs. The air gap reduces weight while the outer shell protects from weather. Architecture's most daring innovation.",
                science: .architecture, icon: "circle.circle"),
            ConstructionStep(order: 3, name: "Invent the Lifting Machines", italianName: "Macchine di Sollevamento",
                description: "Brunelleschi designs a new ox-powered hoist with a reversible gear — materials go up without unhooking the oxen. Engineering genius solves the logistics of height.",
                science: .engineering, icon: "gearshape.2.fill"),
            ConstructionStep(order: 4, name: "Lay the Herringbone Brick", italianName: "Mattoni a Spina di Pesce",
                description: "Bricks are laid in a herringbone (spina di pesce) pattern that is self-supporting as it rises — no centering needed. Each ring of bricks locks the previous ring in place.",
                science: .physics, icon: "rectangle.grid.1x2.fill"),
            ConstructionStep(order: 5, name: "Build the Eight Ribs", italianName: "Costruzione delle Otto Costole",
                description: "Eight major stone ribs rise along the octagon's corners, transferring dome weight down to the drum. Sixteen minor ribs add intermediate support. Structural engineering at its finest.",
                science: .engineering, icon: "triangle.fill"),
            ConstructionStep(order: 6, name: "Close the Dome Rings", italianName: "Chiusura degli Anelli",
                description: "As rings rise, they lean inward more steeply. Mathematics calculates the curvature — a pointed (quinto acuto) profile rather than hemispheric, to reduce outward thrust.",
                science: .mathematics, icon: "arrow.up.to.line"),
            ConstructionStep(order: 7, name: "Set the Lantern", italianName: "Posa della Lanterna",
                description: "The marble lantern crowns the dome, its weight (800 tons) actually compressing and stabilizing the dome's crown. Physics: dead weight prevents the dome from opening at the top.",
                science: .physics, icon: "light.max"),
            ConstructionStep(order: 8, name: "Apply the Copper Ball", italianName: "Posa della Palla di Rame",
                description: "Verrocchio's gilded copper ball (palla) is hoisted 114 meters to the lantern's peak. Young Leonardo da Vinci assists and studies the lifting machines — inspiration for his own inventions.",
                science: .engineering, icon: "circle.fill")
        ],
        completionText: "Capolavoro! Brunelleschi's dome crowns Florence — the symbol of Renaissance genius. You have built what no one believed possible."
    )

    private static let botanicalGarden = ConstructionSequence(
        buildingName: "Botanical Garden",
        introduction: "The first university botanical garden (Orto Botanico di Padova, 1545) must organize living plants for scientific study — nature tamed by geometry.",
        steps: [
            ConstructionStep(order: 1, name: "Design the Circular Layout", italianName: "Progetto Circolare",
                description: "A perfect circle divided into geometric quadrants represents the world's four continents. Geometry organizes nature into a system of knowledge.",
                science: .geometry, icon: "circle.grid.cross.fill"),
            ConstructionStep(order: 2, name: "Prepare the Soil Beds", italianName: "Preparazione del Terreno",
                description: "Different soil types for different plant families — sandy for Mediterranean herbs, rich loam for flowering plants, acidic for ferns. Geology meets botany.",
                science: .geology, icon: "leaf.fill"),
            ConstructionStep(order: 3, name: "Build the Irrigation System", italianName: "Sistema di Irrigazione",
                description: "Underground channels and surface fountains deliver water to every bed. Different plants need different amounts — hydraulic design must be precise and adjustable.",
                science: .hydraulics, icon: "drop.fill"),
            ConstructionStep(order: 4, name: "Construct the Boundary Wall", italianName: "Muro di Cinta",
                description: "A circular wall protects rare plants from theft (medicinal plants were extremely valuable). Architecture must balance security with allowing sunlight and air circulation.",
                science: .architecture, icon: "circle"),
            ConstructionStep(order: 5, name: "Plant by Classification", italianName: "Classificazione Botanica",
                description: "Plants are organized by medicinal properties, family relationships, and geographic origin. Biology creates the first systematic plant classification — a garden that teaches.",
                science: .biology, icon: "tree.fill"),
            ConstructionStep(order: 6, name: "Build the Cold Houses", italianName: "Costruzione delle Serre",
                description: "Glass and wood structures protect tropical plants from frost. Chemistry of glass-making and physics of heat retention create controlled environments.",
                science: .chemistry, icon: "house.fill"),
            ConstructionStep(order: 7, name: "Install Labels and Records", italianName: "Etichettatura e Registrazione",
                description: "Each plant receives a label with Latin name, origin, and properties. This systematic recording — the first botanical database — transforms gardening into science.",
                science: .biology, icon: "tag.fill"),
            ConstructionStep(order: 8, name: "Create the Observation Path", italianName: "Percorso di Osservazione",
                description: "Paths wind through the garden in a specific educational sequence. Students walk from simple to complex plants, from local to exotic. Architecture guides learning.",
                science: .architecture, icon: "figure.walk")
        ],
        completionText: "Giardino completato! Your botanical garden transforms nature into knowledge. Students will study these living specimens for five hundred years."
    )

    private static let glassworks = ConstructionSequence(
        buildingName: "Glassworks",
        introduction: "Murano's glassworks must reach temperatures above 1,000°C and maintain them for hours. The secrets of Venetian glass are guarded on pain of death.",
        steps: [
            ConstructionStep(order: 1, name: "Build the Furnace Core", italianName: "Costruzione del Forno",
                description: "A circular furnace of fire-resistant brick must reach and hold 1,100°C. Chemistry determines which clays withstand extreme heat without cracking.",
                science: .chemistry, icon: "flame.fill"),
            ConstructionStep(order: 2, name: "Design the Three Chambers", italianName: "Progetto delle Tre Camere",
                description: "Three temperature zones: melting (1,100°C), working (900°C), annealing (500°C cooling). Engineering creates separate chambers connected by openings that regulate heat flow.",
                science: .engineering, icon: "rectangle.split.3x1.fill"),
            ConstructionStep(order: 3, name: "Mix the Glass Batch", italianName: "Preparazione della Miscela",
                description: "Silica sand + soda ash (from burnt seaweed) + lime creates the glass mixture. Adding manganese removes green tint; cobalt creates blue. Pure chemistry of transformation.",
                science: .chemistry, icon: "testtube.2"),
            ConstructionStep(order: 4, name: "Install the Crucibles", italianName: "Installazione dei Crogioli",
                description: "Clay crucibles hold the molten glass. Each must be perfectly shaped — a crack means hours of lost work and dangerous spills. Materials must withstand thermal shock.",
                science: .materials, icon: "cup.and.saucer.fill"),
            ConstructionStep(order: 5, name: "Build the Ventilation", italianName: "Sistema di Ventilazione",
                description: "Chimneys and vents control airflow to regulate furnace temperature. Physics of convection: hot air rises, drawing fresh air through lower openings to feed the fire.",
                science: .physics, icon: "wind"),
            ConstructionStep(order: 6, name: "Prepare the Blowing Area", italianName: "Area di Soffiatura",
                description: "A flat stone workspace (marver) for rolling and shaping hot glass. The height and distance from the furnace must allow the glassblower to work before the glass cools.",
                science: .engineering, icon: "circle.dotted"),
            ConstructionStep(order: 7, name: "Set Up the Annealing Oven", italianName: "Forno di Ricottura",
                description: "Finished pieces cool slowly in a separate oven over 12-24 hours. Cooling too fast creates internal stress and shattering. Optics checks: light through the glass reveals stress lines.",
                science: .optics, icon: "thermometer.snowflake"),
            ConstructionStep(order: 8, name: "Test for Cristallo Quality", italianName: "Controllo Qualità",
                description: "The finest Murano glass — cristallo — must be perfectly clear. Optics determines quality: hold the glass to candlelight and look for bubbles, streaks, or discoloration.",
                science: .optics, icon: "sparkles")
        ],
        completionText: "Fornace completata! Your glassworks will produce the finest cristallo in all of Venice. Light itself bends to your mastery of fire and sand."
    )

    private static let arsenal = ConstructionSequence(
        buildingName: "Arsenal",
        introduction: "The Arsenale di Venezia is the world's first factory — assembly-line shipbuilding that can produce one warship per day. Industrial engineering before its time.",
        steps: [
            ConstructionStep(order: 1, name: "Dig the Wet Docks", italianName: "Scavo dei Bacini",
                description: "Deep basins connected to the lagoon allow ships to be built floating. Hydraulic gates control water levels for launching. Engineering tames the sea.",
                science: .engineering, icon: "water.waves"),
            ConstructionStep(order: 2, name: "Build the Rope Walk", italianName: "Costruzione della Corderia",
                description: "A 316-meter-long covered hall for spinning hemp into ship rope. The extreme length allows full-length rope to be twisted without splicing. Physics of tension and torsion.",
                science: .physics, icon: "line.diagonal"),
            ConstructionStep(order: 3, name: "Lay the Keel Blocks", italianName: "Blocchi di Chiglia",
                description: "Stone blocks support ship keels at precise heights. Mathematics determines the block spacing for even weight distribution along the hull during construction.",
                science: .mathematics, icon: "rectangle.bottomhalf.filled"),
            ConstructionStep(order: 4, name: "Set Up the Assembly Line", italianName: "Linea di Montaggio",
                description: "Hulls move past specialized stations: ribs → planking → caulking → masting. Each station has dedicated craftsmen. Engineering organizes 16,000 workers into efficient workflow.",
                science: .engineering, icon: "arrow.right.arrow.left"),
            ConstructionStep(order: 5, name: "Build the Timber Stores", italianName: "Depositi di Legname",
                description: "Oak, larch, and elm are stored in vast warehouses for seasoning. Wood must dry for 2-3 years before use — green timber warps and weakens. Materials science of wood grain.",
                science: .materials, icon: "shippingbox.fill"),
            ConstructionStep(order: 6, name: "Construct the Forge", italianName: "Costruzione della Forgia",
                description: "Multiple forges produce iron fittings: nails, anchors, chain links. Chemistry of iron smelting and tempering — heating to orange-red, then quenching in water for hardness.",
                science: .chemistry, icon: "hammer.fill"),
            ConstructionStep(order: 7, name: "Install the Sail Lofts", italianName: "Veleria",
                description: "Large open rooms where canvas sails are cut and sewn. Mathematics calculates sail area for different ship classes — too much sail in strong wind capsizes the vessel.",
                science: .mathematics, icon: "wind"),
            ConstructionStep(order: 8, name: "Launch and Sea Trial", italianName: "Varo e Collaudo",
                description: "The completed galley slides down greased rails into the lagoon. Physics of buoyancy: the hull must displace enough water to support its full weight plus cargo and crew.",
                science: .physics, icon: "sailboat.fill")
        ],
        completionText: "Arsenale completato! Venice's war fleet rises from your shipyard. One galley per day — an industrial miracle that defends the Republic."
    )

    private static let anatomyTheater = ConstructionSequence(
        buildingName: "Anatomy Theater",
        introduction: "The Teatro Anatomico of Padua (1594) must allow 300 students to observe dissections from every angle. Architecture serves the revolution in medical science.",
        steps: [
            ConstructionStep(order: 1, name: "Design the Funnel Shape", italianName: "Progetto a Imbuto",
                description: "Six concentric elliptical tiers rise steeply around a tiny central table. The funnel shape ensures every student has a clear sightline to the dissection. Geometry of visibility.",
                science: .geometry, icon: "triangle.fill"),
            ConstructionStep(order: 2, name: "Calculate the Sight Lines", italianName: "Calcolo delle Visuali",
                description: "Each tier must be high enough to see over the heads below. Mathematics determines the exact step height and angle — similar to theater seating but far steeper.",
                science: .mathematics, icon: "eye.fill"),
            ConstructionStep(order: 3, name: "Build the Wooden Structure", italianName: "Struttura in Legno",
                description: "Walnut wood forms the railings and tier supports. The structure must support 300 standing students without swaying — engineering of cantilevers and load distribution.",
                science: .engineering, icon: "square.stack.3d.up.fill"),
            ConstructionStep(order: 4, name: "Install the Central Table", italianName: "Tavolo Centrale",
                description: "A rotating wooden table allows the anatomist to turn the specimen for different views. The mechanism must be smooth and stable — engineering of bearings and pivots.",
                science: .engineering, icon: "arrow.triangle.2.circlepath"),
            ConstructionStep(order: 5, name: "Design the Lighting", italianName: "Progetto dell'Illuminazione",
                description: "Candelabra ring the tiers, but the central table needs the most light. Optics determines candle placement to minimize shadows on the dissection surface.",
                science: .optics, icon: "light.max"),
            ConstructionStep(order: 6, name: "Build the Ventilation", italianName: "Sistema di Ventilazione",
                description: "Fresh air must circulate to manage odors from preserved specimens. Physics of air flow: warm air rises through the funnel shape, drawing fresh air from below.",
                science: .physics, icon: "wind"),
            ConstructionStep(order: 7, name: "Create the Preparation Room", italianName: "Sala di Preparazione",
                description: "A separate room below the theater for preserving and preparing specimens. Chemistry of preservation: salt, vinegar, and later formaldehyde extend specimen life.",
                science: .chemistry, icon: "cross.case.fill"),
            ConstructionStep(order: 8, name: "Carve the Decorations", italianName: "Decorazioni Intagliate",
                description: "Carved figures of famous anatomists and Apollo (god of healing) adorn the railings. Biology is celebrated as art — every surface teaches and inspires.",
                science: .biology, icon: "person.bust.fill")
        ],
        completionText: "Teatro completato! Your anatomy theater will revolutionize medical education. Andreas Vesalius himself would approve — science illuminated by architecture."
    )

    private static let leonardoWorkshop = ConstructionSequence(
        buildingName: "Leonardo's Workshop",
        introduction: "Leonardo da Vinci's bottega is both studio and laboratory — where art, science, and invention merge. The universal genius needs a universal workspace.",
        steps: [
            ConstructionStep(order: 1, name: "Find the Right Light", italianName: "Studio della Luce",
                description: "North-facing windows provide consistent, shadow-free light for painting. Leonardo insists on studying how light falls on surfaces — optics informs every brushstroke.",
                science: .optics, icon: "sun.max.fill"),
            ConstructionStep(order: 2, name: "Build the Drawing Tables", italianName: "Tavoli da Disegno",
                description: "Large angled tables for architectural drawings and anatomical studies. The surface must be perfectly flat and smooth — engineering precision for precise drafting.",
                science: .engineering, icon: "pencil.and.ruler.fill"),
            ConstructionStep(order: 3, name: "Set Up the Forge", italianName: "Installazione della Forgia",
                description: "A small forge for metalwork — gears, springs, and mechanical prototypes. Leonardo's machines require precisely shaped metal parts. Chemistry of bronze alloys and tempering.",
                science: .chemistry, icon: "flame.fill"),
            ConstructionStep(order: 4, name: "Create the Mirror Room", italianName: "Stanza degli Specchi",
                description: "Mirrors allow Leonardo to study reversed writing and check paintings for errors. A mirror reveals flaws invisible to the accustomed eye. Physics of reflection.",
                science: .physics, icon: "rectangle.portrait.on.rectangle.portrait.fill"),
            ConstructionStep(order: 5, name: "Build the Model Bench", italianName: "Banco dei Modelli",
                description: "A sturdy workbench with vises, clamps, and measuring tools for building scale models of his inventions. Engineering: every machine is tested at small scale before full construction.",
                science: .engineering, icon: "wrench.and.screwdriver.fill"),
            ConstructionStep(order: 6, name: "Install the Water Tank", italianName: "Vasca dell'Acqua",
                description: "A glass-sided tank for studying water flow, vortices, and hydraulic principles. Leonardo's water studies fill thousands of notebook pages. Hydraulics made visible.",
                science: .hydraulics, icon: "drop.fill"),
            ConstructionStep(order: 7, name: "Organize the Library", italianName: "Organizzazione della Biblioteca",
                description: "Shelves for books on mathematics, anatomy, architecture, and natural philosophy. Leonardo reads Euclid, Vitruvius, and Alberti. Knowledge organized becomes knowledge multiplied.",
                science: .mathematics, icon: "books.vertical.fill"),
            ConstructionStep(order: 8, name: "Prepare the Paint Studio", italianName: "Studio di Pittura",
                description: "Mortar and pestle for grinding pigments, linseed oil for binding, wooden panels for painting. Leonardo experiments with new materials — including the fragile sfumato technique.",
                science: .materials, icon: "paintpalette.fill")
        ],
        completionText: "Bottega completata! Leonardo's workshop stands ready for the master. Here, the boundaries between art and science dissolve entirely."
    )

    private static let flyingMachine = ConstructionSequence(
        buildingName: "Flying Machine",
        introduction: "Leonardo dreams of human flight. His ornithopter must mimic bird wings — but the physics of lift, drag, and thrust must all be solved first.",
        steps: [
            ConstructionStep(order: 1, name: "Study Bird Flight", italianName: "Studio del Volo degli Uccelli",
                description: "Leonardo spends years observing birds — how they soar, bank, and land. He fills notebooks with wing mechanics. Biology reveals the secrets of natural flight.",
                science: .physics, icon: "bird.fill"),
            ConstructionStep(order: 2, name: "Calculate Wing Area", italianName: "Calcolo dell'Apertura Alare",
                description: "A human weighing 75 kg needs enormous wing surface area to generate sufficient lift. Mathematics determines the ratio of body weight to wing span required.",
                science: .mathematics, icon: "ruler.fill"),
            ConstructionStep(order: 3, name: "Design the Wing Frame", italianName: "Struttura dell'Ala",
                description: "Lightweight wooden ribs covered in starched linen form the wing. The frame must flex like a bird's wing — rigid enough to hold shape, flexible enough to change angle.",
                science: .engineering, icon: "wind"),
            ConstructionStep(order: 4, name: "Build the Harness", italianName: "Costruzione dell'Imbracatura",
                description: "The pilot lies prone in a wooden frame, operating the wings with hands, feet, and body movements. Engineering distributes the pilot's effort across all wing surfaces.",
                science: .engineering, icon: "figure.arms.open"),
            ConstructionStep(order: 5, name: "Test the Flapping Mechanism", italianName: "Meccanismo di Battito",
                description: "Pulleys, cranks, and ropes translate human muscle power into wing flaps. Physics reveals the problem: human muscles produce only 1/10 the power-to-weight ratio of birds.",
                science: .physics, icon: "gearshape.fill"),
            ConstructionStep(order: 6, name: "Add the Tail Rudder", italianName: "Timone di Coda",
                description: "A moveable tail surface for steering and stability. Leonardo observes that birds use their tails to turn and brake. Geometry of control surfaces and angles.",
                science: .geometry, icon: "arrow.up.and.down.and.arrow.left.and.right"),
            ConstructionStep(order: 7, name: "Select the Launch Site", italianName: "Scelta del Punto di Lancio",
                description: "Monte Ceceri near Florence provides height for gliding. A hillside launch gives initial speed without needing to generate thrust. Physics of potential energy conversion.",
                science: .physics, icon: "mountain.2.fill"),
            ConstructionStep(order: 8, name: "Test Flight Attempt", italianName: "Tentativo di Volo",
                description: "The machine is launched from the hilltop. Though powered flight fails, the glide reveals crucial aerodynamic data. Leonardo's notes will inspire aviation 400 years later.",
                science: .physics, icon: "airplane")
        ],
        completionText: "Macchina completata! Though the dream of powered flight must wait for the engine, your studies of aerodynamics will echo through centuries of invention."
    )

    private static let vaticanObservatory = ConstructionSequence(
        buildingName: "Vatican Observatory",
        introduction: "The Vatican must peer deeper into the heavens than ever before. Galileo's telescope has changed everything — now the Church must build a proper observatory.",
        steps: [
            ConstructionStep(order: 1, name: "Choose the Tower Site", italianName: "Scelta della Torre",
                description: "The highest point with unobstructed views of the sky in all directions. Astronomy requires dark skies, minimal vibration, and stable air — site selection is critical.",
                science: .astronomy, icon: "star.fill"),
            ConstructionStep(order: 2, name: "Build the Observation Tower", italianName: "Costruzione della Torre",
                description: "A tall stone tower with thick walls to dampen wind vibration. The dome rotates on iron rollers to point the telescope at any part of the sky. Engineering of precision rotation.",
                science: .engineering, icon: "building.columns.fill"),
            ConstructionStep(order: 3, name: "Grind the Telescope Lenses", italianName: "Levigatura delle Lenti",
                description: "Glass lenses must be ground to precise curvatures — a parabolic shape focuses light to a single point. Optics: even a tiny imperfection blurs distant stars.",
                science: .optics, icon: "circle.dashed"),
            ConstructionStep(order: 4, name: "Mount the Telescope Tube", italianName: "Montaggio del Tubo",
                description: "A long brass tube holds the lenses at exactly the right focal distance. Mathematics calculates the focal length needed for different magnifications.",
                science: .mathematics, icon: "scope"),
            ConstructionStep(order: 5, name: "Install the Meridian Line", italianName: "Linea del Meridiano",
                description: "A brass line set into the floor marks the local meridian. When the sun crosses it at noon, astronomers calibrate their clocks. Astronomy meets precision engineering.",
                science: .astronomy, icon: "line.diagonal"),
            ConstructionStep(order: 6, name: "Build the Clock Mechanism", italianName: "Meccanismo dell'Orologio",
                description: "A pendulum clock tracks sidereal time (star time). Physics of harmonic motion: the pendulum's period depends only on its length, not the arc of swing.",
                science: .physics, icon: "clock.fill"),
            ConstructionStep(order: 7, name: "Create the Star Charts", italianName: "Carte Stellari",
                description: "Mapping star positions requires precise angular measurements and mathematical coordinate systems. Each star's position is recorded in right ascension and declination.",
                science: .mathematics, icon: "sparkles"),
            ConstructionStep(order: 8, name: "First Night of Observation", italianName: "Prima Notte di Osservazione",
                description: "The dome opens, the telescope points to Jupiter. Four tiny moons orbit the giant planet — Galileo's discovery confirmed. The universe is larger than anyone imagined.",
                science: .astronomy, icon: "moon.stars.fill")
        ],
        completionText: "Osservatorio completato! The heavens reveal their secrets to patient observation. Your observatory will map the cosmos for generations of astronomers."
    )

    private static let printingPress = ConstructionSequence(
        buildingName: "Printing Press",
        introduction: "Gutenberg's invention reaches Italy. The printing press will multiply knowledge — but building one requires mastery of metallurgy, chemistry, and precision engineering.",
        steps: [
            ConstructionStep(order: 1, name: "Build the Press Frame", italianName: "Telaio del Torchio",
                description: "A massive oak frame must withstand enormous downward pressure without flexing. Engineering of the screw press: a large screw converts rotational force into crushing pressure.",
                science: .engineering, icon: "square.split.1x2.fill"),
            ConstructionStep(order: 2, name: "Cast the Type Molds", italianName: "Fusione dei Caratteri",
                description: "Each letter is carved in reverse into a steel punch, struck into a copper matrix, then cast in lead alloy. Chemistry of type metal: lead + tin + antimony for sharp, durable characters.",
                science: .chemistry, icon: "textformat"),
            ConstructionStep(order: 3, name: "Build the Type Cases", italianName: "Casse dei Caratteri",
                description: "Wooden cases with compartments for every letter, number, and punctuation mark. 'Upper case' (capitals) goes in the top case, 'lower case' (small letters) below — names we still use today.",
                science: .engineering, icon: "rectangle.split.3x3.fill"),
            ConstructionStep(order: 4, name: "Prepare the Ink", italianName: "Preparazione dell'Inchiostro",
                description: "Printing ink must be thick and sticky — not watery like writing ink. Lampblack (soot) mixed with linseed oil and varnish creates ink that transfers cleanly. Pure chemistry.",
                science: .chemistry, icon: "drop.fill"),
            ConstructionStep(order: 5, name: "Build the Ink Balls", italianName: "Costruzione dei Tamponi",
                description: "Leather-covered pads on wooden handles spread ink evenly across type. The leather must be supple but not absorbent. Materials science determines the right animal hide.",
                science: .materials, icon: "circle.fill"),
            ConstructionStep(order: 6, name: "Set Up the Paper Supply", italianName: "Approvvigionamento della Carta",
                description: "Paper must be dampened before printing — dry paper doesn't accept ink well. Physics of capillary action: water drawn into paper fibers makes them swell and grip the ink.",
                science: .physics, icon: "doc.fill"),
            ConstructionStep(order: 7, name: "Compose a Test Page", italianName: "Composizione di Prova",
                description: "Individual lead letters are arranged in a composing stick, line by line, to form a page of text. Each line must be justified (evenly spaced) — mathematics of word spacing.",
                science: .mathematics, icon: "text.justify.leading"),
            ConstructionStep(order: 8, name: "Pull the First Print", italianName: "Prima Stampa",
                description: "The type is inked, paper placed, and the screw driven down. When the paper lifts — crisp, clear text. Every subsequent copy is identical. Knowledge is now infinitely reproducible.",
                science: .engineering, icon: "printer.fill")
        ],
        completionText: "Stamperia completata! Your press will spread knowledge like wildfire. What once took monks months to copy, you produce in hours. The Renaissance of ideas begins here."
    )
}
