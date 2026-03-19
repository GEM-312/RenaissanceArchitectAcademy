import Foundation

/// A curated architectural sketch from the Metropolitan Museum of Art (Open Access API)
struct MuseumSketch: Identifiable {
    let id: Int                 // Met object ID
    let title: String
    let artist: String
    let date: String
    let medium: String
    let imageURL: String        // primaryImage from Met API
    let buildingName: String    // Maps to Building.name
    let studyPrompt: String     // Bird asks this after viewing
    let featureToFind: String   // What the player should tap/identify
    let featureHint: String     // Hint if they can't find it
}

/// Interactive feature the player identifies on the sketch
struct SketchFeature: Identifiable {
    let id = UUID()
    let name: String
    let normalizedPosition: CGPoint  // 0-1 range within image
    let radius: CGFloat              // Tap target radius (normalized)
    let description: String          // Shown after correct tap
}

/// Curated Met Museum sketches for all 17 buildings
/// All are public domain with confirmed image URLs
enum MuseumSketchContent {

    static func sketches(for buildingName: String) -> [MuseumSketch] {
        switch buildingName {

        // ── Ancient Rome ──────────────────────────────────

        case "Aqueduct":
            return [
                MuseumSketch(
                    id: 728104,
                    title: "The Bridge of the Gard (Pont du Gard)",
                    artist: "Jacques Androuet Du Cerceau",
                    date: "1545",
                    medium: "Etching",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP-16967-001.jpg",
                    buildingName: "Aqueduct",
                    studyPrompt: "Count the arches! Why do you think they used three tiers instead of one tall one?",
                    featureToFind: "The three tiers of arches",
                    featureHint: "Look at how the arches stack — small ones on top carry the water channel"
                ),
                MuseumSketch(
                    id: 364593,
                    title: "The Fontana dell'Aqua Giulia",
                    artist: "Giovanni Battista Piranesi",
                    date: "ca. 1753",
                    medium: "Etching",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP828288.jpg",
                    buildingName: "Aqueduct",
                    studyPrompt: "Piranesi drew the ruins of the Aqua Julia. What happened to the top water channel?",
                    featureToFind: "The broken water channel at the top",
                    featureHint: "The top of the structure is crumbling — centuries of wear"
                ),
                MuseumSketch(
                    id: 363938,
                    title: "Ruins from the Caelius Aqueduct and Temple of Claudius",
                    artist: "Giovanni Battista Naldini",
                    date: "ca. 1557",
                    medium: "Red chalk and brown ink",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP810760.jpg",
                    buildingName: "Aqueduct",
                    studyPrompt: "This Renaissance artist sketched these ruins by hand. What drawing tool did he use?",
                    featureToFind: "The red chalk and ink medium",
                    featureHint: "Notice the warm red tones — that's red chalk, a favorite of Renaissance draftsmen"
                ),
            ]

        case "Colosseum":
            return [
                MuseumSketch(
                    id: 400018,
                    title: "Section and Elevation of the Colosseum in Rome",
                    artist: "Giovanni Ambrogio Brambilla",
                    date: "1581",
                    medium: "Etching",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP847229.jpg",
                    buildingName: "Colosseum",
                    studyPrompt: "This is a cross-section — like cutting a cake in half. Can you see the different levels of seating?",
                    featureToFind: "The tiered seating levels",
                    featureHint: "Look inside the cut — the seats rise from the arena floor in steep rows"
                ),
                MuseumSketch(
                    id: 403241,
                    title: "Interior Reconstruction of the Colosseum",
                    artist: "Anonymous, from Speculum Romanae Magnificentiae",
                    date: "16th century",
                    medium: "Engraving",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP870389.jpg",
                    buildingName: "Colosseum",
                    studyPrompt: "This shows what the Colosseum looked like when it was NEW. What covered the top?",
                    featureToFind: "The velarium (canvas sunshade)",
                    featureHint: "Look at the very top — poles and ropes held a massive canvas to shade 50,000 spectators"
                ),
                MuseumSketch(
                    id: 360270,
                    title: "Veduta dell'Anfiteatro Flavio detto il Colosseo",
                    artist: "Giovanni Battista Piranesi",
                    date: "1776",
                    medium: "Etching",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP104275.jpg",
                    buildingName: "Colosseum",
                    studyPrompt: "Piranesi drew the Colosseum as a ruin. Can you count the three types of columns on the outside?",
                    featureToFind: "The three orders: Doric, Ionic, Corinthian columns",
                    featureHint: "Each level has a different column style — plain at bottom, ornate at top"
                ),
            ]

        case "Roman Baths":
            return [
                MuseumSketch(
                    id: 403393,
                    title: "Baths of Agrippa, from Speculum Romanae Magnificentiae",
                    artist: "Giovanni Ambrogio Brambilla",
                    date: "1583",
                    medium: "Engraving",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP870454.jpg",
                    buildingName: "Roman Baths",
                    studyPrompt: "This is a bird's-eye floor plan. Can you find the large central bathing hall?",
                    featureToFind: "The central natatio (swimming pool)",
                    featureHint: "The largest room in the center — that's where Romans swam"
                ),
                MuseumSketch(
                    id: 339683,
                    title: "The Octagonal Room in the Small Baths at Villa of Hadrian",
                    artist: "Giovanni Battista Piranesi",
                    date: "ca. 1777",
                    medium: "Etching",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP820562.jpg",
                    buildingName: "Roman Baths",
                    studyPrompt: "This room has eight sides — an octagon. Why would architects choose this shape for a bath?",
                    featureToFind: "The octagonal vault structure",
                    featureHint: "The eight-sided shape distributes the dome's weight evenly to the walls"
                ),
                MuseumSketch(
                    id: 362673,
                    title: "Plan Designed After Ancient Gymnasia and Roman Baths",
                    artist: "Giovanni Battista Piranesi",
                    date: "1750",
                    medium: "Etching",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP828198.jpg",
                    buildingName: "Roman Baths",
                    studyPrompt: "Piranesi designed this plan INSPIRED by Roman baths. Can you see the symmetry?",
                    featureToFind: "The symmetrical layout (left mirrors right)",
                    featureHint: "Fold this plan in half — both sides match perfectly"
                ),
            ]

        case "Pantheon":
            return [
                MuseumSketch(
                    id: 399993,
                    title: "Reconstruction of the Pantheon, Cut Away to Reveal the Interior",
                    artist: "Anonymous",
                    date: "1553",
                    medium: "Engraving",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP847231.jpg",
                    buildingName: "Pantheon",
                    studyPrompt: "This cutaway shows the Pantheon sliced open. Can you find the oculus — the hole at the top of the dome?",
                    featureToFind: "The oculus (open hole at dome's apex)",
                    featureHint: "Look at the very top of the dome — there's no glass, just an open circle to the sky"
                ),
                MuseumSketch(
                    id: 362562,
                    title: "Pantheon, Portico Column Capital, Projection, Plan, and Details",
                    artist: "Anonymous French architect",
                    date: "Early 16th century",
                    medium: "Dark brown ink, black chalk, incised lines",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP247625.jpg",
                    buildingName: "Pantheon",
                    studyPrompt: "A real architect measured these columns by hand in Rome! Can you see the measurements?",
                    featureToFind: "The measurement annotations and column details",
                    featureHint: "The tiny numbers and lines — Renaissance architects traveled to Rome to measure ancient buildings"
                ),
                MuseumSketch(
                    id: 348799,
                    title: "Veduta del Pantheon d'Agrippa (The Pantheon Exterior)",
                    artist: "Giovanni Battista Piranesi",
                    date: "ca. 1756",
                    medium: "Etching",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP828229.jpg",
                    buildingName: "Pantheon",
                    studyPrompt: "Count the columns on the portico. How many are there? The answer reveals a design secret.",
                    featureToFind: "The 16 Corinthian columns of the portico",
                    featureHint: "Eight across the front, plus eight behind — 16 columns hold up the entrance"
                ),
            ]

        case "Roman Roads":
            return [
                MuseumSketch(
                    id: 416047,
                    title: "View of the Stone Pavement of the Appian Way",
                    artist: "Giovanni Battista Piranesi",
                    date: "1756",
                    medium: "Etching",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP831895.jpg",
                    buildingName: "Roman Roads",
                    studyPrompt: "The Appian Way is 2,300 years old and STILL exists. What do you notice about the stone shapes?",
                    featureToFind: "The interlocking basalt paving stones",
                    featureHint: "The stones are irregular polygons — they lock together like a puzzle, spreading weight evenly"
                ),
                MuseumSketch(
                    id: 412428,
                    title: "Part of the Ancient Appian Way, Three Miles Outside Porta S. Sebastiano",
                    artist: "Giovanni Battista Piranesi",
                    date: "ca. 1748",
                    medium: "Etching",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP827964.jpg",
                    buildingName: "Roman Roads",
                    studyPrompt: "See the monuments along the road? Roman roads weren't just for travel — what else lined them?",
                    featureToFind: "The tombs and monuments lining the road",
                    featureHint: "Important Romans built their family tombs along major roads — to be remembered by travelers"
                ),
            ]

        case "Harbor":
            return [
                MuseumSketch(
                    id: 338737,
                    title: "Part of a Spacious and Magnificent Port in the Manner of the Ancient Romans",
                    artist: "Giovanni Battista Piranesi",
                    date: "ca. 1749-50",
                    medium: "Etching",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP828193.jpg",
                    buildingName: "Harbor",
                    studyPrompt: "Piranesi imagined an ideal Roman port. Can you find the lighthouse?",
                    featureToFind: "The lighthouse (pharos) tower",
                    featureHint: "The tall structure at the harbor entrance — it guided ships with fire at night"
                ),
                MuseumSketch(
                    id: 403938,
                    title: "Birdseye View of the Port of Rome",
                    artist: "Giulio de Musi",
                    date: "1554",
                    medium: "Engraving",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP-13033-001.jpg",
                    buildingName: "Harbor",
                    studyPrompt: "This bird's-eye view shows the entire port. Why is there a curved breakwater?",
                    featureToFind: "The curved breakwater protecting the harbor",
                    featureHint: "The curved wall blocks ocean waves — ships inside are protected from storms"
                ),
                MuseumSketch(
                    id: 403529,
                    title: "Port of Rome, from Speculum Romanae Magnificentiae",
                    artist: "Giovanni Ambrogio Brambilla",
                    date: "1581",
                    medium: "Engraving",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP870571.jpg",
                    buildingName: "Harbor",
                    studyPrompt: "This shows warehouses along the docks. What did Romans store in a port city?",
                    featureToFind: "The warehouse buildings along the waterfront",
                    featureHint: "Grain from Egypt, olive oil from Spain, marble from Greece — all stored here"
                ),
            ]

        case "Siege Workshop":
            return [
                MuseumSketch(
                    id: 358276,
                    title: "De Re Militari (On the Military Arts)",
                    artist: "Roberto Valturio",
                    date: "1472",
                    medium: "Woodcut illustrations in printed book",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP252991.jpg",
                    buildingName: "Siege Workshop",
                    studyPrompt: "This is from a 1472 military engineering manual. Can you identify the siege machine?",
                    featureToFind: "The siege engine mechanism",
                    featureHint: "Look for wheels, levers, and ropes — the same principles as modern cranes"
                ),
                MuseumSketch(
                    id: 387591,
                    title: "The Siege of a Fortress",
                    artist: "Albrecht Dürer",
                    date: "ca. 1500",
                    medium: "Woodcut",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP816479.jpg",
                    buildingName: "Siege Workshop",
                    studyPrompt: "Dürer shows a fortress under attack. What engineering principles make the walls strong?",
                    featureToFind: "The fortress walls and defensive towers",
                    featureHint: "Thick walls, round towers (resist battering rams), and high ground — all engineering"
                ),
                MuseumSketch(
                    id: 402607,
                    title: "Castrum (Roman Military Camp)",
                    artist: "Anonymous, from Speculum Romanae Magnificentiae",
                    date: "16th century",
                    medium: "Engraving",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP870086.jpg",
                    buildingName: "Siege Workshop",
                    studyPrompt: "This shows a Roman castrum — a military camp. Why is it perfectly rectangular?",
                    featureToFind: "The grid layout of the camp",
                    featureHint: "Romans could build this in ONE DAY because every soldier knew the standard layout"
                ),
            ]

        case "Insula":
            return [
                MuseumSketch(
                    id: 408021,
                    title: "Cross-Sections Showing Different Aspects of Buildings in Pompeii",
                    artist: "Francesco Piranesi",
                    date: "1804",
                    medium: "Etching and engraving",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP300528.jpg",
                    buildingName: "Insula",
                    studyPrompt: "These cross-sections show how Roman buildings were constructed. Can you count the floors?",
                    featureToFind: "The multi-story floor levels",
                    featureHint: "Roman insulae had up to 6 stories — the higher you lived, the cheaper (and more dangerous)"
                ),
                MuseumSketch(
                    id: 390215,
                    title: "Ruins with Arched Vaults, Roman Ruins and Buildings",
                    artist: "Johannes and Lucas van Doetecum",
                    date: "1562",
                    medium: "Etching",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP880254.jpg",
                    buildingName: "Insula",
                    studyPrompt: "See the arched vaults? These supported multiple floors. Why arches instead of flat ceilings?",
                    featureToFind: "The barrel vaults and arches",
                    featureHint: "Arches push weight to the sides and down — they can support much more than flat beams"
                ),
            ]

        // ── Renaissance Italy ─────────────────────────────

        case "Duomo", "Il Duomo":
            return [
                MuseumSketch(
                    id: 341618,
                    title: "Study for the Fresco Decoration of the Cupola of Santa Maria del Fiore",
                    artist: "Federico Zuccaro",
                    date: "1576-79",
                    medium: "Red and black chalk, pen and brown ink",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP801722.jpg",
                    buildingName: "Il Duomo",
                    studyPrompt: "This is a study for painting INSIDE Brunelleschi's dome. How do you paint a curved ceiling?",
                    featureToFind: "The curved fresco composition following the dome shape",
                    featureHint: "The artist had to distort figures so they'd look correct when viewed from 100 feet below"
                ),
                MuseumSketch(
                    id: 416883,
                    title: "La Place du Dome à Florence (Piazza del Duomo)",
                    artist: "Jacques Callot",
                    date: "1617",
                    medium: "Etching",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP888270.jpg",
                    buildingName: "Il Duomo",
                    studyPrompt: "Callot captured the Piazza del Duomo in 1617. The dome dominates the skyline — why?",
                    featureToFind: "Brunelleschi's dome rising above the city",
                    featureHint: "At 114 meters, it was the tallest dome in the world — built WITHOUT scaffolding from the ground"
                ),
            ]

        case "Botanical Garden":
            return [
                MuseumSketch(
                    id: 347243,
                    title: "Wilton Garden",
                    artist: "Isaac de Caus",
                    date: "ca. 1640",
                    medium: "Engraving",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP105007.jpg",
                    buildingName: "Botanical Garden",
                    studyPrompt: "Renaissance gardens used geometry to organize nature. Can you see the symmetry?",
                    featureToFind: "The geometric symmetry of the garden layout",
                    featureHint: "The garden is perfectly balanced — left mirrors right, just like Renaissance architecture"
                ),
                MuseumSketch(
                    id: 702013,
                    title: "Altra Veduta in Prospettiva del Teatro et Giardino Contigvo di Mondragone",
                    artist: "Giovanni Battista Falda",
                    date: "1691",
                    medium: "Etching",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP109521.jpg",
                    buildingName: "Botanical Garden",
                    studyPrompt: "This Italian garden combines architecture with nature. Where does the building end and the garden begin?",
                    featureToFind: "The transition from architecture to landscape",
                    featureHint: "Terraces, stairs, and walls blur the line — Renaissance designers saw gardens as outdoor rooms"
                ),
            ]

        case "Glassworks":
            return [
                MuseumSketch(
                    id: 372592,
                    title: "Glass Furnace: Murano",
                    artist: "James McNeill Whistler",
                    date: "1879-80",
                    medium: "Etching and drypoint",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP813641.jpg",
                    buildingName: "Glassworks",
                    studyPrompt: "Whistler sketched the actual glass furnace on Murano island. Why was glassmaking isolated there?",
                    featureToFind: "The furnace building structure",
                    featureHint: "Venice moved glassmakers to Murano in 1291 — furnaces caused fires, and secrets had to be kept"
                ),
                MuseumSketch(
                    id: 344747,
                    title: "Drawings of Glassware (Mirrors, Chandeliers, Goblets)",
                    artist: "Compagnia di Venezia e Murano",
                    date: "1850-80",
                    medium: "Watercolor, pen and ink on paper",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP804085.jpg",
                    buildingName: "Glassworks",
                    studyPrompt: "These are actual design drawings from a Murano glass company. Which piece would be hardest to make?",
                    featureToFind: "The most complex glassware design",
                    featureHint: "Chandeliers with multiple arms required incredible skill — each piece blown and attached by hand"
                ),
            ]

        case "Arsenal":
            return [
                MuseumSketch(
                    id: 397540,
                    title: "View of the Gate of the Arsenale, Venice",
                    artist: "Luca Carlevaris",
                    date: "1703",
                    medium: "Etching",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP832218.jpg",
                    buildingName: "Arsenal",
                    studyPrompt: "The Venice Arsenal was the world's first assembly line — before Ford by 400 years! What guards the entrance?",
                    featureToFind: "The monumental gateway with lions",
                    featureHint: "Stone lions guard the gate — Venice brought them from Greece as war trophies"
                ),
                MuseumSketch(
                    id: 335287,
                    title: "Imaginary View of Venice with Boat-Sheds",
                    artist: "Canaletto",
                    date: "1741",
                    medium: "Pen and brown ink, gray wash",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP232853.jpg",
                    buildingName: "Arsenal",
                    studyPrompt: "Canaletto drew these boat-sheds where galleys were built. How many ships could the Arsenal produce?",
                    featureToFind: "The covered boat-building sheds",
                    featureHint: "At its peak, the Arsenal could build a complete warship in ONE DAY using assembly-line methods"
                ),
            ]

        case "Anatomy Theater":
            return [
                MuseumSketch(
                    id: 358129,
                    title: "De Humani Corporis Fabrica (Of the Structure of the Human Body)",
                    artist: "Andreas Vesalius",
                    date: "1555",
                    medium: "Woodcut",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP357362.jpg",
                    buildingName: "Anatomy Theater",
                    studyPrompt: "Vesalius revolutionized anatomy at Padua. What's different about how he shows the human body?",
                    featureToFind: "The anatomical figure in a lifelike pose",
                    featureHint: "Unlike older texts, Vesalius showed bodies as if they were alive — standing, gesturing, in landscapes"
                ),
                MuseumSketch(
                    id: 340789,
                    title: "Anatomical Study of a Knee",
                    artist: "Michelangelo Buonarroti",
                    date: "ca. 1530",
                    medium: "Pen and brown ink",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP810666.jpg",
                    buildingName: "Anatomy Theater",
                    studyPrompt: "Michelangelo studied real anatomy to sculpt the human body. What joint is he drawing here?",
                    featureToFind: "The knee joint structure",
                    featureHint: "Artists needed to understand bones and muscles to create realistic sculptures and paintings"
                ),
                MuseumSketch(
                    id: 342278,
                    title: "Architectural Sketches and Anatomical Sketches",
                    artist: "Anonymous Italian",
                    date: "16th century",
                    medium: "Pen and brown ink",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP801919.jpg",
                    buildingName: "Anatomy Theater",
                    studyPrompt: "Architecture AND anatomy on the same page! Why did Renaissance artists study both?",
                    featureToFind: "Architecture and anatomy side by side",
                    featureHint: "Renaissance thinkers saw the human body as architecture — bones are columns, ribs are arches"
                ),
            ]

        case "Leonardo's Workshop":
            return [
                MuseumSketch(
                    id: 336656,
                    title: "Divina Proportione",
                    artist: "Leonardo da Vinci",
                    date: "1509",
                    medium: "Woodcut",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP156952.jpg",
                    buildingName: "Leonardo's Workshop",
                    studyPrompt: "Leonardo illustrated these geometric solids for a math book. Can you name any of these shapes?",
                    featureToFind: "The polyhedra (geometric solid shapes)",
                    featureHint: "These are Platonic solids — the building blocks of geometry that fascinated Leonardo"
                ),
                MuseumSketch(
                    id: 339130,
                    title: "Allegory on the Fidelity of the Lizard; Design for a Stage Setting",
                    artist: "Leonardo da Vinci",
                    date: "1496",
                    medium: "Pen and brown ink",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DT232678.jpg",
                    buildingName: "Leonardo's Workshop",
                    studyPrompt: "Leonardo designed stage sets AND studied nature on the same page. What does this tell you about him?",
                    featureToFind: "The dual nature of the page — art and science",
                    featureHint: "Leonardo never separated art from science — his workshop was where both came together"
                ),
                MuseumSketch(
                    id: 337494,
                    title: "Compositional Sketches; Diagram of a Perspectival Projection",
                    artist: "Leonardo da Vinci",
                    date: "1480-85",
                    medium: "Metalpoint, pen and brown ink",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP832657.jpg",
                    buildingName: "Leonardo's Workshop",
                    studyPrompt: "Leonardo worked out the math of perspective here. Can you see the vanishing point lines?",
                    featureToFind: "The perspective lines converging to a point",
                    featureHint: "All lines meet at one point — this mathematical trick creates the illusion of depth on a flat page"
                ),
            ]

        case "Flying Machine":
            return [
                MuseumSketch(
                    id: 659646,
                    title: "New Inventions of Modern Times [Nova Reperta], Title Plate",
                    artist: "Jan Collaert I, after Stradanus",
                    date: "ca. 1600",
                    medium: "Engraving",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP841122.jpg",
                    buildingName: "Flying Machine",
                    studyPrompt: "This print celebrates Renaissance inventions. The dream of flight drove inventors for centuries — what powered Leonardo's design?",
                    featureToFind: "The collection of Renaissance inventions",
                    featureHint: "Compass, printing press, gunpowder, America — and the dream of flight united them all"
                ),
                MuseumSketch(
                    id: 340981,
                    title: "Measured Drawing of a Horse Facing Left",
                    artist: "Andrea del Verrocchio (Leonardo's teacher)",
                    date: "ca. 1480-88",
                    medium: "Metalpoint on blue prepared paper",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP-26710-001.jpg",
                    buildingName: "Flying Machine",
                    studyPrompt: "Leonardo's teacher Verrocchio measured animals precisely. Leonardo applied the same method to birds and flight — why?",
                    featureToFind: "The precise measurements and proportions",
                    featureHint: "To build a flying machine, Leonardo first measured real birds — wingspan, weight, wing-beat frequency"
                ),
            ]

        case "Vatican Observatory":
            return [
                MuseumSketch(
                    id: 393278,
                    title: "The Moon in its First Quarter",
                    artist: "Claude Mellan",
                    date: "1635",
                    medium: "Engraving",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP822422.jpg",
                    buildingName: "Vatican Observatory",
                    studyPrompt: "This is one of the first detailed Moon maps, made from telescope observations. Can you see the craters?",
                    featureToFind: "The lunar craters and mountain shadows",
                    featureHint: "The dark spots are craters — Mellan used a single continuous spiral line to engrave this entire image"
                ),
                MuseumSketch(
                    id: 393543,
                    title: "Full Moon",
                    artist: "Claude Mellan",
                    date: "1635",
                    medium: "Engraving",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP822421.jpg",
                    buildingName: "Vatican Observatory",
                    studyPrompt: "Compare this full moon with the quarter moon. Why do craters look different when the sun angle changes?",
                    featureToFind: "The difference in shadow patterns between full and quarter moon",
                    featureHint: "At full moon, sunlight hits straight on — craters nearly vanish. At quarter, long shadows reveal depth"
                ),
                MuseumSketch(
                    id: 337061,
                    title: "Astronomicum Caesareum",
                    artist: "Michael Ostendorfer",
                    date: "1540",
                    medium: "Hand-colored woodcut with movable paper instruments",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP-18111-001.jpg",
                    buildingName: "Vatican Observatory",
                    studyPrompt: "This 1540 book had MOVABLE paper discs to calculate planet positions. It's an analog computer! What moves?",
                    featureToFind: "The rotating paper calculation discs",
                    featureHint: "The colored circles rotate — line up the date and you can predict where Mars or Venus will appear"
                ),
            ]

        case "Printing Press":
            return [
                MuseumSketch(
                    id: 659683,
                    title: "The Invention of Book Printing, from Nova Reperta",
                    artist: "Jan Collaert I, after Stradanus",
                    date: "ca. 1600",
                    medium: "Engraving",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP841130.jpg",
                    buildingName: "Printing Press",
                    studyPrompt: "This shows a real Renaissance print shop! Can you find the press, the typesetter, and the drying rack?",
                    featureToFind: "The three stages: typesetting, pressing, and drying",
                    featureHint: "Left: setting tiny metal letters. Center: the press squeezing ink onto paper. Right: pages hanging to dry"
                ),
                MuseumSketch(
                    id: 659685,
                    title: "The Invention of Copper Engraving, from Nova Reperta",
                    artist: "Jan Collaert I, after Stradanus",
                    date: "ca. 1600",
                    medium: "Engraving",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP841117.jpg",
                    buildingName: "Printing Press",
                    studyPrompt: "Copper engraving was another printing revolution. How is it different from a printing press with movable type?",
                    featureToFind: "The engraving tools and copper plate",
                    featureHint: "Type prints TEXT from raised letters. Engraving prints IMAGES from carved grooves — opposite methods!"
                ),
                MuseumSketch(
                    id: 365313,
                    title: "Hypnerotomachia Poliphili",
                    artist: "Francesco Colonna",
                    date: "1499",
                    medium: "Woodcut illustrations in printed book",
                    imageURL: "https://images.metmuseum.org/CRDImages/dp/original/DP102816.jpg",
                    buildingName: "Printing Press",
                    studyPrompt: "This is one of the most beautiful books ever printed (1499). How did they combine text and images?",
                    featureToFind: "The harmony of text and woodcut illustration",
                    featureHint: "The woodcut was carved to match the type size — both pressed together in a single pass"
                ),
            ]

        default:
            return []
        }
    }
}
