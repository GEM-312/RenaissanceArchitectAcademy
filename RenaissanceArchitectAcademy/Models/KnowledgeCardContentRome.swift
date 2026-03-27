import SwiftUI

// MARK: - Knowledge Card Content — Ancient Rome Buildings (7 buildings, ~85 cards)
// Writing style: Morgan Housel — story-driven, surprising, punchy (~60-80 words per card).
// Each building's cards teach unique facts at each station — NO duplicate material teaching across buildings.
// Level: Apprentice

extension KnowledgeCardContent {

    // MARK: - Aqueduct (12 cards)

    static var aqueductCards: [KnowledgeCard] {
        let bid = 1
        let name = "Aqueduct"
        return [
            // ── CITY MAP (5 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_cityMap_building_0",
                buildingId: bid, buildingName: name,
                science: .architecture,
                environment: .cityMap, stationKey: "building",
                title: "The Aqua Claudia",
                italianTitle: "Acquedotto Claudio",
                icon: "drop.fill",
                lessonText: "The Aqua Claudia stretched 69 kilometers from mountain springs to Rome. Only 16 km ran on arches — the rest traveled underground through tunnels cut into rock. Emperor Claudius spent 14 years building it. The water arrived so pure that Romans drank it unboiled. The longest engineering project of the ancient world, and 85% of it was invisible.",
                keywords: [
                    KeywordPair(keyword: "Aqua Claudia", definition: "69 km aqueduct built by Emperor Claudius"),
                    KeywordPair(keyword: "16 km", definition: "Length running on visible arches"),
                    KeywordPair(keyword: "14 years", definition: "Construction time for the Aqua Claudia"),
                    KeywordPair(keyword: "Underground", definition: "85% of the aqueduct was hidden in tunnels"),
                ],
                activity: .numberFishing(question: "How many km long was the Aqua Claudia?", correctAnswer: 69, decoys: [32, 45, 83, 100, 120]),
                notebookSummary: "Aqua Claudia: 69 km from springs to Rome, 14 years to build. Only 16 km on arches — 85% underground.",
                visual: CardVisual(
                    type: .crossSection,
                    title: "69 km — Mostly Underground",
                    values: ["depth": 69, "width": 16],
                    labels: ["Underground tunnel (85%)", "Above ground on arches (16 km)", "Mountain springs (source)", "Rome (destination)"],
                    steps: 4, caption: "The longest engineering project of the ancient world — 85% invisible"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_1",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .cityMap, stationKey: "building",
                title: "Step 1: The Chorobates",
                italianTitle: "Il Corobate",
                icon: "level.fill",
                lessonText: "Before laying a single stone, Roman surveyors used a chorobates — a 6-meter wooden beam with a water channel carved along the top. If the water sat perfectly level, the ground was flat. Over 69 km, the aqueduct dropped just 14 meters. That's a gradient of 1:4800 — a marble dropped on the floor rolls faster. Engineering this precise changed civilization.",
                keywords: [
                    KeywordPair(keyword: "Chorobates", definition: "6-meter leveling beam with water channel"),
                    KeywordPair(keyword: "1:4800", definition: "Gradient — 14 m drop over 69 km"),
                    KeywordPair(keyword: "Surveying", definition: "Measuring ground level before construction"),
                ],
                activity: .wordScramble(word: "CHOROBATES", hint: "Roman leveling tool with a water channel on top"),
                notebookSummary: "Chorobates: 6m leveling beam with water channel. Aqua Claudia gradient: 1:4800 (14m drop over 69 km).",
                visual: CardVisual(
                    type: .geometry,
                    title: "The Chorobates — 6m Leveling Beam",
                    values: ["beam": 1, "length": 6, "height": 0.2],
                    labels: ["Water channel on top shows level", "If water is flat → ground is flat"],
                    steps: 3, caption: "1:4800 gradient — a marble on the floor rolls faster"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_2",
                buildingId: bid, buildingName: name,
                science: .mathematics,
                environment: .cityMap, stationKey: "building",
                title: "Step 2: Gradient Math",
                italianTitle: "Matematica del Gradiente",
                icon: "arrow.down.right",
                lessonText: "Water doesn't flow without gravity. The aqueduct needed a precise downhill slope — too steep and water erodes the channel, too gentle and it stagnates. Romans calculated 34 cm drop per kilometer. That's 1:4800. They had no calculators, no satellites. Just a chorobates, string lines, and patience measured in years. Math isn't abstract when a million people need drinking water.",
                keywords: [
                    KeywordPair(keyword: "34 cm/km", definition: "Ideal gradient for aqueduct water flow"),
                    KeywordPair(keyword: "Gravity flow", definition: "Water moves downhill without pumps"),
                    KeywordPair(keyword: "Erosion", definition: "Too steep a gradient wears away the channel"),
                    KeywordPair(keyword: "Stagnation", definition: "Too gentle a gradient stops water movement"),
                ],
                activity: .trueFalse(statement: "The Aqua Claudia dropped 34 cm per kilometer — a gradient of about 1:4800", isTrue: true),
                notebookSummary: "Aqueduct gradient: 34 cm/km (1:4800). Too steep = erosion. Too gentle = stagnation. Gravity does all the work.",
                visual: CardVisual(
                    type: .comparison,
                    title: "Finding the Right Gradient",
                    values: ["equal": 0],
                    labels: ["Too steep\nWater erodes\nthe channel", "Too gentle\nWater stagnates\nand stops", "34 cm drop per kilometer (1:4800) — gravity does all the work"],
                    steps: 3, caption: "No pumps, no engines — just precise math over 69 km"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_3",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .cityMap, stationKey: "building",
                title: "Step 5: Arches & Voussoirs",
                italianTitle: "Archi e Conci",
                icon: "archivebox.fill",
                lessonText: "Where the aqueduct crossed valleys, Romans stacked arches three tiers high — 30 meters tall. Each arch is built from wedge-shaped stones called voussoirs. The keystone at the top locks everything together through compression. Remove it and the arch collapses. Every stone pushes against its neighbor. The arch is strong precisely because it wants to fall apart.",
                keywords: [
                    KeywordPair(keyword: "Voussoir", definition: "Wedge-shaped stone forming an arch"),
                    KeywordPair(keyword: "Keystone", definition: "Top stone that locks the arch together"),
                    KeywordPair(keyword: "Compression", definition: "Stones pushing inward against each other"),
                    KeywordPair(keyword: "30 meters", definition: "Height of triple-tiered aqueduct arches"),
                ],
                activity: .hangman(word: "VOUSSOIR", hint: "Wedge-shaped stone that forms an arch"),
                notebookSummary: "Aqueduct arches: 3 tiers, 30m tall. Voussoir wedge stones + keystone hold through compression. Strong because it wants to fall.",
                visual: CardVisual(
                    type: .force,
                    title: "Arch with Voussoirs + Keystone",
                    values: ["arch": 1, "height": 30, "tiers": 3],
                    labels: ["Wedge-shaped voussoirs", "Keystone locks the top", "Compression: every stone pushes against its neighbor"],
                    steps: 3, caption: "Strong precisely because it wants to fall apart"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_4",
                buildingId: bid, buildingName: name,
                science: .hydraulics,
                environment: .cityMap, stationKey: "building",
                title: "Step 6: The Specus",
                italianTitle: "Lo Speco",
                icon: "rectangle.and.arrow.up.right.and.arrow.down.left",
                lessonText: "Inside every aqueduct runs the specus — a rectangular channel lined with waterproof opus signinum cement. Typically 0.9 meters wide and 1.5 meters tall. Settling tanks filtered sediment every few kilometers. Distribution castella at the city end split water three ways: public fountains, baths, and private homes — in that priority order. If water ran low, homes lost supply first.",
                keywords: [
                    KeywordPair(keyword: "Specus", definition: "Waterproof channel inside the aqueduct"),
                    KeywordPair(keyword: "Opus signinum", definition: "Waterproof cement lining the channel"),
                    KeywordPair(keyword: "Castellum", definition: "Distribution tank splitting water three ways"),
                    KeywordPair(keyword: "Settling tank", definition: "Filters sediment from flowing water"),
                ],
                activity: .wordScramble(word: "SPECUS", hint: "The water channel inside the aqueduct"),
                notebookSummary: "Specus: waterproof channel (0.9m × 1.5m) lined with opus signinum. Castellum distributes water: fountains → baths → homes.",
                visual: CardVisual(
                    type: .crossSection,
                    title: "Specus Channel Cross-Section",
                    values: ["depth": 1.5, "width": 0.9],
                    labels: ["Opus signinum lining", "Water channel", "0.9m wide × 1.5m tall", "Waterproof cement"],
                    steps: 4, caption: "Distribution: public fountains → baths → private homes (that priority order)"
                )
            ),

            // ── WORKSHOP (4 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_workshop_quarry_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "quarry",
                title: "Step 4: Mortar vs Concrete",
                italianTitle: "Malta contro Calcestruzzo",
                icon: "mountain.2.fill",
                lessonText: "Here's the difference: mortar is the glue between stones — lime paste mixed with sand. Concrete is the stone itself — lime, volcanic ash, water, and aggregate chunks. Mortar holds; concrete fills. For the aqueduct, mortar bonds the voussoir arch stones together. Concrete fills the massive pier foundations. Same lime, different jobs. Understanding binders is how you choose the right recipe.",
                keywords: [
                    KeywordPair(keyword: "Mortar", definition: "Lime + sand paste that bonds stones together"),
                    KeywordPair(keyword: "Concrete", definition: "Lime + ash + aggregate that fills foundations"),
                    KeywordPair(keyword: "Binder", definition: "Lime — the glue in both mortar and concrete"),
                    KeywordPair(keyword: "Aggregate", definition: "Rock chunks added to concrete for strength"),
                ],
                activity: .trueFalse(statement: "Mortar and concrete both use lime as their binder", isTrue: true),
                notebookSummary: "Mortar = lime + sand (bonds stones). Concrete = lime + ash + aggregate (fills foundations). Same binder, different recipes.",
                visual: CardVisual(
                    type: .comparison,
                    title: "Mortar vs Concrete",
                    values: ["equal": 0],
                    labels: ["Mortar\nLime + sand\nGlue between stones", "Concrete\nLime + ash + aggregate\nFills foundations", "Same binder (lime) — different jobs: mortar holds, concrete fills"],
                    steps: 3, caption: "Understanding binders is how you choose the right recipe"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_volcano_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .workshop, stationKey: "volcano",
                title: "Step 7: Waterproof Lining",
                italianTitle: "Presa Subacquea",
                icon: "flame.fill",
                lessonText: "Normal lime mortar dissolves in water. Add pozzolana and something miraculous happens — it sets HARDER underwater. The silica in volcanic ash triggers a chemical reaction with lime that doesn't need air. Romans discovered this by accident near Pozzuoli. For aqueduct foundations crossing rivers, this was everything. The material that hates water becomes the one material that conquers it.",
                keywords: [
                    KeywordPair(keyword: "Hydraulic setting", definition: "Concrete hardening underwater without air"),
                    KeywordPair(keyword: "Pozzuoli", definition: "Town near Vesuvius where the reaction was discovered"),
                    KeywordPair(keyword: "Silica reaction", definition: "Volcanic ash + lime = waterproof bond"),
                ],
                activity: .multipleChoice(question: "What makes Roman concrete set underwater?", options: ["Sand", "Volcanic ash (pozzolana)", "Marble dust", "Iron filings"], correctIndex: 1),
                notebookSummary: "Pozzolana + lime = hydraulic concrete that sets HARDER underwater. Silica reaction needs no air. Discovered at Pozzuoli.",
                visual: CardVisual(
                    type: .comparison,
                    title: "Underwater: Dissolves vs Hardens",
                    values: ["equal": 0],
                    labels: ["Normal mortar\nDissolves in water\nNeeds air to set", "Pozzolanic concrete\nSets HARDER underwater\nSilica reaction — no air needed", "The material that hates water becomes the one that conquers it"],
                    steps: 3, caption: "Discovered by accident near Pozzuoli, at the foot of Vesuvius"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_river_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "river",
                title: "Opus Signinum",
                italianTitle: "Opus Signinum",
                icon: "drop.triangle.fill",
                lessonText: "The specus channel needed to be perfectly waterproof. Romans crushed terracotta tiles into powder and mixed it with lime — opus signinum. The ceramic particles filled every pore. They applied it in three coats, each burnished smooth with a stone. The inside of the Aqua Claudia was smoother than modern plumbing. Crushed pottery became the first waterproof lining in history.",
                keywords: [
                    KeywordPair(keyword: "Opus signinum", definition: "Crushed terracotta + lime waterproof coating"),
                    KeywordPair(keyword: "Three coats", definition: "Applied in layers, each burnished smooth"),
                    KeywordPair(keyword: "Burnishing", definition: "Polishing with stone to seal the surface"),
                ],
                activity: .wordScramble(word: "SIGNINUM", hint: "Roman waterproof lining made from crushed terracotta"),
                notebookSummary: "Opus signinum: crushed terracotta + lime, 3 burnished coats. First waterproof channel lining. Smoother than modern plumbing.",
                visual: CardVisual(
                    type: .crossSection,
                    title: "3 Burnished Coats of Opus Signinum",
                    values: ["depth": 0.03],
                    labels: ["Coat 1 (coarse)", "Coat 2 (medium)", "Coat 3 (finest — burnished smooth)"],
                    steps: 3, caption: "Crushed terracotta fills every pore — smoother than modern plumbing"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_mine_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "mine",
                title: "Lead Fistulae Pipes",
                italianTitle: "Fistulae di Piombo",
                icon: "pipe.and.drop.fill",
                lessonText: "At the castellum, water split into lead pipes called fistulae. Romans cast them by pouring molten lead over a sand mold, then bending the sheet into a tube and soldering the seam. Each pipe was stamped with the emperor's name and the pipe's caliber. Ten standard sizes existed. Lead was soft, bendable, and easy to repair — the perfect urban pipe. Its toxicity wasn't understood for centuries.",
                keywords: [
                    KeywordPair(keyword: "Fistula", definition: "Lead water pipe used in Roman cities"),
                    KeywordPair(keyword: "Caliber stamp", definition: "Size marking + emperor's name on each pipe"),
                    KeywordPair(keyword: "10 sizes", definition: "Standard pipe diameters used across Rome"),
                    KeywordPair(keyword: "Soldered seam", definition: "Lead sheet bent and sealed into a tube"),
                ],
                activity: .hangman(word: "FISTULA", hint: "Roman lead pipe stamped with the emperor's name"),
                notebookSummary: "Fistulae: lead pipes cast over sand molds, bent into tubes, soldered shut. 10 standard sizes, stamped with emperor's name.",
                visual: CardVisual(
                    type: .crossSection,
                    title: "Making a Lead Fistula Pipe",
                    values: ["depth": 0.1],
                    labels: ["Flat lead sheet", "Bent into tube", "Soldered seam", "Stamped: size + emperor"],
                    steps: 4, caption: "10 standard sizes — soft, bendable, easy to repair"
                )
            ),

            // ── CRAFTING ROOM (3 cards) ────────────────────────

            KnowledgeCard(
                id: "\(bid)_craftingRoom_workbench_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .craftingRoom, stationKey: "workbench",
                title: "Mixing Aqueduct Mortar",
                italianTitle: "Mescolare la Malta",
                icon: "flask.fill",
                lessonText: "Aqueduct mortar needs to survive weather, vibration, and water pressure. Recipe: 1 part slaked lime, 2 parts clean river sand, half-part pozzolana. Slake the lime first — pour water over quicklime and wait. It boils and steams. Once cool, mix the paste with sand until it clings to a trowel turned upside down. Too wet: it slumps. Too dry: it crumbles. Feel is everything.",
                keywords: [
                    KeywordPair(keyword: "1:2:½", definition: "Lime : sand : pozzolana ratio for aqueduct mortar"),
                    KeywordPair(keyword: "Slaking", definition: "Adding water to quicklime — hot reaction"),
                    KeywordPair(keyword: "Trowel test", definition: "Good mortar clings when trowel is inverted"),
                ],
                activity: .fillInBlanks(text: "Aqueduct mortar: ___ part lime, ___ parts sand, half-part ___", blanks: ["1", "2", "pozzolana"], distractors: ["3", "4", "marble"]),
                notebookSummary: "Aqueduct mortar: 1 lime + 2 sand + ½ pozzolana. Slake lime first. Trowel test: good mortar clings upside down.",
                visual: CardVisual(
                    type: .ratio,
                    title: "Aqueduct Mortar Recipe — 1:2:½",
                    values: ["Lime": 1, "Sand": 2, "Pozzolana": 0.5],
                    labels: ["1 lime : 2 sand : ½ pozzolana"],
                    steps: 3, caption: "Slake lime first, mix until it clings to an inverted trowel"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_craftingRoom_furnace_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .craftingRoom, stationKey: "furnace",
                title: "Firing Signinum Lining",
                italianTitle: "Cottura del Rivestimento Signino",
                icon: "flame.circle.fill",
                lessonText: "Before you can make opus signinum, you need terracotta. Clay tiles fire at 600-900°C until they ring when tapped. Then smash them to powder. The smaller the particles, the better the waterproofing — they fill tinier pores. Sieve through linen cloth. The finest powder goes in the final coat. Romans graded their crushed tile the way jewelers grade diamonds: by fineness.",
                keywords: [
                    KeywordPair(keyword: "600-900°C", definition: "Firing temperature for terracotta tiles"),
                    KeywordPair(keyword: "Ring test", definition: "Tap a tile — clear ring means properly fired"),
                    KeywordPair(keyword: "Graded powder", definition: "Finest particles for the waterproof top coat"),
                ],
                activity: .numberFishing(question: "Minimum firing temperature (°C) for terracotta tiles?", correctAnswer: 600, decoys: [200, 400, 800, 1100, 1500]),
                notebookSummary: "Terracotta fires at 600-900°C (ring test). Crush to powder, sieve through linen. Finest grains for the waterproof coat.",
                visual: CardVisual(
                    type: .temperature,
                    title: "Firing Terracotta — 600-900°C",
                    values: ["transition": 600, "max": 1100],
                    labels: ["Raw clay", "Fired terracotta (rings when tapped)"],
                    steps: 3, caption: "Crush to powder, sieve finest grains — graded like jewelers grade diamonds"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_craftingRoom_shelf_0",
                buildingId: bid, buildingName: name,
                science: .hydraulics,
                environment: .craftingRoom, stationKey: "shelf",
                title: "Flow Rate Testing",
                italianTitle: "Verifica della Portata",
                icon: "gauge.with.dots.needle.33percent",
                lessonText: "Frontinus, Rome's water commissioner, measured aqueduct flow using the quinaria — a pipe with a specific diameter. He calculated the Aqua Claudia delivered 184,000 cubic meters daily. That's 190 liters per person — more than many modern cities. His book De Aquaeductu is the world's first water management manual. Measure everything, waste nothing. Infrastructure runs on data.",
                keywords: [
                    KeywordPair(keyword: "Quinaria", definition: "Standard pipe unit for measuring water flow"),
                    KeywordPair(keyword: "Frontinus", definition: "Rome's water commissioner who measured everything"),
                    KeywordPair(keyword: "184,000 m³/day", definition: "Daily flow of the Aqua Claudia"),
                    KeywordPair(keyword: "De Aquaeductu", definition: "First water management book in history"),
                ],
                activity: .hangman(word: "FRONTINUS", hint: "Rome's water commissioner who wrote De Aquaeductu"),
                notebookSummary: "Frontinus measured flow via quinaria pipes. Aqua Claudia: 184,000 m³/day (190 L/person). De Aquaeductu = first water manual.",
                visual: CardVisual(
                    type: .ratio,
                    title: "Daily Flow — 184,000 m³",
                    values: ["Total flow": 184000, "Per person": 190],
                    labels: ["184,000 m³/day → 190 liters per person"],
                    steps: 3, caption: "More than many modern cities — measured by Frontinus, Rome's water commissioner"
                )
            ),
        ]
    }

    // MARK: - Roman Roads (10 cards)

    static var romanRoadsCards: [KnowledgeCard] {
        let bid = 5
        let name = "Roman Roads"
        return [
            // ── CITY MAP (4 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_cityMap_building_0",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .cityMap, stationKey: "building",
                title: "400,000 Kilometers",
                italianTitle: "400.000 Chilometri",
                icon: "road.lanes",
                lessonText: "At its peak, Rome's road network stretched 400,000 km — enough to circle Earth ten times. 29 highways radiated from a golden milestone in the Forum. Armies marched 30 km per day on them. Trade wagons followed. Then mail carriers. Roads didn't just connect cities — they created an economy. Every empire since has copied this idea. Control the roads, control the world.",
                keywords: [
                    KeywordPair(keyword: "400,000 km", definition: "Total length of Roman road network"),
                    KeywordPair(keyword: "Golden milestone", definition: "Starting point of all roads in the Roman Forum"),
                    KeywordPair(keyword: "29 highways", definition: "Major roads radiating from Rome"),
                    KeywordPair(keyword: "30 km/day", definition: "Standard army marching pace on Roman roads"),
                ],
                activity: .numberFishing(question: "How many km of roads did Rome build at its peak?", correctAnswer: 400000, decoys: [50000, 150000, 250000, 600000, 800000]),
                notebookSummary: "Rome built 400,000 km of roads. 29 highways from the golden milestone. Armies marched 30 km/day. Roads = empire.",
                visual: CardVisual(
                    type: .geometry, title: "400,000 km of Roads from One Point",
                    values: ["diameter": 400000], labels: ["29 highways radiate from the golden milestone", "Enough road to circle Earth 10 times"],
                    steps: 3, caption: "Every road leads to Rome — literally"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_1",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .cityMap, stationKey: "building",
                title: "Step 1 Support: Survey Stakes",
                italianTitle: "La Groma",
                icon: "plus.circle",
                lessonText: "Romans surveyed roads using the groma — a cross-shaped instrument with plumb lines hanging from each arm. Set it at a starting point, sight along the strings, and plant stakes in a perfectly straight line. Some Roman roads run dead straight for 80 km. No GPS, no lasers. Just string, lead weights, and trained eyes. The simplest tools, wielded with discipline, are enough.",
                keywords: [
                    KeywordPair(keyword: "Groma", definition: "Cross-shaped surveying tool with plumb lines"),
                    KeywordPair(keyword: "Plumb lines", definition: "Weighted strings for sighting straight lines"),
                    KeywordPair(keyword: "80 km", definition: "Length of some perfectly straight Roman roads"),
                ],
                activity: .wordScramble(word: "GROMA", hint: "Cross-shaped Roman surveying tool with plumb lines"),
                notebookSummary: "Groma: cross-shaped tool with plumb lines for surveying. Some roads run 80 km dead straight. Simple tools + discipline.",
                visual: CardVisual(type: .geometry, title: "The Groma — Cross-Shaped Level", values: ["diameter": 6], labels: ["Cross arms with plumb lines", "Sight along two arms = straight line", "80 km dead straight with this tool"], steps: 3, caption: "Simple tools + discipline = 80 km dead straight")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_2",
                buildingId: bid, buildingName: name,
                science: .geology,
                environment: .cityMap, stationKey: "building",
                title: "Steps 3–6: Four Layers",
                italianTitle: "Quattro Strati Geologici",
                icon: "square.stack.fill",
                lessonText: "Every Roman road is a geological sandwich. Bottom: statumen — large flat stones for drainage. Next: rudus — fist-sized gravel bound with lime. Then: nucleus — fine gravel and sand packed hard. Top: summa crusta — cut stone polygons fitted without mortar. Total depth: up to 1.5 meters. Each layer serves a different purpose. The road isn't a surface — it's a structure.",
                keywords: [
                    KeywordPair(keyword: "Statumen", definition: "Bottom layer — large flat stones for drainage"),
                    KeywordPair(keyword: "Rudus", definition: "Second layer — gravel bound with lime"),
                    KeywordPair(keyword: "Nucleus", definition: "Third layer — fine gravel packed hard"),
                    KeywordPair(keyword: "Summa crusta", definition: "Top layer — cut stone polygons"),
                ],
                activity: .multipleChoice(question: "What is the bottom layer of a Roman road?", options: ["Nucleus", "Rudus", "Statumen", "Summa crusta"], correctIndex: 2),
                notebookSummary: "4 layers bottom→top: statumen (drainage stones), rudus (lime gravel), nucleus (packed sand), summa crusta (cut polygons). Up to 1.5m deep.",
                visual: CardVisual(type: .crossSection, title: "Four Layers of a Roman Road", values: ["depth": 1.5], labels: ["Summa crusta (polygonal stones)", "Nucleus (packed sand)", "Rudus (lime gravel)", "Statumen (drainage stones)"], steps: 4, caption: "A geological sandwich up to 1.5 meters deep")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_3",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .cityMap, stationKey: "building",
                title: "Step 6: Basalt Paving",
                italianTitle: "Basolato Poligonale",
                icon: "hexagon.fill",
                lessonText: "The Via Appia's surface stones are basalt — volcanic rock so hard it dulls iron chisels. Masons cut them into irregular polygons and fitted them together like a jigsaw puzzle. No mortar needed. The irregular shapes lock tighter under traffic weight. After 2,300 years, you can still walk on the original stones. The Romans chose the hardest rock on Earth and made it the smoothest road.",
                keywords: [
                    KeywordPair(keyword: "Basalt", definition: "Volcanic rock used for road surface — extremely hard"),
                    KeywordPair(keyword: "Polygonal", definition: "Irregular multi-sided shape that interlocks"),
                    KeywordPair(keyword: "Via Appia", definition: "Queen of Roads — Rome's first major highway"),
                    KeywordPair(keyword: "2,300 years", definition: "Age of original basalt paving still walkable"),
                ],
                activity: .hangman(word: "BASALT", hint: "Volcanic rock so hard it dulls iron chisels"),
                notebookSummary: "Via Appia: basalt polygons — no mortar, interlock under weight. 2,300 years old, still walkable. Hardest rock = smoothest road.",
                visual: CardVisual(type: .geometry, title: "Basalt Polygons — No Mortar", values: ["tessellation": 1, "stones": 1], labels: ["Basalt (volcanic)"], steps: 3, caption: "Interlock under weight — 2,300 years old, still walkable")
            ),

            // ── WORKSHOP (3 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_workshop_quarry_0",
                buildingId: bid, buildingName: name,
                science: .geology,
                environment: .workshop, stationKey: "quarry",
                title: "Step 3: Statumen Gravel",
                italianTitle: "Basalto per lo Statumen",
                icon: "mountain.2.fill",
                lessonText: "The statumen needs flat stones that won't shift under load. Quarrymen split basalt along natural fracture lines using iron wedges hammered into drilled holes. Water poured into cracks in winter — ice expansion did the rest. The best statumen stones are hand-selected: flat bottom, rough top. Flat to sit stable, rough to grip the rudus layer above. Every stone is chosen by feel.",
                keywords: [
                    KeywordPair(keyword: "Iron wedges", definition: "Hammered into holes to split basalt"),
                    KeywordPair(keyword: "Ice splitting", definition: "Water freezes in cracks — expands and breaks rock"),
                    KeywordPair(keyword: "Flat bottom", definition: "Statumen stones must sit stable"),
                    KeywordPair(keyword: "Rough top", definition: "Textured surface grips the rudus layer above"),
                ],
                activity: .trueFalse(statement: "Romans used frozen water in cracks to split basalt for road foundations", isTrue: true),
                notebookSummary: "Basalt split with iron wedges + ice expansion. Statumen stones: flat bottom (stable), rough top (grips rudus). Selected by feel.",
                visual: CardVisual(type: .comparison, title: "Ice Splitting — Nature's Chisel", values: ["equal": 0], labels: ["Iron wedge\nin drill holes\nwater added", "Ice expands\ncracks basalt\nalong grain", "Water freezes → 9% expansion → splits the hardest stone"], steps: 3, caption: "Flat bottom for stability, rough top to grip the rudus layer")
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_volcano_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .workshop, stationKey: "volcano",
                title: "Step 4: Rudus Mortar",
                italianTitle: "Legante del Rudus",
                icon: "flame.fill",
                lessonText: "The rudus layer gets its strength from volcanic lime mortar. Gravel alone shifts. Add lime mixed with pozzolana and the gaps fill with cement that hardens over years. The chemical reaction — lime + silica + water — creates calcium silicate hydrate crystals that grow into the gravel pores. The rudus literally grows stronger with time. A road that improves with age is an engineer's dream.",
                keywords: [
                    KeywordPair(keyword: "Calcium silicate hydrate", definition: "Crystal that forms in pozzolanic cement"),
                    KeywordPair(keyword: "Rudus", definition: "Gravel layer bound with volcanic mortar"),
                    KeywordPair(keyword: "Grows stronger", definition: "Pozzolanic reaction continues for years"),
                ],
                activity: .wordScramble(word: "RUDUS", hint: "Gravel road layer bound with volcanic mortar"),
                notebookSummary: "Rudus: gravel + volcanic lime mortar. Pozzolanic reaction creates crystals in pores — gets stronger over years.",
                visual: CardVisual(type: .reaction, title: "Pozzolanic Crystals in Road Mortar", values: ["durability_roman": 2000], labels: ["Lime + volcanic ash", "Calcium silicate crystals", "crystals grow in pores"], steps: 3, caption: "Gets STRONGER over years — crystals fill the gaps between gravel")
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_river_0",
                buildingId: bid, buildingName: name,
                science: .mathematics,
                environment: .workshop, stationKey: "river",
                title: "Step 5: The Nucleus",
                italianTitle: "Matematica del Bombamento",
                icon: "drop.triangle.fill",
                lessonText: "The nucleus layer isn't flat — it's crowned. Romans built a camber: the center sits 15-30 cm higher than the edges. Rainwater runs off to ditches on both sides. The cross-section is a gentle arc, calculated so water flows at walking speed — fast enough to clear, slow enough not to erode. Every Roman road is secretly a roof. Geometry keeps it dry.",
                keywords: [
                    KeywordPair(keyword: "Camber", definition: "Crowned surface — center higher than edges"),
                    KeywordPair(keyword: "15-30 cm", definition: "Height difference between center and edges"),
                    KeywordPair(keyword: "Cross-section", definition: "Gentle arc shape for drainage"),
                    KeywordPair(keyword: "Drainage ditch", definition: "Channels on both sides collecting runoff"),
                ],
                activity: .numberFishing(question: "Maximum camber height (cm) above the road edges?", correctAnswer: 30, decoys: [5, 10, 50, 75, 100]),
                notebookSummary: "Nucleus camber: center 15-30 cm higher than edges. Gentle arc drains rainwater to side ditches. Every road is a roof.",
                visual: CardVisual(type: .flow, title: "Camber — Every Road Is a Roof", values: ["camber": 30], labels: ["Center 15-30 cm higher → water drains to side ditches"], steps: 3, caption: "A gentle arc invisible to the eye — but rain sees it perfectly")
            ),

            // ── CRAFTING ROOM (3 cards) ────────────────────────

            KnowledgeCard(
                id: "\(bid)_craftingRoom_workbench_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .craftingRoom, stationKey: "workbench",
                title: "Step 4: Mix Road Mortar",
                italianTitle: "Ricetta della Malta Stradale",
                icon: "flask.fill",
                lessonText: "Road mortar is rougher than aqueduct mortar — it needs to grip coarse gravel, not smooth stone. Recipe: 1 part lime, 3 parts crushed volcanic rock (larger grain than sand). Mix dry first, then add water slowly. It should feel like wet beach sand. Pack it between gravel stones with a wooden rammer. Each layer gets rammed 50 times per square meter. Roads are built by rhythm.",
                keywords: [
                    KeywordPair(keyword: "1:3 ratio", definition: "Lime to crushed volcanic rock for road mortar"),
                    KeywordPair(keyword: "Dry mix first", definition: "Combine lime + rock before adding water"),
                    KeywordPair(keyword: "Rammer", definition: "Wooden tool for compacting road layers"),
                    KeywordPair(keyword: "50 rams/m²", definition: "Compaction standard per square meter"),
                ],
                activity: .fillInBlanks(text: "Road mortar: ___ part lime, ___ parts crushed volcanic rock, rammed ___ times per square meter", blanks: ["1", "3", "50"], distractors: ["2", "5", "20"]),
                notebookSummary: "Road mortar: 1 lime + 3 crushed volcanic rock. Dry mix, add water. Ram 50 times per m². Built by rhythm.",
                visual: CardVisual(type: .ratio, title: "Road Mortar Recipe — 1:3", values: ["Lime": 1, "Volcanic rock": 3], labels: ["1 lime : 3 crushed volcanic rock"], steps: 3, caption: "Dry mix → add water → ram 50 times per m²")
            ),

            KnowledgeCard(
                id: "\(bid)_craftingRoom_furnace_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .craftingRoom, stationKey: "furnace",
                title: "Lime Firing for Roads",
                italianTitle: "Cottura della Calce per Strade",
                icon: "flame.circle.fill",
                lessonText: "Road-grade quicklime needs the hottest kiln. Limestone chunks stack inside a stone cylinder with charcoal between each layer. Light the bottom. Three days of continuous firing at 900°C drives off carbon dioxide. The white powder that remains — quicklime — is so reactive it burns skin on contact. Store it dry. One raindrop starts the reaction. The road begins in fire.",
                keywords: [
                    KeywordPair(keyword: "3 days", definition: "Continuous firing time for road-grade lime"),
                    KeywordPair(keyword: "900°C", definition: "Kiln temperature for limestone to quicklime"),
                    KeywordPair(keyword: "Quicklime", definition: "CaO — white powder that reacts violently with water"),
                ],
                activity: .trueFalse(statement: "Road-grade quicklime requires 3 days of continuous firing at 900°C", isTrue: true),
                notebookSummary: "Lime firing: 3 days at 900°C. Limestone → quicklime (CaO). Burns skin, reacts with water. Store bone dry.",
                visual: CardVisual(type: .temperature, title: "3-Day Kiln — Limestone to Quicklime", values: ["transition": 900, "max": 1200], labels: ["Limestone (CaCO₃)", "Quicklime (CaO)"], steps: 3, caption: "3 days at 900°C — burns skin, reacts violently with water")
            ),

            KnowledgeCard(
                id: "\(bid)_craftingRoom_shelf_0",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .craftingRoom, stationKey: "shelf",
                title: "Step 8: Milestones",
                italianTitle: "Pietre Miliari",
                icon: "signpost.right.fill",
                lessonText: "Every Roman mile (1,480 meters), a stone column marked the distance from Rome. These milliaria listed the emperor, the road name, and distances to the next three cities. They were the world's first GPS. Soldiers, merchants, and tax collectors all depended on them. Augustus placed a golden milestone in the Forum — mile zero — where all measurements began. Navigation starts with a reference point.",
                keywords: [
                    KeywordPair(keyword: "Milliarium", definition: "Stone milestone placed every Roman mile"),
                    KeywordPair(keyword: "1,480 meters", definition: "Length of one Roman mile"),
                    KeywordPair(keyword: "Golden milestone", definition: "Mile zero in the Roman Forum"),
                    KeywordPair(keyword: "Augustus", definition: "Emperor who established the milestone system"),
                ],
                activity: .numberFishing(question: "How many meters in a Roman mile?", correctAnswer: 1480, decoys: [1000, 1200, 1600, 1850, 2000]),
                notebookSummary: "Milliarium: milestone every 1,480m (1 Roman mile). Listed emperor, road, distances. Golden milestone in Forum = mile zero.",
                visual: CardVisual(type: .geometry, title: "Milestone Every 1,480 Meters", values: ["diameter": 1480, "height": 1.8], labels: ["1 Roman mile = 1,480 m", "Carved: emperor, road, distances"], steps: 3, caption: "Golden milestone in the Forum = mile zero for the entire empire")
            ),
        ]
    }

    // MARK: - Roman Baths (13 cards)

    static var romanBathsCards: [KnowledgeCard] {
        let bid = 3
        let name = "Roman Baths"
        return [
            // ── CITY MAP (5 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_cityMap_building_0",
                buildingId: bid, buildingName: name,
                science: .architecture,
                environment: .cityMap, stationKey: "building",
                title: "Thermae — Social Center",
                italianTitle: "Le Terme — Centro Sociale",
                icon: "building.2.fill",
                lessonText: "Roman baths weren't just for washing. They were libraries, gyms, gardens, and meeting halls — all under one roof. The Baths of Caracalla held 1,600 bathers at once. Citizens spent entire afternoons there. Admission was almost free — emperors subsidized it. Clean citizens are happy citizens. The baths were Rome's greatest social engineering project disguised as architecture.",
                keywords: [
                    KeywordPair(keyword: "Thermae", definition: "Large public bath complex with many functions"),
                    KeywordPair(keyword: "Caracalla", definition: "Emperor who built baths for 1,600 bathers"),
                    KeywordPair(keyword: "Subsidized", definition: "Government paid most costs — almost free entry"),
                    KeywordPair(keyword: "Social engineering", definition: "Architecture designed to shape citizen behavior"),
                ],
                activity: .numberFishing(question: "How many bathers could the Baths of Caracalla hold?", correctAnswer: 1600, decoys: [400, 800, 2500, 5000, 10000]),
                notebookSummary: "Thermae: baths + library + gym + garden. Caracalla: 1,600 bathers. Almost free. Social engineering as architecture.",
                visual: CardVisual(type: .comparison, title: "Thermae — More Than a Bath", values: ["equal": 0], labels: ["Modern gym\nOne purpose\nExpensive", "Roman thermae\nBath + library + gym\n+ garden — almost free", "1,600 bathers simultaneously at Caracalla"], steps: 3, caption: "Social engineering as architecture — open to almost everyone")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_1",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .cityMap, stationKey: "building",
                title: "Step 1: The Hypocaust",
                italianTitle: "Riscaldamento a Ipocausto",
                icon: "flame.fill",
                lessonText: "Under the bath floors lies Rome's greatest invention: the hypocaust. A furnace pushes hot air through a crawl space beneath raised floors supported on brick pilae stacks. Hot air rises through hollow walls — tubuli — and exits through roof vents. The floor itself becomes a radiator. Bathers walked barefoot on heated stone. Central heating, invented 2,000 years before it appeared in houses.",
                keywords: [
                    KeywordPair(keyword: "Hypocaust", definition: "Underfloor heating system using hot air"),
                    KeywordPair(keyword: "Pilae", definition: "Brick stacks supporting the raised floor"),
                    KeywordPair(keyword: "Tubuli", definition: "Hollow wall tiles carrying hot air upward"),
                    KeywordPair(keyword: "Central heating", definition: "One furnace heats the entire building"),
                ],
                activity: .wordScramble(word: "HYPOCAUST", hint: "Roman underfloor heating — hot air beneath raised floors"),
                notebookSummary: "Hypocaust: furnace → hot air under raised floor (pilae) → up through hollow walls (tubuli) → roof vents. First central heating.",
                visual: CardVisual(type: .crossSection, title: "Hypocaust — First Central Heating", values: ["depth": 1.0], labels: ["Floor (radiates heat up)", "Pilae stacks (air gap)", "Hot air from furnace", "Tubuli (hollow walls → roof vents)"], steps: 4, caption: "Furnace → under floor → up through walls → out roof vents")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_2",
                buildingId: bid, buildingName: name,
                science: .hydraulics,
                environment: .cityMap, stationKey: "building",
                title: "Step 2: Water Supply",
                italianTitle: "Castellum di Distribuzione",
                icon: "arrow.triangle.branch",
                lessonText: "A castellum — water distribution tank — sat at each bath complex. The aqueduct fed it from above. Three outlets at different heights: the lowest served the cold pool, the middle the warm pool, the highest the hot pool (hot water evaporates fastest). If aqueduct pressure dropped, the hot pool lost water first — saving the cold pool that served the most bathers. Gravity does the rationing.",
                keywords: [
                    KeywordPair(keyword: "Castellum", definition: "Water tank distributing to different pools"),
                    KeywordPair(keyword: "Three heights", definition: "Outlets ranked by priority — cold lowest"),
                    KeywordPair(keyword: "Gravity rationing", definition: "Low pressure cuts high outlets first"),
                ],
                activity: .multipleChoice(question: "Which pool's outlet was placed lowest in the castellum?", options: ["Hot pool (caldarium)", "Warm pool (tepidarium)", "Cold pool (frigidarium)", "All at equal height"], correctIndex: 2),
                notebookSummary: "Castellum: 3 outlets at different heights. Cold (lowest) → warm → hot (highest). Low pressure cuts hot first. Gravity rations.",
                visual: CardVisual(type: .crossSection, title: "Castellum — 3 Outlets by Height", values: ["depth": 2.0], labels: ["Hot water (highest outlet)", "Warm water (middle)", "Cold water (lowest — last to run dry)"], steps: 3, caption: "When water runs low, hot supply cuts first — gravity rations automatically")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_3",
                buildingId: bid, buildingName: name,
                science: .physics,
                environment: .cityMap, stationKey: "building",
                title: "Step 5: The Tepidarium",
                italianTitle: "Tre Vasche a Temperature Diverse",
                icon: "thermometer.medium",
                lessonText: "Bathers followed a specific route: frigidarium (cold, ~15°C), tepidarium (warm, ~25°C), caldarium (hot, ~40°C). The order matters — moving cold to hot opens pores, then back to cold closes them. The caldarium sat directly over the furnace. The tepidarium shared one wall with the caldarium — heat conducted through stone. The frigidarium was farthest away. Temperature gradient as floor plan.",
                keywords: [
                    KeywordPair(keyword: "Frigidarium", definition: "Cold pool room (~15°C)"),
                    KeywordPair(keyword: "Tepidarium", definition: "Warm room (~25°C) — between cold and hot"),
                    KeywordPair(keyword: "Caldarium", definition: "Hot pool room (~40°C) directly over furnace"),
                    KeywordPair(keyword: "Temperature gradient", definition: "Rooms arranged cold → warm → hot"),
                ],
                activity: .fillInBlanks(text: "Bath route: ___ (cold 15°C) → ___ (warm 25°C) → ___ (hot 40°C)", blanks: ["frigidarium", "tepidarium", "caldarium"], distractors: ["laconicum", "natatio", "apodyterium"]),
                notebookSummary: "Bath route: frigidarium (15°C) → tepidarium (25°C) → caldarium (40°C). Caldarium over furnace. Temperature gradient as architecture.",
                visual: CardVisual(type: .temperature, title: "Bath Temperature Gradient", values: ["transition": 25, "max": 45], labels: ["Frigidarium 15°C", "Caldarium 40°C"], steps: 3, caption: "Cold → warm → hot: temperature gradient as architecture")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_4",
                buildingId: bid, buildingName: name,
                science: .hydraulics,
                environment: .cityMap, stationKey: "building",
                title: "Step 6: The Caldarium",
                italianTitle: "Drenaggio a Gravità",
                icon: "arrow.down.to.line",
                lessonText: "The baths consumed 10 million liters daily. All that water had to go somewhere. Floors sloped 2% toward bronze-grated drains. Underground channels funneled everything into the Cloaca Maxima — Rome's great sewer. The bath's drain water was reused: it flushed public latrines downstream. Nothing wasted. The most sophisticated plumbing of the ancient world ran entirely on slope.",
                keywords: [
                    KeywordPair(keyword: "2% slope", definition: "Floor gradient toward drains"),
                    KeywordPair(keyword: "Cloaca Maxima", definition: "Rome's great sewer collecting all drainage"),
                    KeywordPair(keyword: "10 million liters", definition: "Daily water consumption of a major bath"),
                    KeywordPair(keyword: "Reuse", definition: "Bath drain water flushed public latrines"),
                ],
                activity: .hangman(word: "CLOACA", hint: "Rome's great sewer — the Cloaca Maxima"),
                notebookSummary: "Baths: 10M liters/day. Floors slope 2% to drains → Cloaca Maxima sewer. Drain water reused for latrines. Zero waste.",
                visual: CardVisual(type: .flow, title: "10 Million Liters Daily → Zero Waste", values: ["flow": 10000000], labels: ["2% floor slope → drains → Cloaca Maxima sewer"], steps: 3, caption: "Drain water reused for latrines — nothing wasted")
            ),

            // ── WORKSHOP (3 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_workshop_quarry_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "quarry",
                title: "Marble and Waterproofing",
                italianTitle: "Marmo e Impermeabilizzazione",
                icon: "mountain.2.fill",
                lessonText: "Bath walls needed to be beautiful AND waterproof. Solution: marble veneer over concrete walls sealed with lead clamps. But marble alone leaks through micro-cracks. Behind every slab, Romans applied three coats of opus signinum. The marble is the face; the signinum is the shield. Two materials doing two jobs, layered so perfectly that the baths stayed watertight for 400 years.",
                keywords: [
                    KeywordPair(keyword: "Marble veneer", definition: "Thin decorative slabs over concrete walls"),
                    KeywordPair(keyword: "Lead clamps", definition: "Metal fasteners holding marble to the wall"),
                    KeywordPair(keyword: "Opus signinum", definition: "Waterproof layer behind the marble"),
                ],
                activity: .trueFalse(statement: "Roman bath walls used opus signinum behind the marble to prevent leaks", isTrue: true),
                notebookSummary: "Bath walls: marble veneer (beauty) over opus signinum (waterproofing) over concrete. Lead clamps hold marble. Watertight 400 years.",
                visual: CardVisual(type: .crossSection, title: "Bath Wall — 3 Layers", values: ["depth": 0.5], labels: ["Marble veneer (beauty)", "Opus signinum (waterproof)", "Concrete core (structure)"], steps: 3, caption: "Lead clamps hold marble — watertight for 400 years")
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_volcano_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .workshop, stationKey: "volcano",
                title: "Thermal Cycling Concrete",
                italianTitle: "Calcestruzzo a Ciclo Termico",
                icon: "flame.fill",
                lessonText: "Bath concrete faces a unique enemy: thermal cycling. The caldarium heats to 40°C, then cools overnight. This daily expansion and contraction cracks ordinary cement. Roman bath concrete used extra pozzolana — 1 part lime to 4 parts ash instead of the usual 1:3. The excess silica fills micro-cracks as they form. Self-healing concrete. Romans engineered for the problems they couldn't see.",
                keywords: [
                    KeywordPair(keyword: "Thermal cycling", definition: "Daily heating and cooling that cracks cement"),
                    KeywordPair(keyword: "1:4 ratio", definition: "Extra pozzolana for bath concrete"),
                    KeywordPair(keyword: "Self-healing", definition: "Excess silica fills micro-cracks as they form"),
                ],
                activity: .fillInBlanks(text: "Bath concrete uses ___ part lime to ___ parts pozzolana — extra silica ___ micro-cracks", blanks: ["1", "4", "heals"], distractors: ["2", "3", "prevents"]),
                notebookSummary: "Bath concrete: 1:4 lime-to-pozzolana (vs normal 1:3). Extra silica self-heals thermal cycling cracks. Engineered for invisible problems.",
                visual: CardVisual(type: .ratio, title: "Bath Concrete — 1:4 (Extra Silica)", values: ["Lime": 1, "Pozzolana": 4], labels: ["1:4 ratio (vs normal 1:3) — extra silica self-heals cracks"], steps: 3, caption: "Thermal cycling creates micro-cracks — extra silica fills them")
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_river_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .workshop, stationKey: "river",
                title: "Silica for Glass Windows",
                italianTitle: "Silice per Vetrate",
                icon: "drop.triangle.fill",
                lessonText: "The Baths of Caracalla had glass windows — rare in the ancient world. Romans melted river sand (silica) with natron (soda ash) at 1,100°C. The molten glass was poured onto flat stone and rolled. These panes were thick, greenish, and wavy — but they let light flood the caldarium while keeping heat inside. Glass windows turned the baths from dark caves into light-filled palaces.",
                keywords: [
                    KeywordPair(keyword: "Silica", definition: "River sand — main ingredient in glass"),
                    KeywordPair(keyword: "Natron", definition: "Soda ash flux that lowers melting temperature"),
                    KeywordPair(keyword: "1,100°C", definition: "Temperature needed to melt glass"),
                    KeywordPair(keyword: "Cast glass", definition: "Molten glass poured and rolled flat on stone"),
                ],
                activity: .numberFishing(question: "What temperature (°C) melts sand into glass?", correctAnswer: 1100, decoys: [600, 800, 900, 1400, 1800]),
                notebookSummary: "Bath glass: river sand (silica) + natron at 1,100°C. Poured and rolled flat. Thick and greenish but flooded caldarium with light.",
                visual: CardVisual(type: .temperature, title: "Making Glass — Sand at 1,100°C", values: ["transition": 1100, "max": 1400], labels: ["Sand (SiO₂)", "Molten glass"], steps: 3, caption: "River sand + natron → poured flat → thick but floods the room with light")
            ),

            // ── FOREST (2 cards) ───────────────────────────────

            KnowledgeCard(
                id: "\(bid)_forest_oak_0",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .forest, stationKey: "oak",
                title: "Frigidarium Roof Trusses",
                italianTitle: "Capriate del Frigidarium",
                icon: "triangle.fill",
                lessonText: "The frigidarium needed the widest roof — its cold pool was the largest room. Oak trusses spanned up to 25 meters, using a king-post truss design: two angled rafters meeting at the peak, held by a vertical post. Oak's interlocking grain resists splitting under tension. Each truss carried 20 tons of terracotta roof tiles. The tree that grows slowest carries the most weight.",
                keywords: [
                    KeywordPair(keyword: "King-post truss", definition: "Two rafters + vertical post spanning wide rooms"),
                    KeywordPair(keyword: "25 meters", definition: "Maximum span of frigidarium roof trusses"),
                    KeywordPair(keyword: "20 tons", definition: "Weight of tiles each truss carried"),
                    KeywordPair(keyword: "Interlocking grain", definition: "Oak's structure that resists splitting"),
                ],
                activity: .numberFishing(question: "Maximum span (meters) of frigidarium roof trusses?", correctAnswer: 25, decoys: [10, 15, 35, 45, 60]),
                notebookSummary: "Frigidarium: oak king-post trusses spanning 25m, carrying 20 tons of tiles each. Oak's interlocking grain resists splitting.",
                visual: CardVisual(type: .force, title: "King-Post Truss — 25m Span", values: ["columns": 3, "height": 25, "perColumn": 20, "arrows": 3], labels: ["Oak truss carries 20 tons of tiles over 25m span"], steps: 3, caption: "Depth = span/20 rule: 25m span → 1.25m deep beams")
            ),

            KnowledgeCard(
                id: "\(bid)_forest_chestnut_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .forest, stationKey: "chestnut",
                title: "Step 3 Support: Furnace Fuel",
                italianTitle: "Combustibile per la Fornace",
                icon: "leaf.fill",
                lessonText: "The hypocaust furnace burned continuously. Chestnut wood was preferred — it splits easily, dries quickly, and burns with steady heat. Oak burns hotter but unevenly. The stoker fed logs every 30 minutes, maintaining exactly 300°C in the furnace so the caldarium floor stayed at 40°C. One miscalculation and bathers burn their feet. Temperature control is a craft, not a calculation.",
                keywords: [
                    KeywordPair(keyword: "Chestnut", definition: "Preferred fuel — steady, even heat"),
                    KeywordPair(keyword: "300°C", definition: "Target furnace temperature"),
                    KeywordPair(keyword: "40°C", definition: "Caldarium floor temperature for bathers"),
                    KeywordPair(keyword: "30 minutes", definition: "Feeding interval for the stoker"),
                ],
                activity: .trueFalse(statement: "Chestnut was preferred for bath furnaces because it burns with steady, even heat", isTrue: true),
                notebookSummary: "Chestnut: splits easily, steady heat. Stoker feeds every 30 min. Furnace 300°C → floor 40°C. Temperature control = craft.",
                visual: CardVisual(type: .temperature, title: "Furnace 300°C → Floor 40°C", values: ["transition": 300, "max": 400], labels: ["Furnace (300°C)", "Bath floor (40°C)"], steps: 3, caption: "Chestnut burns 45 min per log — stoker feeds every 30 min for steady heat")
            ),

            // ── CRAFTING ROOM (3 cards) ────────────────────────

            KnowledgeCard(
                id: "\(bid)_craftingRoom_workbench_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .craftingRoom, stationKey: "workbench",
                title: "Glass Recipe",
                italianTitle: "Ricetta del Vetro",
                icon: "flask.fill",
                lessonText: "Roman glass recipe: 60% silica sand, 15% natron (soda ash), 10% lime, 15% recycled glass cullet. The cullet is crucial — it lowers the melting point and makes the batch more predictable. Mix dry, shovel into the crucible, heat to 1,100°C, stir with an iron rod. Green tint comes from iron impurities in the sand. To make it clear, add manganese. Chemistry corrects nature.",
                keywords: [
                    KeywordPair(keyword: "Cullet", definition: "Recycled crushed glass added to the batch"),
                    KeywordPair(keyword: "60% silica", definition: "Main glass ingredient — river sand"),
                    KeywordPair(keyword: "Manganese", definition: "Added to remove green tint from iron impurities"),
                ],
                activity: .multipleChoice(question: "What is 'cullet' in glassmaking?", options: ["Iron impurity", "Recycled crushed glass", "Raw silica sand", "Soda ash flux"], correctIndex: 1),
                notebookSummary: "Roman glass: 60% silica + 15% natron + 10% lime + 15% cullet (recycled glass). 1,100°C. Manganese removes green tint.",
                visual: CardVisual(type: .ratio, title: "Roman Glass Recipe", values: ["Silica": 60, "Natron": 15, "Lime": 10, "Cullet": 15], labels: ["60% silica + 15% natron + 10% lime + 15% recycled glass"], steps: 3, caption: "1,100°C — manganese removes the green tint")
            ),

            KnowledgeCard(
                id: "\(bid)_craftingRoom_furnace_0",
                buildingId: bid, buildingName: name,
                science: .physics,
                environment: .craftingRoom, stationKey: "furnace",
                title: "Step 3: Furnace Firing",
                italianTitle: "Combustione nel Prefurnio",
                icon: "flame.circle.fill",
                lessonText: "The praefurnium is the mouth of the hypocaust furnace — a vaulted chamber where combustion happens. Air enters from below through a grate, feeds the fire, and hot gases travel through the underfloor space. The vault shape accelerates airflow (Venturi effect). A skilled stoker controlled temperature by adjusting the air grate, not just the fuel. Combustion is about oxygen, not just wood.",
                keywords: [
                    KeywordPair(keyword: "Praefurnium", definition: "Vaulted furnace mouth where combustion happens"),
                    KeywordPair(keyword: "Venturi effect", definition: "Narrowing vault accelerates airflow"),
                    KeywordPair(keyword: "Air grate", definition: "Controls oxygen — the real temperature dial"),
                ],
                activity: .wordScramble(word: "PRAEFURNIUM", hint: "The vaulted mouth of the hypocaust furnace"),
                notebookSummary: "Praefurnium: vaulted furnace mouth. Venturi effect accelerates air. Temperature controlled by air grate, not just fuel.",
                visual: CardVisual(type: .flow, title: "Venturi Effect in the Furnace", values: ["flow": 300], labels: ["Vaulted chamber narrows → air accelerates → hotter fire"], steps: 3, caption: "Temperature controlled by air grate opening, not just fuel")
            ),

            KnowledgeCard(
                id: "\(bid)_craftingRoom_shelf_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .craftingRoom, stationKey: "shelf",
                title: "Waterproof Storage",
                italianTitle: "Stoccaggio Impermeabile",
                icon: "archivebox.fill",
                lessonText: "Bath oils, perfumes, and cleaning supplies needed waterproof storage. Romans used amphorae lined with pine pitch — heated tree resin painted inside the clay vessel. The resin fills every pore. For extra protection, a wax seal topped the cork stopper. Quicklime was stored in sealed lead containers — one drop of water and it explodes with heat. Proper storage saves lives.",
                keywords: [
                    KeywordPair(keyword: "Pine pitch", definition: "Heated tree resin waterproofing amphora interiors"),
                    KeywordPair(keyword: "Amphora", definition: "Two-handled clay storage vessel"),
                    KeywordPair(keyword: "Wax seal", definition: "Extra waterproofing over the cork stopper"),
                    KeywordPair(keyword: "Lead container", definition: "For storing reactive quicklime safely"),
                ],
                activity: .hangman(word: "AMPHORA", hint: "Two-handled clay vessel lined with pine pitch"),
                notebookSummary: "Storage: amphorae lined with pine pitch for oils. Wax-sealed cork stoppers. Quicklime in sealed lead. Proper storage saves lives.",
                visual: CardVisual(type: .crossSection, title: "Amphora — Waterproof Storage", values: ["depth": 0.6], labels: ["Wax-sealed cork stopper", "Clay vessel", "Pine pitch lining (waterproof)"], steps: 3, caption: "Oils, perfumes, cleaning supplies — proper storage saves lives")
            ),
        ]
    }

    // MARK: - Insula (12 cards)

    static var insulaCards: [KnowledgeCard] {
        let bid = 8
        let name = "Insula"
        return [
            // ── CITY MAP (5 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_cityMap_building_0",
                buildingId: bid, buildingName: name,
                science: .architecture,
                environment: .cityMap, stationKey: "building",
                title: "First Apartment Buildings",
                italianTitle: "I Primi Condomini",
                icon: "building.fill",
                lessonText: "Rome had a million residents and not enough land. The solution: build up. Insulae were the world's first apartment buildings — 6 to 7 stories tall, housing dozens of families. Ground floors held tabernae shops. Upper floors got smaller, cheaper, and more dangerous. The richest lived lowest. The poorest lived highest — closer to fire, farther from escape. Vertical cities have always sorted people by money.",
                keywords: [
                    KeywordPair(keyword: "Insula", definition: "Roman apartment block — 6-7 stories tall"),
                    KeywordPair(keyword: "Tabernae", definition: "Ground-floor shops in the insula"),
                    KeywordPair(keyword: "Million residents", definition: "Rome's population requiring vertical housing"),
                    KeywordPair(keyword: "Richest lowest", definition: "Wealthy tenants lived on lower, safer floors"),
                ],
                activity: .numberFishing(question: "How many stories tall was a typical Roman insula?", correctAnswer: 7, decoys: [3, 4, 10, 12, 15]),
                notebookSummary: "Insula: Rome's apartment buildings, 6-7 stories. Ground floor = shops (tabernae). Rich lived low, poor lived high. First vertical city.",
                visual: CardVisual(
                    type: .crossSection,
                    title: "6-7 Story Apartment",
                    values: ["height": 7],
                    labels: ["Shops (ground)", "Rich apartments", "Middle class", "Poor (top floor)", "Roof (fire risk)"],
                    steps: 4, caption: "Vertical cities have always sorted people by money"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_1",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .cityMap, stationKey: "building",
                title: "Step 4: Five Stories",
                italianTitle: "Limite di Altezza di Augusto",
                icon: "ruler.fill",
                lessonText: "After a series of catastrophic collapses, Emperor Augustus set the first building code: no insula taller than 20 meters (about 6 stories). Nero later reduced it to 17.5 meters after the Great Fire. The problem wasn't ambition — it was foundation engineering. Roman foundations couldn't reliably support more than 6 stories of heavy brick and concrete. Building codes were written in blood.",
                keywords: [
                    KeywordPair(keyword: "20 meters", definition: "Augustus's maximum building height"),
                    KeywordPair(keyword: "17.5 meters", definition: "Nero's reduced limit after the Great Fire"),
                    KeywordPair(keyword: "Building code", definition: "First height regulation in history"),
                    KeywordPair(keyword: "Foundation limit", definition: "Roman foundations couldn't support 7+ stories"),
                ],
                activity: .numberFishing(question: "Augustus limited insulae to what height (meters)?", correctAnswer: 20, decoys: [10, 15, 25, 30, 40]),
                notebookSummary: "Augustus: max 20m. Nero: max 17.5m after Great Fire. First building codes — written after collapses. Foundations were the limit.",
                visual: CardVisual(
                    type: .comparison,
                    title: "Building Height Limits",
                    values: ["equal": 0],
                    labels: ["Before code\nCollapse risk\nNo limit", "After Augustus\n20m maximum\nNero: 17.5m", "First building codes — written after collapses"],
                    steps: 3, caption: "Building codes were written in blood"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_2",
                buildingId: bid, buildingName: name,
                science: .architecture,
                environment: .cityMap, stationKey: "building",
                title: "Step 2: Tabernae Shops",
                italianTitle: "Le Tabernae",
                icon: "storefront.fill",
                lessonText: "The ground floor of every insula was prime real estate. Wide arched openings faced the street — tabernae. Bakers, butchers, wine sellers, and fullers (launderers) operated from these shops. A wooden mezzanine above the counter served as the shopkeeper's bedroom. The arch opening was both door and display window. Roman retail design: maximum visibility, minimum wasted space.",
                keywords: [
                    KeywordPair(keyword: "Taberna", definition: "Ground-floor shop with arched street opening"),
                    KeywordPair(keyword: "Mezzanine", definition: "Wooden sleeping loft above the shop counter"),
                    KeywordPair(keyword: "Fuller", definition: "Ancient launderer — cleaned clothes with urine"),
                    KeywordPair(keyword: "Arch opening", definition: "Served as both door and display window"),
                ],
                activity: .wordScramble(word: "TABERNAE", hint: "Ground-floor shops in Roman apartment buildings"),
                notebookSummary: "Tabernae: arched ground-floor shops. Bakers, butchers, wine sellers. Mezzanine bedroom above. Max visibility, min wasted space.",
                visual: CardVisual(
                    type: .crossSection,
                    title: "Taberna — Ground Floor Shop",
                    values: ["height": 4],
                    labels: ["Street entrance (arch)", "Shop floor", "Mezzanine bedroom above"],
                    steps: 3, caption: "Maximum visibility, minimum wasted space"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_3",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .cityMap, stationKey: "building",
                title: "Step 4: Brick Walls",
                italianTitle: "Muri Sempre Più Sottili",
                icon: "arrow.up.and.line.horizontal.and.arrow.down",
                lessonText: "Ground-floor walls were 60 cm thick — solid brick and concrete. Each floor above got thinner: 45 cm, then 30 cm, then timber-framed partitions on top. This wasn't carelessness — it was physics. Thicker lower walls carry the cumulative weight of every floor above. Thin upper walls reduce the load they contribute. The building is lightest where it's tallest. Weight management in vertical architecture.",
                keywords: [
                    KeywordPair(keyword: "60 cm", definition: "Ground floor wall thickness — solid brick"),
                    KeywordPair(keyword: "45 cm → 30 cm", definition: "Progressive thinning on upper floors"),
                    KeywordPair(keyword: "Cumulative load", definition: "Each floor carries all floors above it"),
                    KeywordPair(keyword: "Timber frame", definition: "Lightest construction on top floors"),
                ],
                activity: .multipleChoice(question: "Why did insula walls get thinner on upper floors?", options: ["To save money on bricks", "To reduce the load that lower walls carry", "Romans ran out of materials", "Upper floors weren't important"], correctIndex: 1),
                notebookSummary: "Insula walls: 60cm (ground) → 45cm → 30cm → timber (top). Thinner upper floors = less cumulative load. Lightest where tallest.",
                visual: CardVisual(
                    type: .crossSection,
                    title: "Wall Thickness Taper",
                    values: ["depth": 0.6],
                    labels: ["60cm (ground)", "45cm (2nd floor)", "30cm (3rd floor)", "Timber frame (top)"],
                    steps: 4, caption: "Lightest where it's tallest — weight management in vertical architecture"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_4",
                buildingId: bid, buildingName: name,
                science: .geometry,
                environment: .cityMap, stationKey: "building",
                title: "Spiral Stairways",
                italianTitle: "Scale a Chiocciola",
                icon: "arrow.uturn.up",
                lessonText: "With 6 stories and no elevators, stairs were the insula's backbone. Roman engineers used spiral staircases — they fit in a 2-meter circle and serve every floor. Each step is a wedge: wide at the outer wall, narrow at the center column. The central column (newel) carries the weight of every step. Spiral geometry packs maximum vertical travel into minimum floor space.",
                keywords: [
                    KeywordPair(keyword: "Spiral staircase", definition: "Circular stairs fitting in a 2m diameter"),
                    KeywordPair(keyword: "Newel", definition: "Central column carrying all the steps"),
                    KeywordPair(keyword: "Wedge step", definition: "Wide at outer wall, narrow at center"),
                    KeywordPair(keyword: "Floor space", definition: "Spiral uses minimum area for maximum height"),
                ],
                activity: .trueFalse(statement: "Roman insula spiral staircases fit within a 2-meter diameter circle", isTrue: true),
                notebookSummary: "Spiral stairs: 2m diameter, wedge steps, central newel column. Maximum vertical travel in minimum floor space.",
                visual: CardVisual(
                    type: .geometry,
                    title: "Spiral Staircase — 2m Circle",
                    values: ["diameter": 2, "height": 12],
                    labels: ["Wedge steps spiral up", "2m diameter = minimum footprint"],
                    steps: 3, caption: "Maximum vertical travel in minimum floor space"
                )
            ),

            // ── WORKSHOP (3 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_workshop_quarry_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "quarry",
                title: "Mortar Binding Science",
                italianTitle: "Scienza della Malta Legante",
                icon: "mountain.2.fill",
                lessonText: "Insula mortar had to be cheap and strong — these weren't luxury buildings. The recipe: 1 part lime, 4 parts local sand (no expensive pozzolana). The trade-off: slower setting, weaker bond, but one-third the cost. Builders compensated by making joints thicker — 2 cm instead of 1 cm — giving more mortar area for each brick. Economy and engineering, balanced on a budget.",
                keywords: [
                    KeywordPair(keyword: "1:4 ratio", definition: "Lime to local sand — cheaper than pozzolana mix"),
                    KeywordPair(keyword: "2 cm joints", definition: "Thicker mortar compensates for weaker recipe"),
                    KeywordPair(keyword: "Slower setting", definition: "Trade-off of using sand instead of volcanic ash"),
                ],
                activity: .trueFalse(statement: "Insula mortar used cheaper local sand instead of pozzolana, with thicker joints to compensate", isTrue: true),
                notebookSummary: "Insula mortar: 1:4 lime-to-sand (no pozzolana). Weaker but 1/3 cost. 2cm joints vs 1cm. Economy + engineering balanced.",
                visual: CardVisual(
                    type: .ratio,
                    title: "Cheap Mortar Recipe — 1:4",
                    values: ["Lime": 1, "Sand": 4],
                    labels: ["1:4 (no pozzolana) — weaker but 1/3 cost"],
                    steps: 3, caption: "Economy and engineering, balanced on a budget"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_clayPit_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "clayPit",
                title: "Tegulae and Imbrices",
                italianTitle: "Tegole e Embrici",
                icon: "rectangle.split.3x1.fill",
                lessonText: "Roman roofs used two interlocking tile types: tegulae (flat tiles with raised edges) and imbrices (half-round caps covering the joints). Rainwater channeled down the tegulae grooves and off the eaves. No nails needed — gravity and overlap held everything. A single insula used 3,000 tiles, each hand-molded from river clay. The system hasn't changed in 2,000 years. Modern Italian roofs still use it.",
                keywords: [
                    KeywordPair(keyword: "Tegula", definition: "Flat roof tile with raised edges"),
                    KeywordPair(keyword: "Imbrix", definition: "Half-round cap tile covering the joints"),
                    KeywordPair(keyword: "3,000 tiles", definition: "Number needed for one insula roof"),
                    KeywordPair(keyword: "No nails", definition: "Gravity and overlap hold tiles in place"),
                ],
                activity: .hangman(word: "TEGULAE", hint: "Flat Roman roof tiles with raised edges"),
                notebookSummary: "Tegulae (flat + edges) + imbrices (half-round caps). 3,000 tiles per insula. No nails — gravity holds them. Still used today.",
                visual: CardVisual(
                    type: .comparison,
                    title: "Tegulae + Imbrices — Interlocking Tiles",
                    values: ["equal": 0],
                    labels: ["Tegulae\nFlat tiles\nRaised edges", "Imbrices\nHalf-round caps\nCover the joints", "3,000 tiles per insula — no nails, gravity holds them"],
                    steps: 3, caption: "The system hasn't changed in 2,000 years"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_river_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "river",
                title: "Step 7: Mica Windows",
                italianTitle: "Vetro Piano e Finestre di Mica",
                icon: "drop.triangle.fill",
                lessonText: "Upper-floor insulae used two window materials: cast glass for the wealthy, and split mica (lapis specularis) for everyone else. Mica is a natural mineral that cleaves into paper-thin transparent sheets. It blocks wind but passes light. Romans mined it in Hispania. Glass was 10× more expensive but clearer. Most insulae had mica below the 3rd floor and open shutters above. Light was a luxury with a price tag.",
                keywords: [
                    KeywordPair(keyword: "Lapis specularis", definition: "Mica mineral split into transparent window sheets"),
                    KeywordPair(keyword: "Mica", definition: "Natural mineral that cleaves paper-thin"),
                    KeywordPair(keyword: "Hispania", definition: "Roman Spain — major mica mining source"),
                    KeywordPair(keyword: "10× cost", definition: "Glass vs mica price difference"),
                ],
                activity: .wordScramble(word: "MICA", hint: "Natural mineral split into transparent window sheets"),
                notebookSummary: "Windows: cast glass (expensive, clear) or mica/lapis specularis (cheap, translucent). Mica from Hispania. Light was a priced luxury.",
                visual: CardVisual(
                    type: .comparison,
                    title: "Glass vs Mica Windows",
                    values: ["equal": 0],
                    labels: ["Cast glass\nClear, expensive\nRich tenants", "Mica (lapis specularis)\nTranslucent, cheap\nBlocks wind + rain", "Light was a luxury — priced by floor"],
                    steps: 3, caption: "Most insulae had mica below the 3rd floor and open shutters above"
                )
            ),

            // ── FOREST (2 cards) ───────────────────────────────

            KnowledgeCard(
                id: "\(bid)_forest_oak_0",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .forest, stationKey: "oak",
                title: "Step 3: Floor Beams",
                italianTitle: "Interasse delle Travi",
                icon: "rectangle.split.3x1",
                lessonText: "Oak floor beams spanned the width of each apartment — typically 4 to 5 meters. Spaced 40 cm apart, they formed the skeleton that held concrete floors and the people above. The rule: beam depth equals 1/20 of the span. A 5-meter span needs 25 cm deep beams. Too shallow and the floor bounces. Too deep wastes wood. Roman carpenters knew the ratio by apprenticeship, not textbooks.",
                keywords: [
                    KeywordPair(keyword: "40 cm spacing", definition: "Distance between floor beams"),
                    KeywordPair(keyword: "1/20 rule", definition: "Beam depth = span ÷ 20"),
                    KeywordPair(keyword: "4-5 meters", definition: "Typical apartment width (beam span)"),
                    KeywordPair(keyword: "25 cm depth", definition: "Beam size for a 5-meter span"),
                ],
                activity: .numberFishing(question: "What depth beam (cm) for a 5-meter span using the 1/20 rule?", correctAnswer: 25, decoys: [10, 15, 30, 40, 50]),
                notebookSummary: "Oak floor beams: 40cm apart, spanning 4-5m. Rule: depth = span ÷ 20. 5m span → 25cm beam. Learned by apprenticeship.",
                visual: CardVisual(
                    type: .ratio,
                    title: "Beam Depth Rule: Span ÷ 20",
                    values: ["Span": 5, "Depth": 0.25],
                    labels: ["5m span → 25cm deep beam"],
                    steps: 3, caption: "Roman carpenters knew the ratio by apprenticeship, not textbooks"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_forest_poplar_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .forest, stationKey: "poplar",
                title: "Lightweight Upper Frames",
                italianTitle: "Telai Leggeri dei Piani Alti",
                icon: "square.stack.3d.up",
                lessonText: "Upper insula floors used poplar instead of oak. Why? Poplar weighs 40% less. On the 5th and 6th floors, every kilogram matters — the walls below carry it all. Poplar frames were filled with wattle and daub: woven sticks packed with clay. Cheap, light, and fast to build. The downside: highly flammable. Rome's great fires started on upper floors. The cheapest material had the highest cost.",
                keywords: [
                    KeywordPair(keyword: "Poplar", definition: "Light wood — 40% less than oak — for upper floors"),
                    KeywordPair(keyword: "Wattle and daub", definition: "Woven sticks + clay filling between frames"),
                    KeywordPair(keyword: "40% lighter", definition: "Poplar vs oak weight difference"),
                    KeywordPair(keyword: "Flammable", definition: "Upper floors burned easily — caused great fires"),
                ],
                activity: .multipleChoice(question: "Why was poplar used on upper insula floors instead of oak?", options: ["Stronger grain", "40% lighter", "Fire resistant", "Cheaper to cut"], correctIndex: 1),
                notebookSummary: "Upper floors: poplar (40% lighter than oak) + wattle and daub. Cheap, fast, light — but flammable. Rome's fires started high.",
                visual: CardVisual(
                    type: .comparison,
                    title: "Oak vs Poplar Frames",
                    values: ["equal": 0],
                    labels: ["Oak (lower floors)\nHeavy + strong\nFire resistant", "Poplar (upper floors)\n40% lighter\nBut flammable", "Rome's fires started high — where the cheapest wood was"],
                    steps: 3, caption: "The cheapest material had the highest cost"
                )
            ),

            // ── CRAFTING ROOM (2 cards) ────────────────────────

            KnowledgeCard(
                id: "\(bid)_craftingRoom_workbench_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .craftingRoom, stationKey: "workbench",
                title: "Step 4: Lime Plaster",
                italianTitle: "Ricetta della Malta di Calce",
                icon: "flask.fill",
                lessonText: "Insula mortar was the McDonald's of Roman cement — standardized, fast, everywhere. Recipe: 1 part aged lime putty (slaked at least 3 months), 4 parts river sand. Mix to the consistency of thick yogurt. Spread 2 cm thick between bricks. The 3-month aging is key — fresh lime putty has hot spots that crack. Patience is an ingredient. The oldest lime makes the strongest mortar.",
                keywords: [
                    KeywordPair(keyword: "Lime putty", definition: "Slaked lime aged 3+ months before use"),
                    KeywordPair(keyword: "3 months", definition: "Minimum aging time to eliminate hot spots"),
                    KeywordPair(keyword: "1:4 ratio", definition: "Lime putty to river sand"),
                    KeywordPair(keyword: "Thick yogurt", definition: "Correct mortar consistency"),
                ],
                activity: .numberFishing(question: "How many months must lime putty age before use?", correctAnswer: 3, decoys: [1, 2, 6, 9, 12]),
                notebookSummary: "Insula mortar: 1 lime putty (aged 3+ months) + 4 sand. Thick yogurt consistency. 2cm joints. Aging prevents cracking.",
                visual: CardVisual(
                    type: .ratio,
                    title: "Aged Lime Putty — 3+ Months",
                    values: ["Lime putty": 1, "Sand": 4],
                    labels: ["Aged 3+ months to eliminate hot spots", "Thick yogurt consistency"],
                    steps: 3, caption: "Patience is an ingredient — the oldest lime makes the strongest mortar"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_craftingRoom_furnace_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .craftingRoom, stationKey: "furnace",
                title: "Step 8: Fire Tiles",
                italianTitle: "Terracotta a 1000°C",
                icon: "flame.circle.fill",
                lessonText: "Insula tiles and bricks fire at 950-1050°C. Below 900°C, the clay stays porous and crumbles in rain. Above 1100°C, it vitrifies — becomes glassy and brittle. The sweet spot fuses silica particles into a ceramic matrix that's waterproof but not brittle. Roman kilns held temperature by adjusting the air vent — wider for hotter, narrower for cooler. Precision from a hole in a wall.",
                keywords: [
                    KeywordPair(keyword: "950-1050°C", definition: "Sweet spot for terracotta — waterproof, not brittle"),
                    KeywordPair(keyword: "Vitrification", definition: "Above 1100°C — glassy and brittle"),
                    KeywordPair(keyword: "Ceramic matrix", definition: "Fused silica particles forming waterproof tile"),
                    KeywordPair(keyword: "Air vent", definition: "Kiln temperature controlled by opening width"),
                ],
                activity: .fillInBlanks(text: "Below ___°C clay crumbles. Above ___°C it vitrifies. Sweet spot: ___-1050°C", blanks: ["900", "1100", "950"], distractors: ["600", "800", "1200"]),
                notebookSummary: "Terracotta: 950-1050°C sweet spot. Below 900°C = crumbly. Above 1100°C = glassy/brittle. Air vent controls kiln temperature.",
                visual: CardVisual(
                    type: .temperature,
                    title: "Brick Firing Sweet Spot",
                    values: ["transition": 950, "max": 1200],
                    labels: ["Below 900°C = crumbly", "Above 1100°C = brittle"],
                    steps: 3, caption: "Precision from a hole in a wall — air vent controls everything"
                )
            ),
        ]
    }

    // MARK: - Harbor (12 cards)

    static var harborCards: [KnowledgeCard] {
        let bid = 6
        let name = "Harbor"
        return [
            // ── CITY MAP (5 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_cityMap_building_0",
                buildingId: bid, buildingName: name,
                science: .architecture,
                environment: .cityMap, stationKey: "building",
                title: "Portus — Rome's Gateway",
                italianTitle: "Porto — La Porta di Roma",
                icon: "ferry.fill",
                lessonText: "Rome couldn't feed itself. Grain ships from Egypt docked at Portus, 30 km from the city. Emperor Claudius dug a 200-acre artificial harbor basin. Trajan expanded it into a hexagonal inner harbor — six straight walls distributing wave force equally. 350 ships unloaded simultaneously. The harbor that fed a million people was itself an engineering marvel no one remembers.",
                keywords: [
                    KeywordPair(keyword: "Portus", definition: "Rome's main harbor — 30 km from the city"),
                    KeywordPair(keyword: "Hexagonal basin", definition: "Trajan's 6-sided harbor distributing wave force"),
                    KeywordPair(keyword: "350 ships", definition: "Could dock simultaneously at Portus"),
                    KeywordPair(keyword: "200 acres", definition: "Size of Claudius's artificial harbor basin"),
                ],
                activity: .numberFishing(question: "How many ships could dock simultaneously at Portus?", correctAnswer: 350, decoys: [50, 150, 500, 750, 1000]),
                notebookSummary: "Portus: 30 km from Rome. Claudius dug 200-acre basin. Trajan added hexagonal inner harbor. 350 ships at once. Fed a million people.",
                visual: CardVisual(
                    type: .geometry,
                    title: "Portus — 200-Acre Harbor",
                    values: ["diameter": 200],
                    labels: ["Hexagonal inner harbor", "350 ships simultaneously"],
                    steps: 3, caption: "The harbor that fed a million people was itself an engineering marvel"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_1",
                buildingId: bid, buildingName: name,
                science: .physics,
                environment: .cityMap, stationKey: "building",
                title: "Step 1: Tides & Currents",
                italianTitle: "Fisica delle Onde",
                icon: "water.waves",
                lessonText: "Mediterranean storms generate waves 3-4 meters high. A wave's force on impact equals roughly half the water's weight times the square of its speed. A 3-meter wave hits a wall with 30 tons of force per meter. Roman breakwaters needed to absorb this — not resist it. Curved walls redirect wave energy sideways. The strongest wall isn't the thickest. It's the one that refuses to fight.",
                keywords: [
                    KeywordPair(keyword: "30 tons/meter", definition: "Impact force of a 3-meter wave"),
                    KeywordPair(keyword: "Energy absorption", definition: "Breakwater strategy — absorb, don't resist"),
                    KeywordPair(keyword: "Curved walls", definition: "Redirect wave force sideways instead of blocking"),
                    KeywordPair(keyword: "3-4 meters", definition: "Typical Mediterranean storm wave height"),
                ],
                activity: .numberFishing(question: "Force (tons per meter) of a 3-meter wave hitting a wall?", correctAnswer: 30, decoys: [5, 10, 50, 75, 100]),
                notebookSummary: "3m wave = 30 tons/meter impact force. Breakwaters absorb, don't resist. Curved walls redirect energy sideways.",
                visual: CardVisual(
                    type: .force,
                    title: "Wave Impact Force",
                    values: ["columns": 3, "load": 30, "arrows": 3, "perColumn": 10],
                    labels: ["3m wave = 30 tons/meter impact force"],
                    steps: 3, caption: "The strongest wall isn't the thickest — it's the one that refuses to fight"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_2",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .cityMap, stationKey: "building",
                title: "Step 2: Underwater Concrete",
                italianTitle: "Cassoni Stagni",
                icon: "square.dashed",
                lessonText: "How do you build in water? Build a wall first. Roman cofferdams were double rings of wooden piles driven into the seabed, the gap packed with clay. Workers pumped out the trapped water using Archimedean screws. Now you have a dry workspace underwater. Pour concrete, wait for it to set, remove the cofferdam. Building underwater is just building on land — if you can make the water leave first.",
                keywords: [
                    KeywordPair(keyword: "Cofferdam", definition: "Watertight enclosure for building underwater"),
                    KeywordPair(keyword: "Double ring", definition: "Two rows of wooden piles with clay between"),
                    KeywordPair(keyword: "Archimedean screw", definition: "Spiral pump removing water from the enclosure"),
                    KeywordPair(keyword: "Dry workspace", definition: "Pumped-out area for pouring concrete"),
                ],
                activity: .wordScramble(word: "COFFERDAM", hint: "Watertight enclosure for building in water"),
                notebookSummary: "Cofferdam: double ring of piles + clay. Archimedean screws pump water out. Build dry, then remove walls. Underwater = on land.",
                visual: CardVisual(
                    type: .crossSection,
                    title: "Cofferdam — Build Dry Underwater",
                    values: ["depth": 4],
                    labels: ["Water level", "Double pile wall + clay", "Dry building area", "Archimedean screw pumps"],
                    steps: 4, caption: "Building underwater is just building on land — if you can make the water leave"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_3",
                buildingId: bid, buildingName: name,
                science: .physics,
                environment: .cityMap, stationKey: "building",
                title: "Step 3: The Breakwater",
                italianTitle: "Forza del Frangiflutti",
                icon: "waveform.path",
                lessonText: "Vitruvius specified breakwater blocks weighing 10-15 tons minimum. Why? Wave uplift. A wave doesn't just push — it lifts. As water surges over a block, low pressure above creates suction. A 5-ton block gets pulled off the seabed. A 15-ton block stays. The calculation: block weight must exceed 3× the uplift force. Overbuilding by 3× sounds wasteful until the first storm proves you right.",
                keywords: [
                    KeywordPair(keyword: "Wave uplift", definition: "Suction that pulls blocks upward from the seabed"),
                    KeywordPair(keyword: "3× rule", definition: "Block weight must be 3× the uplift force"),
                    KeywordPair(keyword: "10-15 tons", definition: "Vitruvius's minimum breakwater block weight"),
                    KeywordPair(keyword: "Low pressure", definition: "Water flowing over creates suction above"),
                ],
                activity: .multipleChoice(question: "Block weight must exceed how many times the wave uplift force?", options: ["1.5×", "2×", "3×", "5×"], correctIndex: 2),
                notebookSummary: "Breakwater: 10-15 ton blocks minimum. Wave uplift creates suction. 3× rule: block weight ≥ 3× uplift force.",
                visual: CardVisual(
                    type: .force,
                    title: "Breakwater Block Resistance",
                    values: ["columns": 4, "load": 45, "arrows": 4, "perColumn": 15],
                    labels: ["10-15 ton blocks resist 3× wave uplift"],
                    steps: 3, caption: "Overbuilding by 3× sounds wasteful until the first storm proves you right"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_4",
                buildingId: bid, buildingName: name,
                science: .optics,
                environment: .cityMap, stationKey: "building",
                title: "Step 7: The Lighthouse",
                italianTitle: "Ottica del Faro",
                icon: "lighthouse.fill",
                lessonText: "Portus had a lighthouse modeled after Alexandria's Pharos — 50 meters tall. At the top, a bonfire reflected off polished bronze mirrors. The curved mirror shape concentrated light into a beam visible 50 km away. Keepers fed the fire every 2 hours through the night. One lighthouse guided 350 ships daily. The simplest technology — fire and reflection — solving the hardest problem: finding your way in the dark.",
                keywords: [
                    KeywordPair(keyword: "Pharos", definition: "Lighthouse design from Alexandria — model for Portus"),
                    KeywordPair(keyword: "Bronze mirrors", definition: "Polished curved reflectors concentrating firelight"),
                    KeywordPair(keyword: "50 km", definition: "Visible range of the lighthouse beam"),
                    KeywordPair(keyword: "50 meters", definition: "Height of the Portus lighthouse"),
                ],
                activity: .hangman(word: "PHAROS", hint: "Ancient lighthouse design from Alexandria"),
                notebookSummary: "Portus lighthouse: 50m tall, bronze mirror reflectors. Visible 50 km. Fire + curved reflection = beam. Guided 350 ships daily.",
                visual: CardVisual(
                    type: .geometry,
                    title: "Portus Lighthouse",
                    values: ["diameter": 50, "height": 50],
                    labels: ["50m tall", "Bronze mirror reflects fire beam", "Visible 50 km at sea"],
                    steps: 3, caption: "Fire and reflection — solving the hardest problem: finding your way in the dark"
                )
            ),

            // ── WORKSHOP (3 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_workshop_quarry_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "quarry",
                title: "Step 3: Breakwater Stone",
                italianTitle: "Banchine in Pietra",
                icon: "mountain.2.fill",
                lessonText: "Harbor quays needed stone that resists both crushing weight and saltwater. Tufa — soft volcanic rock — was the standard. It's light enough to transport by barge, strong enough to support loaded wagons, and porous enough that salt crystals don't crack it (they fill the pores instead of expanding). Dense stones like marble crack in saltwater. The softest stone wins at the harbor.",
                keywords: [
                    KeywordPair(keyword: "Tufa", definition: "Soft volcanic rock ideal for harbor quays"),
                    KeywordPair(keyword: "Porous", definition: "Salt fills pores instead of cracking the stone"),
                    KeywordPair(keyword: "Salt resistance", definition: "Soft stone absorbs salt, hard stone cracks"),
                ],
                activity: .trueFalse(statement: "Porous tufa resists saltwater better than dense marble because salt fills its pores", isTrue: true),
                notebookSummary: "Harbor quays: tufa — soft volcanic rock. Porous = salt fills pores instead of cracking. Soft stone beats hard at the harbor.",
                visual: CardVisual(
                    type: .comparison,
                    title: "Harbor Stone Selection",
                    values: ["equal": 0],
                    labels: ["Tufa (volcanic)\nPorous — salt fills\npores harmlessly", "Marble/granite\nDense — salt cracks\nfrom inside", "Soft stone beats hard stone at the harbor"],
                    steps: 3, caption: "The softest stone wins at the harbor"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_volcano_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .workshop, stationKey: "volcano",
                title: "Step 2: Marine Concrete",
                italianTitle: "Calcestruzzo Marino",
                icon: "flame.fill",
                lessonText: "Roman marine concrete was mixed with seawater — on purpose. The salt triggers a unique crystal: Al-tobermorite. This mineral grows inside the concrete over centuries, actually making it stronger in seawater. Modern Portland cement dissolves in salt. Roman marine concrete thrives in it. The recipe: volcanic ash, lime, seawater, and volcanic rock aggregate. The ocean that destroys everything else makes this concrete immortal.",
                keywords: [
                    KeywordPair(keyword: "Al-tobermorite", definition: "Crystal that grows in Roman marine concrete"),
                    KeywordPair(keyword: "Seawater", definition: "Mixed intentionally — triggers strengthening crystal"),
                    KeywordPair(keyword: "Portland cement", definition: "Modern concrete that dissolves in salt"),
                ],
                activity: .wordScramble(word: "TOBERMORITE", hint: "Crystal that grows inside Roman marine concrete — gets stronger in seawater"),
                notebookSummary: "Marine concrete: ash + lime + seawater → Al-tobermorite crystal. Grows stronger over centuries in salt. Modern Portland dissolves.",
                visual: CardVisual(
                    type: .comparison,
                    title: "Roman vs Modern Marine Concrete",
                    values: ["equal": 0],
                    labels: ["Roman marine concrete\nAl-tobermorite crystals\nStronger over centuries", "Modern Portland\nDissolves in salt\nFails in decades", "Seawater is the secret ingredient"],
                    steps: 3, caption: "The ocean that destroys everything else makes this concrete immortal"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_mine_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "mine",
                title: "Step 8: Channel Markers",
                italianTitle: "Rivestimento in Piombo",
                icon: "shield.lefthalf.filled",
                lessonText: "Wooden ships rot. Marine worms (teredo) bore through hulls in months. Roman solution: nail thin lead sheets below the waterline. Lead is soft, moldable, and impervious to salt and worms. Copper tacks held it flush. The lead sheeting added weight but doubled the hull's lifespan. Every warship and grain freighter in the Roman fleet wore lead armor. Protection weighs something. It always does.",
                keywords: [
                    KeywordPair(keyword: "Teredo", definition: "Marine worm that bores through wooden hulls"),
                    KeywordPair(keyword: "Lead sheeting", definition: "Thin lead nailed below the waterline"),
                    KeywordPair(keyword: "Copper tacks", definition: "Hold lead flush against the hull"),
                    KeywordPair(keyword: "Double lifespan", definition: "Lead sheeting's benefit to wooden hulls"),
                ],
                activity: .hangman(word: "TEREDO", hint: "Marine worm that destroys wooden ship hulls"),
                notebookSummary: "Lead sheeting below waterline: stops teredo worms, resists salt. Copper tacks hold it. Doubled hull lifespan. Protection has weight.",
                visual: CardVisual(
                    type: .crossSection,
                    title: "Lead Hull Protection",
                    values: ["depth": 3],
                    labels: ["Wooden hull", "Copper tacks", "Lead sheeting (waterline)"],
                    steps: 3, caption: "Protection weighs something — it always does"
                )
            ),

            // ── FOREST (2 cards) ───────────────────────────────

            KnowledgeCard(
                id: "\(bid)_forest_oak_0",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .forest, stationKey: "oak",
                title: "Warehouse Trusses",
                italianTitle: "Capriate dei Magazzini",
                icon: "triangle.fill",
                lessonText: "Portus had 200 warehouses (horrea) storing grain, oil, wine, and marble. Each needed wide-span roofs for forklift-free loading. Oak trusses spanned 12-15 meters — wide enough for ox carts. The truss design: two sloping rafters, a horizontal tie beam, and vertical queen posts. Oak was selected for salt air resistance — its tannins naturally repel moisture. The harbor's skeleton was oak.",
                keywords: [
                    KeywordPair(keyword: "Horrea", definition: "Roman warehouse — 200 at Portus"),
                    KeywordPair(keyword: "Queen posts", definition: "Vertical members in the truss supporting rafters"),
                    KeywordPair(keyword: "12-15 meters", definition: "Warehouse truss span for ox cart access"),
                    KeywordPair(keyword: "Tannins", definition: "Oak's natural moisture-repelling chemicals"),
                ],
                activity: .wordScramble(word: "HORREA", hint: "Roman warehouses — 200 of them stored grain at Portus"),
                notebookSummary: "Horrea: 200 warehouses at Portus. Oak queen-post trusses spanning 12-15m. Tannins resist salt air moisture.",
                visual: CardVisual(
                    type: .force,
                    title: "Warehouse Truss Structure",
                    values: ["columns": 4, "height": 15, "perColumn": 5, "arrows": 3],
                    labels: ["Queen-post trusses spanning 12-15m"],
                    steps: 3, caption: "The harbor's skeleton was oak — tannins naturally repel moisture"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_forest_poplar_0",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .forest, stationKey: "poplar",
                title: "Step 2 Support: Cofferdam",
                italianTitle: "Casseforme per Cassoni",
                icon: "square.stack.3d.up",
                lessonText: "Cofferdam piles were driven into the seabed 3-4 meters deep. Poplar was the choice — it's straight, light, and its wet wood actually swells tighter. The piles formed a double ring, 2 meters apart, packed with puddle clay between. Poplar's fast growth meant replacements were always available. After the concrete set, workers pulled the piles for reuse. Temporary by design, permanent in effect.",
                keywords: [
                    KeywordPair(keyword: "Poplar piles", definition: "Driven 3-4m into the seabed for cofferdams"),
                    KeywordPair(keyword: "Swells wet", definition: "Poplar expands in water — tighter seal"),
                    KeywordPair(keyword: "Puddle clay", definition: "Packed between double ring for waterproofing"),
                    KeywordPair(keyword: "Reusable", definition: "Piles pulled and reused after concrete sets"),
                ],
                activity: .trueFalse(statement: "Poplar wood swells when wet, making it ideal for watertight cofferdam piles", isTrue: true),
                notebookSummary: "Cofferdam: poplar piles 3-4m deep, double ring with puddle clay. Poplar swells wet = tighter seal. Reusable. Temporary → permanent.",
                visual: CardVisual(
                    type: .crossSection,
                    title: "Poplar Piles Swell Tight",
                    values: ["depth": 4],
                    labels: ["Sea level", "Double ring of piles", "Puddle clay seal", "3-4m deep"],
                    steps: 4, caption: "Temporary by design, permanent in effect"
                )
            ),

            // ── CRAFTING ROOM (2 cards) ────────────────────────

            KnowledgeCard(
                id: "\(bid)_craftingRoom_workbench_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .craftingRoom, stationKey: "workbench",
                title: "Step 3: Marine Mortar",
                italianTitle: "Miscela di Calcestruzzo Marino",
                icon: "flask.fill",
                lessonText: "Marine concrete recipe: 1 part lime, 3 parts volcanic ash, seawater (not fresh!). The critical difference — mix and pour into wooden forms lowered into the sea. The concrete sets underwater in 7 days. After curing, it continues strengthening for centuries as Al-tobermorite crystals grow. Roman engineers discovered that the sea's worst quality (salt) was the concrete's best ingredient.",
                keywords: [
                    KeywordPair(keyword: "Seawater", definition: "Used instead of fresh water — triggers crystal growth"),
                    KeywordPair(keyword: "7 days", definition: "Underwater setting time for marine concrete"),
                    KeywordPair(keyword: "Wooden forms", definition: "Lowered into the sea to contain wet concrete"),
                ],
                activity: .fillInBlanks(text: "Marine concrete: ___ part lime, ___ parts volcanic ash, mixed with ___ (not fresh water!)", blanks: ["1", "3", "seawater"], distractors: ["2", "4", "rainwater"]),
                notebookSummary: "Marine concrete: 1 lime + 3 ash + seawater. Pour into forms in the sea. Sets in 7 days, strengthens for centuries.",
                visual: CardVisual(
                    type: .ratio,
                    title: "Marine Concrete — 1:3 + Seawater",
                    values: ["Lime": 1, "Volcanic ash": 3],
                    labels: ["Mixed with seawater (not fresh!)", "Sets underwater in 7 days"],
                    steps: 3, caption: "The sea's worst quality (salt) was the concrete's best ingredient"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_craftingRoom_furnace_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .craftingRoom, stationKey: "furnace",
                title: "Lead Casting at 327°C",
                italianTitle: "Fusione del Piombo a 327°C",
                icon: "flame.circle.fill",
                lessonText: "Lead melts at 327°C — one of the lowest melting points of any useful metal. Pour molten lead into flat sand molds, wait 10 minutes, and you have a sheet ready for hammering onto a ship hull. Roman foundries at Portus cast 200 sheets per day. The low temperature meant wood-fired furnaces were enough — no bellows needed. The easiest metal to melt was the most useful at the harbor.",
                keywords: [
                    KeywordPair(keyword: "327°C", definition: "Lead's melting point — very low for a metal"),
                    KeywordPair(keyword: "Sand molds", definition: "Flat forms for casting lead sheets"),
                    KeywordPair(keyword: "200 sheets/day", definition: "Output of a Portus lead foundry"),
                    KeywordPair(keyword: "No bellows", definition: "Low temperature — wood fire is enough"),
                ],
                activity: .numberFishing(question: "At what temperature (°C) does lead melt?", correctAnswer: 327, decoys: [100, 200, 450, 600, 900]),
                notebookSummary: "Lead melts at 327°C — wood fire, no bellows. Sand molds, 10 min cooling. 200 sheets/day at Portus. Easiest metal, most useful.",
                visual: CardVisual(
                    type: .temperature,
                    title: "Lead Casting at 327°C",
                    values: ["transition": 327, "max": 600],
                    labels: ["Solid lead", "Molten lead"],
                    steps: 3, caption: "The easiest metal to melt was the most useful at the harbor"
                )
            ),
        ]
    }

    // MARK: - Colosseum (13 cards)

    static var colosseumCards: [KnowledgeCard] {
        let bid = 2
        let name = "Colosseum"
        return [
            // ── CITY MAP (5 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_cityMap_building_0",
                buildingId: bid, buildingName: name,
                science: .architecture,
                environment: .cityMap, stationKey: "building",
                title: "50,000 Seats",
                italianTitle: "50.000 Posti a Sedere",
                icon: "sportscourt.fill",
                lessonText: "The Colosseum held 50,000 spectators — and emptied in 15 minutes. 76 entrances, each numbered. Your ticket (tessera) listed your entrance, section, row, and seat. No confusion, no bottlenecks. The corridors (vomitoria) were angled to accelerate crowd flow. Modern stadiums still use this system unchanged. The Romans didn't just build a stadium — they invented crowd management.",
                keywords: [
                    KeywordPair(keyword: "50,000", definition: "Spectator capacity of the Colosseum"),
                    KeywordPair(keyword: "76 entrances", definition: "Numbered gates for crowd distribution"),
                    KeywordPair(keyword: "Tessera", definition: "Ticket listing entrance, section, row, and seat"),
                    KeywordPair(keyword: "Vomitoria", definition: "Angled corridors accelerating crowd exit"),
                ],
                activity: .numberFishing(question: "How many minutes to empty the Colosseum?", correctAnswer: 15, decoys: [5, 30, 45, 60, 90]),
                notebookSummary: "Colosseum: 50,000 seats, 76 numbered entrances. Tessera tickets. Vomitoria corridors empty in 15 min. Invented crowd management.",
                visual: CardVisual(
                    type: .geometry,
                    title: "Colosseum — 76 Exits, 15 Minutes",
                    values: ["diameter": 188, "height": 48],
                    labels: ["76 numbered entrances", "50,000 seats", "Vomitoria angled corridors"],
                    steps: 3, caption: "Romans didn't just build a stadium — they invented crowd management"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_1",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .cityMap, stationKey: "building",
                title: "Draining Nero's Lake",
                italianTitle: "Prosciugare il Lago di Nerone",
                icon: "drop.degreesign.fill",
                lessonText: "Emperor Vespasian built the Colosseum on Nero's private pleasure lake — a political statement. But building on a lakebed meant solving drainage. Engineers drove hundreds of oak piles into the clay, laid a concrete raft foundation 13 meters deep, and installed a permanent drainage system of lead pipes. The lake water was redirected to the city sewers. The foundation cost more than the building above it.",
                keywords: [
                    KeywordPair(keyword: "Nero's lake", definition: "Drained to build the Colosseum — a political act"),
                    KeywordPair(keyword: "13 meters", definition: "Depth of the concrete raft foundation"),
                    KeywordPair(keyword: "Oak piles", definition: "Driven into clay to stabilize the lakebed"),
                    KeywordPair(keyword: "Vespasian", definition: "Emperor who turned Nero's luxury into public arena"),
                ],
                activity: .numberFishing(question: "How deep (meters) is the Colosseum's foundation?", correctAnswer: 13, decoys: [5, 8, 20, 30, 40]),
                notebookSummary: "Built on Nero's drained lake. Oak piles + 13m concrete raft foundation + lead drain pipes. Foundation cost more than the building.",
                visual: CardVisual(
                    type: .crossSection,
                    title: "Foundation on a Drained Lake",
                    values: ["depth": 13],
                    labels: ["Arena floor level", "Oak piles driven into clay", "13m concrete raft", "Lead drainage pipes"],
                    steps: 4, caption: "The foundation cost more than the building above it"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_2",
                buildingId: bid, buildingName: name,
                science: .architecture,
                environment: .cityMap, stationKey: "building",
                title: "Four Classical Orders",
                italianTitle: "Quattro Ordini Classici",
                icon: "building.columns.fill",
                lessonText: "The Colosseum's facade is a textbook — literally. Each of the four stories uses a different column order: Doric (ground, simplest), Ionic (second, scroll capitals), Corinthian (third, acanthus leaves), Composite (top, combined). This wasn't just decoration. Each order is progressively lighter in appearance, making the building seem to float upward. Architecture is visual physics — heavier at the bottom, lighter at the top.",
                keywords: [
                    KeywordPair(keyword: "Doric", definition: "Ground floor — simplest, sturdiest column"),
                    KeywordPair(keyword: "Ionic", definition: "Second floor — scroll-shaped capitals"),
                    KeywordPair(keyword: "Corinthian", definition: "Third floor — ornate acanthus leaf capitals"),
                    KeywordPair(keyword: "Composite", definition: "Top floor — combined Ionic + Corinthian"),
                ],
                activity: .multipleChoice(question: "Which column order is on the ground floor of the Colosseum?", options: ["Ionic", "Corinthian", "Doric", "Composite"], correctIndex: 2),
                notebookSummary: "4 column orders bottom→top: Doric → Ionic → Corinthian → Composite. Each lighter than the last. Visual physics.",
                visual: CardVisual(
                    type: .crossSection,
                    title: "Four Orders — Bottom to Top",
                    values: ["height": 48],
                    labels: ["Doric (ground — simplest)", "Ionic (2nd — scroll capitals)", "Corinthian (3rd — acanthus leaves)", "Composite (top — combined)"],
                    steps: 4, caption: "Architecture is visual physics — heavier at the bottom, lighter at the top"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_3",
                buildingId: bid, buildingName: name,
                science: .acoustics,
                environment: .cityMap, stationKey: "building",
                title: "Step 6: Acoustic Bowl",
                italianTitle: "Catino Acustico",
                icon: "speaker.wave.3.fill",
                lessonText: "The Colosseum's elliptical shape isn't arbitrary — it's acoustic engineering. Sound waves from the arena floor bounce off the curved walls and focus toward the upper seats. Spectators 50 meters away could hear announcements clearly. The seating rake (angle) was precisely 37° — steep enough for sound reflection, gentle enough for comfortable sitting. The bowl shape turns architecture into an amplifier.",
                keywords: [
                    KeywordPair(keyword: "Elliptical shape", definition: "Oval form that focuses sound waves"),
                    KeywordPair(keyword: "37° rake", definition: "Seating angle for optimal acoustics"),
                    KeywordPair(keyword: "Sound reflection", definition: "Curved walls bounce sound to upper tiers"),
                    KeywordPair(keyword: "50 meters", definition: "Distance at which speech remained audible"),
                ],
                activity: .numberFishing(question: "What angle (degrees) were the Colosseum seats raked for acoustics?", correctAnswer: 37, decoys: [15, 25, 45, 55, 70]),
                notebookSummary: "Elliptical shape focuses sound. 37° seating rake for optimal acoustics. Speech audible 50m away. Bowl = amplifier.",
                visual: CardVisual(
                    type: .geometry,
                    title: "Acoustic Bowl — 37° Rake",
                    values: ["diameter": 188, "height": 37],
                    labels: ["Elliptical shape focuses sound waves", "37° seating rake", "Audible 50m away"],
                    steps: 3, caption: "The bowl shape turns architecture into an amplifier"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_4",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .cityMap, stationKey: "building",
                title: "Step 7: The Hypogeum",
                italianTitle: "L'Ipogeo",
                icon: "arrow.down.square.fill",
                lessonText: "Beneath the arena floor lies the hypogeum — two levels of underground tunnels, animal cages, and 80 vertical shafts with rope-and-pulley elevators. Stagehands could lift a lion from the basement to the arena in 7 seconds. Trap doors in the wooden floor opened on cue. The audience never saw the machinery. The greatest show in Rome ran on invisible infrastructure — the definition of engineering.",
                keywords: [
                    KeywordPair(keyword: "Hypogeum", definition: "Two-level underground network beneath the arena"),
                    KeywordPair(keyword: "80 shafts", definition: "Vertical elevators for lifting animals and scenery"),
                    KeywordPair(keyword: "7 seconds", definition: "Time to lift an animal from basement to arena"),
                    KeywordPair(keyword: "Trap doors", definition: "Hidden openings in the wooden arena floor"),
                ],
                activity: .wordScramble(word: "HYPOGEUM", hint: "Underground tunnel network beneath the Colosseum arena"),
                notebookSummary: "Hypogeum: 2 underground levels, 80 elevator shafts, trap doors. Lion from basement to arena in 7 seconds. Invisible infrastructure.",
                visual: CardVisual(
                    type: .crossSection,
                    title: "The Hypogeum — Underground Machine",
                    values: ["depth": 7],
                    labels: ["Arena floor + trap doors", "Level 1: animal cages", "Level 2: storage + tunnels", "80 rope-and-pulley elevators"],
                    steps: 4, caption: "The greatest show in Rome ran on invisible infrastructure"
                )
            ),

            // ── WORKSHOP (4 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_workshop_quarry_0",
                buildingId: bid, buildingName: name,
                science: .geology,
                environment: .workshop, stationKey: "quarry",
                title: "Step 2: Travertine Foundation",
                italianTitle: "Travertino da Tivoli",
                icon: "mountain.2.fill",
                lessonText: "100,000 cubic meters of travertine — quarried from Tivoli, 30 km east. Travertine is a limestone deposited by hot springs. It's riddled with air pockets that make it light (30% lighter than marble) but still strong in compression. Those holes also let iron clamps grip deep inside the stone. After the Middle Ages, people stole the clamps — the holes you see today are vandalism scars, not design.",
                keywords: [
                    KeywordPair(keyword: "Travertine", definition: "Hot-spring limestone — light with air pockets"),
                    KeywordPair(keyword: "Tivoli", definition: "Town 30 km east — source of all Colosseum stone"),
                    KeywordPair(keyword: "100,000 m³", definition: "Volume of travertine used in the Colosseum"),
                    KeywordPair(keyword: "30% lighter", definition: "Travertine vs marble weight comparison"),
                ],
                activity: .hangman(word: "TRAVERTINE", hint: "Limestone from Tivoli's hot springs — 30% lighter than marble"),
                notebookSummary: "Travertine from Tivoli: hot-spring limestone, 30% lighter than marble. 100,000 m³ used. Air pockets grip iron clamps.",
                visual: CardVisual(
                    type: .comparison,
                    title: "Travertine vs Marble",
                    values: ["equal": 0],
                    labels: ["Travertine\n30% lighter\nAir pockets grip clamps", "Marble\nHeavier, denser\nClamps can't grip", "100,000 m³ quarried from Tivoli — 30 km east"],
                    steps: 3, caption: "Those holes you see today are vandalism scars, not design"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_mine_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "mine",
                title: "Step 3: Iron Cramps",
                italianTitle: "300 Tonnellate di Grappe di Ferro",
                icon: "link",
                lessonText: "No mortar joins the Colosseum's travertine blocks. Instead, 300 tons of iron clamps lock each stone to its neighbor. Molten lead was poured into drill holes to anchor each clamp. This system flexes slightly in earthquakes — rigid mortar would crack. After Rome fell, looters pried out the clamps for iron. The building survived 2,000 years of earthquakes but couldn't survive human greed.",
                keywords: [
                    KeywordPair(keyword: "300 tons", definition: "Weight of iron clamps used in the Colosseum"),
                    KeywordPair(keyword: "No mortar", definition: "Blocks joined by iron clamps, not cement"),
                    KeywordPair(keyword: "Lead anchoring", definition: "Molten lead poured into holes to hold clamps"),
                    KeywordPair(keyword: "Earthquake flex", definition: "Clamp joints absorb seismic movement"),
                ],
                activity: .trueFalse(statement: "The Colosseum uses no mortar — 300 tons of iron clamps hold the stone blocks together", isTrue: true),
                notebookSummary: "No mortar: 300 tons iron clamps + molten lead anchors. Flexes in earthquakes. Clamps later stolen — scars visible today.",
                visual: CardVisual(
                    type: .force,
                    title: "300 Tons of Iron Clamps",
                    values: ["columns": 3, "load": 300, "arrows": 3, "perColumn": 100],
                    labels: ["Iron clamps lock block to block", "Molten lead anchors each clamp", "Flexes in earthquakes — rigid mortar would crack"],
                    steps: 3, caption: "Survived 2,000 years of earthquakes but not human greed"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_market_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "market",
                title: "Step 8: Silk Canvas",
                italianTitle: "Velario di Seta",
                icon: "sun.max.trianglebadge.exclamationmark.fill",
                lessonText: "Rome's sun blazed on 50,000 spectators. Solution: the velarium — a massive retractable awning made from silk and linen. 240 masts around the rim held the rigging. 1,000 sailors from the Imperial fleet operated the ropes. The silk was imported from China via the Silk Road. It took 30 minutes to deploy. The world's first retractable roof was operated by the world's first navy.",
                keywords: [
                    KeywordPair(keyword: "Velarium", definition: "Retractable silk awning shading the Colosseum"),
                    KeywordPair(keyword: "240 masts", definition: "Wooden poles around the rim holding rigging"),
                    KeywordPair(keyword: "1,000 sailors", definition: "Imperial fleet crew who operated the ropes"),
                    KeywordPair(keyword: "Silk Road", definition: "Trade route importing silk from China"),
                ],
                activity: .numberFishing(question: "How many sailors operated the Colosseum's velarium?", correctAnswer: 1000, decoys: [100, 250, 500, 2000, 5000]),
                notebookSummary: "Velarium: silk + linen retractable awning. 240 masts, 1,000 sailors. Silk from China. 30 min to deploy. First retractable roof.",
                visual: CardVisual(
                    type: .geometry,
                    title: "The Velarium — Retractable Awning",
                    values: ["diameter": 188, "height": 240],
                    labels: ["240 masts around the rim", "Silk + linen canopy", "1,000 sailors operate ropes"],
                    steps: 3, caption: "The world's first retractable roof — operated by the world's first navy"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_river_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .workshop, stationKey: "river",
                title: "Foundation Curing",
                italianTitle: "Maturazione delle Fondamenta",
                icon: "drop.triangle.fill",
                lessonText: "The Colosseum's concrete foundation needed 2 years to cure fully. Workers kept it wet — pouring water over the surface daily. Hydration is the key chemical reaction: water molecules bond with lime particles to form calcium hydroxide crystals. Dry concrete doesn't cure — it crumbles. The irony: the building that drained a lake needed water to set its own foundation. Water gives, water takes.",
                keywords: [
                    KeywordPair(keyword: "2 years", definition: "Full curing time for the Colosseum foundation"),
                    KeywordPair(keyword: "Hydration", definition: "Water + lime = calcium hydroxide crystals"),
                    KeywordPair(keyword: "Daily watering", definition: "Workers kept the foundation wet during curing"),
                ],
                activity: .numberFishing(question: "How many years did the Colosseum's foundation take to cure?", correctAnswer: 2, decoys: [1, 3, 5, 7, 10]),
                notebookSummary: "Foundation cured 2 years — kept wet daily. Hydration: water + lime → crystals. Dry concrete crumbles. Water builds.",
                visual: CardVisual(
                    type: .reaction,
                    title: "Hydration Curing — 2 Years Wet",
                    values: ["time": 2],
                    labels: ["Water + lime", "Calcium hydroxide crystals", "Daily watering for 2 years"],
                    steps: 3, caption: "The building that drained a lake needed water to set its own foundation"
                )
            ),

            // ── CRAFTING ROOM (4 cards) ────────────────────────

            KnowledgeCard(
                id: "\(bid)_craftingRoom_workbench_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .craftingRoom, stationKey: "workbench",
                title: "Step 4: Pozzolanic Vaults",
                italianTitle: "Calcestruzzo del Colosseo",
                icon: "flask.fill",
                lessonText: "The Colosseum used three concrete recipes: heavy (basalt aggregate) for foundations, medium (tufa aggregate) for walls, light (pumice) for upper vaults. Same binder, different stone. This is graded concrete — the same principle as the Pantheon dome. At the workbench, you'd mix each batch separately. 6 million cubic feet of concrete total. The Colosseum is more concrete than stone.",
                keywords: [
                    KeywordPair(keyword: "Graded concrete", definition: "Different aggregate weights for different levels"),
                    KeywordPair(keyword: "Basalt", definition: "Heavy aggregate for foundations"),
                    KeywordPair(keyword: "Tufa", definition: "Medium aggregate for walls"),
                    KeywordPair(keyword: "Pumice", definition: "Light aggregate for upper vaults"),
                ],
                activity: .multipleChoice(question: "Which aggregate was used in the Colosseum's upper vaults?", options: ["Basalt (heavy)", "Tufa (medium)", "Pumice (light)", "Marble (decorative)"], correctIndex: 2),
                notebookSummary: "3 concrete grades: basalt (foundation), tufa (walls), pumice (vaults). 6M cubic feet total. More concrete than stone.",
                visual: CardVisual(
                    type: .crossSection,
                    title: "Graded Concrete — 3 Weights",
                    values: ["height": 48],
                    labels: ["Basalt aggregate (heavy — foundation)", "Tufa aggregate (medium — walls)", "Pumice aggregate (light — upper vaults)"],
                    steps: 3, caption: "Same binder, different stone — the Colosseum is more concrete than stone"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_craftingRoom_furnace_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .craftingRoom, stationKey: "furnace",
                title: "Marble Polishing",
                italianTitle: "Lucidatura del Marmo",
                icon: "flame.circle.fill",
                lessonText: "The Colosseum's interior gleamed with marble veneer — thin slabs polished to a mirror finish. Polishing started with coarse sand, progressed to fine pumice powder, and ended with a paste of tin oxide heated on a felt pad. The heat opens the stone's pores, and tin fills them — creating a molecular-level smoothness. Romans polished marble the way watchmakers polish crystal. Perfection is about grit sequence.",
                keywords: [
                    KeywordPair(keyword: "Veneer", definition: "Thin decorative marble slabs over concrete"),
                    KeywordPair(keyword: "Tin oxide", definition: "Final polishing paste — fills stone pores"),
                    KeywordPair(keyword: "Grit sequence", definition: "Coarse sand → pumice → tin oxide paste"),
                ],
                activity: .wordScramble(word: "VENEER", hint: "Thin decorative marble slabs polished to a mirror finish"),
                notebookSummary: "Marble polished in 3 stages: coarse sand → pumice → heated tin oxide paste. Tin fills pores. Perfection = grit sequence.",
                visual: CardVisual(
                    type: .comparison,
                    title: "Marble Polishing — 3 Grit Stages",
                    values: ["equal": 0],
                    labels: ["Stage 1: Coarse sand\nRemoves rough surface", "Stage 2: Pumice powder\nSmooths grain", "Stage 3: Heated tin oxide\nFills pores — mirror finish"],
                    steps: 3, caption: "Perfection is about grit sequence"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_craftingRoom_shelf_0",
                buildingId: bid, buildingName: name,
                science: .mathematics,
                environment: .craftingRoom, stationKey: "shelf",
                title: "Seating Mathematics",
                italianTitle: "Matematica dei Posti a Sedere",
                icon: "number",
                lessonText: "The Colosseum's 76 rows of seats divided into 5 social tiers. Each tier calculated by sightlines: the ratio of seat height to distance from the arena. Front-row senators sat 5 meters from the action. Back-row plebeians sat 50 meters away but on a steeper rake — so everyone had clear views. The ellipse geometry means no two rows have the same radius. Every seat is a unique coordinate. 50,000 unique solutions.",
                keywords: [
                    KeywordPair(keyword: "76 rows", definition: "Total rows of seating in the Colosseum"),
                    KeywordPair(keyword: "5 tiers", definition: "Social divisions — senators to plebeians"),
                    KeywordPair(keyword: "Sightline ratio", definition: "Height ÷ distance — ensures clear views"),
                    KeywordPair(keyword: "Ellipse", definition: "Shape where no two rows share the same radius"),
                ],
                activity: .numberFishing(question: "How many rows of seating did the Colosseum have?", correctAnswer: 76, decoys: [30, 50, 64, 90, 120]),
                notebookSummary: "76 rows, 5 social tiers. Sightline ratio: height ÷ distance. Ellipse = every row has unique radius. 50,000 unique seats.",
                visual: CardVisual(
                    type: .geometry,
                    title: "Seating Math — 76 Rows, 5 Tiers",
                    values: ["diameter": 188, "height": 76],
                    labels: ["5 social tiers", "Sightline ratio: height ÷ distance", "Ellipse = every row unique radius"],
                    steps: 3, caption: "50,000 unique solutions — every seat is a unique coordinate"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_craftingRoom_workbench_1",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .craftingRoom, stationKey: "workbench",
                title: "Step 8: The Velarium",
                italianTitle: "Sartiame del Velario",
                icon: "line.diagonal",
                lessonText: "The velarium's rigging was the Colosseum's most complex system. 240 wooden masts socketed into the top wall. Ropes ran from each mast to a central ring above the arena. Pulleys and windlasses on the ground controlled tension. Sailors adjusted each rope separately to account for wind. The geometry: a tension cone, wide at the rim, narrow at the center. A circus tent the size of a football field.",
                keywords: [
                    KeywordPair(keyword: "Tension cone", definition: "Wide at rim, narrow at center — velarium shape"),
                    KeywordPair(keyword: "Windlass", definition: "Ground-level crank controlling rope tension"),
                    KeywordPair(keyword: "Central ring", definition: "Open circle above the arena where all ropes meet"),
                    KeywordPair(keyword: "240 ropes", definition: "One from each mast to the center ring"),
                ],
                activity: .hangman(word: "VELARIUM", hint: "The Colosseum's retractable silk awning operated by 1,000 sailors"),
                notebookSummary: "Velarium rigging: 240 masts → ropes → central ring. Pulleys and windlasses control tension. Tension cone geometry. 1,000 sailors.",
                visual: CardVisual(
                    type: .force,
                    title: "Velarium Tension Cone",
                    values: ["columns": 240, "load": 240, "arrows": 4, "perColumn": 1],
                    labels: ["240 masts at rim", "Ropes converge to central ring", "Pulleys + windlasses control tension", "Wide at rim, narrow at center"],
                    steps: 4, caption: "A circus tent the size of a football field"
                )
            ),
        ]
    }

    // MARK: - Siege Workshop (13 cards)

    static var siegeWorkshopCards: [KnowledgeCard] {
        let bid = 7
        let name = "Siege Workshop"
        return [
            // ── CITY MAP (5 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_cityMap_building_0",
                buildingId: bid, buildingName: name,
                science: .physics,
                environment: .cityMap, stationKey: "building",
                title: "The Onager",
                italianTitle: "L'Onagro",
                icon: "scope",
                lessonText: "The onager was Rome's heavy artillery — a torsion catapult hurling 25 kg stones over 300 meters. A thick rope of twisted sinew (animal tendon) stored elastic energy like a spring. Pull the arm back, lock it, release — the untwisting rope whips the arm forward. One machine, operated by 8 men, could breach a wall in hours. The onager proves that destruction is just physics with a target.",
                keywords: [
                    KeywordPair(keyword: "Onager", definition: "Torsion catapult hurling 25 kg stones"),
                    KeywordPair(keyword: "Sinew rope", definition: "Twisted animal tendon storing elastic energy"),
                    KeywordPair(keyword: "300 meters", definition: "Maximum range of an onager"),
                    KeywordPair(keyword: "8 men", definition: "Crew needed to operate one onager"),
                ],
                activity: .numberFishing(question: "Maximum range (meters) of a Roman onager?", correctAnswer: 300, decoys: [50, 100, 200, 500, 800]),
                notebookSummary: "Onager: torsion catapult. Twisted sinew stores elastic energy. 25 kg stones, 300m range, 8-man crew. Physics with a target.",
                visual: CardVisual(
                    type: .force,
                    title: "Onager — Torsion Catapult",
                    values: ["columns": 1, "load": 25, "arrows": 1, "perColumn": 25],
                    labels: ["Twisted sinew stores elastic energy", "25 kg stone launched 300m", "8-man crew"],
                    steps: 3, caption: "Destruction is just physics with a target"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_1",
                buildingId: bid, buildingName: name,
                science: .mathematics,
                environment: .cityMap, stationKey: "building",
                title: "Step 4: Launch Angles",
                italianTitle: "L'Angolo di 45°",
                icon: "angle",
                lessonText: "Every siege engineer knew: 45° is the launch angle for maximum range. Lower angles travel faster but hit the ground sooner. Higher angles fly longer but lose horizontal distance. At 45°, the vertical and horizontal components of velocity are equal — maximizing the parabolic arc. Roman engineers used a quadrant (quarter-circle protractor) to set the angle. Mathematics makes every stone count.",
                keywords: [
                    KeywordPair(keyword: "45°", definition: "Optimal launch angle for maximum range"),
                    KeywordPair(keyword: "Parabolic arc", definition: "Curved path of a launched projectile"),
                    KeywordPair(keyword: "Quadrant", definition: "Quarter-circle tool measuring launch angle"),
                    KeywordPair(keyword: "Equal components", definition: "At 45°, vertical = horizontal velocity"),
                ],
                activity: .numberFishing(question: "What launch angle (degrees) gives maximum range?", correctAnswer: 45, decoys: [15, 30, 60, 75, 90]),
                notebookSummary: "45° = max range. Vertical and horizontal velocity are equal. Roman quadrant measured the angle. Math makes every stone count.",
                visual: CardVisual(
                    type: .geometry,
                    title: "45° — Maximum Range Arc",
                    values: ["diameter": 300, "height": 45],
                    labels: ["45° launch angle", "Vertical = horizontal velocity", "Parabolic arc for maximum range"],
                    steps: 3, caption: "Mathematics makes every stone count"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_2",
                buildingId: bid, buildingName: name,
                science: .physics,
                environment: .cityMap, stationKey: "building",
                title: "Step 5: Torsion Springs",
                italianTitle: "Energia di Torsione",
                icon: "arrow.trianglehead.2.counterclockwise.rotate.90",
                lessonText: "The secret of Roman siege weapons: torsion energy. Twist a bundle of sinew ropes 180 times. Each twist stores elastic potential energy — like winding a rubber band. The energy scales with the square of the twist count: double the twists, quadruple the power. But over-twist and the sinew snaps. The sweet spot: 70% of breaking tension. Engineering is knowing how close to the edge you can go.",
                keywords: [
                    KeywordPair(keyword: "Torsion", definition: "Energy stored by twisting sinew bundles"),
                    KeywordPair(keyword: "Elastic potential", definition: "Energy stored in twisted fibers — released on trigger"),
                    KeywordPair(keyword: "Square law", definition: "Double twists = 4× power"),
                    KeywordPair(keyword: "70% tension", definition: "Safe operating limit before sinew snaps"),
                ],
                activity: .trueFalse(statement: "Doubling the twists in a torsion rope quadruples the stored energy", isTrue: true),
                notebookSummary: "Torsion: twisted sinew stores elastic energy. Power ∝ twists². Safe limit: 70% of breaking tension. Know the edge.",
                visual: CardVisual(
                    type: .force,
                    title: "Torsion Energy — Square Law",
                    values: ["columns": 2, "load": 4, "arrows": 2, "perColumn": 2],
                    labels: ["Double twists = 4× power", "Safe limit: 70% of breaking tension", "Over-twist and the sinew snaps"],
                    steps: 3, caption: "Engineering is knowing how close to the edge you can go"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_3",
                buildingId: bid, buildingName: name,
                science: .physics,
                environment: .cityMap, stationKey: "building",
                title: "Step 6: Battering Ram",
                italianTitle: "Ariete a Pendolo",
                icon: "arrow.left.arrow.right",
                lessonText: "The battering ram was a 5-ton oak log tipped with iron, suspended from a frame by ropes. Soldiers swung it like a pendulum — each swing higher than the last. Pendulum physics: energy accumulates with each cycle. After 10 swings, the ram hits with the force of 30 men. A bronze or iron head concentrated that force onto a point the size of a fist. Rhythm beats strength.",
                keywords: [
                    KeywordPair(keyword: "Pendulum", definition: "Swinging motion that accumulates energy"),
                    KeywordPair(keyword: "5 tons", definition: "Weight of a Roman battering ram"),
                    KeywordPair(keyword: "Iron head", definition: "Concentrates force to a small impact point"),
                    KeywordPair(keyword: "Energy accumulation", definition: "Each swing adds more force to the next"),
                ],
                activity: .wordScramble(word: "PENDULUM", hint: "Swinging motion that accumulates energy with each cycle"),
                notebookSummary: "Battering ram: 5-ton oak + iron head, suspended as pendulum. Energy accumulates per swing. 10 swings = force of 30 men.",
                visual: CardVisual(
                    type: .force,
                    title: "Battering Ram — Pendulum Physics",
                    values: ["columns": 1, "load": 5, "arrows": 1, "perColumn": 5],
                    labels: ["5-ton oak log + iron head", "Pendulum swing accumulates energy", "10 swings = force of 30 men"],
                    steps: 3, caption: "Rhythm beats strength"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_4",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .cityMap, stationKey: "building",
                title: "Step 7: Tower Frame",
                italianTitle: "Torre d'Assedio",
                icon: "building.2.crop.circle.fill",
                lessonText: "When walls were too high to scale, Romans built mobile siege towers — 20 meters tall, rolling on wheels, with a drawbridge at the top. The tower was clad in wet hides to resist fire arrows. Inside, soldiers climbed 6 internal platforms while archers on top provided covering fire. Building a tower taller than the enemy's wall — in the middle of a battle — is engineering under maximum pressure.",
                keywords: [
                    KeywordPair(keyword: "Siege tower", definition: "Mobile 20m structure rolled to enemy walls"),
                    KeywordPair(keyword: "Wet hides", definition: "Animal skins soaked to resist fire arrows"),
                    KeywordPair(keyword: "Drawbridge", definition: "Drops from tower top onto the wall"),
                    KeywordPair(keyword: "6 platforms", definition: "Internal levels for soldiers climbing inside"),
                ],
                activity: .numberFishing(question: "How tall (meters) was a Roman siege tower?", correctAnswer: 20, decoys: [8, 12, 30, 40, 50]),
                notebookSummary: "Siege tower: 20m tall on wheels. Wet hide fire protection. 6 internal platforms. Drawbridge drops onto walls. Engineering under fire.",
                visual: CardVisual(
                    type: .crossSection,
                    title: "Siege Tower — 20m Mobile Fortress",
                    values: ["height": 20],
                    labels: ["Drawbridge at top", "6 internal platforms", "Wet hide cladding (fire resistant)", "Wheels for rolling to wall"],
                    steps: 4, caption: "Engineering under maximum pressure"
                )
            ),

            // ── WORKSHOP (4 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_workshop_clayPit_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "clayPit",
                title: "Terracotta Roof Tiles",
                italianTitle: "Tegole di Terracotta",
                icon: "rectangle.split.3x1.fill",
                lessonText: "Siege workshops needed roofs that resisted fire arrows. Standard terracotta tiles were the answer — they don't burn, and their overlapping design sheds flaming oil. Tiles were fired at 1,000°C until the clay vitrified into a hard shell. A workshop's roof used 500 tiles weighing 2 kg each — one ton of fire-resistant armor overhead. The roof protects the machines that break the walls.",
                keywords: [
                    KeywordPair(keyword: "Fire resistant", definition: "Terracotta doesn't burn — deflects fire arrows"),
                    KeywordPair(keyword: "1,000°C", definition: "Firing temperature for vitrified tiles"),
                    KeywordPair(keyword: "500 tiles", definition: "Number needed for a workshop roof"),
                    KeywordPair(keyword: "Vitrified", definition: "Clay fused into hard, glassy shell"),
                ],
                activity: .numberFishing(question: "How many terracotta tiles covered a siege workshop roof?", correctAnswer: 500, decoys: [100, 250, 750, 1000, 2000]),
                notebookSummary: "Workshop roof: 500 terracotta tiles at 2 kg each. Fired at 1,000°C until vitrified. Fire-resistant — deflects flaming arrows.",
                visual: CardVisual(
                    type: .temperature,
                    title: "Terracotta Tiles — 1,000°C Vitrification",
                    values: ["transition": 1000, "max": 1200],
                    labels: ["500 tiles × 2 kg = 1 ton of fire armor", "Vitrified at 1,000°C — won't burn"],
                    steps: 3, caption: "The roof protects the machines that break the walls"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_mine_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "mine",
                title: "Step 2: Forge Fittings",
                italianTitle: "Forgia del Ferro a 1100°C",
                icon: "hammer.fill",
                lessonText: "Siege weapon heads needed wrought iron — strong, tough, and able to absorb impacts without shattering. Iron ore was smelted in a bloomery furnace at 1,100°C. The bloom (spongy mass) was hammered repeatedly to expel slag. Each fold doubled the layers — 10 folds created 1,024 layers. This pattern welding produced iron as tough as cheap steel. Patience at the anvil is a form of technology.",
                keywords: [
                    KeywordPair(keyword: "1,100°C", definition: "Bloomery smelting temperature for iron"),
                    KeywordPair(keyword: "Bloom", definition: "Spongy iron mass from the furnace"),
                    KeywordPair(keyword: "Pattern welding", definition: "Folding iron to create layered strength"),
                    KeywordPair(keyword: "1,024 layers", definition: "Result of 10 folds (2¹⁰)"),
                ],
                activity: .numberFishing(question: "How many layers result from folding iron 10 times?", correctAnswer: 1024, decoys: [20, 100, 512, 2048, 5000]),
                notebookSummary: "Wrought iron: smelted at 1,100°C, bloom hammered to expel slag. 10 folds = 1,024 layers. Pattern welding = tough iron.",
                visual: CardVisual(
                    type: .temperature,
                    title: "Bloomery Smelting — 1,100°C",
                    values: ["transition": 1100, "max": 1500],
                    labels: ["Iron ore → spongy bloom", "Hammer to expel slag", "10 folds = 1,024 layers"],
                    steps: 3, caption: "Patience at the anvil is a form of technology"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_mine_1",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "mine",
                title: "Bronze Gear Mechanisms",
                italianTitle: "Ingranaggi in Bronzo",
                icon: "gearshape.2.fill",
                lessonText: "Siege machines used bronze gears for windlasses and pulleys. Bronze (90% copper, 10% tin) is harder than iron, resists corrosion, and casts with smooth tooth surfaces. Romans cast gears using the lost-wax method: carve a wax gear, coat in clay, melt out the wax, pour in bronze. The clay mold captures every detail. One wax model, one perfect gear. Precision starts in wax.",
                keywords: [
                    KeywordPair(keyword: "Lost-wax casting", definition: "Wax model → clay mold → bronze pour"),
                    KeywordPair(keyword: "90:10", definition: "Copper to tin ratio in Roman bronze"),
                    KeywordPair(keyword: "Windlass", definition: "Crank mechanism using bronze gears"),
                    KeywordPair(keyword: "Tooth surface", definition: "Bronze casts smoother than iron — less friction"),
                ],
                activity: .fillInBlanks(text: "Bronze is ___% copper and ___% tin, cast using the lost-___ method", blanks: ["90", "10", "wax"], distractors: ["80", "20", "mold"]),
                notebookSummary: "Bronze gears: 90% Cu + 10% Sn. Lost-wax casting: wax → clay → melt → pour. Smooth tooth surfaces, corrosion resistant.",
                visual: CardVisual(
                    type: .ratio,
                    title: "Bronze Alloy — 90:10",
                    values: ["Copper": 90, "Tin": 10],
                    labels: ["90% copper + 10% tin", "Lost-wax casting for smooth gears"],
                    steps: 3, caption: "One wax model, one perfect gear — precision starts in wax"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_river_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "river",
                title: "Soaking Wood for Resilience",
                italianTitle: "Ammollo del Legno",
                icon: "drop.triangle.fill",
                lessonText: "Siege ram logs were soaked in water for weeks before use. Why? Water fills the wood's cell walls, making the fibers more flexible. A dry log shatters on impact — a soaked log bounces. The process is called water seasoning. After soaking, the log is capped with iron and hung as a pendulum. Wet wood absorbs shock. Dry wood transfers it. The ram needs to flex, not break.",
                keywords: [
                    KeywordPair(keyword: "Water seasoning", definition: "Soaking logs to increase flexibility"),
                    KeywordPair(keyword: "Cell walls", definition: "Wood fibers that absorb water and flex"),
                    KeywordPair(keyword: "Shock absorption", definition: "Wet wood bounces — dry wood shatters"),
                ],
                activity: .trueFalse(statement: "Siege ram logs were soaked in water to make them more flexible on impact", isTrue: true),
                notebookSummary: "Water seasoning: soak logs for weeks. Water fills cell walls → flexible fibers. Wet = bounces on impact. Dry = shatters.",
                visual: CardVisual(
                    type: .comparison,
                    title: "Wet vs Dry Ram Logs",
                    values: ["equal": 0],
                    labels: ["Soaked log\nWater fills cell walls\nFlexible — bounces", "Dry log\nBrittle fibers\nShatters on impact", "The ram needs to flex, not break"],
                    steps: 3, caption: "Wet wood absorbs shock — dry wood transfers it"
                )
            ),

            // ── FOREST (2 cards) ───────────────────────────────

            KnowledgeCard(
                id: "\(bid)_forest_oak_0",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .forest, stationKey: "oak",
                title: "Step 3: Catapult Design",
                italianTitle: "Legno per Telai di Catapulta",
                icon: "triangle.fill",
                lessonText: "The catapult frame endures enormous stress — torsion ropes pull inward with tons of force. Only oak can take it. Oak's interlocking fibers resist splitting. The frame is assembled from 4 main beams joined with mortise-and-tenon joints reinforced by iron plates. Green (fresh-cut) oak is preferred — it's more flexible and absorbs the vibration of each shot. A dry frame cracks after 50 shots. A green one lasts 500.",
                keywords: [
                    KeywordPair(keyword: "Mortise-and-tenon", definition: "Interlocking wood joint for catapult frames"),
                    KeywordPair(keyword: "Green oak", definition: "Fresh-cut — flexible, absorbs vibration"),
                    KeywordPair(keyword: "500 shots", definition: "Lifespan of a green oak catapult frame"),
                    KeywordPair(keyword: "Iron plates", definition: "Reinforce joints against torsion stress"),
                ],
                activity: .multipleChoice(question: "Why was green (fresh) oak preferred for catapult frames?", options: ["Lighter weight", "Better color", "More flexible — absorbs vibration", "Cheaper to cut"], correctIndex: 2),
                notebookSummary: "Catapult frame: green oak (flexible) + mortise-and-tenon joints + iron plates. Green = 500 shots. Dry = 50. Flexibility wins.",
                visual: CardVisual(
                    type: .comparison,
                    title: "Green Oak vs Dry Oak Frames",
                    values: ["equal": 0],
                    labels: ["Green (fresh) oak\nFlexible — absorbs vibration\n500 shots", "Dry oak\nBrittle — cracks under stress\n50 shots", "Mortise-and-tenon joints + iron plate reinforcement"],
                    steps: 3, caption: "A green frame lasts 10× longer — flexibility wins"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_forest_walnut_0",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .forest, stationKey: "walnut",
                title: "Precision Mechanism Parts",
                italianTitle: "Parti di Meccanismi di Precisione",
                icon: "gearshape.fill",
                lessonText: "Walnut is the precision wood. Its tight, uniform grain machines to exact dimensions without splintering. Roman engineers used walnut for trigger mechanisms, ratchet pawls, and aiming gears. A catapult's trigger must release cleanly — any rough edge causes a jerky release that throws off aim. Walnut also resists oil absorption, so it stays dimensionally stable when greased. The wood that doesn't change is the one you trust.",
                keywords: [
                    KeywordPair(keyword: "Walnut", definition: "Tight-grain wood for precision mechanism parts"),
                    KeywordPair(keyword: "Trigger mechanism", definition: "Must release cleanly for accurate aim"),
                    KeywordPair(keyword: "Oil resistant", definition: "Doesn't absorb grease — stays dimensionally stable"),
                    KeywordPair(keyword: "Ratchet pawl", definition: "Walnut mechanism part for incremental tensioning"),
                ],
                activity: .hangman(word: "WALNUT", hint: "Tight-grained wood used for precision catapult triggers"),
                notebookSummary: "Walnut: tight grain, no splintering, oil-resistant. Used for triggers, ratchets, aiming gears. Stability = accuracy.",
                visual: CardVisual(
                    type: .comparison,
                    title: "Walnut — The Precision Wood",
                    values: ["equal": 0],
                    labels: ["Walnut\nTight grain, no splinter\nOil-resistant, stable", "Other woods\nRough edges on cuts\nAbsorb oil — swell", "Triggers, ratchet pawls, aiming gears — stability = accuracy"],
                    steps: 3, caption: "The wood that doesn't change is the one you trust"
                )
            ),

            // ── CRAFTING ROOM (2 cards) ────────────────────────

            KnowledgeCard(
                id: "\(bid)_craftingRoom_workbench_0",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .craftingRoom, stationKey: "workbench",
                title: "Timber Joinery",
                italianTitle: "Giunzioni in Legno",
                icon: "square.grid.2x2.fill",
                lessonText: "Siege machines were assembled in the field — they had to be taken apart and rebuilt quickly. Roman military joinery used three key joints: mortise-and-tenon (strongest), dovetail (resists pulling apart), and scarf (joins two beams end-to-end). No glue — just tight fits and iron pins. A skilled carpenter could assemble an onager from numbered parts in 4 hours. Modularity before the word existed.",
                keywords: [
                    KeywordPair(keyword: "Mortise-and-tenon", definition: "Strongest joint — peg into socket"),
                    KeywordPair(keyword: "Dovetail", definition: "Fan-shaped joint resisting pull-apart"),
                    KeywordPair(keyword: "Scarf joint", definition: "Joins two beams end-to-end"),
                    KeywordPair(keyword: "4 hours", definition: "Assembly time for a field onager"),
                ],
                activity: .multipleChoice(question: "Which joint resists being pulled apart?", options: ["Mortise-and-tenon", "Dovetail", "Scarf", "Butt joint"], correctIndex: 1),
                notebookSummary: "3 siege joints: mortise-and-tenon (strongest), dovetail (pull-resistant), scarf (end-to-end). No glue. Onager assembled in 4 hours.",
                visual: CardVisual(
                    type: .comparison,
                    title: "3 Military Joints — No Glue",
                    values: ["equal": 0],
                    labels: ["Mortise-and-tenon\nStrongest — peg in socket", "Dovetail\nPull-resistant — fan shape", "Scarf joint\nEnd-to-end beam extension"],
                    steps: 3, caption: "Modularity before the word existed — onager assembled in 4 hours"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_craftingRoom_furnace_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .craftingRoom, stationKey: "furnace",
                title: "Step 2: Forge Iron",
                italianTitle: "Tempra del Ferro",
                icon: "flame.circle.fill",
                lessonText: "Raw iron is too soft for siege weapon heads. Tempering fixes this. Heat the iron to cherry red (750°C), then quench in oil — the rapid cooling traps carbon atoms in the crystal lattice, creating martensite (very hard but brittle). Then reheat to 300°C (straw yellow color) and air cool — this 'tempers' the martensite, trading some hardness for toughness. Hard enough to pierce, tough enough not to shatter.",
                keywords: [
                    KeywordPair(keyword: "750°C", definition: "Cherry red — first heating for quenching"),
                    KeywordPair(keyword: "Martensite", definition: "Hard but brittle crystal structure from quenching"),
                    KeywordPair(keyword: "300°C temper", definition: "Straw yellow — second heat for toughness"),
                    KeywordPair(keyword: "Oil quench", definition: "Rapid cooling that traps carbon in crystal"),
                ],
                activity: .fillInBlanks(text: "Tempering: heat to ___°C (cherry red), quench in ___, reheat to ___°C (straw yellow)", blanks: ["750", "oil", "300"], distractors: ["500", "water", "600"]),
                notebookSummary: "Tempering: 750°C → oil quench (martensite) → 300°C reheat (temper). Hard enough to pierce, tough enough not to shatter.",
                visual: CardVisual(
                    type: .temperature,
                    title: "Tempering Cycle — 750°C → 300°C",
                    values: ["transition": 750, "max": 1000],
                    labels: ["750°C cherry red → oil quench", "Martensite: hard but brittle", "300°C straw yellow → air cool (temper)"],
                    steps: 3, caption: "Hard enough to pierce, tough enough not to shatter"
                )
            ),
        ]
    }
}
