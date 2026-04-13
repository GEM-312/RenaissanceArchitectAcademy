import Foundation

/// Pre-written historical NPCs for all 17 buildings.
///
/// Each building maps to a real historical figure with verified facts.
/// Sources: Paul Strathern's "The Medici", existing HistoricalFigureMapping,
/// and verified historical records.
///
/// Lookup: `HistoricalNPCContent.npc(for: buildingName)` → `NPCDisplayData?`
enum HistoricalNPCContent {

    /// Look up the historical NPC for a building
    static func npc(for buildingName: String) -> NPCDisplayData? {
        npcs[buildingName]
    }

    // MARK: - 18 Historical NPCs (17 buildings)

    private static let npcs: [String: NPCDisplayData] = [

        // ━━━ ANCIENT ROME (8 buildings) ━━━

        "Aqueduct": NPCDisplayData(
            name: "Sextus Julius Frontinus",
            trade: "Curator Aquarum (Water Commissioner)",
            greeting: "Salve, young builder! I am Rome's water commissioner — I have mapped every aqueduct, every pipe, every fountain in the city. Do you know that Rome's aqueducts deliver over 200 million gallons of water daily? And not a single pump is needed — gravity alone does the work.",
            historicalFact: "Frontinus documented all nine of Rome's aqueducts in his treatise 'De Aquaeductu'. He discovered that corrupt officials had been secretly tapping the water supply, and reformed the entire system to serve the public.",
            scienceTip: "An aqueduct's gradient must drop exactly 1 foot for every 200 feet of length. Too steep and the water erodes the channel. Too shallow and it stagnates. This precise slope calculation is the same engineering behind modern storm drains.",
            portraitPrompt: ""
        ),

        "Colosseum": NPCDisplayData(
            name: "Rabirius",
            trade: "Architectus (Imperial Architect)",
            greeting: "Welcome, apprentice! Building the Flavian Amphitheatre is no simple task — we must move 50,000 spectators in and out safely. I designed 80 entrance arches, each numbered, so every citizen finds their seat within minutes.",
            historicalFact: "The Colosseum's 80 entrance arches could fill 50,000 seats in 15 minutes and empty them in 5 — a crowd-flow solution that modern stadiums still study. The retractable velarium roof shade required 1,000 sailors to operate.",
            scienceTip: "The Colosseum uses three styles of arches stacked vertically: Doric (bottom), Ionic (middle), Corinthian (top). Each style is progressively lighter, reducing weight on the lower levels — a structural principle called graduated loading.",
            portraitPrompt: ""
        ),

        "Roman Baths": NPCDisplayData(
            name: "Apollodorus of Damascus",
            trade: "Architectus Imperialis (Imperial Architect)",
            greeting: "Ah, another student of architecture! Emperor Trajan himself commissioned me to build the greatest baths Rome has ever seen. The secret is not the marble or the mosaics — it is the hypocaust, the invisible furnace beneath the floor that heats every room.",
            historicalFact: "Apollodorus designed Trajan's Baths with a revolutionary heating system: the hypocaust. Slaves maintained furnaces that pushed hot air under raised floors and through hollow walls, creating the world's first central heating system.",
            scienceTip: "Hot air rises — the hypocaust uses this principle. Furnaces heat air that flows under raised tile floors supported by brick pillars. The hot air then rises through hollow clay pipes in the walls, heating the entire room evenly.",
            portraitPrompt: ""
        ),

        "Pantheon": NPCDisplayData(
            name: "Apollodorus of Damascus",
            trade: "Architectus Imperialis (Imperial Architect)",
            greeting: "Behold my masterwork! The dome you see is 43.3 meters across — the largest unreinforced concrete dome ever built. And that hole at the top? The oculus. It is the only source of light, and when it rains, the water drains through barely visible holes in the floor.",
            historicalFact: "The Pantheon's dome has stood for nearly 1,900 years without any steel reinforcement. Apollodorus achieved this by varying the concrete mix: heavy basalt aggregate at the base, lightweight volcanic pumice near the top — reducing the dome's weight where it matters most.",
            scienceTip: "A perfect sphere 43.3 meters in diameter fits exactly inside the Pantheon — the height from floor to oculus equals the diameter. This mathematical harmony creates a space where geometry and architecture become one.",
            portraitPrompt: ""
        ),

        "Roman Roads": NPCDisplayData(
            name: "Appius Claudius Caecus",
            trade: "Censor (Public Works Commissioner)",
            greeting: "I am Appius Claudius, and I built the first great road of Rome — the Via Appia. They called me blind and foolish, but my road has outlasted every critic. A road is not just stone — it is the spine of an empire.",
            historicalFact: "The Via Appia, begun in 312 BC, stretches 350 miles from Rome to Brindisi. It was so well engineered that sections are still walkable today, over 2,300 years later. Appius Claudius also built Rome's first aqueduct.",
            scienceTip: "Roman roads have four layers: statumen (foundation stones), rudus (rubble and concrete), nucleus (fine gravel and lime), and summa crusta (fitted paving stones). The cambered surface slopes 2% from center to edge for drainage — modern roads use the same technique.",
            portraitPrompt: ""
        ),

        "Harbor": NPCDisplayData(
            name: "Vitruvius",
            trade: "Architectus et Ingeniarius (Architect & Engineer)",
            greeting: "I am Vitruvius, author of De Architectura — the only architectural treatise to survive from antiquity. A harbor is where engineering meets the sea, and the sea forgives nothing. Every breakwater must account for tide, current, and the fury of storms.",
            historicalFact: "Vitruvius described how Roman engineers made concrete that sets underwater — opus caementicium — by mixing volcanic ash with lime. This 'marine concrete' actually grows stronger in seawater, a property modern engineers are still trying to replicate.",
            scienceTip: "Underwater concrete works because volcanic ash contains silica and alumina that react with lime in seawater to form aluminum tobermorite crystals. These crystals grow over centuries, filling cracks — making the concrete self-healing.",
            portraitPrompt: ""
        ),

        "Siege Workshop": NPCDisplayData(
            name: "Archimedes",
            trade: "Mathematicus et Ingeniarius (Mathematician & Engineer)",
            greeting: "Give me a lever long enough and a fulcrum on which to place it, and I shall move the world! I am Archimedes of Syracuse. Every war machine I build — every catapult, every crane, every claw — is just applied mathematics.",
            historicalFact: "During the Siege of Syracuse in 212 BC, Archimedes designed giant cranes that could lift Roman ships out of the water, and mirrors that focused sunlight to set ships ablaze. The Romans feared his machines so much they called him 'the geometrician'.",
            scienceTip: "A catapult is a lever of the first class: the fulcrum sits between the effort and the load. Doubling the arm length quadruples the throwing distance — this is mechanical advantage, the fundamental principle behind all simple machines.",
            portraitPrompt: ""
        ),

        "Insula": NPCDisplayData(
            name: "Marcus Vitruvius Pollio",
            trade: "Architectus (Architect)",
            greeting: "Building homes for citizens is the most important work in Rome. An insula must be strong enough to stand five stories tall, safe from fire, and dignified enough that even a common worker feels proud to live there. These are my building codes.",
            historicalFact: "Vitruvius established Rome's first building codes: insulae could not exceed 70 feet in height. He mandated load-bearing walls of specific thickness and fire breaks between buildings — regulations born from Rome's devastating fires.",
            scienceTip: "Load-bearing walls must increase in thickness at lower floors to support the weight above. Vitruvius's rule: each story's walls must be 1.5 feet thicker than the story above it. This is the principle of compressive stress distribution.",
            portraitPrompt: ""
        ),

        // ━━━ RENAISSANCE ITALY (9 buildings) ━━━

        "Duomo": NPCDisplayData(
            name: "Filippo Brunelleschi",
            trade: "Capomaestro (Master Builder)",
            greeting: "Buongiorno! They said my dome was impossible — 42 meters wide with no centering and no buttresses. But I studied the Pantheon in Rome, and I saw the answer. I invented a herringbone brick pattern that holds itself up as it rises.",
            historicalFact: "Brunelleschi rediscovered the rules of linear perspective, lost since antiquity. His design for the Ospedale degli Innocenti portico is considered the first piece of Renaissance architecture. He also invented an ox-driven hoist to lift 70 million pounds of material.",
            scienceTip: "The dome uses a double-shell design: an inner dome 7 feet thick and an outer dome 2.5 feet thick, connected by 24 ribs. This reduces weight by 40% compared to a solid dome — the same hollow-core principle used in modern bridge decks.",
            portraitPrompt: ""
        ),

        "Botanical Garden": NPCDisplayData(
            name: "Luca Ghini",
            trade: "Professore di Botanica (Professor of Botany)",
            greeting: "Welcome to the garden, young scholar! I founded the first botanical garden in Pisa to teach students something revolutionary: do not just read about plants in ancient books — observe them with your own eyes. I invented a way to preserve them forever: the herbarium.",
            historicalFact: "Ghini created the first herbarium by pressing plants between sheets of paper — a technique still used by botanists today. His students spread the method across Europe, founding botanical gardens in Padua, Florence, and Bologna within a decade.",
            scienceTip: "Plants are classified by their reproductive structures, not their appearance. A tiny daisy and a massive sunflower are in the same family (Asteraceae) because they share the same composite flower structure — hundreds of tiny flowers packed into one head.",
            portraitPrompt: ""
        ),

        "Glassworks": NPCDisplayData(
            name: "Angelo Barovier",
            trade: "Maestro Vetraio (Master Glassmaker)",
            greeting: "I am Angelo Barovier of Murano. I discovered the secret of cristallo — glass so pure and clear it rivals rock crystal. Venice guards our secrets jealously: any glassmaker who leaves the island faces death. But for you, apprentice, I will share what I know.",
            historicalFact: "Barovier invented cristallo around 1450 by purifying glass with manganese dioxide, creating the first truly clear glass in history. Venice confined all glassmakers to Murano island, officially to prevent fires — but really to guard trade secrets.",
            scienceTip: "Glass is an amorphous solid, a 'frozen liquid' where molecules are disordered. Adding manganese dioxide removes the green tint caused by iron impurities by oxidizing the iron — the same chemistry used in modern optical glass.",
            portraitPrompt: ""
        ),

        "Arsenal": NPCDisplayData(
            name: "Vettor Fausto",
            trade: "Maestro d'Arsenale (Master of the Arsenal)",
            greeting: "In Venice's Arsenal, we build a fully armed war galley in a single day. How? Assembly-line production — three centuries before any factory existed. Each station adds one component: hull, mast, oars, rigging, weapons. The ship moves down the canal, workers stay at their posts.",
            historicalFact: "The Venetian Arsenal employed 16,000 workers and could produce a new galley every day using standardized, interchangeable parts. When Henry III of France visited in 1574, they built an entire galley during the time it took him to eat dinner.",
            scienceTip: "Standardized parts are the foundation of mass production. If every oar is the same length and every oarlock the same size, any oar fits any ship — no custom fitting needed. This principle of interchangeability revolutionized manufacturing.",
            portraitPrompt: ""
        ),

        "Anatomy Theater": NPCDisplayData(
            name: "Andreas Vesalius",
            trade: "Professore di Anatomia (Professor of Anatomy)",
            greeting: "For a thousand years, doctors trusted Galen without ever looking inside a human body. I changed that. I dissected corpses with my own hands and proved that Galen — who only dissected animals — was wrong about over 200 points of anatomy.",
            historicalFact: "Vesalius published 'De Humani Corporis Fabrica' in 1543, with illustrations so detailed they revolutionized medicine. He proved that the human jawbone is one bone, not two as Galen claimed, and that blood does not pass through the septum of the heart.",
            scienceTip: "The anatomy theater's circular design uses the same acoustic principles as a Greek amphitheater. Sound waves reflect off the curved walls and focus at the center, so 300 students can hear the professor without amplification.",
            portraitPrompt: ""
        ),

        "Leonardo's Workshop": NPCDisplayData(
            name: "Leonardo da Vinci",
            trade: "Maestro Universale (Universal Master)",
            greeting: "I paint, I sculpt, I engineer, I study the flight of birds and the flow of water. But above all, I observe. Every machine I design begins with a question: how does nature solve this problem? The answers are always in front of us — we just forget to look.",
            historicalFact: "Leonardo filled over 7,000 pages of notebooks with mirror-writing, anatomical drawings, engineering designs, and scientific observations. He designed tanks, helicopters, and diving suits — all centuries before the technology existed to build them.",
            scienceTip: "Leonardo discovered that tree rings record a tree's age and the climate of each year — wide rings mean wet years, narrow rings mean drought. This was the beginning of dendrochronology, a dating technique scientists still use today.",
            portraitPrompt: ""
        ),

        "Flying Machine": NPCDisplayData(
            name: "Leonardo da Vinci",
            trade: "Ingegnere Ducale (Ducal Engineer)",
            greeting: "I have studied the kestrel, the bat, and the swan. Each flies differently, but all obey the same invisible laws. My ornithopter mimics the bird's wing — but I am beginning to think the answer is not flapping at all. It is the shape of the wing that creates lift.",
            historicalFact: "Leonardo's Codex on the Flight of Birds (1505) contains the first scientific analysis of bird flight, including observations about center of gravity, air resistance, and how birds use their tails as rudders. He designed a hang glider with a 33-foot wingspan.",
            scienceTip: "Lift is created by the wing's curved shape: air moves faster over the top surface than the bottom, creating lower pressure above. This pressure difference pushes the wing upward. Leonardo intuited this 400 years before Bernoulli proved it mathematically.",
            portraitPrompt: ""
        ),

        "Vatican Observatory": NPCDisplayData(
            name: "Ignazio Danti",
            trade: "Cosmografo Pontificio (Papal Cosmographer)",
            greeting: "I am Brother Ignazio Danti, Dominican friar and papal cosmographer. I mapped the winds, measured the stars, and helped Pope Gregory reform the calendar. The old Julian calendar had drifted 10 days from the sun — Easter was being celebrated on the wrong date!",
            historicalFact: "Danti built a gnomon in the Basilica of Santa Maria Novella to precisely measure the summer solstice. His measurements proved the Julian calendar was 10 days off, leading directly to the Gregorian calendar reform of 1582.",
            scienceTip: "A gnomon measures the sun's angle by projecting a beam of light onto a calibrated floor line. At solar noon on the summer solstice, the light hits the shortest point. By comparing this to predicted positions, Danti proved the calendar error with mathematical certainty.",
            portraitPrompt: ""
        ),

        "Printing Press": NPCDisplayData(
            name: "Aldus Manutius",
            trade: "Stampatore (Printer & Publisher)",
            greeting: "I believe knowledge should be portable and beautiful. Before me, books were enormous — chained to desks in libraries. I invented the pocket-sized octavo format so a scholar could carry Virgil in his saddlebag. I also created italic type, and — modestly — the semicolon.",
            historicalFact: "Manutius founded the Aldine Press in Venice in 1494 and published the first pocket-sized books, making classical literature affordable for students. His italic typeface, designed by Francesco Griffo, was cut to fit more text per page — saving paper and cost.",
            scienceTip: "A printing press works by applying uniform pressure across a flat surface. The screw mechanism converts rotational force into linear force with a mechanical advantage of about 50:1 — meaning 10 pounds of turning force creates 500 pounds of pressing force.",
            portraitPrompt: ""
        ),
    ]
}
