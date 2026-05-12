import SwiftUI

// MARK: - Knowledge Card Content — Renaissance Buildings (9 buildings, ~109 cards)
// Writing style: Morgan Housel — story-driven, surprising, punchy (~60-80 words per card).
// Each building's cards teach unique facts at each station — NO duplicate material teaching across buildings.
// Level: Apprentice

extension KnowledgeCardContent {

    // MARK: - Duomo (14 cards)

    static var duomoCards: [KnowledgeCard] {
        let bid = 9
        let name = "Duomo"
        return [
            // ── CITY MAP (5 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_cityMap_building_0",
                buildingId: bid, buildingName: name,
                science: .architecture,
                environment: .cityMap, stationKey: "building",
                title: "Brunelleschi's Genius",
                italianTitle: "Il Genio di Brunelleschi",
                icon: "building.columns.fill",
                lessonText: "In 1418, Florence had a problem: an octagonal hole 42 meters wide at the top of its unfinished cathedral. No centering (temporary wooden frame) large enough existed. Filippo Brunelleschi proposed building the dome without centering — an idea so bold the committee almost rejected it. He won by demonstrating an egg standing on its end. Genius isn't inventing something new. It's seeing what everyone else missed.",
                keywords: [
                    KeywordPair(keyword: "Brunelleschi", definition: "Architect who built the dome without centering"),
                    KeywordPair(keyword: "42 meters", definition: "Width of the octagonal drum opening"),
                    KeywordPair(keyword: "1418", definition: "Year of the dome design competition"),
                    KeywordPair(keyword: "No centering", definition: "Built without temporary wooden support frame"),
                ],
                activity: .numberFishing(question: "How wide (meters) is the Duomo's dome opening?", correctAnswer: 42, decoys: [28, 35, 50, 60, 72]),
                notebookSummary: "Brunelleschi won 1418 competition. 42m dome built WITHOUT centering. No one had done it since the Pantheon. Genius = seeing what's missed.",
                visual: CardVisual(type: .crossSection, title: "Brunelleschi's Genius", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_1",
                buildingId: bid, buildingName: name,
                science: .geometry,
                environment: .cityMap, stationKey: "building",
                title: "Step 1: Octagonal Drum",
                italianTitle: "Tamburo Ottagonale",
                icon: "octagon.fill",
                lessonText: "Why octagonal? A circle distributes weight evenly but is hard to build in stone. A square concentrates stress at corners. An octagon splits the difference — 8 corners share the load, and flat walls are easier to construct than curves. Each of the 8 sides acts as a flat arch pushing inward. The octagon isn't a compromise between circle and square. It's better than both.",
                keywords: [
                    KeywordPair(keyword: "Octagonal", definition: "8-sided shape distributing weight at 8 points"),
                    KeywordPair(keyword: "Flat arch", definition: "Each side pushes inward like an arch"),
                    KeywordPair(keyword: "Stress distribution", definition: "8 corners share load vs 4 (square) or ∞ (circle)"),
                ],
                activity: .multipleChoice(question: "Why is an octagonal dome better than a circular one for stone construction?", options: ["More decorative", "Flat walls are easier to build than curves", "Uses less material", "Taller profile"], correctIndex: 1),
                notebookSummary: "Octagon: 8 sides share load (vs 4 for square). Flat walls easier than curves. Each side = flat arch pushing inward. Better than circle or square.",
                visual: CardVisual(type: .crossSection, title: "Step 1: Octagonal Drum", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_2",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .cityMap, stationKey: "building",
                title: "Step 2: Double Shell",
                italianTitle: "Innovazione della Doppia Calotta",
                icon: "circle.circle",
                lessonText: "Brunelleschi's key insight: two domes, not one. An inner shell 2.1 meters thick carries the structural load. An outer shell 0.6 meters thick sheds rain and looks magnificent. Between them: a hidden staircase of 463 steps. The gap reduces weight by 25% compared to a solid dome. Two thin shells are stronger than one thick one — nature uses this trick in eggs and skulls.",
                keywords: [
                    KeywordPair(keyword: "Double shell", definition: "Inner (structural) + outer (protective) dome"),
                    KeywordPair(keyword: "2.1 meters", definition: "Inner shell thickness — carries the load"),
                    KeywordPair(keyword: "0.6 meters", definition: "Outer shell thickness — sheds rain"),
                    KeywordPair(keyword: "25% lighter", definition: "Weight savings vs a single solid dome"),
                ],
                activity: .trueFalse(statement: "Brunelleschi's double-shell dome is 25% lighter than a single solid dome would be", isTrue: true),
                notebookSummary: "Double shell: inner 2.1m (structure) + outer 0.6m (weather). 463-step staircase between. 25% lighter than solid. Eggs use the same trick.",
                visual: CardVisual(type: .crossSection, title: "Step 2: Double Shell", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_3",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .cityMap, stationKey: "building",
                title: "Step 4: Herringbone Brick",
                italianTitle: "Muratura a Spina di Pesce",
                icon: "rectangle.split.3x3.fill",
                lessonText: "Without centering, how do you keep wet mortar from sliding off a curved surface? Brunelleschi's answer: herringbone pattern. Vertical bricks are inserted every few rows at alternating angles, creating interlocking wedges that grip the course below. Each ring of bricks becomes self-supporting as it's laid. The pattern looks decorative but is purely structural — the bricks hold EACH OTHER up while the mortar dries.",
                keywords: [
                    KeywordPair(keyword: "Herringbone", definition: "Zigzag brick pattern — self-supporting as laid"),
                    KeywordPair(keyword: "Vertical bricks", definition: "Inserted at angles to create interlocking wedges"),
                    KeywordPair(keyword: "Self-supporting", definition: "Each ring holds itself without centering"),
                    KeywordPair(keyword: "Structural pattern", definition: "Looks decorative but serves engineering purpose"),
                ],
                activity: .wordScramble(word: "HERRINGBONE", hint: "Zigzag brick pattern that makes the dome self-supporting"),
                notebookSummary: "Herringbone: vertical bricks at alternating angles create wedges. Each ring is self-supporting as laid. No centering needed.",
                visual: CardVisual(type: .crossSection, title: "Step 4: Herringbone Brick", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_4",
                buildingId: bid, buildingName: name,
                science: .physics,
                environment: .cityMap, stationKey: "building",
                title: "Step 7: The Lantern",
                italianTitle: "La Lanterna da 800 Tonnellate",
                icon: "light.beacon.max.fill",
                lessonText: "Atop the dome sits the lantern — a marble tower weighing 800 tons. Counterintuitive: adding weight to a dome's crown strengthens it. The lantern's weight pushes down on the dome's compression ring, locking the bricks tighter together. Without it, the dome would slowly splay outward. Brunelleschi died before it was finished. Verrocchio added the bronze ball. The heaviest piece makes everything lighter.",
                keywords: [
                    KeywordPair(keyword: "Lantern", definition: "800-ton marble tower atop the dome"),
                    KeywordPair(keyword: "Compression ring", definition: "Lantern weight locks dome bricks together"),
                    KeywordPair(keyword: "Splay", definition: "Dome spreading outward without crown weight"),
                    KeywordPair(keyword: "Verrocchio", definition: "Added the bronze ball after Brunelleschi's death"),
                ],
                activity: .numberFishing(question: "How much does the Duomo's lantern weigh (tons)?", correctAnswer: 800, decoys: [200, 400, 1200, 1800, 2500]),
                notebookSummary: "Lantern: 800 tons of marble. Weight compresses the dome ring — prevents splaying. Heaviest piece makes everything stronger.",
                visual: CardVisual(type: .crossSection, title: "Step 7: The Lantern", values: [:], labels: [], steps: 3, caption: "")
            ),

            // ── WORKSHOP (4 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_workshop_quarry_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "quarry",
                title: "Step 8: Carrara Marble",
                italianTitle: "Marmo Policromo di Carrara",
                icon: "mountain.2.fill",
                lessonText: "The Duomo's facade uses three marble colors: white from Carrara, green from Prato, and pink from Maremma. Carrara marble is 99% pure calcium carbonate — the whitest in the world. Michelangelo himself later chose Carrara for the Pietà. The quarries sit 1,000 meters up in the Apuan Alps. Workers slid blocks down on wooden sledges greased with soap. The purest white comes from the highest mountains.",
                keywords: [
                    KeywordPair(keyword: "Carrara", definition: "Source of the world's whitest marble — 99% pure"),
                    KeywordPair(keyword: "Three colors", definition: "White (Carrara), green (Prato), pink (Maremma)"),
                    KeywordPair(keyword: "1,000 meters", definition: "Altitude of the Carrara quarries"),
                    KeywordPair(keyword: "Soap sledges", definition: "Greased wooden slides for moving blocks downhill"),
                ],
                activity: .hangman(word: "CARRARA", hint: "Italian quarry producing the world's whitest marble"),
                notebookSummary: "Duomo facade: 3 marbles — white (Carrara, 99% pure), green (Prato), pink (Maremma). Quarries at 1,000m altitude.",
                visual: CardVisual(type: .crossSection, title: "Step 8: Carrara Marble", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_clayPit_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "clayPit",
                title: "Step 4 Material: Bricks",
                italianTitle: "Quattro Milioni di Mattoni",
                icon: "rectangle.split.3x1.fill",
                lessonText: "Brunelleschi's dome consumed 4 million bricks — each one a specific size for its position. The bricks were fired at Impruneta, 15 km south, using iron-rich Tuscan clay. That iron gives Florentine brick its famous warm red color. Every brick was stamped with the maker's mark. Quality control: if a batch failed the ring test, the entire kiln load was rejected. Four million chances to get it wrong.",
                keywords: [
                    KeywordPair(keyword: "4 million", definition: "Number of bricks in the Duomo's dome"),
                    KeywordPair(keyword: "Impruneta", definition: "Town 15 km south — source of dome bricks"),
                    KeywordPair(keyword: "Iron-rich clay", definition: "Gives Florentine brick its warm red color"),
                    KeywordPair(keyword: "Maker's mark", definition: "Stamp for quality control — reject bad batches"),
                ],
                activity: .numberFishing(question: "How many bricks are in the Duomo's dome?", correctAnswer: 4000000, decoys: [500000, 1000000, 2000000, 6000000, 10000000]),
                notebookSummary: "4 million bricks from Impruneta. Iron-rich clay = red color. Each stamped with maker's mark. Failed batches rejected entirely.",
                visual: CardVisual(type: .crossSection, title: "Step 4 Material: Bricks", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_mine_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "mine",
                title: "Step 5: Iron Chains",
                italianTitle: "Catene di Ferro",
                icon: "link",
                lessonText: "Hidden inside the dome walls: iron catena — horizontal chains encircling the dome like belts. As the dome pushes outward (hoop stress), the chains pull inward, containing the force. Brunelleschi installed chains at 3 levels. Total iron: 70 tons. The chains are invisible from inside or outside — pure engineering, zero decoration. The dome's belt holds it together the way a barrel's hoops hold staves.",
                keywords: [
                    KeywordPair(keyword: "Catena", definition: "Iron chains hidden inside dome walls"),
                    KeywordPair(keyword: "Hoop stress", definition: "Outward force the dome exerts on itself"),
                    KeywordPair(keyword: "3 levels", definition: "Number of chain rings in the dome"),
                    KeywordPair(keyword: "70 tons", definition: "Total weight of iron chains"),
                ],
                activity: .wordScramble(word: "CATENA", hint: "Hidden iron chains encircling the dome to contain hoop stress"),
                notebookSummary: "Catena: 70 tons of iron chains at 3 levels inside the dome. Contain hoop stress (outward push). Invisible. Pure engineering.",
                visual: CardVisual(type: .crossSection, title: "Step 5: Iron Chains", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_market_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .workshop, stationKey: "market",
                title: "Step 8: Stained Glass",
                italianTitle: "Cobalto per Vetrate",
                icon: "paintbrush.fill",
                lessonText: "The Duomo's oculus window blazes with blue stained glass — colored by cobalt oxide. Cobalt was imported from Saxony (Germany) via Venetian traders. Just 2% cobalt oxide in molten glass produces deep blue. The secret: cobalt ions absorb red and green light, transmitting only blue. Glass artists mixed different metal oxides for different colors: copper=green, gold=ruby, manganese=purple. The window is a chemistry experiment frozen in light.",
                keywords: [
                    KeywordPair(keyword: "Cobalt oxide", definition: "2% in glass produces deep blue color"),
                    KeywordPair(keyword: "Saxony", definition: "German source of cobalt — traded via Venice"),
                    KeywordPair(keyword: "Absorption", definition: "Cobalt absorbs red/green, transmits blue"),
                    KeywordPair(keyword: "Metal oxides", definition: "Each metal creates a different glass color"),
                ],
                activity: .multipleChoice(question: "Which metal oxide creates blue stained glass?", options: ["Copper", "Gold", "Cobalt", "Manganese"], correctIndex: 2),
                notebookSummary: "Blue stained glass: 2% cobalt oxide absorbs red/green, transmits blue. Cobalt from Saxony. Each metal oxide = different color.",
                visual: CardVisual(type: .crossSection, title: "Step 8: Stained Glass", values: [:], labels: [], steps: 3, caption: "")
            ),

            // ── CRAFTING ROOM (5 cards) ────────────────────────

            KnowledgeCard(
                id: "\(bid)_craftingRoom_workbench_0",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .craftingRoom, stationKey: "workbench",
                title: "Step 4: Herringbone Mortar",
                italianTitle: "Malta a Spina di Pesce",
                icon: "flask.fill",
                lessonText: "Herringbone mortar needed to set fast — workers couldn't wait for slow-curing lime on a curved surface. Brunelleschi's recipe: quicklime mixed with gypsum (plaster of Paris). Gypsum makes mortar set in 15 minutes instead of 3 days. But gypsum weakens with moisture, so the fast-set mortar was only used for the vertical herringbone bricks. Horizontal courses used standard lime. Two mortars, two jobs, one dome.",
                keywords: [
                    KeywordPair(keyword: "Gypsum", definition: "Additive for fast-setting mortar (15 minutes)"),
                    KeywordPair(keyword: "15 minutes", definition: "Setting time with gypsum vs 3 days without"),
                    KeywordPair(keyword: "Vertical bricks", definition: "Used fast-set gypsum mortar"),
                    KeywordPair(keyword: "Horizontal bricks", definition: "Used standard slow-set lime mortar"),
                ],
                activity: .numberFishing(question: "How many minutes for gypsum mortar to set?", correctAnswer: 15, decoys: [2, 5, 30, 60, 120]),
                notebookSummary: "Herringbone mortar: quicklime + gypsum = 15 min set (vs 3 days). Gypsum for vertical bricks only. Standard lime for horizontal.",
                visual: CardVisual(type: .crossSection, title: "Step 4: Herringbone Mortar", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_craftingRoom_furnace_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .craftingRoom, stationKey: "furnace",
                title: "Step 4: Brick Firing",
                italianTitle: "Colore dei Mattoni all'Ossido di Ferro",
                icon: "flame.circle.fill",
                lessonText: "The Duomo's bricks are a distinctive warm red — not by accident but by chemistry. Tuscan clay from Impruneta is rich in iron oxide (Fe₂O₃). At 900°C in an oxygen-rich kiln, iron oxide stays red. At 1,000°C with restricted oxygen, it turns dark brown. Temperature and atmosphere control the color. Roman bricks were yellow because their clay had less iron. Color is chemistry writing its signature.",
                keywords: [
                    KeywordPair(keyword: "Fe₂O₃", definition: "Iron oxide — gives Florentine brick its red color"),
                    KeywordPair(keyword: "900°C", definition: "Oxygen-rich kiln = red bricks"),
                    KeywordPair(keyword: "1,000°C", definition: "Restricted oxygen = dark brown bricks"),
                    KeywordPair(keyword: "Kiln atmosphere", definition: "Oxygen level determines final brick color"),
                ],
                activity: .fillInBlanks(text: "Iron oxide (___) at ___°C with oxygen = red. At ___°C without oxygen = brown", blanks: ["Fe₂O₃", "900", "1000"], distractors: ["CaCO₃", "600", "1200"]),
                notebookSummary: "Red brick: Fe₂O₃ + 900°C + oxygen. Restrict oxygen at 1,000°C → dark brown. Color = chemistry + kiln control.",
                visual: CardVisual(type: .crossSection, title: "Step 4: Brick Firing", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_craftingRoom_pigmentTable_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .craftingRoom, stationKey: "pigmentTable",
                title: "Step 4: Sinopia Drawing",
                italianTitle: "Ocra Rossa e Sinopia",
                icon: "paintpalette.fill",
                lessonText: "Before painting the dome's interior fresco, artists drew the design in sinopia — red ochre pigment dissolved in water. Red ochre is iron oxide clay (Fe₂O₃) mined from Sinop on Turkey's Black Sea coast. Ground on a marble slab with a muller, mixed with lime water to bond to wet plaster. The sinopia was the Renaissance architect's first draft — drawn directly on the wall before colors were applied.",
                keywords: [
                    KeywordPair(keyword: "Sinopia", definition: "Red ochre preliminary drawing on wet plaster"),
                    KeywordPair(keyword: "Red ochre", definition: "Fe₂O₃ clay pigment from Sinop, Turkey"),
                    KeywordPair(keyword: "Muller", definition: "Stone tool for grinding pigment on marble slab"),
                    KeywordPair(keyword: "Lime water", definition: "Binder that locks pigment into wet plaster"),
                ],
                activity: .wordScramble(word: "SINOPIA", hint: "Red ochre preliminary drawing on plaster — named after the city of Sinop"),
                notebookSummary: "Sinopia: red ochre (Fe₂O₃ from Sinop, Turkey) drawn on wet plaster as first draft. Ground with muller, mixed with lime water.",
                visual: CardVisual(type: .crossSection, title: "Step 4: Sinopia Drawing", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_craftingRoom_shelf_0",
                buildingId: bid, buildingName: name,
                science: .mathematics,
                environment: .craftingRoom, stationKey: "shelf",
                title: "Step 6: Quinto Acuto",
                italianTitle: "Geometria del Quinto Acuto",
                icon: "triangle",
                lessonText: "Brunelleschi's dome follows the quinto acuto ('pointed fifth') curve — an arc whose center is located 4/5 of the way up from the base. This creates a steeper profile than a hemisphere. Steeper means less outward thrust, which means the dome can support itself during construction without centering. The math: radius of curvature = 4/5 × diameter. Geometry made the impossible possible.",
                keywords: [
                    KeywordPair(keyword: "Quinto acuto", definition: "Pointed fifth — dome curve with center at 4/5 height"),
                    KeywordPair(keyword: "Steeper profile", definition: "Less outward thrust than a hemisphere"),
                    KeywordPair(keyword: "4/5 ratio", definition: "Center point of the dome's curvature"),
                    KeywordPair(keyword: "Self-supporting", definition: "Steep curve enables construction without centering"),
                ],
                activity: .hangman(word: "QUINTO", hint: "The 'pointed fifth' curve that makes Brunelleschi's dome self-supporting"),
                notebookSummary: "Quinto acuto: dome curve centered at 4/5 height. Steeper than hemisphere → less outward thrust → no centering needed.",
                visual: CardVisual(type: .crossSection, title: "Step 6: Quinto Acuto", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_craftingRoom_workbench_1",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .craftingRoom, stationKey: "workbench",
                title: "Step 8: Lead Cames",
                italianTitle: "Piombi per Vetrate",
                icon: "rectangle.grid.1x2.fill",
                lessonText: "Stained glass panels are assembled with cames — H-shaped strips of lead that grip glass pieces on both sides. Each came is cast in a long mold, then bent by hand to follow the design. The glass is cut with a hot iron tip, fitted into the came channels, and sealed with linseed oil putty. A rose window contains 500+ lead cames. The art is in the cutting. The structure is in the lead.",
                keywords: [
                    KeywordPair(keyword: "Came", definition: "H-shaped lead strip holding stained glass pieces"),
                    KeywordPair(keyword: "Linseed putty", definition: "Oil-based sealant in came channels"),
                    KeywordPair(keyword: "Hot iron", definition: "Tool for cutting glass to shape"),
                    KeywordPair(keyword: "500+ cames", definition: "Lead strips in a single rose window"),
                ],
                activity: .trueFalse(statement: "Stained glass is held together by H-shaped lead strips called cames", isTrue: true),
                notebookSummary: "Cames: H-shaped lead strips gripping glass on both sides. 500+ per window. Sealed with linseed putty. Structure = lead.",
                visual: CardVisual(type: .crossSection, title: "Step 8: Lead Cames", values: [:], labels: [], steps: 3, caption: "")
            ),
        ]
    }

    // MARK: - Botanical Garden (10 cards)

    static var botanicalGardenCards: [KnowledgeCard] {
        let bid = 10
        let name = "Botanical Garden"
        return [
            // ── CITY MAP (4 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_cityMap_building_0",
                buildingId: bid, buildingName: name,
                science: .biology,
                environment: .cityMap, stationKey: "building",
                title: "Padua 1545",
                italianTitle: "Padova 1545",
                icon: "leaf.fill",
                lessonText: "And so — we begin again. Centuries have passed since we last spoke. Rome fell. The Middle Ages came. Cathedrals rose where temples had stood. And then — slowly, slowly — Italy stirred. In Florence, a man named Cosimo de Medici opened the first new academies. The rebirth had begun. La rinascita. The Renaissance. Now we are in Padua. The year is fifteen hundred forty-five. The Venetian Republic has just funded something the world has never seen before — an academic botanical garden. For medical students. Doctors before this prescribed herbs they had never seen. Half of all medicine, in those years, was botany. The garden that changed medicine — it was not built in a hospital. It was built in a university. And five hundred years later — it is still there.",
                keywords: [
                    KeywordPair(keyword: "Padua 1545", definition: "World's first academic botanical garden"),
                    KeywordPair(keyword: "Venetian Republic", definition: "Funded the garden for medical education"),
                    KeywordPair(keyword: "Medicinal plants", definition: "Primary purpose — training doctors in botany"),
                    KeywordPair(keyword: "Still existing", definition: "Oldest botanical garden in its original location"),
                ],
                activity: .numberFishing(question: "What year did the first academic botanical garden open in Padua?", correctAnswer: 1545, decoys: [1400, 1480, 1520, 1610, 1700]),
                notebookSummary: "Padua 1545: world's first academic botanical garden, funded by the Venetian Republic. Medical students studied medicinal plants firsthand (before this, doctors prescribed herbs they had never seen). Half of Renaissance medicine was botany. Still there 500 years later. The Renaissance — la rinascita — has begun, decades after Cosimo de Medici opened Florence's first new academies.",
                visual: CardVisual(type: .crossSection, title: "Padua 1545", values: [:], labels: [], steps: 3, caption: ""),
                isLeadCard: true
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_1",
                buildingId: bid, buildingName: name,
                science: .geometry,
                environment: .cityMap, stationKey: "building",
                title: "Step 1: Circular Layout",
                italianTitle: "Quadranti Circolari",
                icon: "circle.grid.cross.fill",
                lessonText: "Now — look at the garden from above. Perfect circle. Eighty-four meters across. Inside, two paths cross at the center — aligned to the four directions. North. South. East. West. Each quadrant — divided into sixteen smaller beds. The shape was not chosen for beauty. The circle — it symbolized the world. The four quadrants — they represented the four elements. Earth. Water. Air. Fire. The whole world, organized in a single garden. And around the outside — a wall. To keep thieves away from the rare plants. The geometry — it is not decoration. It is a classification system you can walk through.",
                keywords: [
                    KeywordPair(keyword: "84 meters", definition: "Diameter of the circular garden"),
                    KeywordPair(keyword: "4 quadrants", definition: "Compass-aligned divisions — N, S, E, W"),
                    KeywordPair(keyword: "16 beds", definition: "Subdivisions within each quadrant"),
                    KeywordPair(keyword: "Four elements", definition: "Earth, water, air, fire — symbolic layout"),
                ],
                activity: .numberFishing(question: "What is the diameter (meters) of Padua's circular garden?", correctAnswer: 84, decoys: [40, 60, 100, 120, 150]),
                notebookSummary: "Circular garden: 84m diameter, 4 quadrants (compass-aligned N/S/E/W) of 16 beds each. Circle = the world; 4 quadrants = the 4 elements (earth, water, air, fire). Surrounding wall keeps thieves out. Classification as architecture — geometry you can walk through.",
                visual: CardVisual(type: .crossSection, title: "Step 1: Circular Layout", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_2",
                buildingId: bid, buildingName: name,
                science: .biology,
                environment: .cityMap, stationKey: "building",
                title: "Step 5: Taxonomy",
                italianTitle: "Nascita della Tassonomia",
                icon: "list.bullet.indent",
                lessonText: "Now — meet a man. Luca Ghini. The first director of the garden. Six thousand plant species had to be organized. How? By shared traits. Leaf shape. Flower structure. Seed type. This is the science we now call taxonomy. Classifying living things by what you can observe. And Luca Ghini — he invented something extraordinary. He took plants. He pressed them flat. He glued them to paper. He labeled each one. Name. Origin. Date. We call this a herbarium. A pressed leaf — it is a data point. Six thousand pressed plants — biology's first database. A library you could hold in your hands.",
                keywords: [
                    KeywordPair(keyword: "Taxonomy", definition: "Classifying living things by shared traits"),
                    KeywordPair(keyword: "Luca Ghini", definition: "Invented the herbarium — pressed plant records"),
                    KeywordPair(keyword: "6,000 species", definition: "Number of plants cataloged at Padua"),
                    KeywordPair(keyword: "Herbarium", definition: "Collection of pressed, labeled plant specimens"),
                ],
                activity: .wordScramble(word: "TAXONOMY", hint: "The science of classifying living things by shared features"),
                notebookSummary: "Luca Ghini (Padua's first director) invented the herbarium — pressed dried plants onto labeled paper. Used to organize 6,000 species by shared traits: leaf shape, flower structure, seed type. The beginning of taxonomy — classifying living things by what you can observe. Biology's first database.",
                visual: CardVisual(type: .crossSection, title: "Step 5: Taxonomy", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_3",
                buildingId: bid, buildingName: name,
                science: .biology,
                environment: .cityMap, stationKey: "building",
                title: "Step 7: Records",
                italianTitle: "Registri Botanici",
                icon: "book.fill",
                lessonText: "Every plant that entered Padua was recorded. Origin. Date planted. Soil. Growth rate. Medicinal use. The garden's catalogs had a beautiful name — Horti Academici Patavini. Across Europe, these books became the great reference works of botany. But here is the most remarkable thing. Padua exchanged seeds with sixty other gardens across Europe. Through a catalog — the Index Seminum. Letters traveled by horse. Seeds traveled in pouches. Information moving at the speed of a galloping mare. The world's first open-source scientific network. Ran on paper. And on trust. Knowledge wants to be shared. Always.",
                keywords: [
                    KeywordPair(keyword: "Index Seminum", definition: "Seed exchange catalog shared across Europe"),
                    KeywordPair(keyword: "60 gardens", definition: "European partners in the seed exchange network"),
                    KeywordPair(keyword: "Horti Academici", definition: "Padua's published garden catalogs"),
                    KeywordPair(keyword: "Open source", definition: "Free sharing of botanical knowledge"),
                ],
                activity: .hangman(word: "SEMINUM", hint: "Latin for 'of seeds' — the Index ___ was Europe's seed exchange catalog"),
                notebookSummary: "Padua recorded everything about every plant: origin, date planted, soil, growth, medicinal uses. Horti Academici Patavini catalogs became Europe's botanical reference. Index Seminum: seed exchange catalog shared with 60+ gardens across Europe. The first open-source scientific network — running on paper, horseback, and trust.",
                visual: CardVisual(type: .crossSection, title: "Step 7: Records", values: [:], labels: [], steps: 3, caption: "")
            ),

            // ── WORKSHOP (3 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_workshop_quarry_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "quarry",
                title: "Step 4: Boundary Wall",
                italianTitle: "Pietra per il Muro di Cinta",
                icon: "mountain.2.fill",
                lessonText: "The circular wall around the garden — it served two purposes. First, the obvious one. Keep thieves away from the precious plants. Second — and this you must understand — it stored heat. The stone is trachyte. Volcanic, from the Euganean Hills nearby. During the day, the sun strikes the wall. The wall absorbs the heat. At night, when the air grows cold, the wall slowly releases that warmth. Plants growing close to the wall survive winters two degrees warmer than the open garden. Two degrees — that is the difference between life and death for a delicate plant. The wall was the garden's first greenhouse. A thermal battery — made of stone.",
                keywords: [
                    KeywordPair(keyword: "Trachyte", definition: "Volcanic stone from the Euganean Hills"),
                    KeywordPair(keyword: "Thermal mass", definition: "Stone absorbs heat by day, releases at night"),
                    KeywordPair(keyword: "2°C warmer", definition: "Temperature benefit near the stone wall"),
                    KeywordPair(keyword: "Thermal battery", definition: "Wall stores and releases heat energy"),
                ],
                activity: .trueFalse(statement: "The garden's trachyte wall acted as a thermal battery, keeping nearby plants 2°C warmer", isTrue: true),
                notebookSummary: "Garden wall = Euganean Hills trachyte (volcanic stone). Absorbs the sun's heat by day, radiates it at night. Plants near the wall survive winters 2°C warmer than open ground — the difference between life and death for delicate species. Wall = first greenhouse, a thermal battery made of stone.",
                visual: CardVisual(type: .crossSection, title: "Step 4: Boundary Wall", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_river_0",
                buildingId: bid, buildingName: name,
                science: .hydraulics,
                environment: .workshop, stationKey: "river",
                title: "Step 3: Irrigation",
                italianTitle: "Canali di Irrigazione",
                icon: "drop.triangle.fill",
                lessonText: "You remember the castellum at the baths? The water tank with three outlets, by height? The garden uses the same idea — but more refined. Water comes from the Bacchiglione River. Through underground terracotta pipes. To a central cistern. From the cistern — to all four quadrants. And then, the genius. Each individual bed has a small adjustable gate — a sluice. The curator opens some gates wider. Closes others. Mediterranean herbs get less water. Tropical plants get more. Each bed — receiving exactly the rain of its homeland. Six thousand plants. From five continents. Each one drinking what it would drink at home. Justice — in irrigation.",
                keywords: [
                    KeywordPair(keyword: "Bacchiglione", definition: "River supplying the garden via underground pipes"),
                    KeywordPair(keyword: "Sluice gates", definition: "Adjustable water controls for each bed"),
                    KeywordPair(keyword: "Central cistern", definition: "Distribution tank splitting water to 4 quadrants"),
                    KeywordPair(keyword: "5 continents", definition: "Source range of Padua's 6,000 plant species"),
                ],
                activity: .wordScramble(word: "SLUICE", hint: "Adjustable gate controlling water flow to each garden bed"),
                notebookSummary: "Gravity irrigation: Bacchiglione River → underground terracotta pipes → central cistern → 4 quadrants → adjustable sluice gates per individual bed (callback to bath castellum 3-outlet rationing). 6,000 plants from 5 continents, each watered as in its homeland. Justice in irrigation.",
                visual: CardVisual(type: .crossSection, title: "Step 3: Irrigation", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_quarry_1",
                buildingId: bid, buildingName: name,
                science: .geology,
                environment: .workshop, stationKey: "quarry",
                title: "Step 8: Observation Path",
                italianTitle: "Geologia dei Sentieri",
                icon: "globe.europe.africa.fill",
                lessonText: "Now — look at the paths between the beds. Limestone gravel. Local stone. Crushed small. Walked upon every day. But the choice of stone is not for the walker — it is for the plants. Rain falls. The rainwater slowly dissolves the limestone. Calcium is released. The calcium washes into the soil. We call this natural liming. It keeps the soil slightly alkaline — perfect for Mediterranean herbs. The garden's whole purpose. The paths are not just for walking. They are fertilizing the beds they cross. Infrastructure that feeds. Beautiful — no?",
                keywords: [
                    KeywordPair(keyword: "Limestone gravel", definition: "Paths that dissolve and lime the soil"),
                    KeywordPair(keyword: "pH alkaline", definition: "Condition preferred by Mediterranean herbs"),
                    KeywordPair(keyword: "Euganean Hills", definition: "Local source of limestone gravel"),
                    KeywordPair(keyword: "Calcium release", definition: "Gravel dissolving → natural soil fertilizer"),
                ],
                activity: .multipleChoice(question: "Why were garden paths made from limestone gravel?", options: ["Cheapest option", "Dissolves to fertilize soil with calcium", "Easiest to walk on", "Matched the marble walls"], correctIndex: 1),
                notebookSummary: "Garden paths = local limestone gravel. Rain dissolves the limestone → calcium washes into soil (natural liming) → alkaline pH, perfect for Mediterranean herbs. The paths are not just for walking — they fertilize the beds they cross. Infrastructure that feeds.",
                visual: CardVisual(type: .crossSection, title: "Step 8: Observation Path", values: [:], labels: [], steps: 3, caption: "")
            ),

            // ── CRAFTING ROOM (3 cards) ────────────────────────

            KnowledgeCard(
                id: "\(bid)_craftingRoom_workbench_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .craftingRoom, stationKey: "workbench",
                title: "Step 6: Cold House Glass",
                italianTitle: "Vetro per Serra",
                icon: "flask.fill",
                lessonText: "You remember the bath glass? Made from river sand at eleven hundred degrees? The Renaissance went further. Padua's later greenhouses use Murano glass — the clearest in all of Europe. Why does this matter? Greenhouse glass has a special job. It must let in the ultraviolet light — what plants need for photosynthesis. But it must trap the infrared. The heat. Venetian glass achieved eighty percent light transmission. Your modern glass — ninety percent. The frames are lead cames. The same lead frames that hold stained glass in cathedrals. The craft of stained glass became the science of controlled sunlight. Same tools. Different purpose. And soon — we will travel to Venice, to meet the masters of this glass.",
                keywords: [
                    KeywordPair(keyword: "80% transmission", definition: "Murano glass light transparency"),
                    KeywordPair(keyword: "UV light", definition: "Passes through glass — needed for photosynthesis"),
                    KeywordPair(keyword: "Infrared trapping", definition: "Glass lets light in but traps heat"),
                    KeywordPair(keyword: "Greenhouse effect", definition: "Light enters, heat stays — glass trap"),
                ],
                activity: .trueFalse(statement: "Greenhouse glass works by transmitting UV light for photosynthesis while trapping infrared heat", isTrue: true),
                notebookSummary: "Padua greenhouses used Murano glass — clearest in Europe, 80% light transmission. Greenhouse glass passes UV (for photosynthesis) but traps infrared (heat). Lead came frames = same as stained glass windows. Callback to bath glass; the craft of stained glass became the science of controlled sunlight. Glassworks comes next.",
                visual: CardVisual(type: .crossSection, title: "Step 6: Cold House Glass", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_craftingRoom_furnace_0",
                buildingId: bid, buildingName: name,
                science: .physics,
                environment: .craftingRoom, stationKey: "furnace",
                title: "Step 6: Cold House Heat",
                italianTitle: "Scienza della Ritenzione Termica",
                icon: "flame.circle.fill",
                lessonText: "You remember the Roman hypocaust? The hot air, flowing under the floor of the bath? Fifteen hundred years later, the Renaissance gardeners revived it. For their greenhouses. Terracotta pipes — the same idea — carry warm air from a wood furnace beneath the greenhouse floor. The brick floor stores the heat by day. Releases it slowly at night. Brick absorbs four times more heat than wood. The target — keep the inside above ten degrees, when outside the air drops below freezing. Five degrees. The difference between life and death for a tropical seedling. The same trick the Romans used to warm bathers — now warming plants. Knowledge does not die. It waits.",
                keywords: [
                    KeywordPair(keyword: "Thermal mass", definition: "Brick absorbs 4× more heat than wood"),
                    KeywordPair(keyword: "Underfloor heating", definition: "Warm air pipes beneath the greenhouse"),
                    KeywordPair(keyword: "10°C minimum", definition: "Target interior temperature in winter"),
                    KeywordPair(keyword: "Night release", definition: "Stored heat radiates when temperature drops"),
                ],
                activity: .numberFishing(question: "How many times more heat does brick absorb compared to wood?", correctAnswer: 4, decoys: [2, 3, 6, 8, 10]),
                notebookSummary: "Renaissance greenhouses revived the Roman hypocaust (bath callback). Terracotta pipes carry warm air from a wood furnace beneath the floor. Brick absorbs 4× more heat than wood — stores by day, releases at night. Target: 10°C interior (5°C above freezing — life vs death for a tropical seedling). Knowledge does not die. It waits.",
                visual: CardVisual(type: .crossSection, title: "Step 6: Cold House Heat", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_craftingRoom_shelf_0",
                buildingId: bid, buildingName: name,
                science: .biology,
                environment: .craftingRoom, stationKey: "shelf",
                title: "Step 2: Soil Beds",
                italianTitle: "Scienza del Suolo",
                icon: "leaf.arrow.circlepath",
                lessonText: "Each plant — needs a different soil. Padua's gardeners mixed custom soil for each. Sand and compost for Mediterranean herbs. Clay and peat for bog plants. Pure gravel for alpine species. And then — a discovery. They began adding charcoal to the soil. Pieces of carbon, leftover from the kilns. The result? Better drainage. Less root rot. Healthier plants. Your scientists today have a name for this — biochar. The gardeners of Padua were practicing it five hundred years before the word existed. The first soil scientists were not in laboratories. They were in the gardens. With dirt on their hands. Paying attention.",
                keywords: [
                    KeywordPair(keyword: "Substrate", definition: "Custom soil mix for specific plant needs"),
                    KeywordPair(keyword: "Biochar", definition: "Charcoal in soil — improves drainage"),
                    KeywordPair(keyword: "Root rot", definition: "Disease from waterlogged soil — charcoal prevents it"),
                    KeywordPair(keyword: "Custom mixes", definition: "Sand/compost, clay/peat, pure gravel by plant type"),
                ],
                activity: .wordScramble(word: "BIOCHAR", hint: "Charcoal added to soil for drainage — discovered by Renaissance gardeners"),
                notebookSummary: "Custom soil substrates per plant: sand+compost (Mediterranean herbs), clay+peat (bog), pure gravel (alpine). Adding charcoal improved drainage + prevented root rot — biochar, 500 years before the word existed. The first soil scientists were gardeners with dirt on their hands, paying attention.",
                visual: CardVisual(type: .crossSection, title: "Step 2: Soil Beds", values: [:], labels: [], steps: 3, caption: "")
            ),
        ]
    }

    // MARK: - Glassworks (12 cards)

    static var glassworksCards: [KnowledgeCard] {
        let bid = 11
        let name = "Glassworks"
        return [
            // ── CITY MAP (5 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_cityMap_building_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .cityMap, stationKey: "building",
                title: "Murano's Secrets",
                italianTitle: "I Segreti di Murano",
                icon: "drop.halffull",
                lessonText: "In 1291, Venice moved all glassmakers to Murano island. The official reason: fire safety. The real reason: secrecy. Murano glass recipes were state secrets — masters who fled faced assassination. The isolation worked: for 300 years, Murano produced the finest glass in the world. Cristallo (clear glass) was their crown jewel. The world's best glass came from the world's most controlled island.",
                keywords: [
                    KeywordPair(keyword: "Murano", definition: "Island where Venice confined all glassmakers"),
                    KeywordPair(keyword: "1291", definition: "Year glassmakers were moved to Murano"),
                    KeywordPair(keyword: "Cristallo", definition: "Murano's famous clear glass invention"),
                    KeywordPair(keyword: "State secrets", definition: "Recipes protected by threat of death"),
                ],
                activity: .numberFishing(question: "In what year were Venetian glassmakers moved to Murano?", correctAnswer: 1291, decoys: [1100, 1200, 1350, 1450, 1550]),
                notebookSummary: "1291: Venice moved glassmakers to Murano. Recipes = state secrets. Masters who fled faced death. 300 years of world's finest glass.",
                visual: CardVisual(type: .crossSection, title: "Murano's Secrets", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_1",
                buildingId: bid, buildingName: name,
                science: .physics,
                environment: .cityMap, stationKey: "building",
                title: "Step 1: The Furnace",
                italianTitle: "Fornace a 1100°C",
                icon: "thermometer.sun.fill",
                lessonText: "Murano furnaces burned continuously for months — shutting down cracked the clay crucible from thermal shock. Masters judged temperature by color: dull red (600°C), cherry red (800°C), orange (1,000°C), yellow-white (1,100°C). No thermometers existed. A master's eye was the instrument. The furnace consumed 6 tons of wood daily. One furnace, one master, one color judgment separating success from waste.",
                keywords: [
                    KeywordPair(keyword: "1,100°C", definition: "Working temperature for Murano glass"),
                    KeywordPair(keyword: "Color judgment", definition: "Masters read temperature by glow color"),
                    KeywordPair(keyword: "6 tons/day", definition: "Daily wood consumption per furnace"),
                    KeywordPair(keyword: "Thermal shock", definition: "Cracking from temperature change — never shut down"),
                ],
                activity: .multipleChoice(question: "How did Murano masters measure furnace temperature?", options: ["Mercury thermometer", "By the color of the glow", "Water boiling rate", "Clay test pieces"], correctIndex: 1),
                notebookSummary: "Furnace: 1,100°C, never shut down (thermal shock). Temperature by color: red→orange→yellow-white. 6 tons wood/day. Eye = instrument.",
                visual: CardVisual(type: .crossSection, title: "Step 1: The Furnace", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_2",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .cityMap, stationKey: "building",
                title: "Step 2: Three Chambers",
                italianTitle: "Fornace a Tre Camere",
                icon: "rectangle.split.3x1.fill",
                lessonText: "Murano's furnace had three chambers stacked vertically. Bottom: the firebox (combustion). Middle: the crucible chamber (1,100°C for melting). Top: the annealing lehr (slowly cooling finished pieces). Heat rises naturally from bottom to top — no energy wasted. The glassblower works at the middle, pulls finished pieces up to the lehr. Three temperatures from one fire. Efficiency is vertical.",
                keywords: [
                    KeywordPair(keyword: "Firebox", definition: "Bottom chamber — combustion zone"),
                    KeywordPair(keyword: "Crucible chamber", definition: "Middle — melting at 1,100°C"),
                    KeywordPair(keyword: "Annealing lehr", definition: "Top chamber — slow cooling zone"),
                    KeywordPair(keyword: "Natural convection", definition: "Heat rises — 3 zones from 1 fire"),
                ],
                activity: .fillInBlanks(text: "Three chambers: ___ (bottom, fire), ___ (middle, melting), ___ (top, cooling)", blanks: ["firebox", "crucible", "lehr"], distractors: ["kiln", "furnace", "oven"]),
                notebookSummary: "3 vertical chambers: firebox (bottom) → crucible (middle, 1,100°C) → lehr (top, cooling). Heat rises naturally. One fire, three jobs.",
                visual: CardVisual(type: .crossSection, title: "Step 2: Three Chambers", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_3",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .cityMap, stationKey: "building",
                title: "Step 8: Cristallo",
                italianTitle: "Manganese Decolorante",
                icon: "eyedropper.halffull",
                lessonText: "Raw glass is green — iron impurities absorb red light. Murano masters added manganese dioxide (MnO₂) to counteract iron's green. Manganese absorbs the complementary color (green-yellow), producing neutral transparency. They called it 'glassmaker's soap' — it cleans the color. Too much manganese turns glass purple. The art of clear glass is the art of balanced impurities. Cristallo isn't pure. It's perfectly impure.",
                keywords: [
                    KeywordPair(keyword: "MnO₂", definition: "Manganese dioxide — 'glassmaker's soap'"),
                    KeywordPair(keyword: "Iron impurity", definition: "Causes green color in raw glass"),
                    KeywordPair(keyword: "Complementary color", definition: "Manganese absorbs green to produce clear"),
                    KeywordPair(keyword: "Cristallo", definition: "Clear glass — balanced, not pure"),
                ],
                activity: .wordScramble(word: "MANGANESE", hint: "The 'glassmaker's soap' that removes green tint from glass"),
                notebookSummary: "Green glass = iron impurities. MnO₂ (manganese) absorbs green → clear. 'Glassmaker's soap.' Too much → purple. Cristallo = balanced impurities.",
                visual: CardVisual(type: .crossSection, title: "Step 8: Cristallo", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_4",
                buildingId: bid, buildingName: name,
                science: .physics,
                environment: .cityMap, stationKey: "building",
                title: "Step 7: Annealing",
                italianTitle: "Ricottura — Rilascio delle Tensioni",
                icon: "waveform.path.ecg",
                lessonText: "Cool glass too fast and it shatters days later. Why? Uneven cooling creates internal stress — the outside contracts while the inside is still hot. The solution: annealing. Place the finished piece in the lehr at 500°C and cool it 1°C per minute over 24 hours. Slow cooling lets molecules rearrange evenly. A vase annealed properly lasts centuries. A rushed one shatters on its own. Patience is structural.",
                keywords: [
                    KeywordPair(keyword: "Annealing", definition: "Slow cooling to relieve internal stress"),
                    KeywordPair(keyword: "500°C", definition: "Starting temperature in the annealing lehr"),
                    KeywordPair(keyword: "1°C/minute", definition: "Cooling rate for proper annealing"),
                    KeywordPair(keyword: "Internal stress", definition: "Tension from uneven cooling — causes shattering"),
                ],
                activity: .numberFishing(question: "What cooling rate (°C per minute) is used for annealing glass?", correctAnswer: 1, decoys: [5, 10, 20, 50, 100]),
                notebookSummary: "Annealing: start at 500°C, cool 1°C/min for 24 hours. Slow cooling relieves internal stress. Rushed = shatters. Patience = structure.",
                visual: CardVisual(type: .crossSection, title: "Step 7: Annealing", values: [:], labels: [], steps: 3, caption: "")
            ),

            // ── WORKSHOP (3 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_workshop_quarry_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .workshop, stationKey: "quarry",
                title: "Step 3: Limestone Flux",
                italianTitle: "Calcare come Fondente",
                icon: "mountain.2.fill",
                lessonText: "Pure silica sand melts at 1,700°C — far too hot for any furnace. Add 10% limestone (CaCO₃) and the melting point drops to 1,100°C. Limestone is a flux — it disrupts the silica crystal structure, letting molecules flow at lower temperatures. But too much flux makes glass water-soluble. The Murano recipe: 60% silica, 15% soda, 10% lime, 15% cullet. Every percentage matters.",
                keywords: [
                    KeywordPair(keyword: "Flux", definition: "Additive that lowers silica's melting point"),
                    KeywordPair(keyword: "1,700°C", definition: "Melting point of pure silica — too hot"),
                    KeywordPair(keyword: "10% limestone", definition: "Drops melting point to workable 1,100°C"),
                    KeywordPair(keyword: "Water-soluble", definition: "Too much flux dissolves the glass"),
                ],
                activity: .numberFishing(question: "Pure silica melts at what temperature (°C)?", correctAnswer: 1700, decoys: [800, 1100, 1400, 2000, 2500]),
                notebookSummary: "Limestone (CaCO₃) is a flux: drops silica's melting point from 1,700°C to 1,100°C. Too much = water-soluble glass. 10% is the sweet spot.",
                visual: CardVisual(type: .crossSection, title: "Step 3: Limestone Flux", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_clayPit_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "clayPit",
                title: "Step 4: Crucibles",
                italianTitle: "Crogioli di Argilla Refrattaria",
                icon: "cup.and.saucer.fill",
                lessonText: "The crucible holds molten glass at 1,100°C for days — ordinary clay would melt. Murano used refractory clay from the Vicenza hills, rich in alumina (Al₂O₃). Alumina raises clay's melting point above 1,500°C. Each crucible lasted 6 months before replacement. Making one took 3 weeks: hand-coiled, dried slowly to prevent cracks, then pre-fired to 1,300°C. The container was harder to make than the glass inside it.",
                keywords: [
                    KeywordPair(keyword: "Refractory", definition: "Clay that withstands extreme heat (>1,500°C)"),
                    KeywordPair(keyword: "Alumina", definition: "Al₂O₃ — raises clay's melting point"),
                    KeywordPair(keyword: "6 months", definition: "Lifespan of one crucible"),
                    KeywordPair(keyword: "3 weeks", definition: "Time to make a single crucible"),
                ],
                activity: .hangman(word: "CRUCIBLE", hint: "Clay container holding molten glass at 1,100°C for months"),
                notebookSummary: "Refractory crucible: alumina-rich clay from Vicenza. Melting point >1,500°C. 3 weeks to make, 6 months lifespan. Harder to make than glass.",
                visual: CardVisual(type: .crossSection, title: "Step 4: Crucibles", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_mine_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "mine",
                title: "Step 6: Blowpipes",
                italianTitle: "Canne da Soffio in Bronzo",
                icon: "wind",
                lessonText: "The glassblower's pipe is a 1.5-meter bronze tube. Why bronze? It conducts heat slowly (keeping the handle cool), resists corrosion from glass chemicals, and is rigid enough not to droop with a 2 kg glass gather on the end. Iron rusts. Copper is too soft. Bronze is the Goldilocks metal. The pipe rotates constantly — gravity would pull the glass blob off-center without it. The tool spins. The art doesn't stop.",
                keywords: [
                    KeywordPair(keyword: "1.5 meters", definition: "Length of a glassblower's pipe"),
                    KeywordPair(keyword: "Bronze", definition: "Slow heat conductor — keeps handle cool"),
                    KeywordPair(keyword: "Constant rotation", definition: "Prevents gravity from distorting the glass"),
                    KeywordPair(keyword: "2 kg gather", definition: "Weight of molten glass on the pipe tip"),
                ],
                activity: .trueFalse(statement: "Glassblowing pipes are bronze because it conducts heat slowly, keeping the handle cool", isTrue: true),
                notebookSummary: "Blowpipe: 1.5m bronze tube. Bronze = slow heat, no rust, rigid. Constant rotation prevents gravity distortion. Tool spins continuously.",
                visual: CardVisual(type: .crossSection, title: "Step 6: Blowpipes", values: [:], labels: [], steps: 3, caption: "")
            ),

            // ── FOREST (2 cards) ───────────────────────────────

            KnowledgeCard(
                id: "\(bid)_forest_oak_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .forest, stationKey: "oak",
                title: "Step 1 Support: Fuel",
                italianTitle: "Combustibile per Fornace 24 Ore",
                icon: "leaf.fill",
                lessonText: "Murano furnaces consumed entire forests. Each furnace burned 6 tons of oak daily — 2,000 tons per year. Venice eventually stripped the Dalmatian coast bare. Oak was preferred because it burns hot and long — a single log sustains flame for 45 minutes. Softwoods like pine burn fast and leave creosote deposits. The glass industry's appetite for wood reshaped the Adriatic landscape for centuries.",
                keywords: [
                    KeywordPair(keyword: "6 tons/day", definition: "Oak consumption per furnace"),
                    KeywordPair(keyword: "2,000 tons/year", definition: "Annual wood consumption per furnace"),
                    KeywordPair(keyword: "45 minutes", definition: "Burn time of a single oak log"),
                    KeywordPair(keyword: "Dalmatian coast", definition: "Deforested to feed Murano's furnaces"),
                ],
                activity: .numberFishing(question: "How many tons of wood did one Murano furnace burn per day?", correctAnswer: 6, decoys: [1, 3, 10, 15, 20]),
                notebookSummary: "6 tons oak/day per furnace. 2,000 tons/year. Oak log burns 45 min. Dalmatian coast deforested. Glass reshaped landscapes.",
                visual: CardVisual(type: .crossSection, title: "Step 1 Support: Fuel", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_forest_chestnut_0",
                buildingId: bid, buildingName: name,
                science: .physics,
                environment: .forest, stationKey: "chestnut",
                title: "Step 5: Ventilation",
                italianTitle: "Convezione della Ventilazione",
                icon: "wind",
                lessonText: "Murano workshops were built open-sided to manage heat. The furnace at center created a convection cell: hot air rose through a chimney, pulling cool sea air in from the sides. Workers stood in this cross-draft zone. Without it, ambient temperature near the furnace reached 50°C — lethal for 12-hour shifts. Chestnut beams framed the open walls — light and rot-resistant in the salt air. Architecture saved lives.",
                keywords: [
                    KeywordPair(keyword: "Convection cell", definition: "Hot air rises, pulls cool air in from sides"),
                    KeywordPair(keyword: "Cross-draft", definition: "Cool zone where workers stood safely"),
                    KeywordPair(keyword: "50°C", definition: "Lethal ambient temperature without ventilation"),
                    KeywordPair(keyword: "Chestnut frames", definition: "Light and salt-resistant for open walls"),
                ],
                activity: .multipleChoice(question: "What created the cooling cross-draft in Murano workshops?", options: ["Hand fans", "Natural convection from the furnace", "Water sprinklers", "Underground tunnels"], correctIndex: 1),
                notebookSummary: "Convection: furnace heat rises → pulls cool sea air in sides. Workers in cross-draft zone. Without it: 50°C lethal. Chestnut frames the openings.",
                visual: CardVisual(type: .crossSection, title: "Step 5: Ventilation", values: [:], labels: [], steps: 3, caption: "")
            ),

            // ── CRAFTING ROOM (2 cards) ────────────────────────

            KnowledgeCard(
                id: "\(bid)_craftingRoom_workbench_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .craftingRoom, stationKey: "workbench",
                title: "Step 3: Glass Batch",
                italianTitle: "Miscela del Vetro",
                icon: "flask.fill",
                lessonText: "The glass batch is mixed dry before furnace loading. Recipe: 60 parts silica sand (washed 3 times), 15 parts soda ash (natron from Egypt or barilla from Spain), 10 parts lime (from crushed seashells — purer than limestone), 15 parts cullet (crushed recycled glass). Mix for 30 minutes in a wooden trough. Cullet ensures uniform melting — new ingredients alone are unpredictable. The recycled part makes the new part work.",
                keywords: [
                    KeywordPair(keyword: "Batch", definition: "Dry-mixed glass ingredients before melting"),
                    KeywordPair(keyword: "Barilla", definition: "Spanish soda ash alternative to Egyptian natron"),
                    KeywordPair(keyword: "Seashell lime", definition: "Purer calcium source than quarried limestone"),
                    KeywordPair(keyword: "30 minutes", definition: "Mixing time for a uniform batch"),
                ],
                activity: .fillInBlanks(text: "Glass batch: ___% silica, ___% soda, ___% lime, 15% cullet", blanks: ["60", "15", "10"], distractors: ["40", "20", "25"]),
                notebookSummary: "Glass batch: 60 silica + 15 soda + 10 lime (seashells) + 15 cullet. Mix dry 30 min. Cullet ensures uniform melting.",
                visual: CardVisual(type: .crossSection, title: "Step 3: Glass Batch", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_craftingRoom_furnace_0",
                buildingId: bid, buildingName: name,
                science: .physics,
                environment: .craftingRoom, stationKey: "furnace",
                title: "Step 4: Crucible Prep",
                italianTitle: "Shock Termico del Crogiolo",
                icon: "flame.circle.fill",
                lessonText: "A new crucible can't go straight into the furnace — the 1,100°C shock would shatter it. Pre-heating takes 3 days: first warmed near the furnace (200°C), then moved closer (500°C), then inside (800°C), finally to working position (1,100°C). Each stage lasts 18 hours. The molecules need time to expand uniformly. Rush it and the outer surface expands faster than the core — crack. Ceramics demand respect for time.",
                keywords: [
                    KeywordPair(keyword: "Thermal shock", definition: "Rapid temperature change that shatters ceramics"),
                    KeywordPair(keyword: "3 days", definition: "Pre-heating time for a new crucible"),
                    KeywordPair(keyword: "4 stages", definition: "200°C → 500°C → 800°C → 1,100°C"),
                    KeywordPair(keyword: "18 hours", definition: "Duration at each temperature stage"),
                ],
                activity: .numberFishing(question: "How many days to pre-heat a new crucible safely?", correctAnswer: 3, decoys: [1, 2, 5, 7, 10]),
                notebookSummary: "New crucible: 3-day pre-heat in 4 stages (200→500→800→1,100°C), 18 hours each. Thermal shock shatters if rushed.",
                visual: CardVisual(type: .crossSection, title: "Step 4: Crucible Prep", values: [:], labels: [], steps: 3, caption: "")
            ),
        ]
    }

    // MARK: - Arsenal (13 cards)

    static var arsenalCards: [KnowledgeCard] {
        let bid = 12
        let name = "Arsenal"
        return [
            // ── CITY MAP (5 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_cityMap_building_0",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .cityMap, stationKey: "building",
                title: "16,000 Workers",
                italianTitle: "16.000 Operai",
                icon: "person.3.fill",
                lessonText: "The Venetian Arsenal employed 16,000 arsenalotti — more workers than most Renaissance cities had residents. They built the ships that made Venice a superpower. At peak production in the 1500s, they launched a new galley every single day. Workers ate lunch at their stations. Each was a specialist: hull builders, mast fitters, rope makers, caulkers. The Arsenal was a city inside a city, organized to build.",
                keywords: [
                    KeywordPair(keyword: "16,000", definition: "Workers (arsenalotti) in the Venice Arsenal"),
                    KeywordPair(keyword: "One ship/day", definition: "Peak production rate in the 1500s"),
                    KeywordPair(keyword: "Arsenalotti", definition: "Arsenal workers — specialists in one craft"),
                    KeywordPair(keyword: "Superpower", definition: "The fleet made Venice master of the Mediterranean"),
                ],
                activity: .numberFishing(question: "How many workers did the Venetian Arsenal employ?", correctAnswer: 16000, decoys: [2000, 5000, 8000, 25000, 50000]),
                notebookSummary: "Arsenal: 16,000 arsenalotti. One galley per day at peak. Each worker a specialist. A city inside a city.",
                visual: CardVisual(type: .crossSection, title: "16,000 Workers", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_1",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .cityMap, stationKey: "building",
                title: "Step 2: Rope Walk",
                italianTitle: "Corderia di 316 Metri",
                icon: "line.diagonal",
                lessonText: "The Tana — the Arsenal's rope walk — stretched 316 meters, one of the longest buildings in Europe. Rope makers walked backward the entire length, twisting hemp fibers into cable. A single anchor cable contained 800 individual fibers twisted into strands, strands into rope, rope into cable. The twist pattern matters: S-twist strands laid in Z-twist rope won't unravel. The geometry of spirals keeps ships anchored.",
                keywords: [
                    KeywordPair(keyword: "Tana", definition: "316-meter rope walk — one of Europe's longest"),
                    KeywordPair(keyword: "800 fibers", definition: "Individual hemp strands in one anchor cable"),
                    KeywordPair(keyword: "S-twist / Z-twist", definition: "Opposing twist directions prevent unraveling"),
                    KeywordPair(keyword: "Walking backward", definition: "How rope makers twisted fibers along the walk"),
                ],
                activity: .numberFishing(question: "How long (meters) was the Arsenal's rope walk?", correctAnswer: 316, decoys: [100, 200, 400, 500, 800]),
                notebookSummary: "Tana: 316m rope walk. 800 fibers → strands → rope → cable. S-twist + Z-twist prevents unraveling. Spiral geometry.",
                visual: CardVisual(type: .crossSection, title: "Step 2: Rope Walk", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_2",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .cityMap, stationKey: "building",
                title: "Step 4: Assembly Line",
                italianTitle: "Catena di Montaggio",
                icon: "arrow.right.arrow.left",
                lessonText: "300 years before Henry Ford, Venice invented the assembly line. A galley hull was floated through a canal past a series of stations: masts at Station 1, rigging at Station 2, oars at Station 3, weapons at Station 4, provisions at Station 5. Each station added one system. A complete warship — 40 meters long — assembled in one day. Ford just put the idea on wheels. Venice put it on water.",
                keywords: [
                    KeywordPair(keyword: "Assembly line", definition: "Ship floated past stations — each adds one system"),
                    KeywordPair(keyword: "5 stations", definition: "Masts, rigging, oars, weapons, provisions"),
                    KeywordPair(keyword: "One day", definition: "Time to assemble a complete 40m warship"),
                    KeywordPair(keyword: "300 years before Ford", definition: "Venice invented the assembly line concept"),
                ],
                activity: .trueFalse(statement: "The Venetian Arsenal used an assembly line concept 300 years before Henry Ford", isTrue: true),
                notebookSummary: "Assembly line: hull floated past 5 stations (masts → rigging → oars → weapons → provisions). One warship per day. 300 years before Ford.",
                visual: CardVisual(type: .crossSection, title: "Step 4: Assembly Line", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_3",
                buildingId: bid, buildingName: name,
                science: .physics,
                environment: .cityMap, stationKey: "building",
                title: "Step 8: Sea Trial",
                italianTitle: "Principio di Archimede",
                icon: "water.waves",
                lessonText: "Every ship hull must displace enough water to support its total weight — Archimedes' principle. A galley weighing 150 tons must displace 150 tons of seawater. Arsenal designers carved half-hull models from wood and tested them in water tanks. If the model floated at the correct waterline, the hull shape was approved. Scale models at 1:10 ratio. The physics is the same at any size — that's what makes scaling possible.",
                keywords: [
                    KeywordPair(keyword: "Archimedes' principle", definition: "Buoyancy = weight of displaced water"),
                    KeywordPair(keyword: "150 tons", definition: "Typical galley weight — must displace equal water"),
                    KeywordPair(keyword: "Half-hull model", definition: "Carved wood test at 1:10 scale"),
                    KeywordPair(keyword: "Waterline", definition: "Model must float here before full-scale build"),
                ],
                activity: .hangman(word: "BUOYANCY", hint: "Archimedes' principle — a ship floats by displacing its weight in water"),
                notebookSummary: "Archimedes: ship displaces its weight in water. 150-ton galley = 150 tons displaced. Tested at 1:10 scale in water tanks.",
                visual: CardVisual(type: .crossSection, title: "Step 8: Sea Trial", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_4",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .cityMap, stationKey: "building",
                title: "Step 1: Wet Docks",
                italianTitle: "Bacini Umidi",
                icon: "square.dashed",
                lessonText: "The Arsenal pioneered wet docks — enclosed basins where ships float during construction. Unlike dry docks (drained for building on blocks), wet docks let workers access the hull from boats at any height. Venice's lagoon provided natural level control. Gates sealed the basin; pumps adjusted water height. Building on water eliminated the dangerous task of launching a heavy hull down a slipway. Safer, faster, smarter.",
                keywords: [
                    KeywordPair(keyword: "Wet dock", definition: "Enclosed basin — ship floats during construction"),
                    KeywordPair(keyword: "Dry dock", definition: "Drained basin — ship built on blocks"),
                    KeywordPair(keyword: "Gate system", definition: "Seals the basin for water level control"),
                    KeywordPair(keyword: "No launch", definition: "Ship already floating — no slipway needed"),
                ],
                activity: .multipleChoice(question: "What is the advantage of a wet dock over a dry dock?", options: ["Ship already floats — no dangerous launch needed", "Cheaper to build", "Uses less wood", "Better for painting"], correctIndex: 0),
                notebookSummary: "Wet docks: ships float during construction. No slipway launch. Gates control water level. Safer than dry docks.",
                visual: CardVisual(type: .crossSection, title: "Step 1: Wet Docks", values: [:], labels: [], steps: 3, caption: "")
            ),

            // ── WORKSHOP (4 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_workshop_quarry_0",
                buildingId: bid, buildingName: name,
                science: .geology,
                environment: .workshop, stationKey: "quarry",
                title: "Step 1: Dock Stone",
                italianTitle: "Pietra d'Istria Resistente al Sale",
                icon: "mountain.2.fill",
                lessonText: "Venice is built on Istrian stone — dense white limestone from the Croatian coast. It resists saltwater because its grain is tight: salt crystals can't penetrate deep enough to expand and crack it. The Arsenal's dry dock walls, loading quays, and bridge foundations all used Istrian stone. It polishes to a marble-like finish but is 3× harder. The stone that looks like marble but thinks like granite.",
                keywords: [
                    KeywordPair(keyword: "Istrian stone", definition: "Dense white limestone from Croatia"),
                    KeywordPair(keyword: "Salt resistant", definition: "Tight grain prevents salt penetration"),
                    KeywordPair(keyword: "3× harder", definition: "Than marble — despite similar appearance"),
                ],
                activity: .trueFalse(statement: "Istrian stone resists salt because its grain is too tight for salt crystals to penetrate", isTrue: true),
                notebookSummary: "Istrian stone: dense white limestone from Croatia. Salt can't penetrate tight grain. Looks like marble, 3× harder. Venice's foundation stone.",
                visual: CardVisual(type: .crossSection, title: "Step 1: Dock Stone", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_volcano_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .workshop, stationKey: "volcano",
                title: "Step 1: Marine Concrete",
                italianTitle: "Longevità del Calcestruzzo Marino",
                icon: "flame.fill",
                lessonText: "The Arsenal's underwater foundations used Roman-style pozzolanic concrete — still sound after 500 years. Venice imported volcanic ash from the Phlegraean Fields near Naples. Mixed with seawater and lime, the same Al-tobermorite crystals formed as in ancient Rome. But Venice added crushed brick for extra alumina. Brick + ash + seawater = the longest-lasting concrete in saltwater. Two ancient recipes combined into one Renaissance innovation.",
                keywords: [
                    KeywordPair(keyword: "Phlegraean Fields", definition: "Volcanic ash source near Naples"),
                    KeywordPair(keyword: "Crushed brick", definition: "Venice's addition for extra alumina"),
                    KeywordPair(keyword: "500 years", definition: "Arsenal foundations still sound today"),
                ],
                activity: .wordScramble(word: "POZZOLANIC", hint: "Type of volcanic ash concrete that lasts centuries in saltwater"),
                notebookSummary: "Arsenal concrete: pozzolana (Phlegraean Fields) + crushed brick + seawater + lime. 500 years in saltwater. Roman recipe + Venetian innovation.",
                visual: CardVisual(type: .crossSection, title: "Step 1: Marine Concrete", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_mine_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "mine",
                title: "Step 6: Forge Anchors",
                italianTitle: "Ancore di Ferro",
                icon: "anchor",
                lessonText: "Each galley carried a 200 kg wrought iron anchor. Arsenal blacksmiths forged them from 4 separate iron bars welded together — a technique called faggoting. The bars were heated to white heat (1,200°C) and hammer-welded by 4 smiths striking in rotation. 500 hammer blows per anchor. The arms curved at exactly 40° — the angle that bites deepest into seabed clay. Holding fast is geometry plus force.",
                keywords: [
                    KeywordPair(keyword: "Faggoting", definition: "Welding 4 iron bars together by hammering"),
                    KeywordPair(keyword: "200 kg", definition: "Weight of a galley anchor"),
                    KeywordPair(keyword: "40°", definition: "Arm angle for maximum seabed grip"),
                    KeywordPair(keyword: "500 blows", definition: "Hammer strikes to forge one anchor"),
                ],
                activity: .numberFishing(question: "At what angle (degrees) were anchor arms curved for best grip?", correctAnswer: 40, decoys: [15, 25, 55, 70, 90]),
                notebookSummary: "Anchor: 200 kg, 4 bars faggot-welded, 500 hammer blows. Arms at 40° for max seabed grip. Geometry + force = hold.",
                visual: CardVisual(type: .crossSection, title: "Step 6: Forge Anchors", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_river_0",
                buildingId: bid, buildingName: name,
                science: .physics,
                environment: .workshop, stationKey: "river",
                title: "Step 7: Sail Canvas",
                italianTitle: "Fisica delle Vele",
                icon: "wind",
                lessonText: "A sail doesn't push a ship — it pulls it. Wind flowing over a curved sail creates low pressure on the front (like an airplane wing), generating forward lift. Arsenal sailmakers wove linen canvas in a tight twill weave that held its curved shape under wind load. Each galley had 2 lateen (triangular) sails — the triangular shape lets ships sail closer to the wind than square rigs. Shape beats size.",
                keywords: [
                    KeywordPair(keyword: "Lift", definition: "Low pressure on curved sail pulls the ship forward"),
                    KeywordPair(keyword: "Twill weave", definition: "Tight linen pattern holding sail shape"),
                    KeywordPair(keyword: "Lateen sail", definition: "Triangular — sails closer to the wind"),
                    KeywordPair(keyword: "Airfoil", definition: "Curved shape generating lift — same as airplane wing"),
                ],
                activity: .trueFalse(statement: "A sail generates forward pull through low pressure on its curved surface, like an airplane wing", isTrue: true),
                notebookSummary: "Sails pull (not push): curved shape = low pressure = lift. Lateen (triangular) sails closer to wind. Twill linen holds shape.",
                visual: CardVisual(type: .crossSection, title: "Step 7: Sail Canvas", values: [:], labels: [], steps: 3, caption: "")
            ),

            // ── FOREST (2 cards) ───────────────────────────────

            KnowledgeCard(
                id: "\(bid)_forest_oak_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .forest, stationKey: "oak",
                title: "Step 5: Timber Stores",
                italianTitle: "Stagionatura del Legname — 3 Anni",
                icon: "leaf.fill",
                lessonText: "Fresh-cut oak contains 80% moisture. Build a ship with green wood and it warps as it dries — hull planks gap, frames twist. The Arsenal seasoned oak for 3 full years in open-air sheds. Moisture dropped to 15%. Venice maintained a strategic timber reserve — 100,000 logs at any time, aged and labeled by cut date. The world's first just-in-time inventory was made of trees.",
                keywords: [
                    KeywordPair(keyword: "3 years", definition: "Seasoning time for ship-grade oak"),
                    KeywordPair(keyword: "80% → 15%", definition: "Moisture reduction during seasoning"),
                    KeywordPair(keyword: "100,000 logs", definition: "Venice's strategic timber reserve"),
                    KeywordPair(keyword: "Open-air sheds", definition: "Seasoning method — airflow removes moisture"),
                ],
                activity: .numberFishing(question: "How many years was Arsenal oak seasoned before use?", correctAnswer: 3, decoys: [1, 2, 5, 7, 10]),
                notebookSummary: "Oak seasoned 3 years: 80% → 15% moisture. Venice kept 100,000 logs in reserve, labeled by cut date. First timber inventory.",
                visual: CardVisual(type: .crossSection, title: "Step 5: Timber Stores", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_forest_walnut_0",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .forest, stationKey: "walnut",
                title: "Step 3: Ship Fittings",
                italianTitle: "Raccordi Navali di Precisione",
                icon: "gearshape.fill",
                lessonText: "Walnut was reserved for ship fittings requiring precision: pulley sheaves, tiller mechanisms, and compass housings. Its tight grain machines smoothly without splintering. A pulley sheave must spin freely with minimal friction — walnut's natural oils act as lubricant. One galley used 40 walnut pulleys. The Arsenal kept walnut stocks separate, marked 'per meccanismi' — for mechanisms only. Precision wood, precision use.",
                keywords: [
                    KeywordPair(keyword: "Pulley sheave", definition: "Wheel inside a pulley — walnut spins smoothly"),
                    KeywordPair(keyword: "Natural oils", definition: "Walnut's self-lubricating property"),
                    KeywordPair(keyword: "40 pulleys", definition: "Number of walnut pulleys per galley"),
                    KeywordPair(keyword: "Per meccanismi", definition: "Arsenal label — walnut reserved for mechanisms"),
                ],
                activity: .wordScramble(word: "SHEAVE", hint: "The wheel inside a pulley — walnut spins with natural lubrication"),
                notebookSummary: "Walnut: pulleys, tillers, compass housings. Natural oils = self-lubricating. 40 pulleys per galley. Reserved 'per meccanismi.'",
                visual: CardVisual(type: .crossSection, title: "Step 3: Ship Fittings", values: [:], labels: [], steps: 3, caption: "")
            ),

            // ── CRAFTING ROOM (2 cards) ────────────────────────

            KnowledgeCard(
                id: "\(bid)_craftingRoom_workbench_0",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .craftingRoom, stationKey: "workbench",
                title: "Step 3: Oakum Caulking",
                italianTitle: "Calafataggio con Stoppa",
                icon: "line.horizontal.3",
                lessonText: "Between every hull plank: a gap. Into every gap: oakum — old hemp rope untwisted into loose fibers, soaked in pine tar. Caulkers hammered oakum into seams with a mallet and iron, then sealed with hot pitch. A galley had 200 meters of caulked seams. The process took 3 caulkers 2 days. Miss one seam and the ship leaks. The most important work on the ship was done between the planks.",
                keywords: [
                    KeywordPair(keyword: "Oakum", definition: "Tarred hemp fibers hammered into plank seams"),
                    KeywordPair(keyword: "Pine tar", definition: "Waterproof coating soaked into the hemp"),
                    KeywordPair(keyword: "200 meters", definition: "Total caulked seam length per galley"),
                    KeywordPair(keyword: "Hot pitch", definition: "Final seal over the caulked seam"),
                ],
                activity: .hangman(word: "OAKUM", hint: "Tarred hemp fibers hammered between ship planks to prevent leaks"),
                notebookSummary: "Oakum: untwisted hemp + pine tar. Hammered into 200m of seams per galley. Sealed with hot pitch. Work between planks = most important.",
                visual: CardVisual(type: .crossSection, title: "Step 3: Oakum Caulking", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_craftingRoom_furnace_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .craftingRoom, stationKey: "furnace",
                title: "Step 6: Iron Quenching",
                italianTitle: "Tempra del Ferro a 800°C",
                icon: "flame.circle.fill",
                lessonText: "Arsenal nails, bolts, and chain links were quenched — heated to cherry red (800°C) and plunged into seawater. The rapid cooling traps carbon in the iron lattice, hardening it. Seawater quenches faster than fresh water (salt increases heat transfer). But too fast → brittle. Arsenal smiths used warm seawater (40°C) for a controlled quench. Temperature of the quenching bath matters as much as the forge.",
                keywords: [
                    KeywordPair(keyword: "800°C", definition: "Cherry red — quenching temperature"),
                    KeywordPair(keyword: "Seawater quench", definition: "Salt increases cooling speed vs fresh water"),
                    KeywordPair(keyword: "40°C bath", definition: "Warm seawater for controlled hardening"),
                    KeywordPair(keyword: "Carbon trapping", definition: "Rapid cooling locks carbon in iron lattice"),
                ],
                activity: .fillInBlanks(text: "Quench iron at ___°C in ___°C seawater — salt ___ heat transfer", blanks: ["800", "40", "increases"], distractors: ["600", "20", "decreases"]),
                notebookSummary: "Quenching: 800°C iron into 40°C seawater. Salt increases cooling speed. Traps carbon = harder. Bath temperature matters.",
                visual: CardVisual(type: .crossSection, title: "Step 6: Iron Quenching", values: [:], labels: [], steps: 3, caption: "")
            ),
        ]
    }

    // MARK: - Anatomy Theater (11 cards)

    static var anatomyTheaterCards: [KnowledgeCard] {
        let bid = 13
        let name = "Anatomy Theater"
        return [
            // ── CITY MAP (4 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_cityMap_building_0",
                buildingId: bid, buildingName: name,
                science: .biology,
                environment: .cityMap, stationKey: "building",
                title: "Vesalius's Revolution",
                italianTitle: "La Rivoluzione di Vesalio",
                icon: "figure.stand",
                lessonText: "In 1543, Andreas Vesalius published De Humani Corporis Fabrica — 700 pages proving that Galen, the authority for 1,300 years, was wrong about human anatomy. Galen had dissected pigs and monkeys, not humans. Vesalius dissected human cadavers at the University of Padua. The book's illustrations were revolutionary — detailed woodcuts showing muscles, bones, and organs. Seeing is correcting. The anatomy theater made seeing possible.",
                keywords: [
                    KeywordPair(keyword: "Vesalius", definition: "Proved Galen wrong by dissecting humans"),
                    KeywordPair(keyword: "1543", definition: "Year De Humani Corporis Fabrica was published"),
                    KeywordPair(keyword: "Galen", definition: "Ancient authority — dissected animals, not humans"),
                    KeywordPair(keyword: "De Fabrica", definition: "700-page book with revolutionary anatomy illustrations"),
                ],
                activity: .numberFishing(question: "In what year did Vesalius publish De Humani Corporis Fabrica?", correctAnswer: 1543, decoys: [1400, 1480, 1520, 1600, 1650]),
                notebookSummary: "1543: Vesalius published De Fabrica. Proved Galen wrong (dissected animals, not humans). 700 pages. The anatomy theater made seeing possible.",
                visual: CardVisual(type: .crossSection, title: "Vesalius's Revolution", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_1",
                buildingId: bid, buildingName: name,
                science: .architecture,
                environment: .cityMap, stationKey: "building",
                title: "Step 1: Funnel Shape",
                italianTitle: "Forma a Imbuto",
                icon: "triangle.fill",
                lessonText: "Padua's anatomy theater (built 1594) is an inverted funnel — 6 concentric oval tiers rising steeply around a central dissection table. The narrowest tier is at the bottom (standing room only, 2 meters wide). Each tier above is wider. 300 students packed into a space 11 meters across. No seats — everyone stood, leaning on railings. The funnel shape ensures every student looks DOWN at the table. Anatomy requires a bird's-eye view.",
                keywords: [
                    KeywordPair(keyword: "Inverted funnel", definition: "Narrow at bottom, wide at top"),
                    KeywordPair(keyword: "6 tiers", definition: "Concentric oval standing galleries"),
                    KeywordPair(keyword: "300 students", definition: "Packed into 11-meter diameter"),
                    KeywordPair(keyword: "1594", definition: "Year the permanent theater was built"),
                ],
                activity: .numberFishing(question: "How many students could the anatomy theater hold?", correctAnswer: 300, decoys: [50, 100, 500, 800, 1000]),
                notebookSummary: "Built 1594: inverted funnel, 6 oval tiers, 300 standing students in 11m diameter. Everyone looks down at the dissection table.",
                visual: CardVisual(type: .crossSection, title: "Step 1: Funnel Shape", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_2",
                buildingId: bid, buildingName: name,
                science: .optics,
                environment: .cityMap, stationKey: "building",
                title: "Step 5: Candlelight",
                italianTitle: "Ottica delle Candele",
                icon: "candle.fill",
                lessonText: "Dissections happened in winter (cold preserved the cadaver) and lasted 3 days. No windows — light came from candles held by the students themselves. Each tier had candle sconces angled at 45° toward the table. The collective light of 300 candles created shadowless illumination from every direction. Modern operating rooms use the same principle: ring lights. 300 students weren't just watching. They were the lighting system.",
                keywords: [
                    KeywordPair(keyword: "300 candles", definition: "One per student — collective shadowless light"),
                    KeywordPair(keyword: "45° angle", definition: "Sconce angle directing light to the table"),
                    KeywordPair(keyword: "Winter only", definition: "Cold preserved the cadaver for 3 days"),
                    KeywordPair(keyword: "Ring light", definition: "Modern version of the same all-around principle"),
                ],
                activity: .trueFalse(statement: "Students held candles at 45° angles, creating shadowless illumination from all directions", isTrue: true),
                notebookSummary: "Winter dissections, 3 days. 300 candles at 45° = shadowless light from every direction. Students = the lighting system. Same as modern ring lights.",
                visual: CardVisual(type: .crossSection, title: "Step 5: Candlelight", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_3",
                buildingId: bid, buildingName: name,
                science: .geometry,
                environment: .cityMap, stationKey: "building",
                title: "Step 2: Sight Lines",
                italianTitle: "Geometria delle Linee di Vista",
                icon: "eye",
                lessonText: "Every student needed an unobstructed view of the dissection table — from a 2-meter-wide bottom tier to an 8-meter-wide top tier. The architect calculated sight lines: each tier was raised 30 cm and set back 40 cm from the tier below. The railing height was exactly 90 cm — waist-high for a standing person, low enough to see over from the tier above. 300 clear sight lines. Zero dead angles. Geometry as democracy.",
                keywords: [
                    KeywordPair(keyword: "30 cm rise", definition: "Height increase per tier for clear views"),
                    KeywordPair(keyword: "40 cm setback", definition: "Each tier wider than the one below"),
                    KeywordPair(keyword: "90 cm railings", definition: "Waist height — see over from tier above"),
                    KeywordPair(keyword: "Zero dead angles", definition: "Every position has unobstructed view"),
                ],
                activity: .numberFishing(question: "How tall (cm) were the railings for optimal sight lines?", correctAnswer: 90, decoys: [50, 70, 100, 120, 150]),
                notebookSummary: "Sight lines: 30cm rise + 40cm setback per tier. 90cm railings. 300 students, zero dead angles. Geometry = everyone sees.",
                visual: CardVisual(type: .crossSection, title: "Step 2: Sight Lines", values: [:], labels: [], steps: 3, caption: "")
            ),

            // ── WORKSHOP (3 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_workshop_mine_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "mine",
                title: "Step 4: Bronze Pivot",
                italianTitle: "Meccanismi a Perno di Bronzo",
                icon: "gearshape.fill",
                lessonText: "The dissection table rotated on a bronze pivot — allowing the professor to turn the cadaver to face any tier. Bronze bearings provided smooth, quiet rotation. The pivot was a tapered cone fitting into a matching socket — a design borrowed from Roman door hinges. Oil it once a week and it turns silently for decades. The simplest mechanism enabled the most complex science. Form follows function.",
                keywords: [
                    KeywordPair(keyword: "Bronze pivot", definition: "Rotating mechanism for the dissection table"),
                    KeywordPair(keyword: "Tapered cone", definition: "Self-centering bearing design"),
                    KeywordPair(keyword: "Roman hinge", definition: "Inspiration for the pivot mechanism"),
                    KeywordPair(keyword: "Silent rotation", definition: "Bronze-on-bronze with weekly oiling"),
                ],
                activity: .wordScramble(word: "PIVOT", hint: "Rotating mechanism that turns the dissection table to face any tier"),
                notebookSummary: "Dissection table on bronze pivot — tapered cone bearing from Roman hinge design. Silent rotation, weekly oiling. Simple mechanism, complex science.",
                visual: CardVisual(type: .crossSection, title: "Step 4: Bronze Pivot", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_mine_1",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "mine",
                title: "Step 7: Scalpel Steel",
                italianTitle: "Leghe per Bisturi",
                icon: "scissors",
                lessonText: "Renaissance surgeons needed scalpels sharper than any knife. The blade: high-carbon steel (iron + 1.5% carbon), hardened to Rockwell 60 — harder than modern kitchen knives. The handle: bronze (won't rust from blood). The edge was ground on a stone wheel at 15° — half the angle of a butcher's knife. Sharper = less tissue damage. The scalpel proved that surgery is precision, not strength.",
                keywords: [
                    KeywordPair(keyword: "1.5% carbon", definition: "Steel composition for surgical sharpness"),
                    KeywordPair(keyword: "15° edge", definition: "Half the angle of a butcher's knife"),
                    KeywordPair(keyword: "Rockwell 60", definition: "Hardness rating — harder than modern knives"),
                    KeywordPair(keyword: "Bronze handle", definition: "Won't rust from exposure to blood"),
                ],
                activity: .numberFishing(question: "At what angle (degrees) was a Renaissance scalpel edge ground?", correctAnswer: 15, decoys: [5, 10, 25, 30, 45]),
                notebookSummary: "Scalpel: 1.5% carbon steel (Rockwell 60), 15° edge (half a butcher's knife). Bronze handle resists blood corrosion. Precision > strength.",
                visual: CardVisual(type: .crossSection, title: "Step 7: Scalpel Steel", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_river_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "river",
                title: "Step 3: Timber Prep",
                italianTitle: "Ammollo del Legno per Intaglio",
                icon: "drop.triangle.fill",
                lessonText: "Walnut destined for the theater's carved railings was soaked in river water for 6 months. Water dissolves the sap and tannins, preventing future cracking and insect damage. The slow saturation also makes the grain easier to carve — a dry walnut blank resists the chisel. After soaking, logs air-dried for 1 year. Total prep: 18 months before a chisel touched wood. Great carving starts with great preparation.",
                keywords: [
                    KeywordPair(keyword: "6 months", definition: "River soaking time for walnut logs"),
                    KeywordPair(keyword: "Tannin removal", definition: "Water dissolves sap — prevents cracking"),
                    KeywordPair(keyword: "1 year drying", definition: "Air-drying after water soaking"),
                    KeywordPair(keyword: "18 months total", definition: "Preparation time before carving begins"),
                ],
                activity: .numberFishing(question: "Total months to prepare walnut for carving (soak + dry)?", correctAnswer: 18, decoys: [3, 6, 12, 24, 36]),
                notebookSummary: "Walnut prep: 6 months river soak (removes sap/tannins) + 12 months air-dry = 18 months before carving. Preparation > skill.",
                visual: CardVisual(type: .crossSection, title: "Step 3: Timber Prep", values: [:], labels: [], steps: 3, caption: "")
            ),

            // ── FOREST (3 cards) ───────────────────────────────

            KnowledgeCard(
                id: "\(bid)_forest_walnut_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .forest, stationKey: "walnut",
                title: "Step 8: Walnut Carvings",
                italianTitle: "Intagli in Noce",
                icon: "leaf.fill",
                lessonText: "Every railing, panel, and decorative element in the anatomy theater is carved walnut. Why walnut? Its grain is uniform in all directions — it carves equally well horizontally, vertically, and diagonally. Oak splits along the grain. Pine is too soft. Walnut holds fine detail: the floral scrolls on the railings are 3mm deep. 400 years later, every scroll is still sharp. The wood that carves best is the wood that lasts.",
                keywords: [
                    KeywordPair(keyword: "Uniform grain", definition: "Carves equally in all directions"),
                    KeywordPair(keyword: "3mm detail", definition: "Depth of fine floral scrollwork"),
                    KeywordPair(keyword: "400 years", definition: "Original carvings still sharp"),
                    KeywordPair(keyword: "Isotropic", definition: "Same properties in every direction"),
                ],
                activity: .hangman(word: "WALNUT", hint: "The only wood that carves equally well in all directions"),
                notebookSummary: "All theater carvings: walnut. Uniform grain = carves in any direction. 3mm scrollwork still sharp after 400 years. Best carving = longest lasting.",
                visual: CardVisual(type: .crossSection, title: "Step 8: Walnut Carvings", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_forest_oak_0",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .forest, stationKey: "oak",
                title: "Step 3: Oak Structure",
                italianTitle: "Pali Strutturali in Quercia",
                icon: "rectangle.portrait.fill",
                lessonText: "The theater's 6 tiers needed invisible structural support. Oak posts — 20 cm square — were hidden inside the walnut-clad walls. Oak handles compression (vertical load) better than any other European wood. Each post carries the weight of 50 standing students above it. The walnut you see is decorative. The oak you don't see is structural. Beauty and strength share the same wall but different jobs.",
                keywords: [
                    KeywordPair(keyword: "20 cm square", definition: "Cross-section of hidden oak support posts"),
                    KeywordPair(keyword: "Compression", definition: "Vertical load — oak's strongest property"),
                    KeywordPair(keyword: "50 students", definition: "Weight carried by each oak post"),
                    KeywordPair(keyword: "Hidden inside", definition: "Structure concealed behind decorative walnut"),
                ],
                activity: .trueFalse(statement: "The anatomy theater's structural oak posts are hidden inside walnut-clad walls", isTrue: true),
                notebookSummary: "Hidden oak posts: 20cm square, carry 50 students each. Oak = compression. Walnut = decoration. Same wall, different jobs.",
                visual: CardVisual(type: .crossSection, title: "Step 3: Oak Structure", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_forest_cypress_0",
                buildingId: bid, buildingName: name,
                science: .biology,
                environment: .forest, stationKey: "cypress",
                title: "Step 6: Cypress Ventilation",
                italianTitle: "Conservazione Aromatica",
                icon: "tree.fill",
                lessonText: "Cypress wood contains natural oils (thujone and cedrol) that repel insects and resist fungal decay. The anatomy theater's ceiling panels are cypress — chosen because the aromatic compounds also mask decomposition odors during 3-day dissections. Cypress coffins in ancient Egypt still smell of cedar after 3,000 years. The tree of cemeteries became the wood of the anatomy theater. Death's tree preserving death's study.",
                keywords: [
                    KeywordPair(keyword: "Thujone", definition: "Cypress oil that repels insects"),
                    KeywordPair(keyword: "Cedrol", definition: "Aromatic compound masking decomposition"),
                    KeywordPair(keyword: "Fungal resistance", definition: "Natural oils prevent wood decay"),
                    KeywordPair(keyword: "3-day dissections", definition: "Duration requiring odor management"),
                ],
                activity: .wordScramble(word: "CYPRESS", hint: "Aromatic wood whose natural oils mask decomposition and repel insects"),
                notebookSummary: "Cypress ceiling: thujone + cedrol oils repel insects, resist fungus, mask decomposition. 3-day dissections needed odor control. Death's tree for death's study.",
                visual: CardVisual(type: .crossSection, title: "Step 6: Cypress Ventilation", values: [:], labels: [], steps: 3, caption: "")
            ),

            // ── CRAFTING ROOM (1 card) ─────────────────────────

            KnowledgeCard(
                id: "\(bid)_craftingRoom_workbench_0",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .craftingRoom, stationKey: "workbench",
                title: "Step 8: Carving Tools",
                italianTitle: "Tecniche di Intaglio in Noce",
                icon: "pencil.and.outline",
                lessonText: "Renaissance carvers used 30 different chisel profiles — each for a specific curve. The process: draw the design on paper, transfer to wood with carbon dust, rough-cut with gouges, detail with V-tools and veiners, sand with 3 grits (coarse → medium → fine), seal with walnut oil. The oil darkens the wood to its signature deep brown and fills the pores against moisture. Every panel: 2 weeks of carving, 30 minutes of oiling.",
                keywords: [
                    KeywordPair(keyword: "30 chisel profiles", definition: "Different shapes for different curves"),
                    KeywordPair(keyword: "Carbon dust transfer", definition: "Method of copying paper design onto wood"),
                    KeywordPair(keyword: "Walnut oil", definition: "Seals pores and darkens to signature brown"),
                    KeywordPair(keyword: "2 weeks", definition: "Carving time per decorative panel"),
                ],
                activity: .numberFishing(question: "How many different chisel profiles did Renaissance carvers use?", correctAnswer: 30, decoys: [5, 10, 15, 50, 100]),
                notebookSummary: "Carving: 30 chisel profiles. Design → carbon transfer → gouge → detail → 3-grit sand → walnut oil seal. 2 weeks per panel.",
                visual: CardVisual(type: .crossSection, title: "Step 8: Carving Tools", values: [:], labels: [], steps: 3, caption: "")
            ),
        ]
    }

    // MARK: - Leonardo's Workshop (13 cards)

    static var leonardoWorkshopCards: [KnowledgeCard] {
        let bid = 14
        let name = "Leonardo's Workshop"
        return [
            // ── CITY MAP (5 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_cityMap_building_0",
                buildingId: bid, buildingName: name,
                science: .architecture,
                environment: .cityMap, stationKey: "building",
                title: "The Bottega System",
                italianTitle: "Il Sistema della Bottega",
                icon: "house.fill",
                lessonText: "Leonardo trained in Verrocchio's bottega — a Renaissance workshop where master and apprentices lived, ate, and worked together. Apprentices started at age 12, grinding pigments and sweeping. By 16, they assisted on paintings. By 20, they could accept their own commissions. Leonardo's own workshop in Milan had 6 apprentices and specialized in painting, engineering, and anatomy. The bottega wasn't a school. It was a family that built things.",
                keywords: [
                    KeywordPair(keyword: "Bottega", definition: "Workshop where master and apprentices lived and worked"),
                    KeywordPair(keyword: "Verrocchio", definition: "Leonardo's master — goldsmith, painter, sculptor"),
                    KeywordPair(keyword: "Age 12", definition: "Starting age for apprenticeship"),
                    KeywordPair(keyword: "6 apprentices", definition: "Size of Leonardo's Milan workshop"),
                ],
                activity: .wordScramble(word: "BOTTEGA", hint: "Renaissance workshop where master and apprentices lived together"),
                notebookSummary: "Bottega: live-in workshop. Start age 12 grinding pigments. By 20, own commissions. Leonardo's Milan shop: 6 apprentices. Family that builds.",
                visual: CardVisual(type: .crossSection, title: "The Bottega System", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_1",
                buildingId: bid, buildingName: name,
                science: .optics,
                environment: .cityMap, stationKey: "building",
                title: "Step 1: North Light",
                italianTitle: "Ottica della Luce Nord",
                icon: "sun.max.fill",
                lessonText: "Leonardo insisted his workshop face north. Why? North light is indirect — sunlight bouncing off the sky, never direct rays. It's consistent all day (no moving shadows), cool in color temperature, and reveals true form without harsh highlights. South-facing windows create shifting shadows that fool the painter's eye. Leonardo wrote: 'Choose north light for painting, for it does not vary.' The best light is the one that doesn't change.",
                keywords: [
                    KeywordPair(keyword: "North light", definition: "Indirect skylight — consistent all day"),
                    KeywordPair(keyword: "No moving shadows", definition: "Constant light direction for accurate painting"),
                    KeywordPair(keyword: "Cool color", definition: "North light's natural blue-white tone"),
                    KeywordPair(keyword: "True form", definition: "Objects appear accurately without harsh highlights"),
                ],
                activity: .multipleChoice(question: "Why did Leonardo's workshop face north?", options: ["Warmer in winter", "Better ventilation", "Consistent, shadowless light all day", "Traditional placement"], correctIndex: 2),
                notebookSummary: "North light: indirect, consistent, cool, no moving shadows. Leonardo chose it for painting accuracy. Best light doesn't change.",
                visual: CardVisual(type: .crossSection, title: "Step 1: North Light", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_2",
                buildingId: bid, buildingName: name,
                science: .optics,
                environment: .cityMap, stationKey: "building",
                title: "Step 8: Sfumato",
                italianTitle: "Tecnica dello Sfumato",
                icon: "circle.lefthalf.filled",
                lessonText: "Leonardo invented sfumato — blending paint so gradually that edges disappear. He studied how smoke dissipates and how distant mountains lose definition. The technique: 20-30 translucent oil layers, each barely tinted, applied with fingertips (not brushes). The Mona Lisa's smile uses sfumato — look straight at it and it vanishes; glance sideways and it appears. Your peripheral vision is more sensitive to soft transitions. Art that exploits biology.",
                keywords: [
                    KeywordPair(keyword: "Sfumato", definition: "Gradual blending — edges disappear like smoke"),
                    KeywordPair(keyword: "20-30 layers", definition: "Translucent oil coats built up gradually"),
                    KeywordPair(keyword: "Fingertips", definition: "Applied by touch, not brushes"),
                    KeywordPair(keyword: "Peripheral vision", definition: "More sensitive to soft transitions than direct gaze"),
                ],
                activity: .hangman(word: "SFUMATO", hint: "Leonardo's painting technique — blending until edges vanish like smoke"),
                notebookSummary: "Sfumato: 20-30 translucent layers, applied by fingertips. Edges vanish like smoke. Mona Lisa's smile appears in peripheral vision.",
                visual: CardVisual(type: .crossSection, title: "Step 8: Sfumato", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_3",
                buildingId: bid, buildingName: name,
                science: .hydraulics,
                environment: .cityMap, stationKey: "building",
                title: "Step 6: Water Tank",
                italianTitle: "Vortici nella Vasca d'Acqua",
                icon: "water.waves",
                lessonText: "Leonardo built glass water tanks in his workshop to study fluid dynamics. He dropped dye into flowing water and sketched the vortices. His notebooks contain 730 drawings of water movement — turbulence, eddies, waves. He discovered that water spirals clockwise when draining (in the Northern Hemisphere) centuries before Coriolis described the effect. The workshop wasn't just for art. It was a physics laboratory with paint on the walls.",
                keywords: [
                    KeywordPair(keyword: "Glass tanks", definition: "Built for observing water flow patterns"),
                    KeywordPair(keyword: "730 drawings", definition: "Water studies in Leonardo's notebooks"),
                    KeywordPair(keyword: "Dye tracing", definition: "Colored liquid revealing flow patterns"),
                    KeywordPair(keyword: "Vortex", definition: "Spinning water pattern Leonardo documented"),
                ],
                activity: .numberFishing(question: "How many water flow drawings are in Leonardo's notebooks?", correctAnswer: 730, decoys: [50, 200, 400, 1000, 2000]),
                notebookSummary: "Glass water tanks for fluid dynamics. 730 drawings of vortices, turbulence, eddies. Workshop = physics lab with paint on walls.",
                visual: CardVisual(type: .crossSection, title: "Step 6: Water Tank", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_4",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .cityMap, stationKey: "building",
                title: "Step 3: The Forge",
                italianTitle: "Fucina della Bottega",
                icon: "hammer.fill",
                lessonText: "Leonardo's workshop had its own forge — unusual for a painter. He used it to cast bronze sculptures, fabricate mechanical parts, and experiment with alloys. He designed an improved bellows system: two chambers alternating so air flows continuously (not in puffs). This doubled forge temperature consistency. Leonardo applied engineering to every problem, even airflow. The painter who built a better bellows understood that art needs infrastructure.",
                keywords: [
                    KeywordPair(keyword: "Workshop forge", definition: "Unusual for a painter — for bronze and experiments"),
                    KeywordPair(keyword: "Double bellows", definition: "Alternating chambers for continuous airflow"),
                    KeywordPair(keyword: "Temperature consistency", definition: "No puffs — steady heat for precision work"),
                    KeywordPair(keyword: "Alloy experiments", definition: "Testing metal mixtures at the forge"),
                ],
                activity: .trueFalse(statement: "Leonardo designed a double-chamber bellows for continuous airflow instead of puffs", isTrue: true),
                notebookSummary: "Workshop forge: bronze casting, mechanisms, alloy experiments. Double bellows = continuous air. Art needs infrastructure.",
                visual: CardVisual(type: .crossSection, title: "Step 3: The Forge", values: [:], labels: [], steps: 3, caption: "")
            ),

            // ── WORKSHOP (4 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_workshop_quarry_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "quarry",
                title: "Step 1: White Walls",
                italianTitle: "Intonaco di Calce per la Luce",
                icon: "mountain.2.fill",
                lessonText: "Leonardo's workshop walls were coated in lime plaster — burnished smooth and white. Lime plaster reflects 85% of light (vs 40% for bare stone). Combined with north-facing windows, the white walls created a naturally bright studio without candles during daylight hours. Leonardo specified three coats: rough scratch coat, smooth brown coat, polished finish coat. The whitest wall, like the whitest canvas, starts with lime and patience.",
                keywords: [
                    KeywordPair(keyword: "85% reflection", definition: "Lime plaster's light-bouncing ability"),
                    KeywordPair(keyword: "Three coats", definition: "Scratch → brown → polished finish"),
                    KeywordPair(keyword: "North light + white", definition: "Combination for natural studio brightness"),
                ],
                activity: .numberFishing(question: "What percentage of light does lime plaster reflect?", correctAnswer: 85, decoys: [40, 55, 70, 90, 99]),
                notebookSummary: "Lime plaster: 3 coats, reflects 85% of light. + North windows = bright studio without candles. Whitest wall = best workspace.",
                visual: CardVisual(type: .crossSection, title: "Step 1: White Walls", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_mine_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "mine",
                title: "Step 5: Bronze Gears",
                italianTitle: "Ingranaggi in Bronzo",
                icon: "gearshape.2.fill",
                lessonText: "Leonardo designed over 200 gear mechanisms in his notebooks — compound gear trains, worm gears, cam systems. He cast them in bronze at his workshop forge. His key innovation: involute tooth profiles that mesh smoothly at any rotation angle. Earlier gears had straight teeth that jammed. Leonardo's gears appear in his crane designs, clocks, and the mechanical lion he built for Francis I of France. The smoothest machines start with the right tooth shape.",
                keywords: [
                    KeywordPair(keyword: "200+ mechanisms", definition: "Gear designs in Leonardo's notebooks"),
                    KeywordPair(keyword: "Involute profile", definition: "Curved tooth shape for smooth meshing"),
                    KeywordPair(keyword: "Worm gear", definition: "Screw-shaped gear for high reduction ratio"),
                    KeywordPair(keyword: "Mechanical lion", definition: "Gear-driven automaton for Francis I"),
                ],
                activity: .wordScramble(word: "INVOLUTE", hint: "Curved gear tooth profile that meshes smoothly at any angle"),
                notebookSummary: "200+ gear mechanisms. Involute tooth profiles mesh smoothly (vs straight teeth that jam). Bronze cast. Mechanical lion for Francis I.",
                visual: CardVisual(type: .crossSection, title: "Step 5: Bronze Gears", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_river_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "river",
                title: "Step 3: Casting Sand",
                italianTitle: "Sabbia Idraulica",
                icon: "drop.triangle.fill",
                lessonText: "Leonardo used river sand for two purposes: as casting sand for bronze molds, and as an abrasive for polishing lenses. Casting sand must be fine-grained and clay-rich so it holds its shape when packed around a wax model. Polishing sand must be pure silica with no clay (clay scratches). Leonardo's notebooks specify: 'Arno sand for casting, mountain sand for polishing.' Same material, different sources, different jobs.",
                keywords: [
                    KeywordPair(keyword: "Casting sand", definition: "Clay-rich — holds shape around wax models"),
                    KeywordPair(keyword: "Polishing sand", definition: "Pure silica — no clay to cause scratches"),
                    KeywordPair(keyword: "Arno sand", definition: "River sand for bronze casting"),
                    KeywordPair(keyword: "Mountain sand", definition: "Pure quartz for lens polishing"),
                ],
                activity: .multipleChoice(question: "Why did Leonardo use different sand sources for casting vs polishing?", options: ["Cost difference", "Casting needs clay; polishing needs pure silica", "Color preference", "Superstition"], correctIndex: 1),
                notebookSummary: "Arno sand (clay-rich) for casting molds. Mountain sand (pure silica) for polishing. Same mineral, different sources, different jobs.",
                visual: CardVisual(type: .crossSection, title: "Step 3: Casting Sand", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_mine_1",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .workshop, stationKey: "mine",
                title: "Step 5: Custom Tools",
                italianTitle: "Fabbricazione di Attrezzi",
                icon: "wrench.and.screwdriver.fill",
                lessonText: "Leonardo made his own tools — chisels, files, wire-drawing dies, even specialized pliers. His notebooks show 50+ custom tool designs. The wire-drawing die was critical: iron pulled through progressively smaller holes creates uniform wire for springs and mechanical linkages. Each die was hardened by carburizing (packing in charcoal and heating). A craftsman who can't make his own tools depends on someone else's limitations.",
                keywords: [
                    KeywordPair(keyword: "50+ designs", definition: "Custom tool designs in Leonardo's notebooks"),
                    KeywordPair(keyword: "Wire-drawing die", definition: "Progressively smaller holes for uniform wire"),
                    KeywordPair(keyword: "Carburizing", definition: "Hardening iron by heating with charcoal"),
                    KeywordPair(keyword: "Self-sufficiency", definition: "Making your own tools = no external limits"),
                ],
                activity: .hangman(word: "CARBURIZE", hint: "Hardening process — pack iron in charcoal and heat"),
                notebookSummary: "Leonardo made his own tools: 50+ designs. Wire-drawing dies for springs. Carburized (charcoal-hardened). Self-sufficient craftsman.",
                visual: CardVisual(type: .crossSection, title: "Step 5: Custom Tools", values: [:], labels: [], steps: 3, caption: "")
            ),

            // ── FOREST (2 cards) ───────────────────────────────

            KnowledgeCard(
                id: "\(bid)_forest_oak_0",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .forest, stationKey: "oak",
                title: "Step 2: Drawing Tables",
                italianTitle: "Tavoli da Disegno",
                icon: "rectangle.portrait",
                lessonText: "Leonardo's drawing table was oak — tilted at 30° with an adjustable ledge. Oak doesn't warp in humidity (crucial for accurate drafting), and its hard surface holds paper flat under the quill's pressure. The table surface was planed with a bronze scraper to remove any grain texture that might catch the pen. A drawing table is a precision instrument. Its flatness is the foundation of every line drawn on it.",
                keywords: [
                    KeywordPair(keyword: "30° tilt", definition: "Ergonomic angle for drawing and drafting"),
                    KeywordPair(keyword: "No warping", definition: "Oak stays flat in changing humidity"),
                    KeywordPair(keyword: "Bronze scraper", definition: "Tool for planing grain-free surface"),
                    KeywordPair(keyword: "Precision surface", definition: "Table flatness = accurate drawing"),
                ],
                activity: .numberFishing(question: "At what angle (degrees) was Leonardo's drawing table tilted?", correctAnswer: 30, decoys: [10, 15, 45, 60, 75]),
                notebookSummary: "Drawing table: oak (no warp), 30° tilt, planed with bronze scraper. Precision surface = accurate lines. Table is an instrument.",
                visual: CardVisual(type: .crossSection, title: "Step 2: Drawing Tables", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_forest_poplar_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .forest, stationKey: "poplar",
                title: "Step 8: Poplar Panels",
                italianTitle: "Pannello della Gioconda",
                icon: "photo.artframe",
                lessonText: "The Mona Lisa is painted on poplar — a single panel 77 cm × 53 cm, cut tangentially from the log (flat-sawn). Poplar was the standard for Italian panel paintings because it's light, cheap, and has minimal grain pattern that won't show through thin paint layers. Leonardo sealed both sides with gesso (chalk + rabbit-skin glue) to prevent warping. The world's most famous painting sits on the humblest wood.",
                keywords: [
                    KeywordPair(keyword: "Poplar panel", definition: "Mona Lisa painted on poplar wood"),
                    KeywordPair(keyword: "77 × 53 cm", definition: "Dimensions of the Mona Lisa panel"),
                    KeywordPair(keyword: "Gesso", definition: "Chalk + glue seal preventing warping"),
                    KeywordPair(keyword: "Minimal grain", definition: "Won't show through thin paint layers"),
                ],
                activity: .trueFalse(statement: "The Mona Lisa is painted on a poplar wood panel, sealed with gesso", isTrue: true),
                notebookSummary: "Mona Lisa: poplar panel 77×53cm. Light, cheap, minimal grain. Gesso (chalk + rabbit-skin glue) seals both sides. Humblest wood, greatest painting.",
                visual: CardVisual(type: .crossSection, title: "Step 8: Poplar Panels", values: [:], labels: [], steps: 3, caption: "")
            ),

            // ── CRAFTING ROOM (2 cards) ────────────────────────

            KnowledgeCard(
                id: "\(bid)_craftingRoom_workbench_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .craftingRoom, stationKey: "workbench",
                title: "Step 8: Pigment Grinding",
                italianTitle: "Macinazione dei Pigmenti",
                icon: "paintpalette.fill",
                lessonText: "Leonardo ground his own pigments — a task most masters delegated to apprentices. He insisted on controlling particle size. Coarse-ground lapis lazuli is pale; fine-ground is deep blue (but loses luster). His notebooks record grinding times: 3 hours for ultramarine, 1 hour for ochre. Mixed with linseed oil, the pigment becomes paint. Leonardo wrote: 'The painter who doesn't understand his materials paints with borrowed hands.'",
                keywords: [
                    KeywordPair(keyword: "Particle size", definition: "Controls color intensity and texture"),
                    KeywordPair(keyword: "3 hours", definition: "Grinding time for ultramarine pigment"),
                    KeywordPair(keyword: "Linseed oil", definition: "Binder that turns pigment into oil paint"),
                    KeywordPair(keyword: "Lapis lazuli", definition: "Semi-precious stone ground for blue pigment"),
                ],
                activity: .numberFishing(question: "How many hours to grind lapis lazuli into ultramarine?", correctAnswer: 3, decoys: [1, 2, 5, 8, 12]),
                notebookSummary: "Leonardo ground pigments himself. 3 hours for ultramarine, 1 for ochre. Particle size controls color. + Linseed oil = paint.",
                visual: CardVisual(type: .crossSection, title: "Step 8: Pigment Grinding", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_craftingRoom_furnace_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .craftingRoom, stationKey: "furnace",
                title: "Step 3: Bronze Casting",
                italianTitle: "Fusione di Precisione in Bronzo",
                icon: "flame.circle.fill",
                lessonText: "Leonardo perfected lost-wax casting for his workshop mechanisms. The process: sculpt wax model → coat in ceramic slurry (6 layers, each dried 24 hours) → fire at 700°C to melt wax out → pour molten bronze at 1,050°C → break the ceramic shell → file and polish. For his giant horse statue (never completed), he calculated 70 tons of bronze. The furnace transforms imagination into metal, one layer at a time.",
                keywords: [
                    KeywordPair(keyword: "Lost-wax casting", definition: "Wax → ceramic → melt → bronze pour"),
                    KeywordPair(keyword: "6 ceramic layers", definition: "Each dried 24 hours for mold strength"),
                    KeywordPair(keyword: "1,050°C", definition: "Bronze pouring temperature"),
                    KeywordPair(keyword: "70 tons", definition: "Bronze for Leonardo's giant horse (unfinished)"),
                ],
                activity: .fillInBlanks(text: "Lost-wax: wax → ___ layers ceramic → fire ___°C → pour bronze ___°C", blanks: ["6", "700", "1050"], distractors: ["3", "500", "800"]),
                notebookSummary: "Lost-wax: wax → 6 ceramic layers (24hr each) → fire 700°C → pour bronze 1,050°C. Giant horse: 70 tons (never completed).",
                visual: CardVisual(type: .crossSection, title: "Step 3: Bronze Casting", values: [:], labels: [], steps: 3, caption: "")
            ),
        ]
    }

    // MARK: - Flying Machine (11 cards)

    static var flyingMachineCards: [KnowledgeCard] {
        let bid = 15
        let name = "Flying Machine"
        return [
            // ── CITY MAP (5 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_cityMap_building_0",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .cityMap, stationKey: "building",
                title: "The Ornithopter",
                italianTitle: "L'Ornitottero",
                icon: "bird.fill",
                lessonText: "Leonardo designed a flying machine that flapped like a bird — an ornithopter. His notebooks contain 35,000 words and 500 sketches on flight. The pilot would lie face-down in a wooden cradle and pump pedals connected by cables to articulated wings. Each wing spanned 12 meters. He studied bird anatomy for years before designing it. The machine that never flew was designed by the most thorough researcher who ever lived.",
                keywords: [
                    KeywordPair(keyword: "Ornithopter", definition: "Flapping-wing flying machine"),
                    KeywordPair(keyword: "500 sketches", definition: "Leonardo's flight drawings"),
                    KeywordPair(keyword: "12-meter wings", definition: "Wingspan of the ornithopter"),
                    KeywordPair(keyword: "Face-down cradle", definition: "Pilot position for pedal-powered flight"),
                ],
                activity: .wordScramble(word: "ORNITHOPTER", hint: "Leonardo's flapping-wing flying machine — powered by human pedaling"),
                notebookSummary: "Ornithopter: flapping-wing machine. 500 sketches, 35,000 words. 12m wingspan. Face-down pilot pedaling. Never flew — but most researched.",
                visual: CardVisual(type: .crossSection, title: "The Ornithopter", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_1",
                buildingId: bid, buildingName: name,
                science: .biology,
                environment: .cityMap, stationKey: "building",
                title: "Step 1: Bird Anatomy",
                italianTitle: "Anatomia dell'Ala",
                icon: "bird",
                lessonText: "Leonardo dissected over 30 birds to understand flight. He discovered that the wing's upper surface is curved (cambered) while the lower is flatter — creating a pressure difference. Air moves faster over the top, creating low pressure = lift. He also noted that birds twist their wingtips during the downstroke for thrust and flatten them during the upstroke to reduce drag. Every flight feather is an engineering solution.",
                keywords: [
                    KeywordPair(keyword: "30+ birds", definition: "Dissected by Leonardo for wing anatomy"),
                    KeywordPair(keyword: "Camber", definition: "Curved upper wing surface creating lift"),
                    KeywordPair(keyword: "Pressure difference", definition: "Fast air above = low pressure = lift"),
                    KeywordPair(keyword: "Wing twist", definition: "Downstroke for thrust, upstroke reduces drag"),
                ],
                activity: .trueFalse(statement: "Leonardo discovered that a wing's curved upper surface creates lower pressure than the flat underside, producing lift", isTrue: true),
                notebookSummary: "30+ bird dissections. Curved top (camber) = low pressure = lift. Wings twist: downstroke for thrust, upstroke reduces drag.",
                visual: CardVisual(type: .crossSection, title: "Step 1: Bird Anatomy", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_2",
                buildingId: bid, buildingName: name,
                science: .mathematics,
                environment: .cityMap, stationKey: "building",
                title: "Step 2: Wing Area Math",
                italianTitle: "Matematica della Superficie Alare",
                icon: "function",
                lessonText: "Leonardo calculated: a bird weighing 1 kg needs 0.1 m² of wing area. Scale that to a 90 kg pilot and machine: you need 18 m² of wing. His ornithopter had 2 wings at 12m × 0.75m = 18 m². The math was perfect. The problem wasn't area — it was power. A pigeon generates 10 watts per kilogram of body weight. Humans generate 1 watt. We're 10× too weak to fly by flapping. Mathematics showed the dream; physics showed the limit.",
                keywords: [
                    KeywordPair(keyword: "0.1 m²/kg", definition: "Wing area needed per kilogram of weight"),
                    KeywordPair(keyword: "18 m²", definition: "Wing area for 90 kg pilot + machine"),
                    KeywordPair(keyword: "10 W/kg (bird)", definition: "Power output per kg — birds"),
                    KeywordPair(keyword: "1 W/kg (human)", definition: "Power output per kg — humans (10× too weak)"),
                ],
                activity: .numberFishing(question: "How many m² of wing area does a 90 kg flyer need?", correctAnswer: 18, decoys: [5, 10, 25, 36, 50]),
                notebookSummary: "Wing math: 0.1 m²/kg. 90 kg → 18 m². Correct! But humans = 1 W/kg vs birds = 10 W/kg. 10× too weak. Math right, physics wrong.",
                visual: CardVisual(type: .crossSection, title: "Step 2: Wing Area Math", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_3",
                buildingId: bid, buildingName: name,
                science: .physics,
                environment: .cityMap, stationKey: "building",
                title: "Step 5: Power Ratio",
                italianTitle: "Rapporto di Potenza 1:10",
                icon: "bolt.fill",
                lessonText: "Leonardo eventually realized humans can't generate enough power to flap wings. His later designs shifted to gliders — fixed wings using gravity and air currents. He studied how hawks soar without flapping, riding thermals (rising warm air). His hang glider design from 1505 shows a pilot hanging below fixed triangular wings with a control bar — nearly identical to modern hang gliders. From flapping to soaring: the greatest pivot in aviation history.",
                keywords: [
                    KeywordPair(keyword: "Glider pivot", definition: "Leonardo shifted from flapping to fixed wings"),
                    KeywordPair(keyword: "Thermals", definition: "Rising warm air that hawks ride without flapping"),
                    KeywordPair(keyword: "1505 design", definition: "Hang glider with control bar — modern shape"),
                    KeywordPair(keyword: "Power limit", definition: "Humans produce 1/10 the power birds do"),
                ],
                activity: .multipleChoice(question: "Why did Leonardo shift from flapping wings to gliders?", options: ["Materials weren't strong enough", "Humans can't generate enough power to flap", "Wind was unreliable", "The Pope forbade it"], correctIndex: 1),
                notebookSummary: "Humans = 1/10 bird power. Leonardo pivoted to gliders (1505). Fixed wings + thermals. Hang glider design = nearly identical to modern ones.",
                visual: CardVisual(type: .crossSection, title: "Step 5: Power Ratio", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_4",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .cityMap, stationKey: "building",
                title: "Step 7: Monte Ceceri",
                italianTitle: "Monte Ceceri",
                icon: "mountain.2.fill",
                lessonText: "Leonardo wrote in Codex on the Flight of Birds (1505): 'The great bird will take its first flight from the summit of Monte Ceceri, filling the universe with amazement.' Monte Ceceri (Swan Mountain) rises 400 meters above Florence. Whether the flight happened is debated — some historians say his assistant Tommaso Masini attempted it and broke his leg. Success or failure, this was humanity's first recorded launch attempt. Every flight begins with a cliff and a decision.",
                keywords: [
                    KeywordPair(keyword: "Monte Ceceri", definition: "Swan Mountain — planned launch site near Florence"),
                    KeywordPair(keyword: "400 meters", definition: "Height of Monte Ceceri above Florence"),
                    KeywordPair(keyword: "Codex on Flight", definition: "1505 manuscript with launch prediction"),
                    KeywordPair(keyword: "Tommaso Masini", definition: "Possible test pilot — may have broken his leg"),
                ],
                activity: .hangman(word: "CECERI", hint: "Monte ___ — the hilltop where Leonardo planned humanity's first flight"),
                notebookSummary: "Monte Ceceri: 400m above Florence. 1505: Leonardo predicted first flight. Possibly attempted — Masini may have broken his leg. First launch attempt.",
                visual: CardVisual(type: .crossSection, title: "Step 7: Monte Ceceri", values: [:], labels: [], steps: 3, caption: "")
            ),

            // ── WORKSHOP (3 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_workshop_market_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "market",
                title: "Step 3: Silk Covering",
                italianTitle: "Ali di Taffetà di Seta",
                icon: "wind",
                lessonText: "Leonardo specified taffeta di seta — tightly woven silk — for the wing covering. Why silk? It's the strongest natural fiber per weight. A silk thread can hold the weight of a spider yet weighs nearly nothing. Stretched over a wooden frame and sealed with linseed oil, silk becomes airtight and drum-taut. One wing covering weighed just 2 kg but resisted 50 kg of air pressure. Strength without weight. Nature's best material for nature's hardest problem.",
                keywords: [
                    KeywordPair(keyword: "Taffeta", definition: "Tightly woven silk for wing covering"),
                    KeywordPair(keyword: "Strongest natural fiber", definition: "Silk per unit weight"),
                    KeywordPair(keyword: "Linseed oil seal", definition: "Makes silk airtight and taut"),
                    KeywordPair(keyword: "2 kg per wing", definition: "Weight of silk wing covering"),
                ],
                activity: .trueFalse(statement: "Leonardo chose silk taffeta for wing covering because it's the strongest natural fiber per unit weight", isTrue: true),
                notebookSummary: "Silk taffeta: strongest natural fiber per weight. + Linseed oil = airtight. 2 kg covering resists 50 kg air pressure. Nature's answer.",
                visual: CardVisual(type: .crossSection, title: "Step 3: Silk Covering", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_mine_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "mine",
                title: "Step 5: Bronze Pivots",
                italianTitle: "Giunti a Perno di Bronzo",
                icon: "gearshape.fill",
                lessonText: "The ornithopter's wings needed pivot joints — points where rigid frames met moving parts. Leonardo used bronze bearings with leather washers for smooth, low-friction rotation. His notebooks show the joint design: a tapered pin in a matching socket, with grease channels cut into the bronze. Each wing had 6 pivot points for the flapping and twisting motion. Bronze doesn't gall (cold-weld) like iron. Every flap was smooth.",
                keywords: [
                    KeywordPair(keyword: "6 pivots", definition: "Joints per wing for flapping and twisting"),
                    KeywordPair(keyword: "Galling", definition: "Cold-welding — iron does it, bronze doesn't"),
                    KeywordPair(keyword: "Grease channels", definition: "Cut into bronze for continuous lubrication"),
                    KeywordPair(keyword: "Leather washers", definition: "Seal against dust and reduce friction"),
                ],
                activity: .numberFishing(question: "How many pivot joints did each ornithopter wing have?", correctAnswer: 6, decoys: [2, 4, 8, 10, 12]),
                notebookSummary: "6 pivot joints per wing: bronze bearings + leather washers + grease channels. Bronze doesn't gall like iron. Smooth flapping.",
                visual: CardVisual(type: .crossSection, title: "Step 5: Bronze Pivots", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_mine_1",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "mine",
                title: "Step 5: Iron Cables",
                italianTitle: "Tensione del Filo di Ferro",
                icon: "line.diagonal",
                lessonText: "Thin iron wire connected the pedal mechanism to the wing tips — tension cables that transmitted the pilot's leg power. Leonardo calculated the wire diameter: too thin and it snaps, too thick and it's too heavy. His solution: drawn wire (pulled through dies to make it thinner and stronger). Work-hardened iron wire has twice the tensile strength of cast iron. The wire that's been squeezed hardest pulls the strongest.",
                keywords: [
                    KeywordPair(keyword: "Drawn wire", definition: "Pulled through dies — thinner and stronger"),
                    KeywordPair(keyword: "Work hardening", definition: "Drawing process doubles tensile strength"),
                    KeywordPair(keyword: "Tension cables", definition: "Connect pedals to wing tips"),
                    KeywordPair(keyword: "Diameter calculation", definition: "Balance between strength and weight"),
                ],
                activity: .multipleChoice(question: "Why is drawn wire stronger than cast iron?", options: ["Different alloy", "Work hardening from the drawing process", "Thicker cross-section", "Heat treatment after drawing"], correctIndex: 1),
                notebookSummary: "Iron wire drawn through dies: work hardening doubles tensile strength. Connects pedals to wings. Thinner + stronger = ideal cables.",
                visual: CardVisual(type: .crossSection, title: "Step 5: Iron Cables", values: [:], labels: [], steps: 3, caption: "")
            ),

            // ── FOREST (2 cards) ───────────────────────────────

            KnowledgeCard(
                id: "\(bid)_forest_poplar_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .forest, stationKey: "poplar",
                title: "Step 3: Wing Ribs",
                italianTitle: "Centine Alari Leggere",
                icon: "leaf.fill",
                lessonText: "Leonardo chose poplar for wing ribs — the structural skeleton inside each wing. Poplar is 40% lighter than oak and grows perfectly straight. Each rib was steam-bent to match the wing's airfoil curve. Steam bending: soak poplar in boiling water, clamp it around a form, let it dry. The fibers lock into the curve permanently. 20 ribs per wing, each 3 meters long and 2 cm thick. The skeleton of flight is poplar and steam.",
                keywords: [
                    KeywordPair(keyword: "Wing ribs", definition: "Structural skeleton inside the silk covering"),
                    KeywordPair(keyword: "Steam bending", definition: "Boiling water + clamping = permanent curve"),
                    KeywordPair(keyword: "20 ribs/wing", definition: "Number of poplar ribs per wing"),
                    KeywordPair(keyword: "40% lighter", definition: "Poplar vs oak weight advantage"),
                ],
                activity: .numberFishing(question: "How many ribs did each ornithopter wing have?", correctAnswer: 20, decoys: [5, 10, 15, 30, 40]),
                notebookSummary: "Wing ribs: poplar (40% lighter than oak). Steam-bent to airfoil curve. 20 ribs per wing, 3m × 2cm each. Skeleton of flight.",
                visual: CardVisual(type: .crossSection, title: "Step 3: Wing Ribs", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_forest_oak_0",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .forest, stationKey: "oak",
                title: "Step 4: Oak Harness",
                italianTitle: "Telaio dell'Imbracatura",
                icon: "figure.walk",
                lessonText: "The pilot's harness was oak — the only part that needed maximum strength. A cradle-like frame held the pilot face-down with leather straps. Oak carried the combined forces: the pilot's 70 kg weight pulling down, the wings' 200 kg of lift pulling up, and torsion from pedaling. The harness was the machine's weakest link — if it failed, everything failed. Leonardo reinforced joints with iron brackets. The frame that holds the human holds the dream.",
                keywords: [
                    KeywordPair(keyword: "Oak harness", definition: "Strongest wood for the pilot's frame"),
                    KeywordPair(keyword: "Face-down position", definition: "Pilot lies prone in a cradle"),
                    KeywordPair(keyword: "Combined forces", definition: "Weight down + lift up + torsion from pedaling"),
                    KeywordPair(keyword: "Iron brackets", definition: "Reinforcement at critical harness joints"),
                ],
                activity: .wordScramble(word: "HARNESS", hint: "Oak frame that holds the ornithopter pilot face-down"),
                notebookSummary: "Harness: oak cradle, pilot face-down. Bears weight + lift + torsion. Iron brackets reinforce joints. Weakest link determines everything.",
                visual: CardVisual(type: .crossSection, title: "Step 4: Oak Harness", values: [:], labels: [], steps: 3, caption: "")
            ),

            // ── CRAFTING ROOM (1 card) ─────────────────────────

            KnowledgeCard(
                id: "\(bid)_craftingRoom_workbench_0",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .craftingRoom, stationKey: "workbench",
                title: "Step 3: Silk Assembly",
                italianTitle: "Assemblaggio Seta su Centine",
                icon: "rectangle.grid.1x2.fill",
                lessonText: "Attaching silk to wing ribs required tension and precision. The silk was cut to shape, soaked in warm water to shrink, then stretched over the ribs and secured with waxed linen thread through pre-drilled holes. As the silk dried, it contracted — pulling drum-tight. Then a coat of linseed oil sealed every pore. The process took 3 days per wing. Wet, stretch, dry, seal. Simple steps, in the right order, create an airfoil.",
                keywords: [
                    KeywordPair(keyword: "Wet stretch", definition: "Silk soaked then dried on frame = drum-tight"),
                    KeywordPair(keyword: "Waxed thread", definition: "Waterproof stitching through pre-drilled holes"),
                    KeywordPair(keyword: "3 days/wing", definition: "Assembly time including drying"),
                    KeywordPair(keyword: "Linseed seal", definition: "Final coat making the wing airtight"),
                ],
                activity: .fillInBlanks(text: "Wing assembly: cut silk, soak in ___ water, stretch, ___ thread through holes, dry, seal with ___", blanks: ["warm", "waxed", "linseed"], distractors: ["cold", "cotton", "pine"]),
                notebookSummary: "Silk wing assembly: soak → stretch on ribs → waxed thread → dry (contracts drum-tight) → linseed oil seal. 3 days per wing.",
                visual: CardVisual(type: .crossSection, title: "Step 3: Silk Assembly", values: [:], labels: [], steps: 3, caption: "")
            ),
        ]
    }

    // MARK: - Vatican Observatory (13 cards)

    static var vaticanObservatoryCards: [KnowledgeCard] {
        let bid = 16
        let name = "Vatican Observatory"
        return [
            // ── CITY MAP (5 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_cityMap_building_0",
                buildingId: bid, buildingName: name,
                science: .astronomy,
                environment: .cityMap, stationKey: "building",
                title: "Galileo's Revolution",
                italianTitle: "La Rivoluzione di Galileo",
                icon: "moon.stars.fill",
                lessonText: "In 1610, Galileo pointed a telescope at Jupiter and saw four moons — proof that not everything orbited Earth. The Church resisted: a Sun-centered universe contradicted scripture. Galileo was tried, convicted, and spent his last years under house arrest. But the Vatican eventually built its own observatory, accepting what the telescope revealed. Truth delayed is still truth. Galileo proved that seeing changes believing.",
                keywords: [
                    KeywordPair(keyword: "1610", definition: "Year Galileo discovered Jupiter's moons"),
                    KeywordPair(keyword: "Four moons", definition: "Io, Europa, Ganymede, Callisto"),
                    KeywordPair(keyword: "House arrest", definition: "Galileo's punishment for supporting heliocentrism"),
                    KeywordPair(keyword: "Vatican Observatory", definition: "Church eventually embraced astronomy"),
                ],
                activity: .numberFishing(question: "In what year did Galileo discover Jupiter's moons?", correctAnswer: 1610, decoys: [1543, 1580, 1632, 1680, 1700]),
                notebookSummary: "1610: Galileo saw 4 Jupiter moons — proof of heliocentrism. Church resisted, convicted him. Vatican eventually built its own observatory.",
                visual: CardVisual(type: .crossSection, title: "Galileo's Revolution", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_1",
                buildingId: bid, buildingName: name,
                science: .optics,
                environment: .cityMap, stationKey: "building",
                title: "Step 3: Lens Grinding",
                italianTitle: "Lavorazione delle Lenti",
                icon: "circle.dashed",
                lessonText: "Galileo's telescope used two lenses: a convex objective (bends light inward) and a concave eyepiece (spreads it back to the eye). The objective was ground to a parabolic curve — spherical lenses distort the edges. Grinding: rough-shape glass with iron tools, then polish with progressively finer emery paste. Each lens took 2 weeks. Galileo ground over 100 lenses to find 2 that worked. Optics is 98% rejection.",
                keywords: [
                    KeywordPair(keyword: "Parabolic curve", definition: "Lens shape that focuses without edge distortion"),
                    KeywordPair(keyword: "Convex objective", definition: "Front lens that bends light inward"),
                    KeywordPair(keyword: "Concave eyepiece", definition: "Back lens that spreads light to the eye"),
                    KeywordPair(keyword: "100 lenses → 2", definition: "Galileo's rejection rate for quality optics"),
                ],
                activity: .trueFalse(statement: "Galileo ground over 100 lenses to find just 2 that worked properly", isTrue: true),
                notebookSummary: "Telescope: convex objective + concave eyepiece. Parabolic grinding. 2 weeks per lens. 100 ground, 2 used. Optics = 98% rejection.",
                visual: CardVisual(type: .crossSection, title: "Step 3: Lens Grinding", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_2",
                buildingId: bid, buildingName: name,
                science: .astronomy,
                environment: .cityMap, stationKey: "building",
                title: "Step 5: Meridian Line",
                italianTitle: "La Linea Meridiana",
                icon: "line.diagonal",
                lessonText: "A meridian line is a metal strip set into a cathedral floor, running exactly north-south. A small hole in the roof projects a dot of sunlight onto the floor. As Earth rotates, the dot crosses the line at solar noon. As seasons change, the dot travels along the line — farthest north in winter, farthest south in summer. The line becomes a calendar, clock, and proof that Earth tilts 23.5°. A strip of brass that measures the universe.",
                keywords: [
                    KeywordPair(keyword: "Meridian line", definition: "North-south metal strip measuring solar position"),
                    KeywordPair(keyword: "Solar noon", definition: "Sun dot crosses the line at local midday"),
                    KeywordPair(keyword: "23.5°", definition: "Earth's axial tilt — measured by the line"),
                    KeywordPair(keyword: "Gnomonic hole", definition: "Opening in the roof projecting sunlight"),
                ],
                activity: .numberFishing(question: "What is Earth's axial tilt in degrees, measured by meridian lines?", correctAnswer: 23, decoys: [10, 15, 30, 35, 45]),
                notebookSummary: "Meridian line: brass strip N-S on floor. Sun through roof hole = dot that marks noon, seasons, and Earth's 23.5° tilt. Brass measures universe.",
                visual: CardVisual(type: .crossSection, title: "Step 5: Meridian Line", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_3",
                buildingId: bid, buildingName: name,
                science: .physics,
                environment: .cityMap, stationKey: "building",
                title: "Step 6: Pendulum Clock",
                italianTitle: "Orologio a Pendolo",
                icon: "clock.fill",
                lessonText: "Galileo discovered that a pendulum's swing period depends ONLY on its length — not the weight or arc width. A 1-meter pendulum swings once per second. This isochronism made precise timekeeping possible. Astronomers needed accurate clocks to measure star positions. Christiaan Huygens built the first pendulum clock in 1656, based on Galileo's principle. The universe runs on time. Measuring time runs on a weight and a string.",
                keywords: [
                    KeywordPair(keyword: "Isochronism", definition: "Swing period depends only on pendulum length"),
                    KeywordPair(keyword: "1-meter pendulum", definition: "Swings once per second"),
                    KeywordPair(keyword: "Huygens 1656", definition: "Built first pendulum clock"),
                    KeywordPair(keyword: "Star positions", definition: "Required accurate time measurement"),
                ],
                activity: .wordScramble(word: "PENDULUM", hint: "Its swing period depends only on length — Galileo's timekeeping discovery"),
                notebookSummary: "Pendulum isochronism: period depends only on length. 1m = 1 second. Huygens built first clock (1656). Time measurement enabled astronomy.",
                visual: CardVisual(type: .crossSection, title: "Step 6: Pendulum Clock", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_4",
                buildingId: bid, buildingName: name,
                science: .astronomy,
                environment: .cityMap, stationKey: "building",
                title: "Step 8: First Discovery",
                italianTitle: "Le Quattro Lune di Giove",
                icon: "sparkles",
                lessonText: "Galileo named them the Medicean stars (for his patron). We call them the Galilean moons: Io (volcanic), Europa (ice ocean), Ganymede (largest moon in the solar system), and Callisto (cratered). Their orbits proved that moons orbit planets, not just Earth. Galileo tracked their positions nightly for months, creating the first orbital tables. Systematic observation beat philosophical argument. Data defeats dogma.",
                keywords: [
                    KeywordPair(keyword: "Galilean moons", definition: "Io, Europa, Ganymede, Callisto"),
                    KeywordPair(keyword: "Medicean stars", definition: "Galileo's original name for Jupiter's moons"),
                    KeywordPair(keyword: "Ganymede", definition: "Largest moon in the solar system"),
                    KeywordPair(keyword: "Orbital tables", definition: "Nightly position tracking — first systematic data"),
                ],
                activity: .hangman(word: "GANYMEDE", hint: "Largest moon in the solar system — one of Galileo's 4 Jovian discoveries"),
                notebookSummary: "4 Galilean moons: Io, Europa, Ganymede (largest), Callisto. Orbits proved moons orbit planets. Systematic data defeated dogma.",
                visual: CardVisual(type: .crossSection, title: "Step 8: First Discovery", values: [:], labels: [], steps: 3, caption: "")
            ),

            // ── WORKSHOP (4 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_workshop_mine_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "mine",
                title: "Step 2: Lead Dome",
                italianTitle: "Copertura a Piombo della Cupola",
                icon: "shield.lefthalf.filled",
                lessonText: "Observatory domes were clad in lead sheeting — the same technique used on the Pantheon. Lead is malleable (hammered into shape), waterproof, and expands/contracts with temperature without cracking. Each sheet overlapped the next by 5 cm, sealed with molten lead solder. A dome needs to rotate smoothly on its track — lead's weight (11.3 g/cm³) actually helps by providing momentum. The heaviest roof is the one that turns easiest.",
                keywords: [
                    KeywordPair(keyword: "Lead cladding", definition: "Waterproof, malleable dome covering"),
                    KeywordPair(keyword: "5 cm overlap", definition: "Sheet overlap sealed with lead solder"),
                    KeywordPair(keyword: "11.3 g/cm³", definition: "Lead's density — provides rotational momentum"),
                    KeywordPair(keyword: "Rotating dome", definition: "Heavy lead helps maintain smooth rotation"),
                ],
                activity: .numberFishing(question: "What is lead's density in g/cm³?", correctAnswer: 11, decoys: [3, 5, 8, 15, 20]),
                notebookSummary: "Observatory dome: lead sheets (11.3 g/cm³). 5cm overlap + solder. Waterproof, flexible, and heavy = smooth rotation on track.",
                visual: CardVisual(type: .crossSection, title: "Step 2: Lead Dome", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_quarry_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "quarry",
                title: "Step 5: Marble Floor",
                italianTitle: "Linea Meridiana in Marmo",
                icon: "mountain.2.fill",
                lessonText: "The meridian line required the flattest possible surface — any dip causes the sun dot to wander. White Carrara marble was planed to within 0.5 mm tolerance using iron straightedges and stone-cutting saws. The brass line was inlaid into a groove cut with a chisel exactly 2 mm wide. Marble's thermal expansion is tiny: 0.006 mm per °C per meter. The floor barely breathes. Precision on this scale turns a floor into a scientific instrument.",
                keywords: [
                    KeywordPair(keyword: "0.5 mm tolerance", definition: "Maximum surface deviation allowed"),
                    KeywordPair(keyword: "2 mm groove", definition: "Width of the brass inlay channel"),
                    KeywordPair(keyword: "0.006 mm/°C/m", definition: "Marble's tiny thermal expansion"),
                    KeywordPair(keyword: "Carrara marble", definition: "Whitest, flattest stone available"),
                ],
                activity: .trueFalse(statement: "Marble was used for meridian lines because its thermal expansion is only 0.006 mm per °C per meter", isTrue: true),
                notebookSummary: "Meridian: Carrara marble planed to 0.5mm tolerance. Brass inlaid in 2mm groove. Marble expands just 0.006mm/°C/m. Floor = instrument.",
                visual: CardVisual(type: .crossSection, title: "Step 5: Marble Floor", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_river_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .workshop, stationKey: "river",
                title: "Step 3: Pure Glass",
                italianTitle: "Vetro Puro per Lenti",
                icon: "drop.triangle.fill",
                lessonText: "Telescope lenses required the purest glass available — any bubbles, streaks, or color distort the image. Venetian cristallo came closest: triple-filtered sand, soda ash from dried seagrass (barilla), and pure seashell lime. The glass was stirred continuously for 24 hours at 1,100°C to remove bubbles. Then cooled over 5 days. From a 10 kg batch, only 200 grams yielded lens-quality blanks. 2% yield. The clearest glass comes from the most rejected batches.",
                keywords: [
                    KeywordPair(keyword: "Cristallo", definition: "Venetian clear glass — purest available"),
                    KeywordPair(keyword: "2% yield", definition: "Only 200g lens-quality from 10 kg batch"),
                    KeywordPair(keyword: "24-hour stir", definition: "Continuous stirring to remove bubbles"),
                    KeywordPair(keyword: "5-day cooling", definition: "Slow annealing for optical quality"),
                ],
                activity: .numberFishing(question: "What percentage of a glass batch yielded lens-quality blanks?", correctAnswer: 2, decoys: [10, 20, 30, 50, 75]),
                notebookSummary: "Lens glass: cristallo, 24hr stirring, 5-day cooling. 10 kg batch → 200g usable (2% yield). Clearest glass = most rejected.",
                visual: CardVisual(type: .crossSection, title: "Step 3: Pure Glass", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_market_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "market",
                title: "Step 2: Ultramarine Fresco",
                italianTitle: "Lapislazzuli dall'Afghanistan",
                icon: "diamond.fill",
                lessonText: "Lapis lazuli — the only source of true blue pigment (ultramarine) — came from the Sar-i Sang mines in Afghanistan, 6,000 km from Rome. Traded through Persia, Egypt, and Venice. It cost more per gram than gold. Observatory ceilings painted ultramarine blue represented the night sky. The extraction process was complex: crush, mix with wax and lye, knead for weeks. The world's most expensive color required the world's longest supply chain.",
                keywords: [
                    KeywordPair(keyword: "Lapis lazuli", definition: "Blue stone from Afghanistan — source of ultramarine"),
                    KeywordPair(keyword: "Sar-i Sang", definition: "Afghan mines — only major lapis source"),
                    KeywordPair(keyword: "6,000 km", definition: "Distance from Afghanistan to Rome"),
                    KeywordPair(keyword: "More than gold", definition: "Ultramarine's cost per gram"),
                ],
                activity: .wordScramble(word: "ULTRAMARINE", hint: "Blue pigment from lapis lazuli — more expensive than gold"),
                notebookSummary: "Lapis lazuli from Afghanistan (Sar-i Sang, 6,000 km). Costlier than gold. Crush + wax + lye + weeks of kneading = ultramarine.",
                visual: CardVisual(type: .crossSection, title: "Step 2: Ultramarine Fresco", values: [:], labels: [], steps: 3, caption: "")
            ),

            // ── CRAFTING ROOM (4 cards) ────────────────────────

            KnowledgeCard(
                id: "\(bid)_craftingRoom_workbench_0",
                buildingId: bid, buildingName: name,
                science: .optics,
                environment: .craftingRoom, stationKey: "workbench",
                title: "Step 4: Telescope Tube",
                italianTitle: "Assemblaggio del Telescopio",
                icon: "scope",
                lessonText: "Galileo's telescope was simple: two lenses in a lead tube. The objective lens (convex, ~4 cm diameter) sat at the far end. The eyepiece (concave, ~2 cm) sat near the eye. The tube length determined magnification: 20× for his best model. Alignment was critical — the two lenses' centers had to match within 0.1 mm. Galileo wrapped the lenses in leather shims and slid them into the tube. Two pieces of glass, perfectly aligned, revealed the universe.",
                keywords: [
                    KeywordPair(keyword: "20× magnification", definition: "Galileo's best telescope power"),
                    KeywordPair(keyword: "0.1 mm alignment", definition: "Maximum error between lens centers"),
                    KeywordPair(keyword: "Lead tube", definition: "Housing for the two lenses"),
                    KeywordPair(keyword: "Leather shims", definition: "Wrapped around lenses for precise fit"),
                ],
                activity: .numberFishing(question: "What magnification did Galileo's best telescope achieve?", correctAnswer: 20, decoys: [5, 10, 50, 100, 200]),
                notebookSummary: "Telescope: convex objective + concave eyepiece in lead tube. 20× magnification. Alignment within 0.1mm. Two lenses revealed the universe.",
                visual: CardVisual(type: .crossSection, title: "Step 4: Telescope Tube", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_craftingRoom_furnace_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .craftingRoom, stationKey: "furnace",
                title: "Step 4: Lead Tube",
                italianTitle: "Fusione del Piombo a 327°C",
                icon: "flame.circle.fill",
                lessonText: "The telescope tube was cast lead — poured around a wooden mandrel (cylinder form). Lead melts at 327°C, cools in 15 minutes, and machines easily with hand tools. After removing the mandrel, the inside was reamed smooth with an iron tool. The tube had to be perfectly cylindrical — any oval squeezes the lenses out of alignment. Lead was also used for the dome rotation track. The observatory ran on the lowest-melting metal.",
                keywords: [
                    KeywordPair(keyword: "327°C", definition: "Lead melting point — low and workable"),
                    KeywordPair(keyword: "Mandrel", definition: "Wooden cylinder used as tube mold"),
                    KeywordPair(keyword: "Reaming", definition: "Iron tool smoothing the tube interior"),
                    KeywordPair(keyword: "Cylindrical precision", definition: "Oval tube misaligns the lenses"),
                ],
                activity: .fillInBlanks(text: "Lead tube: pour at ___°C around a wooden ___, cool ___ minutes, ream smooth", blanks: ["327", "mandrel", "15"], distractors: ["450", "cylinder", "60"]),
                notebookSummary: "Telescope tube: lead poured at 327°C around wooden mandrel. Cool 15 min. Ream smooth inside. Must be perfectly cylindrical.",
                visual: CardVisual(type: .crossSection, title: "Step 4: Lead Tube", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_craftingRoom_pigmentTable_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .craftingRoom, stationKey: "pigmentTable",
                title: "Step 2: Grind Ultramarine",
                italianTitle: "Macinazione del Lapislazzuli",
                icon: "paintpalette.fill",
                lessonText: "Extracting blue from lapis lazuli is alchemy-grade chemistry. Crush the stone to powder. Mix with melted pine resin, beeswax, and lye. Knead for 3 weeks. The blue lazurite particles migrate into the lye while impurities stay in the wax. Strain, dry, grind. The first extraction is the deepest blue (Fra Angelico grade). The second is paler. The third is grey. One stone yields 3 qualities of blue. Patience and chemistry, inseparable.",
                keywords: [
                    KeywordPair(keyword: "Lazurite", definition: "Blue mineral inside lapis lazuli"),
                    KeywordPair(keyword: "3-week kneading", definition: "Pine resin + wax + lye separates blue"),
                    KeywordPair(keyword: "Fra Angelico grade", definition: "First extraction — deepest, most expensive blue"),
                    KeywordPair(keyword: "3 extractions", definition: "Deep blue → pale → grey from one stone"),
                ],
                activity: .numberFishing(question: "How many weeks of kneading to extract ultramarine from lapis?", correctAnswer: 3, decoys: [1, 2, 5, 8, 12]),
                notebookSummary: "Ultramarine extraction: crush lapis + pine resin + wax + lye. Knead 3 weeks. 3 extractions: deep blue → pale → grey.",
                visual: CardVisual(type: .crossSection, title: "Step 2: Grind Ultramarine", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_craftingRoom_shelf_0",
                buildingId: bid, buildingName: name,
                science: .astronomy,
                environment: .craftingRoom, stationKey: "shelf",
                title: "Step 7: Star Charts",
                italianTitle: "Carte Stellari e Declinazione",
                icon: "star.fill",
                lessonText: "Astronomers recorded star positions using two coordinates: right ascension (east-west, measured in hours) and declination (north-south, measured in degrees from the celestial equator). Each observation was logged with date, time, instrument used, and weather. Tycho Brahe's catalog of 1,000 stars — accurate to 1 arcminute — was the gold standard. Astronomers don't discover with telescopes. They discover with records. The notebook is the real instrument.",
                keywords: [
                    KeywordPair(keyword: "Right ascension", definition: "East-west coordinate measured in hours"),
                    KeywordPair(keyword: "Declination", definition: "North-south coordinate in degrees"),
                    KeywordPair(keyword: "1 arcminute", definition: "Tycho Brahe's star position accuracy"),
                    KeywordPair(keyword: "Tycho Brahe", definition: "Cataloged 1,000 stars before telescopes existed"),
                ],
                activity: .hangman(word: "DECLINATION", hint: "North-south coordinate for star positions, measured in degrees"),
                notebookSummary: "Star coordinates: right ascension (hours, east-west) + declination (degrees, north-south). Tycho's 1,000-star catalog: 1 arcminute accuracy.",
                visual: CardVisual(type: .crossSection, title: "Step 7: Star Charts", values: [:], labels: [], steps: 3, caption: "")
            ),
        ]
    }

    // MARK: - Printing Press (12 cards)

    static var printingPressCards: [KnowledgeCard] {
        let bid = 17
        let name = "Printing Press"
        return [
            // ── CITY MAP (5 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_cityMap_building_0",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .cityMap, stationKey: "building",
                title: "Gutenberg's Revolution",
                italianTitle: "La Rivoluzione di Gutenberg",
                icon: "book.fill",
                lessonText: "Before Gutenberg, a monk copied one Bible in 2 years. After Gutenberg: 180 Bibles in 3 years. His press arrived in Italy in 1465. By 1500, Venice alone had 150 print shops producing 4,000 titles. Knowledge that took a lifetime to copy could now reach thousands in weeks. The printing press didn't create new knowledge. It made existing knowledge impossible to destroy. Copies are survival.",
                keywords: [
                    KeywordPair(keyword: "Gutenberg", definition: "Invented moveable type printing (~1440)"),
                    KeywordPair(keyword: "180 Bibles", definition: "Gutenberg's first print run in 3 years"),
                    KeywordPair(keyword: "150 shops", definition: "Venice's print shops by 1500"),
                    KeywordPair(keyword: "1465", definition: "Printing press arrived in Italy"),
                ],
                activity: .numberFishing(question: "How many print shops operated in Venice by 1500?", correctAnswer: 150, decoys: [20, 50, 75, 300, 500]),
                notebookSummary: "Gutenberg: 180 Bibles in 3 years (vs 1 per 2 years by hand). Italy 1465. Venice: 150 shops by 1500. Copies = survival.",
                visual: CardVisual(type: .crossSection, title: "Gutenberg's Revolution", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_1",
                buildingId: bid, buildingName: name,
                science: .physics,
                environment: .cityMap, stationKey: "building",
                title: "Step 1: Screw Press",
                italianTitle: "Coppia della Pressa a Vite",
                icon: "wrench.fill",
                lessonText: "Gutenberg adapted the wine/olive screw press for printing. A wooden screw converts rotational force into downward pressure. The mechanical advantage: a 10 cm handle radius and 2 mm thread pitch multiplies force by 314×. A printer pulling with 10 kg of force generates 3,140 kg on the platen — enough to transfer ink evenly across a full page. The press is a force multiplier. Physics turns a gentle pull into a perfect impression.",
                keywords: [
                    KeywordPair(keyword: "Screw press", definition: "Converts rotation into downward pressure"),
                    KeywordPair(keyword: "314× force", definition: "Mechanical advantage of the screw"),
                    KeywordPair(keyword: "Platen", definition: "Flat surface pressing paper against type"),
                    KeywordPair(keyword: "3,140 kg", definition: "Pressure on the page from 10 kg pull"),
                ],
                activity: .numberFishing(question: "How many times does the screw press multiply force?", correctAnswer: 314, decoys: [10, 50, 100, 500, 1000]),
                notebookSummary: "Screw press: 314× force multiplication. 10 kg pull → 3,140 kg on platen. Adapted from wine press. Gentle pull = perfect impression.",
                visual: CardVisual(type: .crossSection, title: "Step 1: Screw Press", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_2",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .cityMap, stationKey: "building",
                title: "Step 2: Type Metal",
                italianTitle: "Lega dei Caratteri Mobili",
                icon: "textformat",
                lessonText: "Gutenberg's genius wasn't the press — it was the type metal. He developed an alloy: 80% lead (low melting point), 15% antimony (hardens the lead), 5% tin (improves flow into molds). This alloy expands 1% on cooling — filling every detail of the letter mold. Modern type metal still uses essentially this recipe. The alloy that expands slightly when it freezes captures letters perfectly. A metal that grows makes knowledge grow.",
                keywords: [
                    KeywordPair(keyword: "Type metal", definition: "80% lead + 15% antimony + 5% tin"),
                    KeywordPair(keyword: "Antimony", definition: "Hardens the soft lead"),
                    KeywordPair(keyword: "1% expansion", definition: "Alloy grows on cooling — fills mold details"),
                    KeywordPair(keyword: "Tin", definition: "Improves molten metal flow into the mold"),
                ],
                activity: .fillInBlanks(text: "Type metal: ___% lead, ___% antimony, ___% tin — expands 1% on cooling", blanks: ["80", "15", "5"], distractors: ["60", "25", "10"]),
                notebookSummary: "Type metal: 80% Pb + 15% Sb + 5% Sn. Expands 1% on cooling → fills every mold detail. Recipe unchanged for 500 years.",
                visual: CardVisual(type: .crossSection, title: "Step 2: Type Metal", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_3",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .cityMap, stationKey: "building",
                title: "Step 4: Oil-Based Ink",
                italianTitle: "Inchiostro a Base d'Olio",
                icon: "drop.fill",
                lessonText: "Water-based ink beads off metal type. Gutenberg invented oil-based printing ink: lampblack (carbon soot) suspended in linseed oil with a touch of turpentine. The oil clings to metal type faces, transfers cleanly to damp paper, and dries by oxidation (not evaporation). It doesn't smear after printing. This was the second critical invention — without oil ink, moveable type is useless. The press gets the credit. The ink does the work.",
                keywords: [
                    KeywordPair(keyword: "Lampblack", definition: "Carbon soot — the pigment in black ink"),
                    KeywordPair(keyword: "Linseed oil", definition: "Binder that clings to metal type"),
                    KeywordPair(keyword: "Oxidation drying", definition: "Ink hardens by absorbing oxygen — doesn't smear"),
                    KeywordPair(keyword: "Oil-based", definition: "Sticks to metal (water-based beads off)"),
                ],
                activity: .multipleChoice(question: "Why did Gutenberg switch from water-based to oil-based ink?", options: ["Cheaper ingredients", "Water-based ink beads off metal type", "Oil ink is blacker", "Church preference"], correctIndex: 1),
                notebookSummary: "Oil-based ink: lampblack + linseed oil + turpentine. Clings to metal type, dries by oxidation (no smearing). Press gets credit, ink does work.",
                visual: CardVisual(type: .crossSection, title: "Step 4: Oil-Based Ink", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_4",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .cityMap, stationKey: "building",
                title: "Step 7: Compose a Page",
                italianTitle: "Velocità del Compositore",
                icon: "character.cursor.ibeam",
                lessonText: "A skilled compositor picked individual type pieces from a case and arranged them into a page — backward and mirrored. Speed: 1,500 characters per hour. A Bible page has ~2,500 characters. Two hours to set one page, but that page could print 500 copies in a day. Setting is slow; printing is fast. The bottleneck is always composition. The hardest part of spreading knowledge is arranging it — letter by letter, in mirror.",
                keywords: [
                    KeywordPair(keyword: "Compositor", definition: "Person who arranges type into pages"),
                    KeywordPair(keyword: "1,500 chars/hour", definition: "Speed of a skilled compositor"),
                    KeywordPair(keyword: "Backward + mirrored", definition: "Type must be set in reverse to print correctly"),
                    KeywordPair(keyword: "500 copies/day", definition: "Print output from one set page"),
                ],
                activity: .numberFishing(question: "How many characters per hour could a skilled compositor set?", correctAnswer: 1500, decoys: [200, 500, 800, 3000, 5000]),
                notebookSummary: "Compositor: 1,500 chars/hour, backward + mirrored. One page = 2 hours to set. Then 500 copies/day. Composition is the bottleneck.",
                visual: CardVisual(type: .crossSection, title: "Step 7: Compose a Page", values: [:], labels: [], steps: 3, caption: "")
            ),

            // ── WORKSHOP (3 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_workshop_mine_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .workshop, stationKey: "mine",
                title: "Step 2: Type Alloy",
                italianTitle: "Lega Piombo-Stagno-Antimonio",
                icon: "cube.fill",
                lessonText: "Mining provided the three metals for type: lead from galena ore, tin from cassiterite, antimony from stibnite. Each ore was smelted separately. Lead at 327°C, tin at 232°C, antimony at 630°C. Then combined in precise ratios. Too much lead = soft type that wears out. Too much antimony = brittle type that cracks. The alloy must be hard enough to survive 500 impressions but soft enough to melt and recast. Balance is everything.",
                keywords: [
                    KeywordPair(keyword: "Galena", definition: "Lead ore (PbS) — smelted at 327°C"),
                    KeywordPair(keyword: "Cassiterite", definition: "Tin ore (SnO₂) — smelted at 232°C"),
                    KeywordPair(keyword: "Stibnite", definition: "Antimony ore (Sb₂S₃) — smelted at 630°C"),
                    KeywordPair(keyword: "500 impressions", definition: "Minimum lifespan of a single type piece"),
                ],
                activity: .hangman(word: "ANTIMONY", hint: "Metal from stibnite ore — hardens lead in type alloy"),
                notebookSummary: "Type metals: lead (galena), tin (cassiterite), antimony (stibnite). Each smelted separately, combined precisely. 500 impressions per piece.",
                visual: CardVisual(type: .crossSection, title: "Step 2: Type Alloy", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_river_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "river",
                title: "Step 6: Dampen Paper",
                italianTitle: "Carta Umidificata",
                icon: "drop.triangle.fill",
                lessonText: "Paper goes through the press damp — not dry. Dampening softens the fibers so they absorb ink and conform to the type surface. Too wet: ink bleeds. Too dry: ink sits on top and smears. Renaissance printers dampened sheets between wet felts overnight. The ideal moisture: 20-25%. After printing, sheets hung on lines to dry — the printshop ceiling was a forest of drying pages. Wet paper receives. Dry paper keeps.",
                keywords: [
                    KeywordPair(keyword: "Dampened paper", definition: "20-25% moisture for optimal ink absorption"),
                    KeywordPair(keyword: "Wet felts", definition: "Sheets sandwiched overnight to dampen evenly"),
                    KeywordPair(keyword: "Ink bleeding", definition: "Problem when paper is too wet"),
                    KeywordPair(keyword: "Drying lines", definition: "Printed sheets hung from ceiling"),
                ],
                activity: .numberFishing(question: "What moisture percentage is ideal for printing paper?", correctAnswer: 25, decoys: [5, 10, 40, 60, 80]),
                notebookSummary: "Paper dampened to 20-25% moisture between wet felts overnight. Too wet = bleed. Too dry = smear. Sheets dry on ceiling lines.",
                visual: CardVisual(type: .crossSection, title: "Step 6: Dampen Paper", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_mine_1",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "mine",
                title: "Step 1: Iron Frame",
                italianTitle: "Telaio della Pressa in Ferro",
                icon: "rectangle.compress.vertical",
                lessonText: "The press frame must resist 3,000+ kg of force without flexing. Early frames were oak (like wine presses), but Italian printers upgraded to iron. A cast-iron frame weighed 200 kg and was rigid enough for even pressure across the entire platen. Uneven pressure = faded edges. The frame was bolted to the floor and ceiling. The rigidity of the frame determines the clarity of every letter on every page.",
                keywords: [
                    KeywordPair(keyword: "Cast-iron frame", definition: "200 kg frame replacing wooden structure"),
                    KeywordPair(keyword: "3,000+ kg", definition: "Force the frame must resist"),
                    KeywordPair(keyword: "Even pressure", definition: "Rigid frame prevents faded edges"),
                    KeywordPair(keyword: "Floor + ceiling bolts", definition: "Frame anchored to building structure"),
                ],
                activity: .trueFalse(statement: "Italian printers replaced wooden press frames with 200 kg cast-iron ones for rigidity", isTrue: true),
                notebookSummary: "Iron press frame: 200 kg, resists 3,000+ kg. Bolted to floor and ceiling. Rigidity = even pressure = clear print edge to edge.",
                visual: CardVisual(type: .crossSection, title: "Step 1: Iron Frame", values: [:], labels: [], steps: 3, caption: "")
            ),

            // ── FOREST (2 cards) ───────────────────────────────

            KnowledgeCard(
                id: "\(bid)_forest_oak_0",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .forest, stationKey: "oak",
                title: "Step 1: Oak Press",
                italianTitle: "Costruzione del Telaio",
                icon: "rectangle.portrait",
                lessonText: "The original Gutenberg press frame was oak — two massive uprights (15 cm × 15 cm) with a crossbeam carrying the screw. Oak was chosen for compression strength: the uprights absorb 1,500 kg each without crushing. The screw hole was lined with a bronze bushing for smooth rotation. Even after iron frames became standard, the screw itself often remained oak — it was cheaper to replace when the threads wore out.",
                keywords: [
                    KeywordPair(keyword: "15 × 15 cm", definition: "Cross-section of oak press uprights"),
                    KeywordPair(keyword: "1,500 kg each", definition: "Compression load per upright"),
                    KeywordPair(keyword: "Bronze bushing", definition: "Smooth-rotation lining for the screw hole"),
                    KeywordPair(keyword: "Replaceable screw", definition: "Oak screw cheaper to replace than iron"),
                ],
                activity: .numberFishing(question: "Compression load (kg) each oak upright carries?", correctAnswer: 1500, decoys: [500, 800, 2500, 4000, 6000]),
                notebookSummary: "Oak press: 15×15cm uprights, 1,500 kg each. Bronze bushing in screw hole. Oak screw cheaper to replace when worn.",
                visual: CardVisual(type: .crossSection, title: "Step 1: Oak Press", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_forest_walnut_0",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .forest, stationKey: "walnut",
                title: "Step 3: Type Cases",
                italianTitle: "Casse dei Caratteri",
                icon: "tray.2.fill",
                lessonText: "Type was stored in walnut cases — shallow trays divided into compartments, one per character. The compositor reached into compartments by muscle memory. Capitals were stored in the upper case (angled above). Lowercase letters in the lower case (flat on the desk). This is why we say 'uppercase' and 'lowercase' — the terms come from the physical position of walnut type trays. Language preserves the memory of wooden furniture.",
                keywords: [
                    KeywordPair(keyword: "Upper case", definition: "Top tray — capital letters stored here"),
                    KeywordPair(keyword: "Lower case", definition: "Bottom tray — small letters stored here"),
                    KeywordPair(keyword: "Type case", definition: "Walnut tray with compartments per character"),
                    KeywordPair(keyword: "Muscle memory", definition: "Compositor reaches by feel, not sight"),
                ],
                activity: .multipleChoice(question: "Where does the term 'uppercase' come from?", options: ["Font size terminology", "The physical position of capital letter trays", "Latin grammar rules", "Gutenberg's personal preference"], correctIndex: 1),
                notebookSummary: "Walnut type cases: upper case (capitals, top) + lower case (small letters, bottom). Terms survive in language. Furniture became vocabulary.",
                visual: CardVisual(type: .crossSection, title: "Step 3: Type Cases", values: [:], labels: [], steps: 3, caption: "")
            ),

            // ── CRAFTING ROOM (2 cards) ────────────────────────

            KnowledgeCard(
                id: "\(bid)_craftingRoom_workbench_0",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .craftingRoom, stationKey: "workbench",
                title: "Step 2: Punch to Matrix",
                italianTitle: "Punzone → Matrice → Carattere",
                icon: "square.grid.3x3.fill",
                lessonText: "Making type is a 3-step process. Step 1: a steel punch is hand-carved with a letter in relief (raised). Step 2: the punch is hammered into a copper bar — creating a matrix (the letter in reverse). Step 3: molten type metal is poured into the matrix — producing a type piece with the letter in relief again. One punch makes unlimited matrices. One matrix casts thousands of type pieces. Three steps from unique to infinite.",
                keywords: [
                    KeywordPair(keyword: "Punch", definition: "Steel tool with letter carved in relief"),
                    KeywordPair(keyword: "Matrix", definition: "Copper mold struck from the punch"),
                    KeywordPair(keyword: "Type piece", definition: "Cast metal letter for the printing press"),
                    KeywordPair(keyword: "3-step process", definition: "Punch → matrix → type — unique to infinite"),
                ],
                activity: .wordScramble(word: "MATRIX", hint: "Copper mold struck from a steel punch — used to cast thousands of type pieces"),
                notebookSummary: "Punch (steel, relief) → Matrix (copper, reverse) → Type (metal, relief). 1 punch → ∞ matrices → ∞ type. Three steps to infinity.",
                visual: CardVisual(type: .crossSection, title: "Step 2: Punch to Matrix", values: [:], labels: [], steps: 3, caption: "")
            ),

            KnowledgeCard(
                id: "\(bid)_craftingRoom_furnace_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .craftingRoom, stationKey: "furnace",
                title: "Step 2: Cast Type",
                italianTitle: "Metallo dei Caratteri a 240°C",
                icon: "flame.circle.fill",
                lessonText: "Type metal melts at 240°C — low enough for a small charcoal furnace. The caster ladles molten alloy into a hand mold containing the copper matrix. Cool for 10 seconds. Open the mold. A perfect letter, mirror-reversed, with a 1% expansion that fills every serif. A skilled caster produced 4,000 type pieces per day. Each one identical. The letter 'e' cast at dawn is indistinguishable from the 'e' cast at dusk. Uniformity is the point.",
                keywords: [
                    KeywordPair(keyword: "240°C", definition: "Melting point of type metal alloy"),
                    KeywordPair(keyword: "10 seconds", definition: "Cooling time per type piece"),
                    KeywordPair(keyword: "4,000/day", definition: "Output of a skilled type caster"),
                    KeywordPair(keyword: "Mirror-reversed", definition: "Type reads backward — prints forward"),
                ],
                activity: .numberFishing(question: "How many type pieces could a skilled caster produce per day?", correctAnswer: 4000, decoys: [500, 1000, 2000, 6000, 10000]),
                notebookSummary: "Type metal: 240°C, 10-second cooling. 1% expansion fills every serif. 4,000 pieces/day. Every letter identical. Uniformity = the point.",
                visual: CardVisual(type: .crossSection, title: "Step 2: Cast Type", values: [:], labels: [], steps: 3, caption: "")
            ),
        ]
    }
}
