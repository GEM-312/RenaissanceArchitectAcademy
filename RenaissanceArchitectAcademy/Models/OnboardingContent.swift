import Foundation

/// A single page in the onboarding story sequence
struct StoryPage: Identifiable {
    let id = UUID()
    let title: String
    let text: String
    /// Whether the bird companion should appear on this page
    let showBird: Bool
    /// Optional animated background frames prefix (e.g. "WorkshopWelcomeFrame"), 15 frames 00-14
    var backgroundFramePrefix: String? = nil
}

/// A historical lesson the bird teaches before the player's first visit to a workshop station
struct StationLesson: Identifiable {
    let id = UUID()
    let stationLabel: String
    let title: String
    let text: String
    let sciences: [Science]
}

/// All static narrative content for the onboarding system
enum OnboardingContent {

    // MARK: - Story Pages (3 cinematic pages)

    static let storyPages: [StoryPage] = [
        StoryPage(
            title: "The Discovery",
            text: """
            The year is 1485. In a small town near Florence, a talented youth has been noticed \
            by the most powerful family in Italy.

            A letter arrives, sealed with the crest of the Medici:

            "We have heard of your gifts in drawing and your curiosity for how things work. \
            Come to Florence. Lorenzo de' Medici himself will sponsor your apprenticeship \
            under the finest architects of the age."
            """,
            showBird: false
        ),
        StoryPage(
            title: "The Workshop",
            text: """
            You arrive at the bustling bottega — a Renaissance workshop alive with creation. \
            Marble dust fills the air. Apprentices carve columns while masters debate the geometry \
            of perfect arches.

            The Medici have arranged for you to study under the finest architects and engineers. \
            You will learn to build structures that blend beauty with science — from Roman aqueducts \
            to soaring cathedral domes.

            "But first," says the workshop master, "you will need a teacher..."
            """,
            showBird: false,
            backgroundFramePrefix: "WorkshopWelcomeFrame"
        ),
        StoryPage(
            title: "The Bird Companion",
            text: """
            A small bird lands on your shoulder — bright-eyed and ancient beyond its years. \
            It cocks its head and speaks:

            "I have guided apprentices since the days of Vitruvius. I watched the Romans pour \
            concrete that still stands two thousand years later. I perched on Brunelleschi's \
            scaffolding as he raised the dome of Florence."

            "I will teach you the thirteen sciences behind the greatest structures ever built. \
            Are you ready, young architect?"
            """,
            showBird: true
        ),
    ]

    // MARK: - Station Lessons (8 resource stations)

    static func lesson(for station: ResourceStationType) -> StationLesson? {
        stationLessons[station]
    }

    static let stationLessons: [ResourceStationType: StationLesson] = [
        .quarry: StationLesson(
            stationLabel: "Quarry",
            title: "The Emperor's Marble",
            text: """
            Emperor Augustus once boasted: "I found Rome a city of brick and left it a city of marble."

            The quarries of Carrara — the same quarries Michelangelo would later choose for his David — \
            supplied white marble across the Empire. But the real secret was limestone: when burned to \
            calcium oxide and mixed with water, it becomes the morite that held Rome together.

            Every great structure begins here, with stone pulled from the earth.
            """,
            sciences: [.geology, .chemistry, .materials]
        ),

        .river: StationLesson(
            stationLabel: "River",
            title: "Leonardo's Water Studies",
            text: """
            Leonardo da Vinci filled entire notebooks studying how water flows — its currents, \
            vortices, and erosive power. He understood water as both creator and destroyer.

            Rivers carry fine sand, essential for making mortar and concrete. The Romans mixed \
            sand with lime and volcanic ash to create concrete so strong that harbors built \
            two thousand years ago still stand beneath the Mediterranean.

            Watch the current carefully — it has much to teach.
            """,
            sciences: [.hydraulics, .physics, .engineering]
        ),

        .volcano: StationLesson(
            stationLabel: "Volcano",
            title: "The Pozzolana Secret",
            text: """
            The Romans discovered something miraculous near Mount Vesuvius: volcanic ash they \
            called pozzolana. When mixed with lime and seawater, it created concrete that actually \
            grew stronger underwater.

            Modern scientists have only recently understood why — the volcanic ash triggers a \
            chemical reaction that fills microscopic cracks with mineral crystals. Roman harbors \
            and the Pantheon's dome owe their immortality to this one ingredient.

            Collect it carefully. There is nothing else like it.
            """,
            sciences: [.chemistry, .materials, .geology]
        ),

        .clayPit: StationLesson(
            stationLabel: "Clay Pit",
            title: "Bricks of the Dome",
            text: """
            "Terra cotta" — baked earth. Clay fired at over 1000°C transforms into one of \
            humanity's oldest building materials.

            When Brunelleschi faced the impossible task of spanning Florence's cathedral without \
            wooden centering, he turned to terracotta bricks laid in a herringbone pattern. \
            Each ring of bricks was self-supporting, locking into the ring below.

            Four million bricks. No scaffolding. The greatest engineering feat of the Renaissance.
            """,
            sciences: [.materials, .engineering, .architecture]
        ),

        .mine: StationLesson(
            stationLabel: "Mine",
            title: "Iron and Lead",
            text: """
            The Colosseum's massive stone blocks are held together not by mortar but by iron \
            clamps — thousands of them, forged in the fires of Roman smithies. When medieval \
            scavengers pried them out for scrap, the building began to crumble.

            Lead was equally vital. The Romans cast it into sheets for waterproof roofing and \
            rolled it into pipes for their aqueducts. The Latin word for lead — "plumbum" — \
            gives us the word "plumber."

            Metal is the skeleton within the stone.
            """,
            sciences: [.engineering, .materials, .chemistry]
        ),

        .pigmentTable: StationLesson(
            stationLabel: "Pigment Table",
            title: "Colors Worth More Than Gold",
            text: """
            Renaissance painters didn't buy paint — they ground it from minerals, stone by stone. \
            The most precious was ultramarine blue, made from lapis lazuli hauled thousands of \
            miles from Afghanistan. It cost more than gold by weight.

            Red ochre came from iron-rich earth. Verdigris green was scraped from copper plates \
            left to corrode in vinegar. Every color was chemistry — a reaction between mineral \
            and medium, earth and oil.

            These pigments don't just decorate — they tell the science of color itself.
            """,
            sciences: [.chemistry, .optics, .materials]
        ),

        .forest: StationLesson(
            stationLabel: "Forest",
            title: "The Hidden Structure",
            text: """
            Before any stone arch could stand, carpenters built a wooden frame called "centering" — \
            a perfect curved scaffold that held each stone in place until the keystone locked them \
            all together. Then the centering was removed, and the arch stood on its own.

            Brunelleschi's genius was building the dome of Florence without centering — but for \
            every other arch, vault, and dome in history, timber made it possible.

            Wood is the invisible partner to every stone masterpiece.
            """,
            sciences: [.engineering, .architecture, .physics]
        ),

        .market: StationLesson(
            stationLabel: "Market",
            title: "The Silk Road's End",
            text: """
            Venice sat at the western end of the Silk Road, a gateway where East met West. \
            Merchants traded silk from China, spices from India, and marble quarried from \
            quarries across the Mediterranean.

            The Pantheon's interior used marble from Egypt, Greece, Tunisia, and Turkey — \
            a geological map of the Roman Empire in stone. Renaissance builders continued \
            this tradition, importing the finest materials money could buy.

            Every great building is a story of trade, travel, and connection.
            """,
            sciences: [.geology, .materials, .engineering]
        ),
    ]
}
