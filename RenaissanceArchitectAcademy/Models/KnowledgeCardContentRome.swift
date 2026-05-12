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
                lessonText: "Welcome to Rome. Sixty-nine kilometers — that is how far this water has traveled to reach us. From mountain springs, all the way here. Emperor Claudius spent fourteen years building it. Fourteen years. And yet — most of it, you will never see. Only sixteen kilometers run on arches. The rest is hidden — carved through rock, buried in tunnels. The longest engineering project of the ancient world — and eighty-five percent of it is invisible. Remember what I tell you. In Rome, the genius is often what you cannot see. Are you ready?",
                keywords: [
                    KeywordPair(keyword: "Aqua Claudia", definition: "69 km aqueduct built by Emperor Claudius"),
                    KeywordPair(keyword: "16 km", definition: "Length running on visible arches"),
                    KeywordPair(keyword: "14 years", definition: "Construction time for the Aqua Claudia"),
                    KeywordPair(keyword: "Underground", definition: "85% of the aqueduct was hidden in tunnels"),
                ],
                activity: .numberFishing(question: "How many km long was the Aqua Claudia?", correctAnswer: 69, decoys: [32, 45, 83, 100, 120]),
                notebookSummary: "Aqua Claudia. 69 km from mountain springs to Rome. Emperor Claudius spent 14 years building it. Only 16 km run on arches — 85% is invisible, underground.",
                visual: CardVisual(
                    type: .crossSection,
                    title: "69 km — Mostly Underground",
                    values: ["depth": 69, "width": 16],
                    labels: ["Underground tunnel (85%)", "Above ground on arches (16 km)", "Mountain springs (source)", "Rome (destination)"],
                    steps: 4, caption: "The longest engineering project of the ancient world — 85% invisible"
                ),
                isLeadCard: true
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_1",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .cityMap, stationKey: "building",
                title: "Step 1: The Chorobates",
                italianTitle: "Il Corobate",
                icon: "level.fill",
                lessonText: "Before a single stone — we must measure. See? Here is the chorobates. Six meters long, made of wood. A channel runs along the top, filled with water. If the water sits perfectly level — the ground is level. Simple. Now look at what they measured. Over sixty-nine kilometers, the aqueduct drops just fourteen meters. Fourteen. A marble rolling across this floor moves faster. And yet — every drop of water arrives. Engineering this precise — it does not just change a city. It changes what is possible.",
                keywords: [
                    KeywordPair(keyword: "Chorobates", definition: "6-meter leveling beam with water channel"),
                    KeywordPair(keyword: "1:4800", definition: "Gradient — 14 m drop over 69 km"),
                    KeywordPair(keyword: "Surveying", definition: "Measuring ground level before construction"),
                ],
                activity: .wordScramble(word: "CHOROBATES", hint: "Roman leveling tool with a water channel on top"),
                notebookSummary: "Chorobates: 6m wooden beam with water channel on top. Tests if ground is level. Aqua Claudia drops 14m over 69 km — gradient 1:4800.",
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
                lessonText: "Listen. Water moves only when gravity pulls it. So the slope — must be exact. Too steep, the water tears the channel apart. Too gentle, it stops. Stagnates. Vitruvius, our great architect, wrote it down for us — thirty-four centimeters of fall, for every kilometer. That is the secret. One in four thousand eight hundred. No calculators. No machines. Only a chorobates, string lines, and patience measured in years. When a million people need to drink — the math is not abstract. The math is everything.",
                keywords: [
                    KeywordPair(keyword: "34 cm/km", definition: "Ideal gradient for aqueduct water flow"),
                    KeywordPair(keyword: "Gravity flow", definition: "Water moves downhill without pumps"),
                    KeywordPair(keyword: "Erosion", definition: "Too steep a gradient wears away the channel"),
                    KeywordPair(keyword: "Stagnation", definition: "Too gentle a gradient stops water movement"),
                ],
                activity: .trueFalse(statement: "The Aqua Claudia dropped 34 cm per kilometer — a gradient of about 1:4800", isTrue: true),
                notebookSummary: "Vitruvius set the rule: 34 cm fall per km (1:4800). Too steep = erosion. Too gentle = stagnation. No pumps — gravity alone.",
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
                lessonText: "Where the aqueduct crosses a valley, we build arches. Three tiers — thirty meters high. Each arch is made of wedge-shaped stones. We call them voussoirs. At the very top — one stone. The keystone. It locks them all together. Now — think about what is happening. Every stone pushes against the next. Every stone wants to fall. But the others will not let it. Take away the keystone, and the arch collapses in an instant. The arch is strong precisely because it wants to fall apart. Beautiful — no? You will see this trick again, when we build greater things.",
                keywords: [
                    KeywordPair(keyword: "Voussoir", definition: "Wedge-shaped stone forming an arch"),
                    KeywordPair(keyword: "Keystone", definition: "Top stone that locks the arch together"),
                    KeywordPair(keyword: "Compression", definition: "Stones pushing inward against each other"),
                    KeywordPair(keyword: "30 meters", definition: "Height of triple-tiered aqueduct arches"),
                ],
                activity: .hangman(word: "VOUSSOIR", hint: "Wedge-shaped stone that forms an arch"),
                notebookSummary: "Aqueduct arches: 3 tiers, 30m tall. Wedge-shaped voussoirs + keystone hold by compression. Strong precisely because it wants to fall apart.",
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
                lessonText: "Inside the aqueduct — there is a channel. We call it the specus. Almost one meter wide, one and a half meters tall. Lined with waterproof cement so not a single drop is lost. Every few kilometers, a settling tank traps the sediment. Clean water continues. At the city — the castellum. The distribution tank. It splits the water three ways. First, public fountains, for everyone. Then, the baths. And only then — private homes. If the water ran low? Your home was first to lose its supply. The Roman order — fairness before comfort.",
                keywords: [
                    KeywordPair(keyword: "Specus", definition: "Waterproof channel inside the aqueduct"),
                    KeywordPair(keyword: "Opus signinum", definition: "Waterproof cement lining the channel"),
                    KeywordPair(keyword: "Castellum", definition: "Distribution tank splitting water three ways"),
                    KeywordPair(keyword: "Settling tank", definition: "Filters sediment from flowing water"),
                ],
                activity: .wordScramble(word: "SPECUS", hint: "The water channel inside the aqueduct"),
                notebookSummary: "Specus: waterproof channel (~0.9m × 1.5m). Castellum splits water 3 ways: public fountains → baths → private homes. If water ran low, homes lost first.",
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
                lessonText: "Now — feel the difference in your hands. Mortar is the glue between stones. Lime paste, mixed with sand. It holds. Concrete is the stone itself. Lime, volcanic ash, water, and chunks of rock. It fills. Same family — different jobs. For our arches, mortar bonds the voussoirs together. For the great piers below — concrete fills them. Same lime in both. The Romans built an empire on knowing which recipe to choose.",
                keywords: [
                    KeywordPair(keyword: "Mortar", definition: "Lime + sand paste that bonds stones together"),
                    KeywordPair(keyword: "Concrete", definition: "Lime + ash + aggregate that fills foundations"),
                    KeywordPair(keyword: "Binder", definition: "Lime — the glue in both mortar and concrete"),
                    KeywordPair(keyword: "Aggregate", definition: "Rock chunks added to concrete for strength"),
                ],
                activity: .trueFalse(statement: "Mortar and concrete both use lime as their binder", isTrue: true),
                notebookSummary: "Mortar = lime + sand (bonds stones, like the voussoirs). Concrete = lime + ash + aggregate (fills piers + foundations). Same lime, different recipes.",
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
                lessonText: "Listen carefully — this is the secret. Normal lime mortar? Drop it in water. It dissolves. Gone. But add pozzolana — volcanic ash from the slopes of Vesuvius — and something miraculous happens. It sets HARDER underwater. The silica in the ash triggers a reaction that needs no air. The Romans found this by accident, near a town called Pozzuoli. For our aqueduct foundations — crossing rivers — this changed everything. The material that hated water became the one that conquered it. You will see this ash again, when we build the Pantheon.",
                keywords: [
                    KeywordPair(keyword: "Hydraulic setting", definition: "Concrete hardening underwater without air"),
                    KeywordPair(keyword: "Pozzuoli", definition: "Town near Vesuvius where the reaction was discovered"),
                    KeywordPair(keyword: "Silica reaction", definition: "Volcanic ash + lime = waterproof bond"),
                ],
                activity: .multipleChoice(question: "What makes Roman concrete set underwater?", options: ["Sand", "Volcanic ash (pozzolana)", "Marble dust", "Iron filings"], correctIndex: 1),
                notebookSummary: "Pozzolana + lime = hydraulic concrete that sets HARDER underwater. Silica reaction needs no air. Discovered by accident near Pozzuoli (Vesuvius). Same ash returns at the Pantheon.",
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
                lessonText: "The channel must hold every drop. Not a leak. Not a seep. So we crush old terracotta tiles — pottery, broken roof tiles — into a fine powder. We mix it with lime. We call it opus signinum. The ceramic particles fill every pore in the cement. Then we apply it in three coats. Each coat — burnished smooth with a polishing stone. The inside of the Aqua Claudia? Smoother than the plumbing in your modern city. Crushed pottery — the first waterproof lining in history. Strange — no?",
                keywords: [
                    KeywordPair(keyword: "Opus signinum", definition: "Crushed terracotta + lime waterproof coating"),
                    KeywordPair(keyword: "Three coats", definition: "Applied in layers, each burnished smooth"),
                    KeywordPair(keyword: "Burnishing", definition: "Polishing with stone to seal the surface"),
                ],
                activity: .wordScramble(word: "SIGNINUM", hint: "Roman waterproof lining made from crushed terracotta"),
                notebookSummary: "Opus signinum: crushed terracotta tiles + lime, applied in 3 burnished coats. Fills every pore. First waterproof lining in history. Smoother than modern plumbing.",
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
                lessonText: "At the castellum, water splits into pipes — lead pipes. We call them fistulae. The metalworkers cast them by pouring molten lead over a sand mold. Then they bend the flat sheet into a tube. Solder the seam. Stamp each one with the emperor's name and the caliber. Ten standard sizes — soft, bendable, easy to repair. The perfect pipe for a great city. And yet — we did not know then what we know now. That this metal could harm those who drank from it. The Romans did not know. Centuries would pass before we did.",
                keywords: [
                    KeywordPair(keyword: "Fistula", definition: "Lead water pipe used in Roman cities"),
                    KeywordPair(keyword: "Caliber stamp", definition: "Size marking + emperor's name on each pipe"),
                    KeywordPair(keyword: "10 sizes", definition: "Standard pipe diameters used across Rome"),
                    KeywordPair(keyword: "Soldered seam", definition: "Lead sheet bent and sealed into a tube"),
                ],
                activity: .hangman(word: "FISTULA", hint: "Roman lead pipe stamped with the emperor's name"),
                notebookSummary: "Fistulae: lead pipes cast over sand molds, bent and soldered into tubes. 10 sizes, each stamped with emperor + caliber. The Romans did not know lead could harm — centuries passed before we did.",
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
                lessonText: "Now — your hands get dirty. Aqueduct mortar must survive weather, vibration, the pressure of water. The recipe? One part slaked lime. Two parts clean river sand. A half-part of pozzolana. First, slake the lime — pour water over the quicklime, and step back. It boils. It steams. Once cool, you mix the paste with sand. Slowly. Until it clings to your trowel — even when you turn it upside down. Too wet? It slumps. Too dry? It crumbles. The recipe is on paper. But the feel — the feel is in your hands.",
                keywords: [
                    KeywordPair(keyword: "1:2:½", definition: "Lime : sand : pozzolana ratio for aqueduct mortar"),
                    KeywordPair(keyword: "Slaking", definition: "Adding water to quicklime — hot reaction"),
                    KeywordPair(keyword: "Trowel test", definition: "Good mortar clings when trowel is inverted"),
                ],
                activity: .fillInBlanks(text: "Aqueduct mortar: ___ part lime, ___ parts sand, half-part ___", blanks: ["1", "2", "pozzolana"], distractors: ["3", "4", "marble"]),
                notebookSummary: "Aqueduct mortar: 1 lime + 2 sand + ½ pozzolana. Slake the lime first (it boils + steams). Trowel test: good mortar clings upside down. Feel is everything.",
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
                lessonText: "Before you can make opus signinum, you need terracotta. Real terracotta. Clay tiles fire in the kiln, between six hundred and nine hundred degrees. How do you know when they are ready? Listen. Tap one with your finger. When it rings clear, like a bell — it is ready. Now, smash them. Crush them to powder. The smaller the particles, the better the waterproofing. Sieve through linen cloth. The finest powder — for the final coat. The Romans graded their crushed tile the way jewelers grade diamonds. By fineness.",
                keywords: [
                    KeywordPair(keyword: "600-900°C", definition: "Firing temperature for terracotta tiles"),
                    KeywordPair(keyword: "Ring test", definition: "Tap a tile — clear ring means properly fired"),
                    KeywordPair(keyword: "Graded powder", definition: "Finest particles for the waterproof top coat"),
                ],
                activity: .numberFishing(question: "Minimum firing temperature (°C) for terracotta tiles?", correctAnswer: 600, decoys: [200, 400, 800, 1100, 1500]),
                notebookSummary: "Terracotta fires at 600-900°C. Ring test: tap it, when it rings clear like a bell — it's ready. Crush, sieve through linen. Finest powder for the final coat — graded like diamonds.",
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
                lessonText: "Almost done. But before we leave the aqueduct — you must meet a man. His name was Frontinus. Rome's water commissioner. He did not build the Aqua Claudia. But he made sure it ran. He measured every flow using a pipe of standard size — the quinaria. He calculated that the Aqua Claudia delivered one hundred and eighty-four thousand cubic meters of water. Every day. One hundred and ninety liters for every Roman — more than many of your modern cities. He wrote his findings in a book. De Aquaeductu. The first water manual in history. Frontinus taught us a rule that still holds today. Measure everything. Waste nothing. Infrastructure runs on data.",
                keywords: [
                    KeywordPair(keyword: "Quinaria", definition: "Standard pipe unit for measuring water flow"),
                    KeywordPair(keyword: "Frontinus", definition: "Rome's water commissioner who measured everything"),
                    KeywordPair(keyword: "184,000 m³/day", definition: "Daily flow of the Aqua Claudia"),
                    KeywordPair(keyword: "De Aquaeductu", definition: "First water management book in history"),
                ],
                activity: .hangman(word: "FRONTINUS", hint: "Rome's water commissioner who wrote De Aquaeductu"),
                notebookSummary: "Frontinus, Rome's water commissioner, measured flow using quinaria pipes. Aqua Claudia: 184,000 m³/day = 190 L per person. De Aquaeductu — the first water manual. Measure everything. Waste nothing.",
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
                lessonText: "Welcome back. Today — we follow the roads. Look at the number. Four hundred thousand kilometers. Enough to circle the earth ten times. And every single one of them — leads here. To Rome. Twenty-nine great highways radiate from one point in the Forum. A man named Appius Claudius Caecus built the first of them — three hundred and twelve years before Christ. The Via Appia. The Queen of Roads. Armies marched on them. Trade wagons followed. Then mail. Then empire. Every road leads to Rome — literally. Control the roads — and you control the world.",
                keywords: [
                    KeywordPair(keyword: "400,000 km", definition: "Total length of Roman road network"),
                    KeywordPair(keyword: "Golden milestone", definition: "Starting point of all roads in the Roman Forum"),
                    KeywordPair(keyword: "29 highways", definition: "Major roads radiating from Rome"),
                    KeywordPair(keyword: "30 km/day", definition: "Standard army marching pace on Roman roads"),
                ],
                activity: .numberFishing(question: "How many km of roads did Rome build at its peak?", correctAnswer: 400000, decoys: [50000, 150000, 250000, 600000, 800000]),
                notebookSummary: "400,000 km of Roman roads — enough to circle the earth 10 times. 29 highways radiate from the golden milestone in the Forum. Appius Claudius Caecus began the Via Appia in 312 BC. Control the roads, control the world.",
                visual: CardVisual(
                    type: .geometry, title: "400,000 km of Roads from One Point",
                    values: ["diameter": 400000], labels: ["29 highways radiate from the golden milestone", "Enough road to circle Earth 10 times"],
                    steps: 3, caption: "Every road leads to Rome — literally"
                ),
                isLeadCard: true
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_1",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .cityMap, stationKey: "building",
                title: "Step 1 Support: Survey Stakes",
                italianTitle: "La Groma",
                icon: "plus.circle",
                lessonText: "Before you can build straight — you must see straight. See? This is the groma. Cross-shaped. Plumb lines hanging from each arm. Lead weights pull the strings perfectly vertical. The surveyor sets it down, sights along two arms, plants a stake far away. Then walks to the stake and sights another — even further. For eighty kilometers, sometimes. Dead straight. No GPS. No lasers. Only string, lead, and patient eyes. The simplest tools — wielded with discipline — are enough to build an empire.",
                keywords: [
                    KeywordPair(keyword: "Groma", definition: "Cross-shaped surveying tool with plumb lines"),
                    KeywordPair(keyword: "Plumb lines", definition: "Weighted strings for sighting straight lines"),
                    KeywordPair(keyword: "80 km", definition: "Length of some perfectly straight Roman roads"),
                ],
                activity: .wordScramble(word: "GROMA", hint: "Cross-shaped Roman surveying tool with plumb lines"),
                notebookSummary: "Groma: cross-shaped surveying instrument with plumb lines from each arm. Sight along arms, plant stakes in straight line. 80 km dead straight, with only string + lead weights + trained eyes.",
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
                lessonText: "Now — look beneath your feet. A Roman road is not a surface. It is a structure. Four layers, one upon the other. Total depth — up to one and a half meters. At the bottom: statumen. Large flat stones, for drainage. Above that: rudus. Fist-sized gravel, bound with lime. Then: nucleus. Fine gravel and sand, packed hard. And at the top: summa crusta. Cut stone polygons, fitted without mortar. Each layer — a different purpose. The road that lasts two thousand years does not happen by accident. Every layer knows its job.",
                keywords: [
                    KeywordPair(keyword: "Statumen", definition: "Bottom layer — large flat stones for drainage"),
                    KeywordPair(keyword: "Rudus", definition: "Second layer — gravel bound with lime"),
                    KeywordPair(keyword: "Nucleus", definition: "Third layer — fine gravel packed hard"),
                    KeywordPair(keyword: "Summa crusta", definition: "Top layer — cut stone polygons"),
                ],
                activity: .multipleChoice(question: "What is the bottom layer of a Roman road?", options: ["Nucleus", "Rudus", "Statumen", "Summa crusta"], correctIndex: 2),
                notebookSummary: "A Roman road is a structure, not a surface. 4 layers, 1.5m total: statumen (drainage stones), rudus (lime gravel), nucleus (packed sand), summa crusta (cut polygons). Every layer knows its job.",
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
                lessonText: "And now — the top layer. The Via Appia's surface stones are basalt. Volcanic rock. So hard, it dulls the iron chisel that cuts it. The masons shape them into irregular polygons — like pieces of a puzzle — and fit them together. No mortar. Nothing to glue them. The shapes themselves lock tighter under every footstep, every wheel. Two thousand three hundred years later, you can still walk on the original stones. The Romans chose the hardest rock on earth. And they made it the smoothest road. Beautiful — no?",
                keywords: [
                    KeywordPair(keyword: "Basalt", definition: "Volcanic rock used for road surface — extremely hard"),
                    KeywordPair(keyword: "Polygonal", definition: "Irregular multi-sided shape that interlocks"),
                    KeywordPair(keyword: "Via Appia", definition: "Queen of Roads — Rome's first major highway"),
                    KeywordPair(keyword: "2,300 years", definition: "Age of original basalt paving still walkable"),
                ],
                activity: .hangman(word: "BASALT", hint: "Volcanic rock so hard it dulls iron chisels"),
                notebookSummary: "Via Appia: basalt polygons fitted without mortar — irregular shapes interlock tighter under weight. 2,300 years old, still walked on. The hardest rock on earth, made into the smoothest road.",
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
                lessonText: "The bottom layer — the statumen — needs flat stones. Stones that will not shift under load. So the quarrymen find natural cracks in the basalt. They drive iron wedges into holes drilled along the line. And then — they wait. Winter comes. Water is poured into the cracks. The water freezes. And ice does what no hammer can do. It splits the hardest rock on earth. Then the best stones are hand-selected. Flat bottom — to sit stable. Rough top — to grip the rudus layer above. Every stone is chosen — by feel.",
                keywords: [
                    KeywordPair(keyword: "Iron wedges", definition: "Hammered into holes to split basalt"),
                    KeywordPair(keyword: "Ice splitting", definition: "Water freezes in cracks — expands and breaks rock"),
                    KeywordPair(keyword: "Flat bottom", definition: "Statumen stones must sit stable"),
                    KeywordPair(keyword: "Rough top", definition: "Textured surface grips the rudus layer above"),
                ],
                activity: .trueFalse(statement: "Romans used frozen water in cracks to split basalt for road foundations", isTrue: true),
                notebookSummary: "Basalt split with iron wedges + frozen water (9% expansion). Statumen stones: flat bottom (sits stable), rough top (grips the rudus). Every stone chosen by feel.",
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
                lessonText: "Now — listen. You remember the pozzolana? The volcanic ash from Pozzuoli? The one that sets HARDER underwater? Here it is again. We use it for the rudus layer. Gravel alone would shift, would crumble. But mix in lime and pozzolana — and something miraculous begins. The silica in the ash reacts with the lime. Crystals form. Tiny crystals, growing into every pore between the stones. Slowly. For years. Decades. The road becomes stronger with age. And we are not done with this ash. It returns again — when we build the Pantheon.",
                keywords: [
                    KeywordPair(keyword: "Calcium silicate hydrate", definition: "Crystal that forms in pozzolanic cement"),
                    KeywordPair(keyword: "Rudus", definition: "Gravel layer bound with volcanic mortar"),
                    KeywordPair(keyword: "Grows stronger", definition: "Pozzolanic reaction continues for years"),
                ],
                activity: .wordScramble(word: "RUDUS", hint: "Gravel road layer bound with volcanic mortar"),
                notebookSummary: "Rudus: gravel bound by lime + pozzolana (callback to Aqueduct). Silica + lime → calcium silicate crystals fill the pores between stones. Gets stronger over years. Same ash returns at the Pantheon.",
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
                lessonText: "Look closely at any Roman road. From the side. Notice the shape. The nucleus layer is not flat. It is crowned. The center sits fifteen to thirty centimeters higher than the edges. Why? Because rain falls. And rain that stays — rots the road. So we make the road into a roof. A gentle arc. Water runs off to ditches on both sides. Fast enough to clear. Slow enough not to erode. Every Roman road is secretly — a roof. Geometry keeps it dry. The eye cannot see the slope. But the rain — the rain knows.",
                keywords: [
                    KeywordPair(keyword: "Camber", definition: "Crowned surface — center higher than edges"),
                    KeywordPair(keyword: "15-30 cm", definition: "Height difference between center and edges"),
                    KeywordPair(keyword: "Cross-section", definition: "Gentle arc shape for drainage"),
                    KeywordPair(keyword: "Drainage ditch", definition: "Channels on both sides collecting runoff"),
                ],
                activity: .numberFishing(question: "Maximum camber height (cm) above the road edges?", correctAnswer: 30, decoys: [5, 10, 50, 75, 100]),
                notebookSummary: "Nucleus is crowned, not flat — center 15-30 cm higher than the edges. Rain runs off to side ditches. Every Roman road is secretly a roof. The eye does not see the slope, but the rain knows.",
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
                lessonText: "Now — your hands get dirty again. But this is not aqueduct mortar. Road mortar is rougher. Coarser. It must grip large gravel, not smooth stone. Same lime — but a rougher cousin. One part lime. Three parts crushed volcanic rock. Bigger than sand. Mix dry first. Then add water slowly. It should feel like wet beach sand in your hands. Now — pack it between the gravel with a wooden rammer. Fifty times — every square meter. Fifty. Roads are built by rhythm. Strike, lift, strike, lift. Hour after hour.",
                keywords: [
                    KeywordPair(keyword: "1:3 ratio", definition: "Lime to crushed volcanic rock for road mortar"),
                    KeywordPair(keyword: "Dry mix first", definition: "Combine lime + rock before adding water"),
                    KeywordPair(keyword: "Rammer", definition: "Wooden tool for compacting road layers"),
                    KeywordPair(keyword: "50 rams/m²", definition: "Compaction standard per square meter"),
                ],
                activity: .fillInBlanks(text: "Road mortar: ___ part lime, ___ parts crushed volcanic rock, rammed ___ times per square meter", blanks: ["1", "3", "50"], distractors: ["2", "5", "20"]),
                notebookSummary: "Road mortar = rougher cousin of aqueduct mortar. 1 lime + 3 crushed volcanic rock (larger grain than sand). Mix dry, add water. Pack between gravel — 50 hammer strikes per m². Roads built by rhythm.",
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
                lessonText: "You have made quicklime before — for the aqueduct. But for the roads, we burn it longer. Three days. Not one. Limestone chunks stacked inside a stone cylinder. Charcoal between every layer. Light the bottom — and wait. Three days of fire. Nine hundred degrees. The fire drives the carbon out of the stone. What remains is quicklime. White. Powdery. So reactive — one drop of water and it burns. Store it dry. Always dry. And remember — you will fire this powder again. In greater buildings to come.",
                keywords: [
                    KeywordPair(keyword: "3 days", definition: "Continuous firing time for road-grade lime"),
                    KeywordPair(keyword: "900°C", definition: "Kiln temperature for limestone to quicklime"),
                    KeywordPair(keyword: "Quicklime", definition: "CaO — white powder that reacts violently with water"),
                ],
                activity: .trueFalse(statement: "Road-grade quicklime requires 3 days of continuous firing at 900°C", isTrue: true),
                notebookSummary: "Road-grade quicklime: 3 days continuous firing at 900°C (longer than aqueduct lime). CaCO₃ → CaO + CO₂. Burns skin, reacts violently with water — store bone dry. Same powder returns at the Pantheon.",
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
                lessonText: "Almost done. But before we leave the roads — one last thing. Look. Every Roman mile — one thousand four hundred and eighty meters — a stone column stands. We call them milliaria. Each one carved with the emperor's name, the road's name, the distances to the next three cities. The world's first map. Soldiers, merchants, tax collectors — they all depended on these stones. And then — there is one stone that matters above all the others. Augustus, the first emperor, placed a column of gilded bronze in the Forum. The golden milestone. Mile zero. Every measurement in the empire begins at this single point. Remember this, when you build greater things. Navigation begins with a reference point.",
                keywords: [
                    KeywordPair(keyword: "Milliarium", definition: "Stone milestone placed every Roman mile"),
                    KeywordPair(keyword: "1,480 meters", definition: "Length of one Roman mile"),
                    KeywordPair(keyword: "Golden milestone", definition: "Mile zero in the Roman Forum"),
                    KeywordPair(keyword: "Augustus", definition: "Emperor who established the milestone system"),
                ],
                activity: .numberFishing(question: "How many meters in a Roman mile?", correctAnswer: 1480, decoys: [1000, 1200, 1600, 1850, 2000]),
                notebookSummary: "Milliaria: stone columns every 1,480m (1 Roman mile). Carved with emperor + road + distances to next 3 cities — the world's first map. Augustus placed the gilded golden milestone in the Forum = mile zero. Navigation begins with a reference point.",
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
                lessonText: "And now — Act Two begins. The bath. But this is not what you think. Not a place to wash. The Romans called it the thermae. Library. Gymnasium. Garden. Meeting hall. All under one roof. Emperor Caracalla built one that held sixteen hundred bathers at the same time. Citizens spent entire afternoons here — slaves next to senators, soldiers next to scholars. Admission was almost free. The emperor paid the difference. Why? A clean citizen is a happy citizen. A happy citizen does not revolt. The thermae was Rome's greatest social engineering project — disguised as architecture.",
                keywords: [
                    KeywordPair(keyword: "Thermae", definition: "Large public bath complex with many functions"),
                    KeywordPair(keyword: "Caracalla", definition: "Emperor who built baths for 1,600 bathers"),
                    KeywordPair(keyword: "Subsidized", definition: "Government paid most costs — almost free entry"),
                    KeywordPair(keyword: "Social engineering", definition: "Architecture designed to shape citizen behavior"),
                ],
                activity: .numberFishing(question: "How many bathers could the Baths of Caracalla hold?", correctAnswer: 1600, decoys: [400, 800, 2500, 5000, 10000]),
                notebookSummary: "Thermae: bath + library + gym + garden, all under one roof. Caracalla's complex held 1,600 bathers — slaves alongside senators. Almost free admission, subsidized by emperors. Social engineering disguised as architecture.",
                visual: CardVisual(type: .comparison, title: "Thermae — More Than a Bath", values: ["equal": 0], labels: ["Modern gym\nOne purpose\nExpensive", "Roman thermae\nBath + library + gym\n+ garden — almost free", "1,600 bathers simultaneously at Caracalla"], steps: 3, caption: "Social engineering as architecture — open to almost everyone"),
                isLeadCard: true
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_1",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .cityMap, stationKey: "building",
                title: "Step 1: The Hypocaust",
                italianTitle: "Riscaldamento a Ipocausto",
                icon: "flame.fill",
                lessonText: "Beneath the floor — the greatest Roman invention you have never heard of. The hypocaust. A furnace burns hot air. The hot air flows through a crawl space — under the floor. The floor itself sits on small brick towers we call pilae. Above, hollow tiles run inside the walls — tubuli. Heat rises through the walls. Out the roof vents. The whole building — heated. The floor is now a radiator. Bathers walked barefoot on warm stone. This — this is central heating. Two thousand years before any of your houses had it.",
                keywords: [
                    KeywordPair(keyword: "Hypocaust", definition: "Underfloor heating system using hot air"),
                    KeywordPair(keyword: "Pilae", definition: "Brick stacks supporting the raised floor"),
                    KeywordPair(keyword: "Tubuli", definition: "Hollow wall tiles carrying hot air upward"),
                    KeywordPair(keyword: "Central heating", definition: "One furnace heats the entire building"),
                ],
                activity: .wordScramble(word: "HYPOCAUST", hint: "Roman underfloor heating — hot air beneath raised floors"),
                notebookSummary: "Hypocaust: furnace → hot air under raised floor (supported on pilae brick stacks) → up through hollow wall tiles (tubuli) → out roof vents. The floor itself becomes a radiator. First central heating — 2,000 years before any house had it.",
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
                lessonText: "You remember the castellum — the tank that splits aqueduct water three ways? Here it is again. But this time — for the bath. Three outlets, three heights. The cold pool — outlet at the bottom. The warm pool — outlet in the middle. The hot pool — outlet at the top. Why? Because hot water evaporates fastest. If the aqueduct pressure drops, the hot pool loses water first. The cold pool — which serves the most bathers — keeps running. Gravity does the rationing. Without a single engineer awake to manage it. The Romans built justice into the plumbing.",
                keywords: [
                    KeywordPair(keyword: "Castellum", definition: "Water tank distributing to different pools"),
                    KeywordPair(keyword: "Three heights", definition: "Outlets ranked by priority — cold lowest"),
                    KeywordPair(keyword: "Gravity rationing", definition: "Low pressure cuts high outlets first"),
                ],
                activity: .multipleChoice(question: "Which pool's outlet was placed lowest in the castellum?", options: ["Hot pool (caldarium)", "Warm pool (tepidarium)", "Cold pool (frigidarium)", "All at equal height"], correctIndex: 2),
                notebookSummary: "Castellum at the bath: 3 outlets at different heights (callback to aqueduct). Cold pool = lowest outlet, warm = middle, hot = highest (hot water evaporates fastest). When pressure drops, hot loses first — cold (most bathers) keeps running. Gravity rations automatically — justice built into the plumbing.",
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
                lessonText: "The bath has a route. A path the body follows. First — the frigidarium. Cold pool. Fifteen degrees. The shock that wakes you. Then — the tepidarium. Warm. Twenty-five degrees. The middle room. Then — the caldarium. Hot. Forty degrees. Pores open. The body breathes through its skin. After, you return to the cold. Pores close. The body sealed. The order matters. And here is the beautiful thing — the caldarium sits directly above the furnace. The tepidarium shares its wall. The frigidarium is far away. The architects did not place rooms by guess. They placed them by temperature. Floor plan as physics.",
                keywords: [
                    KeywordPair(keyword: "Frigidarium", definition: "Cold pool room (~15°C)"),
                    KeywordPair(keyword: "Tepidarium", definition: "Warm room (~25°C) — between cold and hot"),
                    KeywordPair(keyword: "Caldarium", definition: "Hot pool room (~40°C) directly over furnace"),
                    KeywordPair(keyword: "Temperature gradient", definition: "Rooms arranged cold → warm → hot"),
                ],
                activity: .fillInBlanks(text: "Bath route: ___ (cold 15°C) → ___ (warm 25°C) → ___ (hot 40°C)", blanks: ["frigidarium", "tepidarium", "caldarium"], distractors: ["laconicum", "natatio", "apodyterium"]),
                notebookSummary: "Bath route: frigidarium (15°C, cold) → tepidarium (25°C, warm) → caldarium (40°C, hot). Cold to hot opens pores; back to cold seals them. Caldarium sits directly above the furnace; tepidarium shares a wall; frigidarium is far away. Floor plan as physics.",
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
                lessonText: "Ten million liters of water — every day. Where does it all go? Down. Through the floor. The floor itself slopes — two percent, just enough — toward bronze grated drains. From the drains, underground channels lead to the Cloaca Maxima. The great sewer of Rome. And here is the genius — the dirty bath water does not simply disappear. It travels downhill, into the public latrines. It flushes them clean before it goes to the river. Nothing is wasted. The most sophisticated plumbing of the ancient world — it runs entirely on slope. No pumps. No machines. Only gravity, and patience.",
                keywords: [
                    KeywordPair(keyword: "2% slope", definition: "Floor gradient toward drains"),
                    KeywordPair(keyword: "Cloaca Maxima", definition: "Rome's great sewer collecting all drainage"),
                    KeywordPair(keyword: "10 million liters", definition: "Daily water consumption of a major bath"),
                    KeywordPair(keyword: "Reuse", definition: "Bath drain water flushed public latrines"),
                ],
                activity: .hangman(word: "CLOACA", hint: "Rome's great sewer — the Cloaca Maxima"),
                notebookSummary: "Baths consumed 10 million liters/day. Floors slope 2% toward bronze-grated drains. Underground channels lead to the Cloaca Maxima (Rome's great sewer). Drain water reused downstream to flush public latrines. Nothing wasted — all on gravity, no pumps.",
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
                lessonText: "Bath walls must be beautiful. They must also be waterproof. So we use two materials. Marble — on the outside. Polished, gleaming, the face the bathers see. And behind it — you remember? Opus signinum. The crushed pottery lining we made for the aqueduct. Three coats again. But this time, hidden. The marble takes the praise. The signinum does the work. Lead clamps fix the marble to the concrete behind. Together, this wall stayed watertight for four hundred years. Two materials. Two jobs. The face — and the shield.",
                keywords: [
                    KeywordPair(keyword: "Marble veneer", definition: "Thin decorative slabs over concrete walls"),
                    KeywordPair(keyword: "Lead clamps", definition: "Metal fasteners holding marble to the wall"),
                    KeywordPair(keyword: "Opus signinum", definition: "Waterproof layer behind the marble"),
                ],
                activity: .trueFalse(statement: "Roman bath walls used opus signinum behind the marble to prevent leaks", isTrue: true),
                notebookSummary: "Bath walls: marble veneer (face) over opus signinum waterproofing (shield, callback to aqueduct) over concrete core. Lead clamps hold the marble. Stayed watertight 400 years. The marble takes the praise; the signinum does the work.",
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
                lessonText: "And now — listen to a beautiful engineering trick. Bath concrete has a unique enemy. Thermal cycling. Hot all day, cold all night. Every day. Every night. Expansion. Contraction. Ordinary cement cracks. But — the Romans changed the recipe. You remember the pozzolana? The volcanic ash that hardens underwater? Here we use more of it. Not one part lime to three parts ash — but one to FOUR. The extra silica fills the micro-cracks AS THEY FORM. The concrete heals itself. Self-healing stone. Two thousand years ago. The Romans engineered for problems they could not see.",
                keywords: [
                    KeywordPair(keyword: "Thermal cycling", definition: "Daily heating and cooling that cracks cement"),
                    KeywordPair(keyword: "1:4 ratio", definition: "Extra pozzolana for bath concrete"),
                    KeywordPair(keyword: "Self-healing", definition: "Excess silica fills micro-cracks as they form"),
                ],
                activity: .fillInBlanks(text: "Bath concrete uses ___ part lime to ___ parts pozzolana — extra silica ___ micro-cracks", blanks: ["1", "4", "heals"], distractors: ["2", "3", "prevents"]),
                notebookSummary: "Bath concrete: 1:4 lime-to-pozzolana (extra silica, vs the normal 1:3 from aqueduct/roads). Caldarium 40°C by day, cool by night — thermal cycling cracks ordinary cement. The extra silica fills micro-cracks AS THEY FORM. Self-healing stone. Engineered for invisible problems.",
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
                lessonText: "The Baths of Caracalla had glass windows. Rare in the ancient world. Most buildings of Rome had no glass — only mica or open shutters. To make glass, you melt river sand — silica — with natron, a kind of soda ash. Eleven hundred degrees. The molten glass is poured onto flat stone, then rolled. The panes are thick. Greenish. Wavy as old water. But they let light flood the caldarium. The dark cave becomes a palace. And listen — we will return to this material. Soon, in Venice, glass becomes something else entirely. Patience.",
                keywords: [
                    KeywordPair(keyword: "Silica", definition: "River sand — main ingredient in glass"),
                    KeywordPair(keyword: "Natron", definition: "Soda ash flux that lowers melting temperature"),
                    KeywordPair(keyword: "1,100°C", definition: "Temperature needed to melt glass"),
                    KeywordPair(keyword: "Cast glass", definition: "Molten glass poured and rolled flat on stone"),
                ],
                activity: .numberFishing(question: "What temperature (°C) melts sand into glass?", correctAnswer: 1100, decoys: [600, 800, 900, 1400, 1800]),
                notebookSummary: "Bath glass: river sand (silica) + natron at 1,100°C, poured onto flat stone + rolled. Thick, greenish, wavy — but floods the caldarium with light. The dark cave becomes a palace. This same material returns at Venice (Glassworks).",
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
                lessonText: "The frigidarium — the cold pool — is the largest room in the bath. Its roof must span twenty-five meters. Without a single column. How? Oak trusses. The king-post design — two angled rafters meeting at the peak, held by a vertical post. You remember the rule? Depth equals span divided by twenty. Twenty-five-meter span — one and a quarter meters deep. Oak's grain interlocks — resists splitting under tension. Each truss carries twenty tons of terracotta tiles. The tree that grows slowest carries the most weight. There is a lesson in that.",
                keywords: [
                    KeywordPair(keyword: "King-post truss", definition: "Two rafters + vertical post spanning wide rooms"),
                    KeywordPair(keyword: "25 meters", definition: "Maximum span of frigidarium roof trusses"),
                    KeywordPair(keyword: "20 tons", definition: "Weight of tiles each truss carried"),
                    KeywordPair(keyword: "Interlocking grain", definition: "Oak's structure that resists splitting"),
                ],
                activity: .numberFishing(question: "Maximum span (meters) of frigidarium roof trusses?", correctAnswer: 25, decoys: [10, 15, 35, 45, 60]),
                notebookSummary: "Frigidarium: oak king-post trusses (two rafters + vertical post) span 25m without columns. Insula 1/20 rule: 25m span → 1.25m deep beams. Each truss carries 20 tons of tiles. Oak's interlocking grain resists splitting. The tree that grows slowest carries the most weight.",
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
                lessonText: "The furnace must never go out. Day. Night. Always burning. For this, the Romans chose chestnut wood. Why not oak? Oak burns hotter — but it burns unevenly. Chestnut splits easily. Dries quickly. Burns with steady, even heat. The stoker feeds the fire every thirty minutes. His task — keep the furnace at exactly three hundred degrees. So that the caldarium floor stays at forty. One miscalculation, and the bathers burn their feet. The stoker is invisible. No bather knows his name. But without him — no warm bath. Temperature control is a craft. Not a calculation.",
                keywords: [
                    KeywordPair(keyword: "Chestnut", definition: "Preferred fuel — steady, even heat"),
                    KeywordPair(keyword: "300°C", definition: "Target furnace temperature"),
                    KeywordPair(keyword: "40°C", definition: "Caldarium floor temperature for bathers"),
                    KeywordPair(keyword: "30 minutes", definition: "Feeding interval for the stoker"),
                ],
                activity: .trueFalse(statement: "Chestnut was preferred for bath furnaces because it burns with steady, even heat", isTrue: true),
                notebookSummary: "Chestnut over oak: splits easily, dries quickly, burns with steady even heat (oak burns hot but unevenly). Stoker feeds every 30 min. Furnace 300°C → floor 40°C. Bathers walk barefoot. The stoker is invisible but essential — temperature control is a craft, not a calculation.",
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
                lessonText: "The glass recipe. Sixty parts silica — river sand. Fifteen parts natron — the soda ash. Ten parts lime — yes, the same lime you have made before. And fifteen parts cullet — recycled, crushed old glass. Why? Because cullet lowers the melting point. Makes the batch more reliable. Mix dry. Shovel into the crucible. Eleven hundred degrees. Stir with an iron rod. The glass comes out greenish — that is iron in the sand. To remove the tint, add manganese. Chemistry corrects what nature gives. The Romans wasted nothing — not even broken glass.",
                keywords: [
                    KeywordPair(keyword: "Cullet", definition: "Recycled crushed glass added to the batch"),
                    KeywordPair(keyword: "60% silica", definition: "Main glass ingredient — river sand"),
                    KeywordPair(keyword: "Manganese", definition: "Added to remove green tint from iron impurities"),
                ],
                activity: .multipleChoice(question: "What is 'cullet' in glassmaking?", options: ["Iron impurity", "Recycled crushed glass", "Raw silica sand", "Soda ash flux"], correctIndex: 1),
                notebookSummary: "Roman glass recipe: 60% silica (river sand) + 15% natron (soda ash) + 10% lime + 15% cullet (recycled crushed glass — lowers melting point, makes batch reliable). 1,100°C. Manganese removes the green tint from iron impurities. Romans wasted nothing — not even broken glass.",
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
                lessonText: "The praefurnium. The mouth of the hypocaust furnace. A vaulted chamber. This is where the fire lives. Air enters from below — through a metal grate. It feeds the flames. The hot gases rush out the back, into the crawl space beneath the floor. Now — look at the shape. The vault narrows as it rises. This is no accident. Narrowing the vault — accelerates the airflow. Faster air, hotter fire. We call this the Venturi effect. The skilled stoker controls the temperature by adjusting the grate. Not the fuel. Oxygen is the real fuel. Wood is only the messenger.",
                keywords: [
                    KeywordPair(keyword: "Praefurnium", definition: "Vaulted furnace mouth where combustion happens"),
                    KeywordPair(keyword: "Venturi effect", definition: "Narrowing vault accelerates airflow"),
                    KeywordPair(keyword: "Air grate", definition: "Controls oxygen — the real temperature dial"),
                ],
                activity: .wordScramble(word: "PRAEFURNIUM", hint: "The vaulted mouth of the hypocaust furnace"),
                notebookSummary: "Praefurnium: vaulted mouth of the hypocaust furnace. Air enters via grate from below. Vault narrows upward — Venturi effect accelerates airflow → hotter fire. Temperature controlled by the air grate, not the fuel. Oxygen is the real fuel — wood is only the messenger.",
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
                lessonText: "Bath oils. Perfumes. Cleaning supplies. All these things must be stored. And the clay vessels we use — the amphorae — they leak. So inside, we paint pine pitch. Heated tree resin. It fills every pore in the clay. A cork stopper on top — sealed with hot wax. The most dangerous material we store? Quicklime. One drop of water — and it explodes with heat. So we keep quicklime in sealed lead containers. Bone dry. Always. Listen — proper storage saves lives. The most boring detail of the bath — it is also one of the most important.",
                keywords: [
                    KeywordPair(keyword: "Pine pitch", definition: "Heated tree resin waterproofing amphora interiors"),
                    KeywordPair(keyword: "Amphora", definition: "Two-handled clay storage vessel"),
                    KeywordPair(keyword: "Wax seal", definition: "Extra waterproofing over the cork stopper"),
                    KeywordPair(keyword: "Lead container", definition: "For storing reactive quicklime safely"),
                ],
                activity: .hangman(word: "AMPHORA", hint: "Two-handled clay vessel lined with pine pitch"),
                notebookSummary: "Storage: amphorae lined with pine pitch (heated tree resin fills clay pores) for oils + perfumes. Cork stoppers sealed with hot wax. Quicklime stored in sealed lead containers — one drop of water and it explodes with heat. The most boring detail saves lives.",
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
                lessonText: "Welcome to your third building. A million Romans lived in this city — and there was not enough land. So they built up. The first apartment buildings the world had ever seen. Six stories. Sometimes seven. Housing dozens of families under one roof. Ground floors held shops. The upper floors got smaller, cheaper, more dangerous. Listen to this — the richest lived lowest. The poorest lived highest. Closer to fire. Farther from escape. You remember the aqueduct? Water flowed first to the public fountains, then to baths, then to homes. The same Roman order — only now, it climbs the stairs.",
                keywords: [
                    KeywordPair(keyword: "Insula", definition: "Roman apartment block — 6-7 stories tall"),
                    KeywordPair(keyword: "Tabernae", definition: "Ground-floor shops in the insula"),
                    KeywordPair(keyword: "Million residents", definition: "Rome's population requiring vertical housing"),
                    KeywordPair(keyword: "Richest lowest", definition: "Wealthy tenants lived on lower, safer floors"),
                ],
                activity: .numberFishing(question: "How many stories tall was a typical Roman insula?", correctAnswer: 7, decoys: [3, 4, 10, 12, 15]),
                notebookSummary: "Insulae: Rome's first apartment buildings — 6 to 7 stories. A million Romans + not enough land = build up. Ground floor = shops (tabernae). Richest lived lowest, poorest highest. Same Roman order as the specus — now climbing stairs.",
                visual: CardVisual(
                    type: .crossSection,
                    title: "6-7 Story Apartment",
                    values: ["height": 7],
                    labels: ["Shops (ground)", "Rich apartments", "Middle class", "Poor (top floor)", "Roof (fire risk)"],
                    steps: 4, caption: "Vertical cities have always sorted people by money"
                ),
                isLeadCard: true
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_1",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .cityMap, stationKey: "building",
                title: "Step 4: Five Stories",
                italianTitle: "Limite di Altezza di Augusto",
                icon: "ruler.fill",
                lessonText: "Tall buildings fall. That is the truth no engineer can escape. After many catastrophic collapses — entire insulae crashing down on their residents — Emperor Augustus did something new. He wrote a law. No building taller than twenty meters. About six stories. After the Great Fire of Rome, Nero made it stricter — seventeen and a half meters. Why? Foundations. The Roman ground beneath the city could only carry so much weight. Brick and concrete have a price. Listen to me — building codes are written in blood. Every rule, after a tragedy.",
                keywords: [
                    KeywordPair(keyword: "20 meters", definition: "Augustus's maximum building height"),
                    KeywordPair(keyword: "17.5 meters", definition: "Nero's reduced limit after the Great Fire"),
                    KeywordPair(keyword: "Building code", definition: "First height regulation in history"),
                    KeywordPair(keyword: "Foundation limit", definition: "Roman foundations couldn't support 7+ stories"),
                ],
                activity: .numberFishing(question: "Augustus limited insulae to what height (meters)?", correctAnswer: 20, decoys: [10, 15, 25, 30, 40]),
                notebookSummary: "Augustus: max 20m (after catastrophic collapses). Nero: max 17.5m (after the Great Fire). The first building codes in history — written in blood. The real limit was foundation engineering, not ambition.",
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
                lessonText: "The ground floor — this was the most valuable space in the building. Wide arches opened directly to the street. We called these shops tabernae. Bakers, with their loaves. Butchers, with their hooks. Wine sellers. And the fullers — the Roman launderers, who cleaned clothes with — well, with urine. Yes. Urine. Ammonia, you see. It works. Above the counter, a wooden mezzanine — that was where the shopkeeper slept. One arch served as both door and window. Maximum visibility — minimum wasted space. Roman commerce — simple, perfect.",
                keywords: [
                    KeywordPair(keyword: "Taberna", definition: "Ground-floor shop with arched street opening"),
                    KeywordPair(keyword: "Mezzanine", definition: "Wooden sleeping loft above the shop counter"),
                    KeywordPair(keyword: "Fuller", definition: "Ancient launderer — cleaned clothes with urine"),
                    KeywordPair(keyword: "Arch opening", definition: "Served as both door and display window"),
                ],
                activity: .wordScramble(word: "TABERNAE", hint: "Ground-floor shops in Roman apartment buildings"),
                notebookSummary: "Tabernae: arched ground-floor shops — bakers, butchers, wine sellers, fullers (who cleaned clothes with urine, for the ammonia). Mezzanine bedroom above the counter. Arch served as door + display window. Max visibility, min wasted space.",
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
                lessonText: "Look at the walls. At the bottom — sixty centimeters thick. Solid brick and concrete. As we climb — they grow thinner. Forty-five centimeters at the second floor. Thirty at the third. By the top — only wooden frames remain. This is not carelessness. This is physics. The lowest walls must carry everything above them. The highest walls — they carry only themselves. So the building grows lighter as it grows taller. Lightest where it is tallest. Strange — no? In a Roman insula, the higher you go — the less weight there is to fall.",
                keywords: [
                    KeywordPair(keyword: "60 cm", definition: "Ground floor wall thickness — solid brick"),
                    KeywordPair(keyword: "45 cm → 30 cm", definition: "Progressive thinning on upper floors"),
                    KeywordPair(keyword: "Cumulative load", definition: "Each floor carries all floors above it"),
                    KeywordPair(keyword: "Timber frame", definition: "Lightest construction on top floors"),
                ],
                activity: .multipleChoice(question: "Why did insula walls get thinner on upper floors?", options: ["To save money on bricks", "To reduce the load that lower walls carry", "Romans ran out of materials", "Upper floors weren't important"], correctIndex: 1),
                notebookSummary: "Insula walls taper as they climb: 60cm (ground) → 45cm → 30cm → timber (top). Lightest where it is tallest. The lowest walls carry everything above; the highest walls carry only themselves.",
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
                lessonText: "Six stories. No elevators. Climbing is daily life. So the engineers gave the insula its backbone — the spiral staircase. A perfect circle, two meters across. That is all. Each step is a wedge — wide at the outer wall, narrow at the center. In the middle, a single column — we call it the newel. It carries the weight of every step above it. Maximum height. Minimum space. Geometry as a solution to crowding. Look at any old building in modern Rome — these stairs are still there. Two thousand years of climbing.",
                keywords: [
                    KeywordPair(keyword: "Spiral staircase", definition: "Circular stairs fitting in a 2m diameter"),
                    KeywordPair(keyword: "Newel", definition: "Central column carrying all the steps"),
                    KeywordPair(keyword: "Wedge step", definition: "Wide at outer wall, narrow at center"),
                    KeywordPair(keyword: "Floor space", definition: "Spiral uses minimum area for maximum height"),
                ],
                activity: .trueFalse(statement: "Roman insula spiral staircases fit within a 2-meter diameter circle", isTrue: true),
                notebookSummary: "Spiral staircases: 2m diameter, wedge steps (wide outside, narrow at center), central newel column carries all the steps. Maximum vertical travel in minimum floor space — the same stairs still climb in old Roman buildings today.",
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
                lessonText: "Now — your hands get dirty again. But this is a third recipe. You have learned the aqueduct mortar — strong, with pozzolana. You have learned the road mortar — rougher, with crushed volcanic rock. This is the insula recipe. The cheapest of all. One part lime. Four parts local sand. No pozzolana — it costs too much. The trade-off? The mortar sets slower. Bonds weaker. But it costs one third. So the builders make the joints thicker — two centimeters instead of one — more mortar between every brick. Economy and engineering — balanced on a budget.",
                keywords: [
                    KeywordPair(keyword: "1:4 ratio", definition: "Lime to local sand — cheaper than pozzolana mix"),
                    KeywordPair(keyword: "2 cm joints", definition: "Thicker mortar compensates for weaker recipe"),
                    KeywordPair(keyword: "Slower setting", definition: "Trade-off of using sand instead of volcanic ash"),
                ],
                activity: .trueFalse(statement: "Insula mortar used cheaper local sand instead of pozzolana, with thicker joints to compensate", isTrue: true),
                notebookSummary: "Insula mortar (3rd recipe learned): 1 lime + 4 local sand. No pozzolana — too expensive. Weaker but 1/3 the cost. Compensate with thicker 2cm joints (vs 1cm). Economy + engineering balanced on a budget.",
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
                lessonText: "And now — the roof. Two tiles. The tegula — flat, with raised edges. The imbrix — half-round, like a cup turned upside down. It covers the joints between tegulae. Rain falls. Water runs down the channels, off the eaves, to the street below. No nails. Only gravity. Only careful overlap. Three thousand tiles for a single insula — all hand-molded from river clay. Walk through any Italian village today, you will see this same roof. Two thousand years — and we have not improved it. Every Roman, no matter how poor — had a roof.",
                keywords: [
                    KeywordPair(keyword: "Tegula", definition: "Flat roof tile with raised edges"),
                    KeywordPair(keyword: "Imbrix", definition: "Half-round cap tile covering the joints"),
                    KeywordPair(keyword: "3,000 tiles", definition: "Number needed for one insula roof"),
                    KeywordPair(keyword: "No nails", definition: "Gravity and overlap hold tiles in place"),
                ],
                activity: .hangman(word: "TEGULAE", hint: "Flat Roman roof tiles with raised edges"),
                notebookSummary: "Roof = tegulae (flat tiles with raised edges) + imbrices (half-round caps over the joints). 3,000 tiles per insula, hand-molded from river clay. No nails — only gravity + overlap. Still used in Italy today. Every Roman, no matter how poor, had a roof.",
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
                lessonText: "Windows. Now — listen carefully. The wealthy had cast glass. Clear. Beautiful. Expensive. The rest had mica. We call it lapis specularis — natural stone that splits into paper-thin transparent sheets. It blocks wind. It passes light. Mined far away — in Hispania. Carried back to Rome by the wagonload. Glass cost ten times more. So in the typical insula — mica below the third floor. And above? Wooden shutters. Open in summer. Closed in winter. Light, you see, is a luxury. With a price tag. What money buys — what poverty pays.",
                keywords: [
                    KeywordPair(keyword: "Lapis specularis", definition: "Mica mineral split into transparent window sheets"),
                    KeywordPair(keyword: "Mica", definition: "Natural mineral that cleaves paper-thin"),
                    KeywordPair(keyword: "Hispania", definition: "Roman Spain — major mica mining source"),
                    KeywordPair(keyword: "10× cost", definition: "Glass vs mica price difference"),
                ],
                activity: .wordScramble(word: "MICA", hint: "Natural mineral split into transparent window sheets"),
                notebookSummary: "Windows = cast glass (rich, clear, 10× more expensive) or mica/lapis specularis (cheap, translucent, mined in Hispania). Mica below 3rd floor, wooden shutters above. Light was a priced luxury — what money buys, what poverty pays.",
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
                lessonText: "You will need oak. Strong, heavy, slow-growing oak — for the floor beams. Each beam spans the width of an apartment — four to five meters. Spaced forty centimeters apart. Together, they hold up the concrete floor — and every person who walks above. Now — listen. Here is the rule the master carpenter taught the apprentice. Beam depth — equals span — divided by twenty. A five-meter span? Twenty-five centimeters deep. Too shallow, the floor bounces. Too deep, wood is wasted. No books taught this rule. Only years of cutting, lifting, fitting. The carpenter knew it — by hand, by year. Like you will.",
                keywords: [
                    KeywordPair(keyword: "40 cm spacing", definition: "Distance between floor beams"),
                    KeywordPair(keyword: "1/20 rule", definition: "Beam depth = span ÷ 20"),
                    KeywordPair(keyword: "4-5 meters", definition: "Typical apartment width (beam span)"),
                    KeywordPair(keyword: "25 cm depth", definition: "Beam size for a 5-meter span"),
                ],
                activity: .numberFishing(question: "What depth beam (cm) for a 5-meter span using the 1/20 rule?", correctAnswer: 25, decoys: [10, 15, 30, 40, 50]),
                notebookSummary: "Oak floor beams span 4-5m, spaced 40cm apart. Rule: beam depth = span ÷ 20. A 5m span needs a 25cm deep beam. Roman carpenters knew this by apprenticeship — by hand, by year. No textbooks.",
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
                lessonText: "Higher up — the wood changes. Not oak. Poplar. Forty percent lighter. On the fifth floor, the sixth — every kilogram matters. Every kilogram presses down on the walls below. So we use the lighter wood. Cheap. Fast to cut. Easy to lift. Between the poplar frames — wattle and daub. Woven sticks packed with clay. Quick to build. And then — the price. Poplar burns. Wattle burns. Clay does not. But when the fire starts in a poor man's room at the top of the insula — the whole building is in trouble. Rome's great fires started in these rooms. The cheapest material — it had the highest cost.",
                keywords: [
                    KeywordPair(keyword: "Poplar", definition: "Light wood — 40% less than oak — for upper floors"),
                    KeywordPair(keyword: "Wattle and daub", definition: "Woven sticks + clay filling between frames"),
                    KeywordPair(keyword: "40% lighter", definition: "Poplar vs oak weight difference"),
                    KeywordPair(keyword: "Flammable", definition: "Upper floors burned easily — caused great fires"),
                ],
                activity: .multipleChoice(question: "Why was poplar used on upper insula floors instead of oak?", options: ["Stronger grain", "40% lighter", "Fire resistant", "Cheaper to cut"], correctIndex: 1),
                notebookSummary: "Upper floors used poplar (40% lighter than oak) + wattle and daub (woven sticks + clay). Cheap, fast, light — but flammable. Rome's great fires started in these top rooms. The cheapest material had the highest cost.",
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
                lessonText: "You have made lime mortar before. For the aqueduct. For the roads. But this — this is different. Insula mortar uses the SAME lime you have made. But it must age. Three months. Sometimes longer. Slaked lime, sitting in a pit, covered with water. Slowly — invisibly — it changes. The hot spots cool. The crystals settle. Then — and only then — you mix one part of this aged lime with four parts river sand. The consistency of thick yogurt. Spread two centimeters thick between every brick. Patience is an ingredient. The oldest lime — it makes the strongest mortar.",
                keywords: [
                    KeywordPair(keyword: "Lime putty", definition: "Slaked lime aged 3+ months before use"),
                    KeywordPair(keyword: "3 months", definition: "Minimum aging time to eliminate hot spots"),
                    KeywordPair(keyword: "1:4 ratio", definition: "Lime putty to river sand"),
                    KeywordPair(keyword: "Thick yogurt", definition: "Correct mortar consistency"),
                ],
                activity: .numberFishing(question: "How many months must lime putty age before use?", correctAnswer: 3, decoys: [1, 2, 6, 9, 12]),
                notebookSummary: "Insula plaster: 1 aged lime putty (slaked 3+ months) + 4 river sand. Aging eliminates the hot spots that crack fresh lime. Thick yogurt consistency, 2cm joints. Patience is an ingredient — the oldest lime makes the strongest mortar.",
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
                lessonText: "The last lesson. Brick and tile firing. The temperature must be exact. Below nine hundred degrees — the clay stays porous. Rain destroys it. Above eleven hundred — it vitrifies. Becomes glassy. Brittle. The sweet spot? Nine hundred fifty to ten hundred fifty. There, the silica fuses into a ceramic matrix — waterproof, but not fragile. How does the kiln master hold this temperature? An air vent. A hole in the wall. Wider for hotter. Narrower for cooler. Precision — from a hole in a wall. And so — we close. Today we have walked from water, to road, to home. The body of an empire is complete. But there is more, my apprentice. Soon — we will go higher. To temples. To domes that hold the sky. To gods.",
                keywords: [
                    KeywordPair(keyword: "950-1050°C", definition: "Sweet spot for terracotta — waterproof, not brittle"),
                    KeywordPair(keyword: "Vitrification", definition: "Above 1100°C — glassy and brittle"),
                    KeywordPair(keyword: "Ceramic matrix", definition: "Fused silica particles forming waterproof tile"),
                    KeywordPair(keyword: "Air vent", definition: "Kiln temperature controlled by opening width"),
                ],
                activity: .fillInBlanks(text: "Below ___°C clay crumbles. Above ___°C it vitrifies. Sweet spot: ___-1050°C", blanks: ["900", "1100", "950"], distractors: ["600", "800", "1200"]),
                notebookSummary: "Brick firing sweet spot: 950-1050°C. Below 900°C = porous, crumbles in rain. Above 1100°C = vitrified, glassy + brittle. Kiln temperature held by an air vent — precision from a hole in a wall.",
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
                lessonText: "Rome could not feed itself. A million people. Not enough grain in all of Italy. So the ships came — from Egypt, from Africa, from Spain. And they all docked here. Portus. Thirty kilometers from the city, where the Tiber meets the sea. Emperor Claudius dug an artificial basin — two hundred acres. Then Emperor Trajan called for his greatest architect — Apollodorus of Damascus. The same Apollodorus who, some say, designed the Pantheon. Apollodorus built a second harbor inside the first. Hexagonal. Six straight walls, distributing the force of the waves equally. Three hundred and fifty ships unloaded at once. The harbor that fed a million people — itself an engineering marvel no one remembers.",
                keywords: [
                    KeywordPair(keyword: "Portus", definition: "Rome's main harbor — 30 km from the city"),
                    KeywordPair(keyword: "Hexagonal basin", definition: "Trajan's 6-sided harbor distributing wave force"),
                    KeywordPair(keyword: "350 ships", definition: "Could dock simultaneously at Portus"),
                    KeywordPair(keyword: "200 acres", definition: "Size of Claudius's artificial harbor basin"),
                ],
                activity: .numberFishing(question: "How many ships could dock simultaneously at Portus?", correctAnswer: 350, decoys: [50, 150, 500, 750, 1000]),
                notebookSummary: "Portus: Rome's gateway, 30 km from the city. Claudius dug a 200-acre artificial basin. Trajan called Apollodorus of Damascus (architect, also linked to the Pantheon) to add a hexagonal inner harbor — 6 walls distributing wave force equally. 350 ships unloaded simultaneously. Fed a million people.",
                visual: CardVisual(
                    type: .geometry,
                    title: "Portus — 200-Acre Harbor",
                    values: ["diameter": 200],
                    labels: ["Hexagonal inner harbor", "350 ships simultaneously"],
                    steps: 3, caption: "The harbor that fed a million people was itself an engineering marvel"
                ),
                isLeadCard: true
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_1",
                buildingId: bid, buildingName: name,
                science: .physics,
                environment: .cityMap, stationKey: "building",
                title: "Step 1: Tides & Currents",
                italianTitle: "Fisica delle Onde",
                icon: "water.waves",
                lessonText: "The Mediterranean is not always calm. In a storm, waves rise three meters. Sometimes four. And a wave is not just water — it is force. The math is brutal. A three-meter wave hits a wall with thirty tons of force, every meter. Imagine. So our breakwaters cannot simply stand and resist. They must absorb. They must let the energy pass through them, redirect it sideways. Curved walls, not straight ones. The strongest wall in the harbor — it is not the thickest. It is the one that refuses to fight.",
                keywords: [
                    KeywordPair(keyword: "30 tons/meter", definition: "Impact force of a 3-meter wave"),
                    KeywordPair(keyword: "Energy absorption", definition: "Breakwater strategy — absorb, don't resist"),
                    KeywordPair(keyword: "Curved walls", definition: "Redirect wave force sideways instead of blocking"),
                    KeywordPair(keyword: "3-4 meters", definition: "Typical Mediterranean storm wave height"),
                ],
                activity: .numberFishing(question: "Force (tons per meter) of a 3-meter wave hitting a wall?", correctAnswer: 30, decoys: [5, 10, 50, 75, 100]),
                notebookSummary: "Mediterranean storms: 3-4m waves. A 3m wave hits with 30 tons/meter impact force. Breakwaters absorb, do not resist. Curved walls redirect energy sideways. The strongest wall is the one that refuses to fight.",
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
                lessonText: "How do you build in water? You make the water leave. Listen. The Romans built what we call a cofferdam. Two rings of wooden piles, driven deep into the seabed. The gap between the rings — packed tight with clay. Then the workers brought the Archimedean screw — a spiral pump invented by Archimedes himself. Turn the handle. Water rises up the spiral. Out of the enclosure. Soon — dry ground, in the middle of the sea. Pour the concrete. Wait. Set. Remove the dam. Building underwater is just building on land — if you can make the water leave first.",
                keywords: [
                    KeywordPair(keyword: "Cofferdam", definition: "Watertight enclosure for building underwater"),
                    KeywordPair(keyword: "Double ring", definition: "Two rows of wooden piles with clay between"),
                    KeywordPair(keyword: "Archimedean screw", definition: "Spiral pump removing water from the enclosure"),
                    KeywordPair(keyword: "Dry workspace", definition: "Pumped-out area for pouring concrete"),
                ],
                activity: .wordScramble(word: "COFFERDAM", hint: "Watertight enclosure for building in water"),
                notebookSummary: "Cofferdam: double ring of wooden piles driven into the seabed, gap packed with clay. Archimedean screws (spiral pumps) remove the trapped water → dry workspace underwater. Pour concrete, set, remove the dam. Make the water leave first.",
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
                lessonText: "You remember Vitruvius? Our great architect, who wrote the books that taught us everything? He returns here. For the breakwater, he wrote a rule. No block lighter than ten or fifteen tons. Why so heavy? Because a wave does not only push. It LIFTS. As the water surges over a block, low pressure forms above. Suction. A five-ton block — pulled off the seabed by a single wave. A fifteen-ton block — it stays. The rule: the block must weigh three times the uplift force. Overbuilding by three? Sounds wasteful. Until the first storm. Then — you bless Vitruvius.",
                keywords: [
                    KeywordPair(keyword: "Wave uplift", definition: "Suction that pulls blocks upward from the seabed"),
                    KeywordPair(keyword: "3× rule", definition: "Block weight must be 3× the uplift force"),
                    KeywordPair(keyword: "10-15 tons", definition: "Vitruvius's minimum breakwater block weight"),
                    KeywordPair(keyword: "Low pressure", definition: "Water flowing over creates suction above"),
                ],
                activity: .multipleChoice(question: "Block weight must exceed how many times the wave uplift force?", options: ["1.5×", "2×", "3×", "5×"], correctIndex: 2),
                notebookSummary: "Vitruvius's rule (callback to Aqueduct): breakwater blocks must weigh 10-15 tons minimum. Wave uplift creates suction above the block — a 5-ton block gets ripped off; a 15-ton block stays. The 3× rule: block weight ≥ 3× the uplift force. Overbuilding sounds wasteful until the first storm.",
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
                lessonText: "And how does a ship find Portus at night? Look. There — fifty meters tall. The lighthouse. Built in the design of the great Pharos of Alexandria — one of the seven wonders of the ancient world. At the very top, a bonfire burns. Behind the fire — polished bronze mirrors. The mirrors are curved. The curve concentrates the light into a beam. Visible fifty kilometers out to sea. The keepers feed the fire every two hours through the night. One man's job — to keep the light alive. So that three hundred and fifty ships can find their way home. The simplest technology — fire and reflection — solving the hardest problem of all. Finding your way in the dark.",
                keywords: [
                    KeywordPair(keyword: "Pharos", definition: "Lighthouse design from Alexandria — model for Portus"),
                    KeywordPair(keyword: "Bronze mirrors", definition: "Polished curved reflectors concentrating firelight"),
                    KeywordPair(keyword: "50 km", definition: "Visible range of the lighthouse beam"),
                    KeywordPair(keyword: "50 meters", definition: "Height of the Portus lighthouse"),
                ],
                activity: .hangman(word: "PHAROS", hint: "Ancient lighthouse design from Alexandria"),
                notebookSummary: "Portus lighthouse: 50m tall, modeled on the Pharos of Alexandria (one of the 7 wonders). Bonfire at the top + curved polished bronze mirrors concentrate the light into a beam visible 50 km at sea. Keepers fed the fire every 2 hours through the night. Guided 350 ships daily.",
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
                lessonText: "The harbor quays need stone — but not just any stone. The stone must hold up the weight of loaded wagons. And it must survive the salt. So — what do we choose? Marble is dense, beautiful, strong. But in the harbor — marble cracks. The salt crystals grow inside the stone. They split it from within. So we use the opposite. Tufa. Soft volcanic rock. So porous, you can press your fingernail into it. And here is the magic — when salt crystals form inside tufa, they have room. They fill the pores. They do not split anything. The softest stone wins at the harbor. The opposite of what your eyes would choose.",
                keywords: [
                    KeywordPair(keyword: "Tufa", definition: "Soft volcanic rock ideal for harbor quays"),
                    KeywordPair(keyword: "Porous", definition: "Salt fills pores instead of cracking the stone"),
                    KeywordPair(keyword: "Salt resistance", definition: "Soft stone absorbs salt, hard stone cracks"),
                ],
                activity: .trueFalse(statement: "Porous tufa resists saltwater better than dense marble because salt fills its pores", isTrue: true),
                notebookSummary: "Harbor quays: tufa (soft volcanic rock). Porous structure lets salt crystals fill the pores instead of cracking the stone. Dense stones like marble shatter in saltwater because the salt crystals grow inside and split the stone. The softest stone wins at the harbor.",
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
                lessonText: "Now — listen to this. The Romans mixed their marine concrete with SEAWATER. On purpose. Why? Because the salt triggers something miraculous. A crystal forms inside the concrete. We did not know its name then. Modern scientists call it Al-tobermorite. The crystal grows for centuries. The concrete becomes STRONGER as the years pass. Your modern Portland cement? Dissolves in salt. Fails in decades. Roman marine concrete? Thrives in salt. The ocean that destroys everything else — makes this concrete immortal.",
                keywords: [
                    KeywordPair(keyword: "Al-tobermorite", definition: "Crystal that grows in Roman marine concrete"),
                    KeywordPair(keyword: "Seawater", definition: "Mixed intentionally — triggers strengthening crystal"),
                    KeywordPair(keyword: "Portland cement", definition: "Modern concrete that dissolves in salt"),
                ],
                activity: .wordScramble(word: "TOBERMORITE", hint: "Crystal that grows inside Roman marine concrete — gets stronger in seawater"),
                notebookSummary: "Marine concrete = volcanic ash + lime + SEAWATER (on purpose) + volcanic rock aggregate. Salt triggers Al-tobermorite crystal growth — the concrete gets STRONGER over centuries in seawater. Modern Portland cement dissolves in salt. The ocean that destroys everything else makes this concrete immortal.",
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
                lessonText: "A wooden ship has one terrible enemy. You cannot see it. The teredo. A marine worm that bores into wood, hollowing the hull from the inside. In a single year — a ship can be destroyed. So the Romans wrapped the hull in metal. Below the waterline — thin lead sheets, nailed flat with copper tacks. Lead is soft, moldable, impervious to salt and worms. The lead doubles the ship's lifespan. But — every ship in the Roman fleet now wears armor. Protection weighs something. It always does.",
                keywords: [
                    KeywordPair(keyword: "Teredo", definition: "Marine worm that bores through wooden hulls"),
                    KeywordPair(keyword: "Lead sheeting", definition: "Thin lead nailed below the waterline"),
                    KeywordPair(keyword: "Copper tacks", definition: "Hold lead flush against the hull"),
                    KeywordPair(keyword: "Double lifespan", definition: "Lead sheeting's benefit to wooden hulls"),
                ],
                activity: .hangman(word: "TEREDO", hint: "Marine worm that destroys wooden ship hulls"),
                notebookSummary: "Teredo (marine worm) destroys wooden hulls within a year. Lead sheets nailed below the waterline with copper tacks — impervious to salt + worms. Doubles hull lifespan, but every ship wears armor weight. Protection weighs something — it always does.",
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
                lessonText: "Portus has two hundred warehouses. We call them horrea. Grain, oil, wine, marble — every cargo that arrives, stored here. Each warehouse needs a wide roof. Wide enough for an ox cart to pass beneath. Twelve to fifteen meters. So we use oak trusses. Two sloping rafters, a horizontal tie beam below, and vertical posts we call queen posts. You remember the rule? Beam depth equals span divided by twenty. A fifteen-meter span — seventy-five centimeters deep. But why oak, not poplar? Because the salt air rots cheap wood. Oak has tannins — natural chemicals that repel moisture. The harbor's skeleton is oak. The trees that grew slow now hold the cargo of an empire.",
                keywords: [
                    KeywordPair(keyword: "Horrea", definition: "Roman warehouse — 200 at Portus"),
                    KeywordPair(keyword: "Queen posts", definition: "Vertical members in the truss supporting rafters"),
                    KeywordPair(keyword: "12-15 meters", definition: "Warehouse truss span for ox cart access"),
                    KeywordPair(keyword: "Tannins", definition: "Oak's natural moisture-repelling chemicals"),
                ],
                activity: .wordScramble(word: "HORREA", hint: "Roman warehouses — 200 of them stored grain at Portus"),
                notebookSummary: "Horrea: 200 warehouses at Portus (grain, oil, wine, marble). Oak queen-post trusses span 12-15m for ox-cart loading. Insula 1/20 rule: 15m span → 75cm deep beams. Oak's natural tannins repel salt air moisture — the harbor's skeleton is oak.",
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
                lessonText: "For the cofferdam piles — we use poplar. Driven into the seabed, three or four meters deep. Why poplar? Three reasons. First — it grows straight. Second — it is light to carry. And third — here is the magic — when poplar wood gets wet, it SWELLS. It expands. The piles press tighter against the clay. The dam becomes more watertight as it sits in the sea. Poplar grows fast. There is always more for replacements. And when the concrete sets, the workers pull the piles back up. Reused on the next project. Temporary by design. Permanent in effect.",
                keywords: [
                    KeywordPair(keyword: "Poplar piles", definition: "Driven 3-4m into the seabed for cofferdams"),
                    KeywordPair(keyword: "Swells wet", definition: "Poplar expands in water — tighter seal"),
                    KeywordPair(keyword: "Puddle clay", definition: "Packed between double ring for waterproofing"),
                    KeywordPair(keyword: "Reusable", definition: "Piles pulled and reused after concrete sets"),
                ],
                activity: .trueFalse(statement: "Poplar wood swells when wet, making it ideal for watertight cofferdam piles", isTrue: true),
                notebookSummary: "Cofferdam piles: poplar (straight + light + swells when wet, sealing tighter against the clay). Driven 3-4m into the seabed in a double ring with puddle clay between. Poplar's fast growth = always replacements. Piles pulled and reused. Temporary by design, permanent in effect.",
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
                lessonText: "You have learned many recipes by now. Aqueduct mortar — one to two to a half. Road mortar — one to three. Insula — one to four, no pozzolana. Baths — one to four with extra silica. This is the FIFTH recipe. Marine mortar. One part lime. Three parts volcanic ash. And seawater. Not fresh water — SEAWATER. Mix in wooden forms, then lower the form into the sea itself. The concrete sets underwater in seven days. After that — it grows stronger for centuries. The same salt that destroys ordinary cement — for our marine concrete, it is the ingredient that gives life.",
                keywords: [
                    KeywordPair(keyword: "Seawater", definition: "Used instead of fresh water — triggers crystal growth"),
                    KeywordPair(keyword: "7 days", definition: "Underwater setting time for marine concrete"),
                    KeywordPair(keyword: "Wooden forms", definition: "Lowered into the sea to contain wet concrete"),
                ],
                activity: .fillInBlanks(text: "Marine concrete: ___ part lime, ___ parts volcanic ash, mixed with ___ (not fresh water!)", blanks: ["1", "3", "seawater"], distractors: ["2", "4", "rainwater"]),
                notebookSummary: "Marine mortar (5th recipe learned): 1 lime + 3 volcanic ash + SEAWATER (not fresh). Mix in wooden forms lowered into the sea. Sets underwater in 7 days, then strengthens for centuries via Al-tobermorite crystals. The salt that destroys ordinary cement is what gives this concrete life.",
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
                lessonText: "You remember the lead pipes? The fistulae we made for the aqueduct? The same metal returns here. But now — not for water. For ships. Lead melts at three hundred twenty-seven degrees. Lower than any other useful metal. So low, that a wood fire is enough. No bellows. No special furnace. Pour the molten lead into flat sand molds. Ten minutes — it cools. You have a sheet, ready to nail onto a ship's hull. The Roman foundries at Portus cast two hundred sheets a day. Every day. The easiest metal to melt — turned out to be the most useful at the harbor. From pipes that carry water, to armor that holds back worms. Same metal. Two empires of use.",
                keywords: [
                    KeywordPair(keyword: "327°C", definition: "Lead's melting point — very low for a metal"),
                    KeywordPair(keyword: "Sand molds", definition: "Flat forms for casting lead sheets"),
                    KeywordPair(keyword: "200 sheets/day", definition: "Output of a Portus lead foundry"),
                    KeywordPair(keyword: "No bellows", definition: "Low temperature — wood fire is enough"),
                ],
                activity: .numberFishing(question: "At what temperature (°C) does lead melt?", correctAnswer: 327, decoys: [100, 200, 450, 600, 900]),
                notebookSummary: "Lead melts at 327°C (lowest of any useful metal) — wood fire is enough, no bellows. Sand molds, 10 min cooling. 200 sheets/day at Portus foundries. Same metal as the aqueduct fistulae — pipes that carry water, sheets that armor ships against teredo worms. Two empires of use.",
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
