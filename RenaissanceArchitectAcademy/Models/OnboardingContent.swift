import Foundation

/// Per-gender override for animated background frames. Set on a `StoryPage`
/// when boy and girl variants have different frame counts or video durations
/// (e.g. Page 2 — the Boy catch animation runs ~4s, Girl runs ~1.8s).
struct FrameVariant {
    let count: Int
    let duration: Double
}

/// A single page in the onboarding story sequence
struct StoryPage: Identifiable {
    let id = UUID()
    let title: String
    /// Narrator text (default body font). On pages with a letter, this is the
    /// pre-letter intro line.
    let text: String
    /// Optional letter / handwritten content (rendered in PetitFormalScript-Regular).
    /// Appears between `text` and `outroText` on the page.
    var letterText: String? = nil
    /// Optional narrator outro shown after the letter content.
    var outroText: String? = nil
    /// Whether the bird companion should appear on this page
    let showBird: Bool
    /// Optional animated background frames prefix (e.g. "LorenzoLetterFrame").
    /// Frames are looked up as `{prefix}00`, `{prefix}01`, etc., up to `backgroundFrameCount - 1`.
    /// Supports `{gender}` token substitution at render time.
    var backgroundFramePrefix: String? = nil
    /// Number of frames in the background animation. Default 15 matches the
    /// historical WorkshopWelcomeFrame pattern. Set explicitly for longer sequences.
    var backgroundFrameCount: Int = 15
    /// Total duration the animation should play over (seconds). Each frame
    /// holds for `duration / (frameCount - 1)`. Default 1.5s matches the
    /// historical 10fps pattern for 15 frames.
    var backgroundFrameDuration: Double = 1.5
    /// Optional per-gender overrides for the animation timing. When a gender
    /// has an entry here, its `count` and `duration` are used instead of the
    /// page-level defaults — letting boy and girl frames play at their own
    /// native pace and freeze on the last frame while narration finishes.
    var backgroundFrameVariants: [ApprenticeGender: FrameVariant] = [:]
    /// When true, animated frames render full-screen (scaledToFill, anchored
    /// to bottom) instead of the smaller 680pt figure-style. Use for cinematic
    /// frames where the composition extends to the screen edges and a visible
    /// image edge mid-screen would look broken (e.g. Lorenzo's letter folding
    /// where the hands extend beyond the figure box).
    var backgroundFillsScreen: Bool = false
    /// Optional static background image filename in Assets.xcassets (e.g. "InvitationParchment").
    /// Takes precedence over the solid parchment color. Renders behind the text.
    var backgroundImage: String? = nil
    /// Optional audio narration filename (without extension), played on page appear.
    /// Looked up as both .mp3 and .m4a in the bundle.
    var audioName: String? = nil
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

    // MARK: - Story Pages (4 cinematic pages)
    //
    // Use the `{name}` token for the apprentice's name — StoryNarrativeView
    // substitutes it at render time using onboardingState.apprenticeName.
    //
    // Florence arrival + Workshop entry are intentionally NOT here — they
    // belong later in the game: arrival when the player begins the Duomo
    // (building 17, Apprentice finale), and the workshop entry in the
    // Architect level (Ray's scope).

    static let storyPages: [StoryPage] = [
        StoryPage(
            title: "The Letter Is Sealed",
            text: """
            The year is 1485. In the Palazzo Medici, Lorenzo lifts his quill from the page. \
            He has been searching for new talent across all of Italy, and tonight, he has found one.

            He seals the letter in red wax with the Medici crest. And he sends it flying. \
            Across mountains, across rivers, all the way to you.
            """,
            showBird: false,
            backgroundFramePrefix: "LorenzoLetterFrame",
            backgroundFrameCount: 56,
            backgroundFrameDuration: 17.98,
            backgroundFillsScreen: true, // letter-folding extends past the 680 figure box
            audioName: "LorenzoLetterNarration"
        ),
        StoryPage(
            title: "The Letter Arrives",
            text: """
            Far across Italy, you are sketching by candlelight when something taps the windowpane.

            A folded letter — sealed in red wax — drifts down through the air as if guided by hand. \
            You reach out. You catch it.

            The seal is warm. It glows faintly in your hand. Whoever sent this wanted you, \
            {name}, and only you, to read what is inside.
            """,
            showBird: false,
            backgroundFramePrefix: "{gender}CatchingLetterFrame",
            backgroundFrameCount: 30,
            backgroundFrameDuration: 4.01,
            backgroundFrameVariants: [
                .boy:  FrameVariant(count: 30, duration: 4.01),
                .girl: FrameVariant(count: 30, duration: 1.78),
            ],
            audioName: "LetterArrivesNarration"
        ),
        StoryPage(
            title: "The Invitation",
            text: "",
            letterText: """
            We have heard of your gifts, {name}. Your drawings. Your curiosity for how things work.

            I, Lorenzo de' Medici, will sponsor your apprenticeship under the finest architects of \
            the age. Before you stretches the ancient world — Rome's mighty aqueducts, its towering \
            Colosseum, the perfect dome of the Pantheon. You will study them all.

            And when you have mastered the apprentice's craft and earned the Architect's Seal, a \
            greater journey awaits: the Giardino di San Marco — my school here in Florence, where \
            Michelangelo once studied and the spirit of Brunelleschi lives in every stone.

            Find us by the Duomo when you arrive. There is much to learn, {name}.
            """,
            outroText: "Below the signature: a promise of florins — Florence's gold — for every step of your apprenticeship.",
            showBird: false,
            backgroundImage: "InvitationParchment"
        ),
        StoryPage(
            title: "The Bird Arrives",
            text: """
            A small bird flies through the open window and lands on your shoulder — \
            bright-eyed and ancient beyond its years. It cocks its head and speaks:

            "Ciao, apprendista! Maestro Leonardo da Vinci sends me to you. I have flown across \
            the centuries — I perched on Brunelleschi's scaffolding as he raised the dome, \
            I watched the Romans pour concrete that still stands two thousand years later."

            "I will travel with you to Florence, {name}. I will teach you the thirteen sciences \
            behind the greatest structures ever built. Are you ready?"
            """,
            showBird: false, // replaced by gender-specific bird arrival video
            backgroundFramePrefix: "BirdArrival{gender}Frame",
            backgroundFrameCount: 30,
            backgroundFrameDuration: 4.08, // girl native duration
            backgroundFrameVariants: [
                .boy:  FrameVariant(count: 30, duration: 4.34), // boy assets pending
                .girl: FrameVariant(count: 30, duration: 4.08),
            ]
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
