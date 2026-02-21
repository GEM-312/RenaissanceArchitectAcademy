import Foundation

// LANGUAGE GUIDE FOR LESSON AUTHORS:
//
// Apprentice: Simple words, short sentences, lots of analogies ("like building with LEGOs"),
//             explain every term, encouraging tone ("Great job! Now let's learn...")
//
// Architect:  Clear but more detailed, introduce proper terms with brief explanations,
//             narrative storytelling, moderate sentence complexity
//
// Master:     Professional/academic, assumes foundational knowledge, technical terminology,
//             complex sentence structures, scholarly references

/// Static lesson content for all buildings
/// Same pattern as ChallengeContent in Challenge.swift
enum LessonContent {

    /// Look up the interactive lesson for a building by name
    static func lesson(for buildingName: String) -> BuildingLesson? {
        switch buildingName {
        case "Aqueduct":            return aqueductLesson
        case "Colosseum":           return colosseumLesson
        case "Roman Baths":         return romanBathsLesson
        case "Pantheon":            return pantheonLesson
        case "Roman Roads":         return romanRoadsLesson
        case "Harbor":              return harborLesson
        case "Siege Workshop":      return siegeWorkshopLesson
        case "Insula":              return insulaLesson
        case "Duomo", "Il Duomo":   return duomoLesson
        case "Botanical Garden":    return botanicalGardenLesson
        case "Glassworks":          return glassworksLesson
        case "Arsenal":             return arsenalLesson
        case "Anatomy Theater":     return anatomyTheaterLesson
        case "Leonardo's Workshop": return leonardoWorkshopLesson
        case "Flying Machine":      return flyingMachineLesson
        case "Vatican Observatory": return vaticanObservatoryLesson
        case "Printing Press":      return printingPressLesson
        default:                    return nil
        }
    }

    // MARK: - Pantheon Lesson (Geometry, Architecture, Materials Science)

    static let pantheonLesson = BuildingLesson(
        buildingName: "Pantheon",
        title: "The Temple of All Gods",
        sections: [

            // ── 1. ARCHITECTURE: Introduction ───────────────────

            .reading(LessonReading(
                title: "The Temple of All Gods",
                body: """
                In **125 AD**, Emperor **Hadrian** finished building something incredible — \
                the **Pantheon**, a temple dedicated to all the gods of Rome.

                This wasn't actually the first Pantheon. A leader named **Marcus Agrippa** \
                built the original about 150 years earlier. It burned down twice! Hadrian \
                decided not to just fix it — he tore everything down and started fresh. His \
                new design was bold: a huge **circular room** (called a **rotunda**) topped \
                by the biggest dome anyone had ever built.
                """,
                science: .architecture,
                illustrationIcon: "building.columns.fill"
            )),

            // ── 2. Fun Fact: The Inscription ────────────────────

            .funFact(LessonFunFact(
                text: """
                The inscription on the facade reads **M·AGRIPPA·L·F·COS·TERTIVM·FECIT** — \
                "Marcus Agrippa, son of Lucius, made this when consul for the third time." \
                Hadrian kept Agrippa's name even though he rebuilt the entire building. \
                He never put his own name on structures he restored — a rare act of modesty \
                for a Roman emperor. This inscription confused historians for centuries!
                """
            )),

            // ── 3. QUESTION: Architecture ───────────────────────

            .question(LessonQuestion(
                question: "Why does the Pantheon's inscription credit Marcus Agrippa instead of Hadrian?",
                options: [
                    "Agrippa designed the dome",
                    "Roman law required it",
                    "Hadrian never inscribed his name on restored buildings",
                    "The inscription was added later by mistake"
                ],
                correctIndex: 2,
                explanation: "Hadrian had a personal policy of never putting his own name on buildings he restored or rebuilt. The historian Cassius Dio noted this unusual modesty, which confused scholars for centuries about who actually built the rotunda.",
                science: .architecture
            )),

            // ── 4. ARCHITECTURE: Vitruvius's Principles ─────────

            .reading(LessonReading(
                title: "Vitruvius's Three Principles",
                body: """
                About a hundred years before the Pantheon, a Roman architect named \
                **Vitruvius** wrote a book called **De Architectura** — the only building \
                guide from the ancient world that still exists today. He said every great \
                building needs three things:

                **Firmitas** — it must be strong and last a long time
                **Utilitas** — it must be useful and work well
                **Venustas** — it must be beautiful

                The Pantheon nails all three. Its walls are **6.4 meters thick** — that's \
                about the width of two cars parked end to end — holding up a dome weighing \
                4,535 tonnes (**firmitas**). The round interior lets people worship in every \
                direction, with the opening at the top connecting them to the sky \
                (**utilitas**). And its perfect proportions and marble surfaces have amazed \
                visitors for nearly 2,000 years (**venustas**).
                """,
                science: .architecture,
                illustrationIcon: "text.book.closed.fill"
            )),

            // ── 5. QUESTION: Architecture ───────────────────────

            .question(LessonQuestion(
                question: "According to Vitruvius, what three qualities must every great building possess?",
                options: [
                    "Height, width, and depth",
                    "Firmitas, utilitas, and venustas",
                    "Gold, marble, and bronze",
                    "Columns, arches, and domes"
                ],
                correctIndex: 1,
                explanation: "Vitruvius wrote in De Architectura that buildings need firmitas (structural strength), utilitas (function), and venustas (beauty). Renaissance architect Leon Battista Alberti later expanded on these principles, and they remain foundational in architecture education today.",
                science: .architecture
            )),

            // ── 6. FILL IN BLANKS: Architecture ───────────────────

            .fillInBlanks(LessonFillInBlanks(
                title: "Complete the Passage",
                text: """
                The Roman architect {{Vitruvius}} wrote {{De Architectura}}, declaring that \
                all great buildings must possess three qualities: {{firmitas}} (strength), \
                {{utilitas}} (function), and {{venustas}} (beauty).
                """,
                distractors: ["Hadrian", "De Re Aedificatoria", "gravitas", "pietas"],
                science: .architecture
            )),

            // ── 7. GEOMETRY: The Perfect Sphere ─────────────────

            .reading(LessonReading(
                title: "A Perfect Sphere",
                body: """
                Step inside the Pantheon and look up. The dome rises **43.3 meters** above \
                the floor — and the room is exactly **43.3 meters** wide too.

                Think of it like this: if you could roll a giant ball 43.3 meters wide into \
                the building, it would fit perfectly — touching the floor and the inside of \
                the dome at the same time. The bottom half of the building is shaped like a \
                **cylinder** (like a can), and the top half is a **hemisphere** (half a ball). \
                Together, they hold this invisible perfect **sphere**.

                Nothing about the Pantheon's shape is random — it's geometry built in stone.
                """,
                science: .geometry,
                illustrationIcon: "circle.circle"
            )),

            // ── 7. Fun Fact: Perfect Number ─────────────────────

            .funFact(LessonFunFact(
                text: """
                The dome's interior has **28 coffers** (sunken panels) in each of its 5 rings. \
                Why 28? Because it's a **perfect number** — the sum of its divisors equals \
                itself: 1 + 2 + 4 + 7 + 14 = 28. Only four perfect numbers were known in \
                antiquity. The mathematician **Nicomachus of Gerasa**, writing during \
                Hadrian's era, associated perfect numbers with virtue and cosmic harmony — \
                fitting for a temple to all the gods.
                """
            )),

            // ── 8. QUESTION: Geometry ───────────────────────────

            .question(LessonQuestion(
                question: "What makes the Pantheon's interior proportions geometrically unique?",
                options: [
                    "It is the tallest dome ever built",
                    "A perfect sphere fits exactly inside it",
                    "It contains no right angles",
                    "The walls are curved like a spiral"
                ],
                correctIndex: 1,
                explanation: "The interior diameter (43.3m) equals the height from floor to oculus (43.3m), so a perfect sphere fits exactly inside the space. The lower cylinder and upper hemisphere together contain this invisible sphere — a deliberate geometric harmony.",
                science: .geometry
            )),

            // ── 9. GEOMETRY: The Oculus ─────────────────────────

            .reading(LessonReading(
                title: "The Eye of the Pantheon",
                body: """
                At the very top of the dome, there's a round hole called the **oculus** \
                (that's Latin for "eye"). It's the only source of natural light inside, \
                and it's **8.2 meters** wide — about one-fifth the width of the dome.

                As the sun moves through the sky, a bright **beam of light** sweeps across \
                the walls and floor like a giant spotlight. On **April 21st** — the day \
                Romans celebrated their city's birthday — the light lines up perfectly with \
                the entrance. Imagine the emperor walking in, bathed in sunlight, as if the \
                gods were welcoming him.
                """,
                science: .geometry,
                illustrationIcon: "sun.max.fill"
            )),

            // ── 10. Fun Fact: Rain ──────────────────────────────

            .funFact(LessonFunFact(
                text: """
                Yes, **it rains through the oculus!** The marble floor is slightly **convex** \
                (domed upward at the center) with **22 hidden drainage holes** around the \
                edges. But here's the surprise: warm air rising inside the dome creates \
                **nebulization** that partially deflects raindrops — so far less water \
                reaches the floor than you'd expect. Every **Pentecost Sunday**, firefighters \
                climb above the dome and drop thousands of **red rose petals** through the \
                oculus — a tradition that may date back to 609 AD.
                """
            )),

            // ── 11. GEOMETRY CALCULATION: Oculus Area ──────────────

            .question(LessonQuestion(
                question: "Calculate the area of the oculus. The oculus is a circle with diameter 8.2 meters. Using the formula A = πr², what is its area? (Use π ≈ 3.14)",
                options: [
                    "≈ 52.8 m²",
                    "≈ 25.7 m²",
                    "≈ 105.6 m²",
                    "≈ 211.1 m²"
                ],
                correctIndex: 0,
                explanation: "The radius is half the diameter: r = 8.2 ÷ 2 = 4.1 m. Then A = π × r² = 3.14 × 4.1² = 3.14 × 16.81 ≈ 52.8 m². That's the size of the opening letting light (and rain!) into the Pantheon.",
                science: .geometry,
                hints: [
                    "Start by finding the radius — it's half the diameter.",
                    "r = 8.2 ÷ 2 = 4.1 m. Now square it: 4.1² = ?",
                    "4.1² = 16.81. Multiply by π: 3.14 × 16.81 = ?"
                ]
            )),

            // ── 12. GEOMETRY CALCULATION: Hemisphere Volume ──────

            .question(LessonQuestion(
                question: "The dome is a hemisphere with an interior diameter of 43.3 meters. Using V = (2/3)πr³, what is the approximate volume of the dome's interior hemisphere?",
                options: [
                    "≈ 21,300 m³",
                    "≈ 42,500 m³",
                    "≈ 10,700 m³",
                    "≈ 5,400 m³"
                ],
                correctIndex: 0,
                explanation: "The radius is r = 43.3 ÷ 2 = 21.65 m. Volume = (2/3) × π × r³ = (2/3) × 3.14 × 21.65³ = (2/3) × 3.14 × 10,152 ≈ (2/3) × 31,877 ≈ 21,252 m³. That's enough space to hold over 8 Olympic swimming pools!",
                science: .geometry,
                hints: [
                    "First find the radius from the diameter, then cube it.",
                    "r = 21.65 m. Now compute r³ = 21.65 × 21.65 × 21.65",
                    "r³ ≈ 10,152. Plug in: V = (2/3) × 3.14 × 10,152"
                ]
            )),

            // ── 12b. QUESTION: Geometry Ratio ────────────────────

            .question(LessonQuestion(
                question: "The oculus diameter is approximately what fraction of the dome's interior diameter?",
                options: [
                    "One half (1/2)",
                    "One third (1/3)",
                    "One fifth (1/5)",
                    "One tenth (1/10)"
                ],
                correctIndex: 2,
                explanation: "The oculus is 8.2 meters wide and the dome's interior diameter is 43.3 meters. 8.2 ÷ 43.3 ≈ 0.19, almost exactly 1/5 — a deliberate proportional relationship. The Romans were masters of mathematical ratios in architecture.",
                science: .geometry,
                hints: [
                    "Divide the oculus diameter by the dome diameter.",
                    "8.2 ÷ 43.3 ≈ 0.19. Which fraction is closest to 0.19?"
                ]
            )),

            // ── 12. MATERIALS: Roman Concrete ───────────────────

            .reading(LessonReading(
                title: "The Secret of Roman Concrete",
                body: """
                The Pantheon's dome weighs **4,535 tonnes** — and it's been standing for \
                nearly 2,000 years with no steel inside it at all. How is that possible? \
                The secret is **Roman concrete**.

                Vitruvius wrote down the recipe: mix **quicklime** (calcium oxide, made by \
                heating limestone) with **volcanic ash** called **pozzolana** from near \
                Mount Vesuvius, plus water and chunks of stone. The ratio was \
                **1 part lime to 3 parts pozzolana**.

                The volcanic ash is the magic ingredient. When you mix it with lime and \
                water, a chemical reaction happens that creates a material stronger than \
                modern cement — and it can even harden underwater!
                """,
                science: .materials,
                illustrationIcon: "mountain.2.fill"
            )),

            // ── 13. Fun Fact: Self-healing ──────────────────────

            .funFact(LessonFunFact(
                text: """
                In 2023, **MIT researchers** discovered that Roman builders used **hot mixing** — \
                combining quicklime and volcanic ash at temperatures exceeding **200°C**. This \
                created tiny calcium-rich lumps called **lime clasts**. When cracks form in the \
                concrete, water seeps in and reacts with these lime clasts, producing calcium \
                carbonate that **seals the crack shut**. Roman concrete literally **heals itself** — \
                which is why it lasts millennia while modern concrete crumbles within decades.
                """
            )),

            // ── 14. QUESTION: Materials ─────────────────────────

            .question(LessonQuestion(
                question: "What volcanic material gives Roman concrete its extraordinary durability?",
                options: [
                    "Obsidian glass",
                    "Pumice stone",
                    "Pozzolana (volcanic ash)",
                    "Basalt rock"
                ],
                correctIndex: 2,
                explanation: "Pozzolana — volcanic ash from near Mount Vesuvius — is the key ingredient. When mixed with lime and water, it creates an incredibly strong binder. Vitruvius noted its remarkable ability to harden even underwater, making it essential for Roman harbors and aqueducts too.",
                science: .materials
            )),

            // ── 15. MATERIALS: Graduated Aggregate ──────────────

            .reading(LessonReading(
                title: "The Graduated Dome",
                body: """
                Here's where the builders got really clever. The dome isn't made of the \
                same concrete all the way through. At the bottom, they used **heavy \
                travertine** stone. As they built higher, they switched to lighter \
                **volcanic tuff**. Near the very top, they used **pumice** — a rock so \
                light it actually floats on water!

                Think of it like stacking blocks: you want the heaviest ones at the bottom \
                and the lightest at the top. If they had used heavy stone everywhere, the \
                dome would have been **80% heavier** and probably would have collapsed. \
                By making it lighter as it goes up, they kept the weight manageable — a \
                trick so smart that nobody matched it for over a thousand years.
                """,
                science: .materials,
                illustrationIcon: "chart.bar.fill"
            )),

            // ── 16. Environment: Workshop ───────────────────────

            .environmentPrompt(LessonEnvironmentPrompt(
                destination: .workshop,
                title: "Discover Materials at the Workshop",
                description: "The Pantheon required volcanic ash, limestone, marble, and lead. Visit the Workshop to learn about these raw materials and discover how Romans crafted them into concrete, lime mortar, and marble slabs.",
                icon: "hammer.fill"
            )),

            // ── 17. FILL IN BLANKS: Materials ─────────────────────

            .fillInBlanks(LessonFillInBlanks(
                title: "Complete the Passage",
                text: """
                Roman concrete was made by mixing {{quicklime}} with volcanic ash called \
                {{pozzolana}} from Mount Vesuvius. Vitruvius prescribed a ratio of \
                {{1}} part lime to {{3}} parts pozzolana. The dome used graduated \
                aggregate: heavy {{travertine}} at the base and lightweight {{pumice}} at the top.
                """,
                distractors: ["ite", "obsidian", "2", "5", "granite", "marble"],
                science: .materials
            )),

            // ── 18. QUESTION: Materials ─────────────────────────

            .question(LessonQuestion(
                question: "Why did the builders use progressively lighter aggregate toward the top of the dome?",
                options: [
                    "Lighter materials were cheaper to transport",
                    "To reduce weight where it matters most",
                    "They ran out of heavy stone midway through construction",
                    "For better acoustics inside the temple"
                ],
                correctIndex: 1,
                explanation: "By using heavy travertine at the base and lightweight pumice at the top, the builders reduced the dome's weight exactly where the structural load is most critical. This graduated approach prevented the dome from collapsing under its own massive weight — pure engineering brilliance.",
                science: .materials
            )),

            // ── 18. ARCHITECTURE: Egyptian Columns ──────────────

            .reading(LessonReading(
                title: "Columns from the Desert",
                body: """
                Before you enter the main room, you walk through the **portico** — a big \
                covered porch held up by **16 giant columns** made of Egyptian granite. Each \
                one is carved from a single block of stone, stands **12 meters tall**, and \
                weighs **50 tonnes** (that's about 10 elephants!).

                The front columns were cut from rock at a quarry called **Mons Claudianus** \
                in the Egyptian desert. Getting them to Rome was an epic journey: dragged on \
                sleds to the Nile River, floated on boats to the sea, shipped across the \
                Mediterranean, and then pulled up the Tiber River. That's over **2,500 km** \
                of travel for each column.

                These columns use the **Corinthian style** — the fanciest of the three Greek \
                column designs. You can recognize it by the carved **acanthus leaves** \
                decorating the top.
                """,
                science: .architecture,
                illustrationIcon: "building.columns.fill"
            )),

            // ── 19. Fun Fact: Bronze Scandal ────────────────────

            .funFact(LessonFunFact(
                text: """
                In 1625, Pope **Urban VIII** of the Barberini family stripped **200 tonnes** of \
                bronze from the Pantheon's portico ceiling. He melted it down to cast 80 cannons \
                for Castel Sant'Angelo and Bernini's famous baldachin in St. Peter's Basilica. \
                Romans coined the bitter saying: **"Quod non fecerunt barbari, fecerunt \
                Barberini"** — "What the barbarians didn't do, the Barberini did."
                """
            )),

            // ── 20. ARCHITECTURE: Hidden Engineering ────────────

            .reading(LessonReading(
                title: "Hidden Engineering",
                body: """
                You can't see them from inside, but the Pantheon's walls hide **relieving \
                arches** — brick arches buried in the concrete. Think of them like hidden \
                bridges: they redirect the dome's enormous weight around the doorways and \
                openings, sending the force safely down into **8 massive stone piers**.

                On the outside, **step rings** wrap around the base of the dome like layers \
                of a wedding cake. These push inward and reduce the dome's urge to spread \
                outward by **27%**. The dome even has cracks running up from the bottom — \
                and the Romans planned for this! With those cracks, the dome works like a \
                ring of **wedge-shaped arches** leaning on each other, which is actually \
                more stable than a solid shell.

                Every detail — seen and unseen — keeps the building standing. That's \
                **firmitas** at its best.
                """,
                science: .architecture,
                illustrationIcon: "archivebox.fill"
            )),

            // ── 21. QUESTION: Architecture ──────────────────────

            .question(LessonQuestion(
                question: "What hidden structural feature redirects the dome's weight around doorways?",
                options: [
                    "Iron support beams",
                    "Wooden load-bearing frames",
                    "Relieving arches of brick",
                    "Flying buttresses"
                ],
                correctIndex: 2,
                explanation: "Semicircular relieving arches made of bipedales bricks are embedded within the concrete walls. They're invisible from inside but essential — they redirect the dome's 4,535-tonne load around the niches and doorways into the 8 structural piers. Flying buttresses weren't invented until the Gothic period, 1,000 years later.",
                science: .architecture
            )),

            // ── 22. Environment: Forest ─────────────────────────

            .environmentPrompt(LessonEnvironmentPrompt(
                destination: .forest,
                title: "Gather Timber in the Forest",
                description: "Building the Pantheon required enormous amounts of timber for scaffolding, wooden formwork for the dome, and temporary centering for the arches. Visit the Forest to gather timber for your construction.",
                icon: "tree.fill"
            )),

            // ── 23. ARCHITECTURE: Legacy ────────────────────────

            .reading(LessonReading(
                title: "A Living Legacy",
                body: """
                The Pantheon has been used for nearly 2,000 years straight — first as a \
                temple to the gods, then as a church starting in **609 AD**. That's why it \
                survived when other Roman buildings were taken apart for building materials. \
                The famous painter **Raphael** is buried inside it.

                Over a thousand years later, an architect named **Filippo Brunelleschi** \
                wanted to build the dome for Florence's **Duomo**. He studied the Pantheon \
                and Vitruvius's book to learn how the Romans did it, then figured out how \
                to push those ideas even further.

                When you build the Duomo in this game, you'll see how Brunelleschi stood \
                on the shoulders of these Roman giants to create the biggest dome since \
                the Pantheon itself.
                """,
                science: .architecture,
                illustrationIcon: "sparkles"
            )),
        ]
    )
}
