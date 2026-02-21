import Foundation

// MARK: - Renaissance Italy Lessons (Buildings 9-17)

extension LessonContent {

    // MARK: - Il Duomo (#9)

    static let duomoLesson = BuildingLesson(
        buildingName: "Il Duomo",
        title: "Brunelleschi's Impossible Dome",
        sections: [

            // ── 1. ARCHITECTURE: Introduction ───────────────────

            .reading(LessonReading(
                title: "The Cathedral That Waited",
                body: """
                In **1296**, the city of **Florence** began building a massive cathedral — \
                **Santa Maria del Fiore**. But there was a problem: they planned a dome \
                so enormous that nobody knew how to build it. For over **100 years**, the \
                cathedral sat with a giant hole in its roof!

                Then, in **1418**, a goldsmith-turned-architect named **Filippo Brunelleschi** \
                won a competition to finish the job. He had studied the **Pantheon** in Rome \
                and figured out a revolutionary new way to build a dome — without the \
                traditional wooden scaffolding called **centering**.
                """,
                science: .architecture,
                illustrationIcon: "building.columns.fill"
            )),

            // ── 2. Fun Fact: The Competition ────────────────────

            .funFact(LessonFunFact(
                text: """
                The competition to design the dome was fierce. **Brunelleschi** and his rival \
                **Lorenzo Ghiberti** both submitted plans. Legend says Brunelleschi challenged \
                the judges: "Whoever can make an egg stand upright on a marble table should \
                build the dome." When nobody could, Brunelleschi smashed the bottom of the egg \
                flat and stood it up. "Anyone could have done that!" they protested. "Yes," he \
                replied, "and anyone could build the dome — **after seeing my plans**."
                """
            )),

            // ── 3. QUESTION: Architecture ───────────────────────

            .question(LessonQuestion(
                question: "Why did Florence's cathedral remain unfinished for over 100 years?",
                options: [
                    "The city ran out of money",
                    "Nobody knew how to build the planned dome",
                    "A war destroyed the original plans",
                    "The Pope forbade construction"
                ],
                correctIndex: 1,
                explanation: "The planned dome was so large (42 meters across) that no architect could figure out how to build it. Traditional methods required wooden centering (temporary scaffolding), but no tree was tall enough to span the gap. It took Brunelleschi's revolutionary engineering to solve the problem.",
                science: .architecture
            )),

            // ── 4. GEOMETRY: The Octagonal Shape ────────────────

            .reading(LessonReading(
                title: "Eight Sides, One Dome",
                body: """
                Unlike the Pantheon's **circular** dome, the Duomo is built on an \
                **octagonal** base — that's an eight-sided shape. Think of it like a \
                stop sign standing up, with a dome rising from each of its eight edges.

                The dome spans **42 meters** across — just barely smaller than the \
                Pantheon's 43.3 meters. But here's what makes it harder: the Pantheon's \
                dome sits on massive **6.4-meter-thick walls**, while the Duomo's dome \
                sits on a tall **drum** (a raised octagonal wall) **13 meters** high. \
                That means the dome is perched way up in the air, where it's much harder \
                to support.
                """,
                science: .geometry,
                illustrationIcon: "octagon"
            )),

            // ── 5. Fun Fact: The Herringbone Secret ─────────────

            .funFact(LessonFunFact(
                text: """
                Brunelleschi's secret weapon was the **herringbone brick pattern**. Instead \
                of laying all bricks flat, he angled some bricks vertically in a zigzag \
                pattern (like the bones of a fish — that's where the name comes from). \
                These vertical bricks acted like tiny **bookends**, keeping each ring of \
                bricks locked in place while the mortar dried. This meant each ring could \
                support itself without any wooden scaffolding underneath!
                """
            )),

            // ── 6. GEOMETRY: Calculating Circumference ──────────

            .question(LessonQuestion(
                question: "The Duomo's octagonal drum has a diameter of 42 meters. If we approximate it as a circle, what is its circumference? Use C = πd with π ≈ 3.14.",
                options: [
                    "≈ 131.9 meters",
                    "≈ 84.0 meters",
                    "≈ 263.8 meters",
                    "≈ 65.9 meters"
                ],
                correctIndex: 0,
                explanation: "C = π × d = 3.14 × 42 = 131.88 meters ≈ 131.9 meters. That's longer than a football field! Imagine laying bricks around that entire distance, ring after ring, over 4 million bricks total.",
                science: .geometry,
                hints: [
                    "The formula for circumference is C = π × diameter.",
                    "Plug in: C = 3.14 × 42",
                    "3.14 × 42 = 131.88 ≈ 131.9 meters"
                ]
            )),

            // ── 7. ARCHITECTURE: Double Shell ───────────────────

            .reading(LessonReading(
                title: "A Dome Inside a Dome",
                body: """
                Here's Brunelleschi's cleverest trick: he didn't build one dome — he \
                built **two**! An outer dome (the one you see from outside) and a \
                thinner inner dome (the one you see from inside). Between them is a \
                gap about **1.2 meters** wide, connected by stone **ribs**.

                Think of it like a thermos bottle: the outer wall protects against \
                weather, while the inner wall creates the beautiful ceiling you see \
                when looking up. The gap between them makes the whole structure \
                much **lighter** than a single thick dome would be — saving about \
                **25%** of the weight. You can actually climb **463 steps** through \
                this gap all the way to the top!
                """,
                science: .architecture,
                illustrationIcon: "circle.circle"
            )),

            // ── 8. QUESTION: Architecture ───────────────────────

            .question(LessonQuestion(
                question: "What is the main advantage of Brunelleschi's double-shell dome design?",
                options: [
                    "It looks more decorative from outside",
                    "It reduces weight while maintaining strength",
                    "It keeps rain out better than a single dome",
                    "It was cheaper to build"
                ],
                correctIndex: 1,
                explanation: "The double-shell design reduces the dome's weight by about 25% compared to a single thick dome. The two shells are connected by ribs that transfer loads efficiently, while the air gap between them means less material is needed. This was critical because the dome sits on a raised drum, not thick walls like the Pantheon.",
                science: .architecture
            )),

            // ── 9. PHYSICS: Weight and Forces ───────────────────

            .reading(LessonReading(
                title: "The Battle Against Gravity",
                body: """
                A dome pushes outward as well as downward — imagine squeezing a ball \
                between your hands, and it tries to bulge out to the sides. This \
                outward push is called **hoop stress**, and it's the force that can \
                crack a dome apart.

                Brunelleschi fought this in two ways. First, he used **stone chains** — \
                rings of sandstone blocks locked together with iron clamps, wrapped \
                around the dome like a belt. These act like a giant rubber band, \
                holding the dome together. Second, the **lantern** on top (weighing \
                a massive **725 tonnes**) actually pushes straight down, keeping the \
                bricks compressed and preventing them from spreading apart.
                """,
                science: .physics,
                illustrationIcon: "arrow.down.circle"
            )),

            // ── 10. Fun Fact: Four Million Bricks ───────────────

            .funFact(LessonFunFact(
                text: """
                The dome contains over **4 million bricks** weighing a total of about \
                **37,000 tonnes** — heavier than the Titanic! Brunelleschi invented a \
                special **ox-powered hoist** to lift materials to the top. It had a \
                reversible gear so the oxen could walk in circles without stopping, \
                switching between lifting and lowering loads. Even **Leonardo da Vinci** \
                sketched this machine in his notebooks, calling it a marvel of engineering.
                """
            )),

            // ── 11. QUESTION: Physics ───────────────────────────

            .question(LessonQuestion(
                question: "What is the purpose of the heavy lantern on top of the dome?",
                options: [
                    "It's purely decorative",
                    "It houses a bell",
                    "Its weight compresses the bricks and prevents spreading",
                    "It collects rainwater"
                ],
                correctIndex: 2,
                explanation: "The 725-tonne lantern acts as a stabilizing keystone. Its enormous weight pushes straight down on the top of the dome, keeping the bricks in compression and counteracting the outward hoop stress that could cause the dome to crack and spread apart.",
                science: .physics
            )),

            // ── 12. GEOMETRY: Comparing Domes ───────────────────

            .question(LessonQuestion(
                question: "The Pantheon's dome has a diameter of 43.3m, and the Duomo's is 42m. What percentage of the Pantheon's diameter is the Duomo's? (Round to nearest whole number)",
                options: [
                    "≈ 97%",
                    "≈ 90%",
                    "≈ 85%",
                    "≈ 75%"
                ],
                correctIndex: 0,
                explanation: "42 ÷ 43.3 = 0.97 = 97%. The two domes are nearly identical in span! But the Duomo is arguably more impressive because it was built without concrete (just brick and stone) and without centering, perched on a 13-meter drum rather than resting on massive walls.",
                science: .geometry,
                hints: [
                    "Divide the Duomo's diameter by the Pantheon's diameter.",
                    "42 ÷ 43.3 = ?",
                    "42 ÷ 43.3 ≈ 0.97. Convert to percentage: 0.97 × 100 = 97%"
                ]
            )),

            // ── 13. FILL IN BLANKS: Architecture ────────────────

            .fillInBlanks(LessonFillInBlanks(
                title: "Complete the Passage",
                text: """
                Filippo {{Brunelleschi}} won the competition to build the Duomo's dome in \
                {{1418}}. He used a {{herringbone}} brick pattern that made each ring \
                self-supporting. The {{double shell}} design reduced weight by 25%. Stone \
                chains and a heavy {{lantern}} prevent the dome from spreading apart.
                """,
                distractors: ["Ghiberti", "1296", "running bond", "single wall", "oculus"],
                science: .architecture
            )),

            // ── 14. Environment: Workshop ───────────────────────

            .environmentPrompt(LessonEnvironmentPrompt(
                destination: .workshop,
                title: "Gather Materials for the Duomo",
                description: "The Duomo required marble slabs for its polychrome exterior, terracotta tiles for the dome, stained glass for the windows, and pigments for the interior frescoes. Visit the Workshop to craft these materials.",
                icon: "hammer.fill"
            )),

            // ── 15. PHYSICS: How the Herringbone Works ──────────

            .reading(LessonReading(
                title: "How Herringbone Bricks Work",
                body: """
                Imagine stacking books on a shelf. If you lay them all flat, they can \
                slide off easily. But if you lean some books against each other at \
                angles, they lock in place — that's basically how herringbone works.

                In the dome, most bricks are laid **horizontally** in rings. But every \
                few bricks, Brunelleschi placed one **vertically** (on its end). These \
                vertical bricks act like **bookends**, preventing the horizontal bricks \
                from sliding inward before the mortar sets. This was revolutionary — \
                it meant he could build the dome **ring by ring** without any wooden \
                framework underneath.
                """,
                science: .physics,
                illustrationIcon: "rectangle.split.3x3"
            )),

            // ── 16. QUESTION: Physics ───────────────────────────

            .question(LessonQuestion(
                question: "How do the vertical bricks in the herringbone pattern help during construction?",
                options: [
                    "They make the dome more waterproof",
                    "They prevent horizontal bricks from sliding before mortar sets",
                    "They create decorative patterns on the surface",
                    "They allow for window openings"
                ],
                correctIndex: 1,
                explanation: "The vertical bricks act as bookends or mechanical keys, locking the horizontal bricks in place while the mortar is still wet. This eliminated the need for wooden centering — the temporary framework that domes traditionally required during construction.",
                science: .physics
            )),

            // ── 17. Environment: Forest ─────────────────────────

            .environmentPrompt(LessonEnvironmentPrompt(
                destination: .forest,
                title: "Gather Timber for Hoisting",
                description: "While the dome itself needed no wooden centering, Brunelleschi's construction required enormous timber for the ox-powered hoist, scaffolding platforms, and the wooden chains between stone rings. Visit the Forest to gather timber.",
                icon: "tree.fill"
            )),

            // ── 18. ARCHITECTURE: Frescoes and Completion ───────

            .reading(LessonReading(
                title: "Painting Heaven Inside",
                body: """
                After the dome was finished in **1436**, artists painted the inside with \
                a massive **fresco** — a painting done on wet plaster. **Giorgio Vasari** \
                and **Federico Zuccari** created **The Last Judgment**, covering over \
                **3,600 square meters** of curved surface. That's about the size of \
                ten tennis courts — on a ceiling!

                Brunelleschi never saw the completed interior. He died in **1446**, just \
                ten years after the dome was finished. But his achievement changed \
                architecture forever. He proved that ancient Roman engineering could be \
                combined with new ideas to create something even the Romans couldn't \
                have imagined.
                """,
                science: .architecture,
                illustrationIcon: "paintbrush.fill"
            )),

            // ── 19. Fun Fact: Still the Largest ─────────────────

            .funFact(LessonFunFact(
                text: """
                The Duomo's dome is **still the largest masonry dome ever built** — nearly \
                600 years later! No one has built a bigger dome using just bricks and mortar \
                (without steel or reinforced concrete). It weighs about **37,000 tonnes** and \
                rises **114.5 meters** above street level. The ball and cross on top of the \
                lantern was made by **Andrea del Verrocchio** — whose young apprentice was \
                none other than **Leonardo da Vinci**.
                """
            )),

            // ── 20. QUESTION: Architecture ──────────────────────

            .question(LessonQuestion(
                question: "What ancient building did Brunelleschi study before designing the Duomo's dome?",
                options: [
                    "The Colosseum in Rome",
                    "The Parthenon in Athens",
                    "The Pantheon in Rome",
                    "The Hagia Sophia in Constantinople"
                ],
                correctIndex: 2,
                explanation: "Brunelleschi spent years in Rome studying the Pantheon and its revolutionary concrete dome. He analyzed its graduated aggregate technique, coffered ceiling, and structural principles. While he couldn't use concrete (the Roman recipe was lost), he adapted the principles using brick and his innovative herringbone pattern.",
                science: .architecture
            )),
        ]
    )

    // MARK: - Botanical Garden (#10)

    static let botanicalGardenLesson = BuildingLesson(
        buildingName: "Botanical Garden",
        title: "The Garden of Knowledge",
        sections: [

            // ── 1. BIOLOGY: Introduction ────────────────────────

            .reading(LessonReading(
                title: "The World's First University Garden",
                body: """
                In **1545**, the University of **Padua** created something brand new — \
                a garden specifically designed for studying plants scientifically. It's \
                the **oldest botanical garden** in the world that's still in its \
                original location!

                Before this, people grew plants in **monastery gardens** mainly for \
                medicine and food. But the Padua garden was different: it was organized \
                by **plant families**, with labels and careful records. It was a \
                **living library** where students could learn to identify plants and \
                understand how they grow.
                """,
                science: .biology,
                illustrationIcon: "leaf.fill"
            )),

            // ── 2. Fun Fact: The Palm Tree ──────────────────────

            .funFact(LessonFunFact(
                text: """
                The garden's most famous resident is a **Mediterranean palm** planted in \
                **1585** — making it over **440 years old**! It's called "Goethe's Palm" \
                because the German poet **Johann Wolfgang von Goethe** visited in 1786 and \
                was so inspired by this tree that he wrote an essay about how plants evolve \
                their shapes. This single palm tree helped spark the science of **plant \
                morphology** (the study of plant forms).
                """
            )),

            // ── 3. QUESTION: Biology ────────────────────────────

            .question(LessonQuestion(
                question: "What made the Padua Botanical Garden different from earlier monastery gardens?",
                options: [
                    "It was much larger",
                    "It was organized scientifically for studying plants",
                    "It only grew flowers, not herbs",
                    "It was open to the public for free"
                ],
                correctIndex: 1,
                explanation: "While monastery gardens grew plants mainly for practical use (medicine and food), the Padua garden was designed for scientific study. Plants were organized by families, carefully labeled, and used for teaching — making it the first true botanical research garden.",
                science: .biology
            )),

            // ── 4. CHEMISTRY: Medicinal Plants ──────────────────

            .reading(LessonReading(
                title: "Nature's Pharmacy",
                body: """
                Renaissance botanical gardens were like **living pharmacies**. Doctors \
                and students came to learn which plants could heal — and which were \
                dangerous.

                **Digitalis** (from the **foxglove** plant) was used to treat heart \
                problems. **Quinine** (from **cinchona bark**, brought from South America) \
                fought **malaria**. **Willow bark** contained a chemical we now call \
                **aspirin**. But these same plants could be deadly in the wrong dose — \
                the difference between medicine and poison was just a matter of \
                **concentration**.
                """,
                science: .chemistry,
                illustrationIcon: "cross.case.fill"
            )),

            // ── 5. Fun Fact: Poison Garden ──────────────────────

            .funFact(LessonFunFact(
                text: """
                Many botanical gardens had a special locked section for **poisonous plants**. \
                Students had to learn to recognize **belladonna** (deadly nightshade), \
                **hemlock** (which killed Socrates), and **wolfsbane**. The professor held \
                the only key! Some Renaissance doctors became experts at both **healing and \
                poisoning** — and a few were suspected of using their knowledge for both.
                """
            )),

            // ── 6. QUESTION: Chemistry ──────────────────────────

            .question(LessonQuestion(
                question: "What determines whether a medicinal plant heals or harms?",
                options: [
                    "The color of the flower",
                    "The time of year it's picked",
                    "The concentration (dose)",
                    "Whether it grows in sun or shade"
                ],
                correctIndex: 2,
                explanation: "The key principle of toxicology — 'the dose makes the poison' — was first stated by the Renaissance physician Paracelsus. Digitalis in small doses regulates the heart, but too much stops it. Understanding concentration was fundamental to Renaissance pharmacy.",
                science: .chemistry
            )),

            // ── 7. CHEMISTRY: Distillation ──────────────────────

            .reading(LessonReading(
                title: "Extracting Nature's Essences",
                body: """
                Renaissance scientists didn't just grow plants — they **extracted** useful \
                chemicals from them using a process called **distillation**.

                Here's how it works: you heat a plant in water until it becomes **steam**. \
                The steam carries the plant's **essential oils** with it. Then you cool \
                the steam down, and it turns back into liquid — but now it's a \
                **concentrated** version of the plant's chemistry. This is how they made \
                **perfumes**, **medicines**, and even early **chemical reagents**.

                The equipment they used — glass flasks, tubes, and cooling coils — \
                looked a lot like a chemistry lab. In fact, these botanical distilleries \
                were some of the **first modern laboratories**!
                """,
                science: .chemistry,
                illustrationIcon: "flame.fill"
            )),

            // ── 8. GEOLOGY: Soil and Growth ─────────────────────

            .reading(LessonReading(
                title: "The Ground Beneath the Plants",
                body: """
                Renaissance gardeners discovered that the **same plant** could produce \
                very different medicines depending on the **soil** it grew in. They \
                called this connection between land and growth what we now call **terroir**.

                **Clay soil** holds water well — good for plants that like moisture. \
                **Sandy soil** drains quickly — better for Mediterranean herbs. \
                **Volcanic soil** (like near Vesuvius) is rich in minerals and grows \
                incredibly potent plants. The pH of soil — whether it's **acidic** or \
                **alkaline** — also affects which nutrients plants can absorb.
                """,
                science: .geology,
                illustrationIcon: "mountain.2.fill"
            )),

            // ── 9. QUESTION: Geology ────────────────────────────

            .question(LessonQuestion(
                question: "Why does the same plant species produce different medicinal properties in different soils?",
                options: [
                    "The plant changes its DNA in each soil",
                    "Soil minerals, pH, and water content affect the plant's chemistry",
                    "The color of the soil stains the roots",
                    "Wind patterns vary between soil types"
                ],
                correctIndex: 1,
                explanation: "Plants absorb different minerals depending on soil composition. Volcanic soils are mineral-rich, producing more potent plants. Soil pH determines which nutrients dissolve in water and become available to roots. This is why Renaissance gardeners carefully matched soil types to their desired plants.",
                science: .geology
            )),

            // ── 10. FILL IN BLANKS: Biology ─────────────────────

            .fillInBlanks(LessonFillInBlanks(
                title: "Complete the Passage",
                text: """
                The world's oldest botanical garden was founded at the University of \
                {{Padua}} in {{1545}}. Renaissance gardens served as living \
                {{pharmacies}} where students studied medicinal plants. The process \
                of {{distillation}} was used to extract essential oils. The quality \
                of soil, or {{terroir}}, affects the chemistry of plants.
                """,
                distractors: ["Florence", "1492", "libraries", "fermentation", "climate"],
                science: .biology
            )),

            // ── 11. BIOLOGY: Classification ─────────────────────

            .reading(LessonReading(
                title: "Naming the Natural World",
                body: """
                With thousands of plants arriving from the **New World** (the Americas), \
                Renaissance botanists needed a way to **organize** them. They began \
                grouping plants by shared features — leaf shape, flower structure, \
                seed type — creating the first **classification systems**.

                A professor named **Luca Ghini** at Pisa invented the **herbarium** — \
                a collection of dried, pressed plants glued to paper with labels. \
                This was revolutionary! For the first time, scientists could compare \
                plants from different regions without traveling. These early systems \
                paved the way for **Carl Linnaeus**, who created the modern \
                **genus-species** naming system 200 years later.
                """,
                science: .biology,
                illustrationIcon: "books.vertical.fill"
            )),

            // ── 12. QUESTION: Biology ───────────────────────────

            .question(LessonQuestion(
                question: "What was a 'herbarium' and why was it revolutionary?",
                options: [
                    "A greenhouse for growing tropical plants indoors",
                    "A collection of dried, pressed plants for comparison and study",
                    "A recipe book for herbal medicines",
                    "A garden maze designed for meditation"
                ],
                correctIndex: 1,
                explanation: "A herbarium preserved dried, pressed plant specimens on labeled sheets. For the first time, scientists could compare plants from different continents without traveling. Luca Ghini created the first known herbarium in the 1530s, and the technique is still used by botanists today.",
                science: .biology
            )),

            // ── 13. Environment: Workshop ───────────────────────

            .environmentPrompt(LessonEnvironmentPrompt(
                destination: .workshop,
                title: "Craft Materials for the Garden",
                description: "The Botanical Garden needed lime mortar for its brick walls, glass panes for greenhouse roofing, and marble for its pathways and fountains. Visit the Workshop to craft these materials.",
                icon: "hammer.fill"
            )),

            // ── 14. Environment: Forest ─────────────────────────

            .environmentPrompt(LessonEnvironmentPrompt(
                destination: .forest,
                title: "Collect Plant Specimens",
                description: "Renaissance botanists explored forests and wild areas to discover new plant species. Visit the Forest to find specimens for your garden's herbarium.",
                icon: "tree.fill"
            )),

            // ── 15. BIOLOGY: Legacy ─────────────────────────────

            .reading(LessonReading(
                title: "Seeds of Modern Science",
                body: """
                The Renaissance botanical gardens planted the seeds (literally!) for \
                modern **biology**, **chemistry**, and **medicine**. The careful \
                observation, labeling, and classification they practiced became the \
                foundation of the **scientific method**.

                Today, botanical gardens around the world continue this mission. The \
                Padua garden — now a **UNESCO World Heritage Site** — still grows many \
                of the same species planted 480 years ago. It reminds us that science \
                begins with **curiosity** and careful **observation** of the natural world.
                """,
                science: .biology,
                illustrationIcon: "sparkles"
            )),

            // ── 16. QUESTION: Biology ───────────────────────────

            .question(LessonQuestion(
                question: "What scientific practice, fundamental to modern biology, was pioneered in Renaissance botanical gardens?",
                options: [
                    "Genetic engineering",
                    "Systematic observation and classification",
                    "Microscopy",
                    "DNA analysis"
                ],
                correctIndex: 1,
                explanation: "Renaissance botanical gardens pioneered systematic observation, labeling, and classification of plants — core practices of the scientific method. By carefully recording plant characteristics and organizing them by shared features, these gardens laid the groundwork for modern taxonomy and biology.",
                science: .biology
            )),
        ]
    )

    // MARK: - Glassworks (#11)

    static let glassworksLesson = BuildingLesson(
        buildingName: "Glassworks",
        title: "Fire and Light on Murano",
        sections: [

            // ── 1. CHEMISTRY: Introduction ──────────────────────

            .reading(LessonReading(
                title: "The Island of Secrets",
                body: """
                In **1291**, the government of **Venice** ordered all glassmakers to \
                move their workshops to the island of **Murano**, about a mile from \
                the city. The official reason was **fire safety** — glass furnaces \
                reached **1,400°C** and could burn down the wooden buildings of Venice. \
                But the real reason was to keep the glassmakers' secrets under lock \
                and key.

                Venetian glass was the finest in the world, and the government made it \
                a **crime punishable by death** for any glassmaker to leave Murano or \
                share their techniques. These artisans were both **prisoners and \
                celebrities** — they couldn't leave, but they lived like nobility.
                """,
                science: .chemistry,
                illustrationIcon: "flame.fill"
            )),

            // ── 2. Fun Fact: Death Penalty ──────────────────────

            .funFact(LessonFunFact(
                text: """
                The Venetian decree of 1291 stated that any glassmaker who left Murano \
                would have their **family members imprisoned** until they returned. If they \
                still refused to come back, **assassins would be sent**. Despite this, some \
                glassmakers did escape to other countries, spreading Venetian techniques \
                across Europe. The phrase **"Murano glass"** became so famous that imitators \
                everywhere tried to copy it — usually failing to match the original quality.
                """
            )),

            // ── 3. CHEMISTRY: Glass Recipe ──────────────────────

            .reading(LessonReading(
                title: "The Recipe for Glass",
                body: """
                Glass is made from just three main ingredients, but getting the recipe \
                right is incredibly tricky.

                **Silica** (silicon dioxide, **SiO₂**) is the main ingredient — it comes \
                from **sand**. But silica alone melts at a scorching **1,700°C**, which \
                was impossible for Renaissance furnaces. So glassmakers added **soda ash** \
                (sodium carbonate, **Na₂CO₃**) as a **flux** — a substance that lowers \
                the melting point to about **1,400°C**.

                There's a catch: glass made with just silica and soda dissolves in water! \
                Adding **lime** (calcium oxide, **CaO**) fixes this, making the glass \
                stable and durable. The basic ratio was about **75% silica, 15% soda, \
                10% lime**.
                """,
                science: .chemistry,
                illustrationIcon: "testtube.2"
            )),

            // ── 4. QUESTION: Chemistry ──────────────────────────

            .question(LessonQuestion(
                question: "Why did glassmakers add soda ash (Na₂CO₃) to the silica?",
                options: [
                    "To make the glass more transparent",
                    "To add color to the glass",
                    "To lower the melting point of silica",
                    "To make the glass waterproof"
                ],
                correctIndex: 2,
                explanation: "Pure silica melts at 1,700°C — far too hot for Renaissance furnaces. Soda ash acts as a flux, lowering the melting temperature to about 1,400°C, which was achievable. Without this flux, glass production would have been impossible with the technology of the time.",
                science: .chemistry
            )),

            // ── 5. CHEMISTRY: Cristallo Glass ───────────────────

            .reading(LessonReading(
                title: "The Invention of Crystal-Clear Glass",
                body: """
                Around **1450**, a Murano glassmaker named **Angelo Barovier** achieved \
                something remarkable: he created **cristallo** — glass so clear it looked \
                like **rock crystal**. Previous glass always had a greenish or brownish \
                tint from iron impurities in the sand.

                Barovier's secret was using **manganese dioxide** (MnO₂) to neutralize \
                the iron's color. He also carefully selected the purest **quartz pebbles** \
                instead of ordinary sand, and purified his soda ash by burning specific \
                seashore plants. The result was the clearest glass the world had ever \
                seen — and it made Venice fabulously wealthy.
                """,
                science: .chemistry,
                illustrationIcon: "sparkle"
            )),

            // ── 6. Fun Fact: Colored Glass ──────────────────────

            .funFact(LessonFunFact(
                text: """
                Murano glassmakers could create almost any color by adding different \
                **metal oxides**: **cobalt** for deep blue, **copper** for green or red \
                (depending on conditions), **gold** for a stunning ruby red (called \
                **cranberry glass**), **tin** for opaque white, and **manganese** for \
                purple. The exact recipes were family secrets, passed from father to son. \
                Some colors — like the famous **Murano red** — required such precise \
                temperatures that only the most skilled masters could produce them.
                """
            )),

            // ── 7. OPTICS: Light and Glass ──────────────────────

            .reading(LessonReading(
                title: "Bending Light",
                body: """
                When light passes from air into glass, something magical happens — it \
                **bends**. This bending is called **refraction**, and it happens because \
                light travels **slower** through glass than through air.

                Venetian glassmakers noticed that curved glass could **magnify** things. \
                By the late 1200s, they were making **reading stones** (half-sphere \
                magnifiers) and eventually **spectacles** — eyeglasses! These were some \
                of the first **optical instruments**, and they changed the world. \
                Eventually, this understanding of refraction led to **telescopes** and \
                **microscopes**.
                """,
                science: .optics,
                illustrationIcon: "eye.fill"
            )),

            // ── 8. QUESTION: Optics ─────────────────────────────

            .question(LessonQuestion(
                question: "What causes light to bend when it enters glass?",
                options: [
                    "Glass absorbs some wavelengths of light",
                    "The color of the glass filters the light",
                    "Light travels at a different speed in glass than in air",
                    "The smooth surface of glass reflects light"
                ],
                correctIndex: 2,
                explanation: "Refraction occurs because light changes speed when moving between materials. Light travels slower through glass than through air, causing it to bend at the boundary. This principle — first observed by Venetian glassmakers — is the foundation of all lens-based technology.",
                science: .optics
            )),

            // ── 9. MATERIALS: Glassblowing ──────────────────────

            .reading(LessonReading(
                title: "The Art of Glassblowing",
                body: """
                At **1,400°C**, glass becomes a glowing orange liquid that can be shaped \
                like taffy. A glassblower gathers a blob of molten glass on the end of \
                a long iron **blowpipe**, then blows air into it like inflating a balloon. \
                By twisting, pulling, and using tools, they can create **vases**, \
                **goblets**, **beads**, and even incredibly thin **chandeliers**.

                But timing is everything. Work too slowly and the glass hardens — try \
                to reheat it too fast and it can **shatter** from thermal stress. After \
                shaping, the finished piece goes into a special oven called a **lehr** \
                for **annealing** — slowly cooling it over many hours to prevent \
                internal cracks.
                """,
                science: .materials,
                illustrationIcon: "wand.and.stars"
            )),

            // ── 10. QUESTION: Materials ─────────────────────────

            .question(LessonQuestion(
                question: "What is 'annealing' and why is it essential in glassmaking?",
                options: [
                    "Adding color to molten glass",
                    "Slowly cooling glass to prevent internal stress and cracking",
                    "Polishing the glass surface to make it clear",
                    "Heating glass to remove air bubbles"
                ],
                correctIndex: 1,
                explanation: "Annealing is the controlled slow cooling of glass in a special oven called a lehr. When glass cools unevenly, different parts shrink at different rates, creating internal stresses that can cause spontaneous cracking. Slow, uniform cooling allows these stresses to release gradually.",
                science: .materials
            )),

            // ── 11. FILL IN BLANKS: Chemistry ───────────────────

            .fillInBlanks(LessonFillInBlanks(
                title: "Complete the Passage",
                text: """
                Glass is made primarily from {{silica}} (SiO₂), with {{soda ash}} added \
                as a flux to lower the melting point. Angelo {{Barovier}} invented cristallo \
                glass around 1450. When light passes through glass, it bends — a phenomenon \
                called {{refraction}}. Finished glass must be slowly cooled in a process \
                called {{annealing}}.
                """,
                distractors: ["calcium", "pumice", "Galileo", "reflection", "tempering"],
                science: .chemistry
            )),

            // ── 12. Environment: Workshop ───────────────────────

            .environmentPrompt(LessonEnvironmentPrompt(
                destination: .workshop,
                title: "Craft Materials for the Glassworks",
                description: "Building a glassworks requires lime mortar for the thick brick walls, timber beams for the roof structure, terracotta tiles for heat-resistant flooring, and bronze fittings for the furnace. Visit the Workshop to gather these materials.",
                icon: "hammer.fill"
            )),

            // ── 13. OPTICS: Lenses and Discovery ────────────────

            .reading(LessonReading(
                title: "From Glass to Discovery",
                body: """
                The same principles of refraction that Venetian glassmakers used for \
                spectacles eventually led to some of the greatest scientific discoveries \
                in history. In **1609**, **Galileo Galilei** used Venetian glass lenses \
                to build a **telescope** that magnified objects **20 times**. Looking \
                at the night sky, he discovered the **moons of Jupiter**, the **phases \
                of Venus**, and **craters on the Moon**.

                All of this was possible because Murano glassmakers had spent centuries \
                perfecting clear, bubble-free glass. Without their cristallo, the \
                Scientific Revolution might have been delayed by decades.
                """,
                science: .optics,
                illustrationIcon: "sparkles"
            )),

            // ── 14. QUESTION: Optics ────────────────────────────

            .question(LessonQuestion(
                question: "How did Venetian glassmaking contribute to Galileo's astronomical discoveries?",
                options: [
                    "Glassmakers funded his research",
                    "Their cristallo glass provided the clear lenses he needed for his telescope",
                    "They built the observatory where he worked",
                    "Glass mirrors were used to reflect starlight"
                ],
                correctIndex: 1,
                explanation: "Galileo's telescope relied on high-quality glass lenses to magnify distant objects. The cristallo glass perfected by Murano artisans was the clearest available, making precise lens-grinding possible. Without centuries of Venetian glassmaking expertise, Galileo's discoveries would not have been possible.",
                science: .optics
            )),
        ]
    )

    // MARK: - Arsenal (#12)

    static let arsenalLesson = BuildingLesson(
        buildingName: "Arsenal",
        title: "The Assembly Line of Venice",
        sections: [

            // ── 1. ENGINEERING: Introduction ────────────────────

            .reading(LessonReading(
                title: "The World's First Factory",
                body: """
                Long before Henry Ford invented the automobile assembly line, the \
                **Arsenale di Venezia** (Venice Arsenal) was doing something remarkably \
                similar — in the **1300s**! This massive shipyard could build a fully \
                equipped **warship** (called a **galley**) in just **one day**.

                At its peak, the Arsenal employed **16,000 workers** — making it the \
                largest industrial complex in Europe. It covered **45 acres** (about \
                32 football fields) and had its own foundries, rope-making facilities, \
                timber storage, and even a bakery to provision the ships.
                """,
                science: .engineering,
                illustrationIcon: "ferry.fill"
            )),

            // ── 2. Fun Fact: Henry III's Visit ──────────────────

            .funFact(LessonFunFact(
                text: """
                In **1574**, when King **Henry III of France** visited Venice, the Arsenal \
                workers put on a show. They assembled a **complete galley** — from bare keel \
                to fully armed warship — in the time it took the king to eat his banquet \
                dinner. That's about **2 hours**! This was possible because every part was \
                **pre-made** and **standardized**, ready to snap together like a giant kit. \
                Henry was so astonished that he declared it the most impressive thing he'd \
                ever seen.
                """
            )),

            // ── 3. QUESTION: Engineering ────────────────────────

            .question(LessonQuestion(
                question: "What made the Venice Arsenal revolutionary for its time?",
                options: [
                    "It built the largest ships in the world",
                    "It used standardized parts and assembly-line production",
                    "It was powered by water wheels",
                    "It invented the compass for navigation"
                ],
                correctIndex: 1,
                explanation: "The Arsenal pioneered standardized, interchangeable parts and an assembly-line approach where ship hulls moved past specialized workstations. Each station added specific components — a concept that wouldn't appear again until the Industrial Revolution, over 300 years later.",
                science: .engineering
            )),

            // ── 4. ENGINEERING: Assembly Line ───────────────────

            .reading(LessonReading(
                title: "Ships on a Conveyor Belt",
                body: """
                Here's how the Arsenal's assembly line worked. A ship's **keel** \
                (the backbone) was laid down at one end of a long canal. Then the \
                hull was **towed along** the canal, passing different stations where \
                workers added specific parts:

                **Station 1**: Keel and ribs (skeleton)
                **Station 2**: Hull planking (skin)
                **Station 3**: Caulking and waterproofing
                **Station 4**: Masts and rigging
                **Station 5**: Weapons and armor
                **Station 6**: Provisions and crew supplies

                Every part at each station was **pre-made to standard sizes**, so any \
                mast fit any ship, any oar fit any oarlock. This **interchangeability** \
                was centuries ahead of its time.
                """,
                science: .engineering,
                illustrationIcon: "line.horizontal.3"
            )),

            // ── 5. PHYSICS: Galley Design ───────────────────────

            .reading(LessonReading(
                title: "The Science of Speed on Water",
                body: """
                A Venetian galley was designed for **speed**. Its long, narrow hull \
                cut through the water with minimal **drag** — the resistance water \
                puts on a moving object. The ratio of length to width was about \
                **8:1** (a galley might be 40 meters long but only 5 meters wide).

                Each galley had about **150 oarsmen** plus sails for wind power. The \
                oars acted as **levers** — the longer the oar, the more force it could \
                apply to the water, but the harder it was to pull. Arsenal engineers \
                calculated the optimal oar length for the best balance of **power** \
                and **speed**.
                """,
                science: .physics,
                illustrationIcon: "wind"
            )),

            // ── 6. QUESTION: Physics ────────────────────────────

            .question(LessonQuestion(
                question: "Why were Venetian galleys designed with a length-to-width ratio of about 8:1?",
                options: [
                    "To carry more cargo",
                    "To reduce water drag and maximize speed",
                    "To fit more oarsmen",
                    "To navigate narrow canals"
                ],
                correctIndex: 1,
                explanation: "A narrow hull creates less drag (water resistance) as it moves forward. The 8:1 ratio was optimized through centuries of experience — too narrow and the ship becomes unstable, too wide and it slows down. This same principle is used in modern racing boats.",
                science: .physics
            )),

            // ── 7. MATERIALS: Wood and Rope ─────────────────────

            .reading(LessonReading(
                title: "Oak, Pine, and Hemp",
                body: """
                Building ships required enormous quantities of **materials**. The Arsenal \
                maintained vast **timber reserves** — primarily **oak** for structural \
                parts (keel, ribs) because it's incredibly strong and rot-resistant, \
                and **pine** for planking because it's lighter and easier to work.

                The **Tana** — the Arsenal's rope-making building — was **316 meters** \
                long, one of the longest buildings in Europe. Workers twisted **hemp \
                fibers** into ropes strong enough to anchor warships in storms. A single \
                galley needed over **1 kilometer** of rope for its rigging!
                """,
                science: .materials,
                illustrationIcon: "tree.fill"
            )),

            // ── 8. Fun Fact: Galileo's Visit ────────────────────

            .funFact(LessonFunFact(
                text: """
                In **1593**, the great scientist **Galileo Galilei** was invited to consult \
                at the Arsenal. He studied the workers' techniques for scaling up ship \
                designs and realized something important: you can't just make a ship \
                **twice as big** by doubling all measurements. A ship twice as long would \
                need to be **much thicker** to avoid breaking — because volume grows faster \
                than area. This insight became the **square-cube law**, one of the \
                foundations of structural engineering.
                """
            )),

            // ── 9. QUESTION: Materials ──────────────────────────

            .question(LessonQuestion(
                question: "Why was oak wood preferred for the keel and structural ribs of galleys?",
                options: [
                    "It was the cheapest wood available",
                    "Its light weight made ships faster",
                    "Its strength and rot-resistance made it ideal for structural parts",
                    "Its color was preferred by Venetian tradition"
                ],
                correctIndex: 2,
                explanation: "Oak is one of the strongest and most durable woods, with natural resistance to rot — critical for parts constantly exposed to seawater. The keel and ribs bear the greatest structural loads, so they required the toughest material. Pine was used for lighter, less critical parts like hull planking.",
                science: .materials
            )),

            // ── 10. ENGINEERING: Standardization ────────────────

            .reading(LessonReading(
                title: "The Power of Standards",
                body: """
                The Arsenal's greatest innovation wasn't any single ship — it was the \
                idea of **standardization**. Every component was made to exact \
                specifications so that parts from different workshops could fit \
                together perfectly.

                This meant that during battle, a damaged ship could be **repaired** \
                using parts from any other Arsenal ship. It also meant new workers \
                could be trained quickly — they only needed to learn **one task** at \
                one station, not how to build an entire ship. This concept of \
                **interchangeable parts** is the foundation of all modern \
                manufacturing.
                """,
                science: .engineering,
                illustrationIcon: "gearshape.2.fill"
            )),

            // ── 11. FILL IN BLANKS: Engineering ─────────────────

            .fillInBlanks(LessonFillInBlanks(
                title: "Complete the Passage",
                text: """
                The Venice {{Arsenal}} could build a galley in one day using \
                {{standardized}} parts. Ship hulls moved along a canal past \
                specialized {{stations}}. The rope-making building called the \
                {{Tana}} was 316 meters long. {{Galileo}} studied ship scaling \
                here and discovered the square-cube law.
                """,
                distractors: ["Colosseum", "custom", "warehouses", "Piazza", "Vesalius"],
                science: .engineering
            )),

            // ── 12. Environment: Workshop ───────────────────────

            .environmentPrompt(LessonEnvironmentPrompt(
                destination: .workshop,
                title: "Gather Arsenal Materials",
                description: "The Arsenal required concrete for its massive walls, timber beams for ship construction, glass panes for workshops, and bronze fittings for ship hardware. Visit the Workshop to craft these essential materials.",
                icon: "hammer.fill"
            )),

            // ── 13. Environment: Forest ─────────────────────────

            .environmentPrompt(LessonEnvironmentPrompt(
                destination: .forest,
                title: "Source Oak for Ship Keels",
                description: "The Arsenal consumed vast quantities of timber — especially oak for keels and ribs. Venice maintained protected forests specifically for ship-building. Visit the Forest to gather timber for the fleet.",
                icon: "tree.fill"
            )),

            // ── 14. ENGINEERING: Legacy ─────────────────────────

            .reading(LessonReading(
                title: "From Galleys to Factories",
                body: """
                The Arsenal's ideas — **assembly lines**, **standardized parts**, \
                **specialized workers** — lay dormant for centuries until the \
                **Industrial Revolution**. When **Eli Whitney** proposed interchangeable \
                parts for muskets in 1798, and **Henry Ford** created his automobile \
                assembly line in 1913, they were unknowingly following the Arsenal's \
                playbook.

                The Arsenal operated for over **700 years** (from the 1100s to 1797), \
                making it one of the longest-running industrial enterprises in history. \
                Even the word "**arsenal**" itself comes from the Venetian dialect \
                word **arzanà**, meaning "house of industry."
                """,
                science: .engineering,
                illustrationIcon: "sparkles"
            )),

            // ── 15. QUESTION: Engineering ───────────────────────

            .question(LessonQuestion(
                question: "What modern manufacturing concept was pioneered at the Venice Arsenal centuries before the Industrial Revolution?",
                options: [
                    "Robot automation",
                    "Assembly line production with interchangeable parts",
                    "Computer-aided design",
                    "3D printing"
                ],
                correctIndex: 1,
                explanation: "The Arsenal pioneered assembly-line production with standardized, interchangeable parts — the same concepts that would later drive the Industrial Revolution. Ship hulls moved past specialized stations where pre-made components were added, just as modern factory products move along conveyor belts.",
                science: .engineering
            )),
        ]
    )

    // MARK: - Anatomy Theater (#13)

    static let anatomyTheaterLesson = BuildingLesson(
        buildingName: "Anatomy Theater",
        title: "The Theater of the Body",
        sections: [

            // ── 1. BIOLOGY: Introduction ────────────────────────

            .reading(LessonReading(
                title: "Learning by Looking",
                body: """
                For over **1,300 years**, European doctors learned about the human body \
                from ancient books written by a Greek physician named **Galen** (129-216 AD). \
                The problem? Galen had never dissected a human — he studied **monkeys and \
                pigs** and assumed humans were similar. He was wrong about many things.

                In **1543**, a young professor at the University of **Padua** named \
                **Andreas Vesalius** decided to see for himself. He performed his own \
                **dissections** and published a book called **De Humani Corporis Fabrica** \
                ("On the Structure of the Human Body") — correcting over **200 of \
                Galen's errors**. This book changed medicine forever.
                """,
                science: .biology,
                illustrationIcon: "person.fill"
            )),

            // ── 2. Fun Fact: Vesalius's Age ─────────────────────

            .funFact(LessonFunFact(
                text: """
                Vesalius published his groundbreaking book when he was just **28 years old**! \
                He personally performed every dissection and supervised the artist **Jan van \
                Calcar** (a student of Titian) who created the stunning illustrations. The \
                book showed **muscular figures in dramatic poses** against Italian landscapes — \
                making anatomy both scientific and artistic. Vesalius's work was so \
                revolutionary that some older professors **burned his book** in protest!
                """
            )),

            // ── 3. QUESTION: Biology ────────────────────────────

            .question(LessonQuestion(
                question: "What was revolutionary about Vesalius's approach to anatomy?",
                options: [
                    "He used X-rays to see inside the body",
                    "He personally performed dissections instead of relying on ancient texts",
                    "He invented the microscope for studying cells",
                    "He was the first to teach anatomy at a university"
                ],
                correctIndex: 1,
                explanation: "Before Vesalius, professors read from Galen's ancient texts while a barber-surgeon did the cutting. Vesalius broke this tradition by performing dissections himself, directly observing the body's actual structure. This hands-on approach corrected over 200 errors in the accepted medical knowledge.",
                science: .biology
            )),

            // ── 4. BIOLOGY: The Theater Itself ──────────────────

            .reading(LessonReading(
                title: "An Oval of Knowledge",
                body: """
                The permanent anatomy theater at Padua was built in **1594** — the oldest \
                surviving anatomy theater in the world. It's shaped like an **oval cone** \
                with **six concentric tiers** of standing galleries, steeply angled so \
                everyone could see the dissection table in the center below.

                The theater is tiny — only about **7.5 meters** across at the top — and \
                could squeeze in about **300 spectators**. There are **no windows**. It's \
                made entirely of carved **walnut wood**, and the only light came from \
                **300 candles** held by spectators or placed in holders around the walls. \
                The atmosphere must have been intense: crowded, hot, dimly lit, with the \
                smell of herbs used to mask the odor of the cadaver.
                """,
                science: .biology,
                illustrationIcon: "eye.circle.fill"
            )),

            // ── 5. OPTICS: Candlelight Design ──────────────────

            .reading(LessonReading(
                title: "Lighting the Unseen",
                body: """
                With **no windows**, lighting the anatomy theater was a serious challenge. \
                The designers used clever **optics**: candles were placed at specific \
                heights and angles around the dissection table, with polished metal \
                **reflectors** behind them to direct light downward.

                The **concentric oval** shape also helped — it focused reflected light \
                toward the center, like a spotlight. The steep viewing angle meant \
                spectators in the upper tiers looked almost straight down, giving \
                them a clear view despite the distance. Every design choice was made \
                to ensure **maximum visibility** of the dissection.
                """,
                science: .optics,
                illustrationIcon: "lightbulb.fill"
            )),

            // ── 6. QUESTION: Optics ─────────────────────────────

            .question(LessonQuestion(
                question: "How did the theater's design solve the challenge of lighting without windows?",
                options: [
                    "They used oil lamps hung from the ceiling",
                    "Candles with metal reflectors directed light toward the center table",
                    "Torches were placed on the walls",
                    "They performed dissections outdoors when possible"
                ],
                correctIndex: 1,
                explanation: "Polished metal reflectors behind candles directed light toward the central dissection table. The oval shape of the theater also helped focus reflected light. About 300 candles were used, creating enough illumination for spectators to observe fine anatomical details.",
                science: .optics
            )),

            // ── 7. CHEMISTRY: Preservation ──────────────────────

            .reading(LessonReading(
                title: "The Race Against Time",
                body: """
                Without refrigeration, bodies decompose quickly — especially in warm \
                weather. That's why dissections were **only performed in winter**, when \
                cold temperatures slowed decay. Even so, a cadaver could only last about \
                **3-4 weeks** of lectures.

                Renaissance anatomists used **embalming** techniques to buy more time. \
                They injected bodies with mixtures of **vinegar**, **turpentine**, and \
                **aromatic herbs** (like rosemary and lavender). These chemicals slowed \
                bacterial growth — though nobody understood bacteria yet. They just knew \
                from experience that these substances **preserved** tissue longer.
                """,
                science: .chemistry,
                illustrationIcon: "snowflake"
            )),

            // ── 8. Fun Fact: Where Bodies Came From ─────────────

            .funFact(LessonFunFact(
                text: """
                Getting bodies for dissection was a major problem. Usually only **executed \
                criminals** were available, and the Church required they be buried quickly. \
                Some anatomy professors had to beg local judges to **time executions** to \
                coincide with their lecture schedules! When bodies ran short, less scrupulous \
                professors hired "**resurrection men**" — grave robbers who dug up fresh \
                corpses under cover of night. The practice was illegal but widely tolerated \
                because medical education depended on it.
                """
            )),

            // ── 9. QUESTION: Chemistry ──────────────────────────

            .question(LessonQuestion(
                question: "Why were anatomical dissections only performed during winter months?",
                options: [
                    "Students were on vacation in summer",
                    "Cold temperatures slowed decomposition of the cadaver",
                    "The theater was too hot in summer",
                    "Professors preferred winter schedules"
                ],
                correctIndex: 1,
                explanation: "Without modern refrigeration, bodies decompose rapidly in warm temperatures. Winter cold naturally slowed this process, giving anatomists 3-4 weeks to perform detailed dissections. Combined with embalming using vinegar and herbs, this was enough time to complete a full anatomy course.",
                science: .chemistry
            )),

            // ── 10. FILL IN BLANKS: Biology ─────────────────────

            .fillInBlanks(LessonFillInBlanks(
                title: "Complete the Passage",
                text: """
                In 1543, {{Vesalius}} published De Humani Corporis Fabrica, correcting \
                over 200 errors by the ancient physician {{Galen}}. The Padua anatomy \
                theater (built {{1594}}) has six concentric tiers of carved {{walnut}} \
                wood. Bodies were preserved using {{vinegar}} and aromatic herbs.
                """,
                distractors: ["Galileo", "Hippocrates", "1450", "oak", "formaldehyde"],
                science: .biology
            )),

            // ── 11. Environment: Workshop ───────────────────────

            .environmentPrompt(LessonEnvironmentPrompt(
                destination: .workshop,
                title: "Craft Materials for the Theater",
                description: "The Anatomy Theater is built entirely from carved walnut wood, with bronze fittings for candle holders and reflectors, and timber beams for the structural frame. Visit the Workshop to craft these materials.",
                icon: "hammer.fill"
            )),

            // ── 12. BIOLOGY: Legacy ─────────────────────────────

            .reading(LessonReading(
                title: "Seeing Is Believing",
                body: """
                The anatomy theater at Padua changed medicine from a subject learned \
                from **books** to a science based on **direct observation**. This \
                principle — that you must **see for yourself** rather than trust \
                ancient authority — is the foundation of the **scientific method**.

                Padua's tradition attracted some of the greatest minds in history. \
                **William Harvey** studied here and later discovered how blood \
                **circulates** through the body. **Galileo** taught mathematics here. \
                The little walnut theater — just 7.5 meters across — helped launch \
                a revolution in how humans understand themselves.
                """,
                science: .biology,
                illustrationIcon: "sparkles"
            )),

            // ── 13. QUESTION: Biology ───────────────────────────

            .question(LessonQuestion(
                question: "What broader scientific principle did the anatomy theater help establish?",
                options: [
                    "That ancient Greek texts are always correct",
                    "That direct observation is more reliable than trusting ancient authority",
                    "That medicine should be practiced without surgery",
                    "That education should be limited to universities"
                ],
                correctIndex: 1,
                explanation: "The anatomy theater embodied the revolutionary idea that scientists must observe directly rather than blindly trust ancient texts. Vesalius proved that Galen was wrong about many things — demonstrating that even respected authorities can be corrected through careful, firsthand observation.",
                science: .biology
            )),
        ]
    )

    // MARK: - Leonardo's Workshop (#14)

    static let leonardoWorkshopLesson = BuildingLesson(
        buildingName: "Leonardo's Workshop",
        title: "The Universal Genius",
        sections: [

            // ── 1. ENGINEERING: Introduction ────────────────────

            .reading(LessonReading(
                title: "The Most Curious Mind in History",
                body: """
                **Leonardo da Vinci** (1452-1519) was perhaps the most talented person \
                who ever lived. He was a **painter**, **sculptor**, **architect**, \
                **engineer**, **scientist**, **musician**, and **inventor** — all at \
                the same time. A person with deep knowledge in many subjects is called \
                a **polymath**, and Leonardo was the ultimate example.

                Leonardo's workshop in **Milan** was a whirlwind of activity. Paintings \
                sat on easels next to **flying machine models**. Anatomical sketches \
                shared tables with **war machine designs**. He filled over **7,000 pages** \
                of notebooks with ideas, drawings, and observations — all written in \
                **mirror script** (backwards, from right to left).
                """,
                science: .engineering,
                illustrationIcon: "pencil.and.outline"
            )),

            // ── 2. Fun Fact: Mirror Writing ─────────────────────

            .funFact(LessonFunFact(
                text: """
                Leonardo wrote **everything backwards** — you need a mirror to read his \
                notebooks naturally. Why? Nobody knows for sure. Some historians think it \
                was to keep his ideas **secret**. Others point out that Leonardo was \
                **left-handed**, and writing right-to-left is actually more natural for \
                lefties (no smudging the ink!). His notebooks contain designs for a \
                **helicopter**, **tank**, **diving suit**, **solar concentrator**, and \
                **calculator** — all centuries before they were actually built.
                """
            )),

            // ── 3. QUESTION: Engineering ────────────────────────

            .question(LessonQuestion(
                question: "Why is Leonardo da Vinci considered a 'polymath'?",
                options: [
                    "He spoke many languages",
                    "He had deep expertise across many different fields",
                    "He traveled to many countries",
                    "He taught at multiple universities"
                ],
                correctIndex: 1,
                explanation: "A polymath is someone with deep knowledge across many subjects. Leonardo excelled in painting, sculpture, anatomy, engineering, mathematics, botany, geology, and more. His ability to connect ideas across fields — like using anatomy to improve his art — made his genius unique.",
                science: .engineering
            )),

            // ── 4. ENGINEERING: Verrocchio's Training ───────────

            .reading(LessonReading(
                title: "Learning in a Master's Workshop",
                body: """
                At age **14**, Leonardo became an apprentice in the workshop of \
                **Andrea del Verrocchio** in Florence — one of the most respected \
                artists and craftsmen of the time. Renaissance workshops were like \
                **trade schools**: apprentices learned painting, sculpting, metalwork, \
                and engineering all at once.

                Verrocchio taught Leonardo to observe the world with **scientific \
                precision** — studying how light falls on surfaces, how muscles move \
                under skin, how water flows. This training turned Leonardo from a \
                talented boy into a genius who could **see the science behind art** \
                and the **art behind science**.
                """,
                science: .engineering,
                illustrationIcon: "graduationcap.fill"
            )),

            // ── 5. PHYSICS: Machines and Forces ─────────────────

            .reading(LessonReading(
                title: "Leonardo's Machines",
                body: """
                Leonardo was fascinated by **forces** and **motion**. He designed \
                hundreds of machines, many based on simple physics principles:

                **Gears**: He drew elaborate gear trains that could multiply force \
                or change the direction of motion — the same principles used in \
                modern transmissions.

                **Pulleys**: He designed multi-pulley systems that could lift \
                extremely heavy loads with relatively little effort.

                **Springs**: He experimented with coiled springs to store energy — \
                like winding up a toy car. His **spring-powered cart** is considered \
                the world's first **self-propelled vehicle**.
                """,
                science: .physics,
                illustrationIcon: "gearshape.2.fill"
            )),

            // ── 6. Fun Fact: The Tank ───────────────────────────

            .funFact(LessonFunFact(
                text: """
                Leonardo designed an **armored fighting vehicle** — essentially a **tank** — \
                around 1487. It was a turtle-shaped wooden shell covered in metal plates, with \
                cannons pointing in every direction. Inside, soldiers turned cranks to move it \
                forward. But here's the mystery: the gears in his drawing are designed to make \
                the wheels turn **in opposite directions**, so it wouldn't move! Was this a \
                deliberate **sabotage** to prevent his weapon from being built by enemies who \
                might steal his plans? Many historians think so.
                """
            )),

            // ── 7. QUESTION: Physics ────────────────────────────

            .question(LessonQuestion(
                question: "What physics principle did Leonardo use in his spring-powered cart?",
                options: [
                    "Gravity pulling the cart downhill",
                    "Wind power pushing the cart",
                    "Stored energy in coiled springs releasing slowly",
                    "Magnetic attraction between metal parts"
                ],
                correctIndex: 2,
                explanation: "Leonardo's spring-powered cart used coiled springs wound tight to store elastic potential energy. As the springs unwound, they released this energy gradually through a gear mechanism, propelling the cart forward without any human, animal, or wind power — making it history's first self-propelled vehicle.",
                science: .physics
            )),

            // ── 8. MATERIALS: The Bronze Horse ──────────────────

            .reading(LessonReading(
                title: "The Giant Horse That Never Was",
                body: """
                In **1482**, Leonardo moved to Milan to work for **Duke Ludovico Sforza**. \
                His biggest commission was the **Gran Cavallo** — a bronze horse statue \
                that would have been **7.3 meters tall** (about 24 feet), the largest \
                bronze statue in the world.

                Leonardo spent **17 years** preparing. He studied real horses, measuring \
                their proportions precisely. He built a **full-size clay model** and \
                designed a revolutionary new casting technique. But in **1499**, French \
                troops invaded Milan. The **70 tonnes of bronze** set aside for the \
                horse was melted down to make **cannons** instead. French archers used \
                Leonardo's clay model for **target practice**, destroying it completely.
                """,
                science: .materials,
                illustrationIcon: "figure.equestrian.sports"
            )),

            // ── 9. QUESTION: Materials ──────────────────────────

            .question(LessonQuestion(
                question: "Why was the Gran Cavallo never completed?",
                options: [
                    "Leonardo lost interest in the project",
                    "The Duke ran out of money",
                    "The bronze was melted for cannons when French troops invaded",
                    "The casting technique failed"
                ],
                correctIndex: 2,
                explanation: "Leonardo worked on the Gran Cavallo for 17 years, but when French troops invaded Milan in 1499, the 70 tonnes of bronze reserved for the statue was melted down for weapons. The full-size clay model was destroyed by French soldiers using it for archery practice.",
                science: .materials
            )),

            // ── 10. ENGINEERING: Anatomy Studies ────────────────

            .reading(LessonReading(
                title: "Drawing the Human Machine",
                body: """
                Leonardo performed over **30 dissections** of human bodies to understand \
                how the body works — he called it "the machine of machines." His \
                anatomical drawings are so accurate that modern surgeons still marvel \
                at them.

                He was the first to draw the **heart's four chambers** correctly, and \
                he discovered that the **aortic valve** opens and closes using a \
                swirling motion of blood. He drew the **spine** with all its curves, \
                the **muscles** of the arm showing how they pull bones like levers, \
                and the **fetus in the womb** with remarkable accuracy.

                His most famous anatomical drawing, the **Vitruvian Man**, shows ideal \
                human proportions inscribed in both a circle and a square.
                """,
                science: .engineering,
                illustrationIcon: "heart.fill"
            )),

            // ── 11. FILL IN BLANKS: Engineering ─────────────────

            .fillInBlanks(LessonFillInBlanks(
                title: "Complete the Passage",
                text: """
                Leonardo da Vinci trained in {{Verrocchio}}'s workshop in Florence. \
                He filled over {{7000}} pages of notebooks written in {{mirror}} \
                script. His famous anatomical drawing is called the {{Vitruvian}} \
                Man. The unfinished bronze horse was called the {{Gran Cavallo}}.
                """,
                distractors: ["Brunelleschi", "3000", "Latin", "Renaissance", "Pegasus"],
                science: .engineering
            )),

            // ── 12. PHYSICS: Camera Obscura ─────────────────────

            .reading(LessonReading(
                title: "Drawing with Light",
                body: """
                Leonardo experimented with a device called a **camera obscura** \
                (Latin for "dark room"). It works like this: make a small hole in \
                the wall of a dark room, and light from outside projects an **upside-down \
                image** on the opposite wall.

                This happens because light travels in straight lines. Light from the \
                top of a scene enters the hole and hits the bottom of the wall, while \
                light from the bottom hits the top — flipping the image. Leonardo \
                realized that the human **eye works exactly the same way** — the lens \
                projects an inverted image onto the retina, and the brain flips it \
                right-side up.
                """,
                science: .physics,
                illustrationIcon: "camera.fill"
            )),

            // ── 13. QUESTION: Physics ───────────────────────────

            .question(LessonQuestion(
                question: "How does a camera obscura create an image?",
                options: [
                    "Mirrors reflect light onto a screen",
                    "Light through a small hole projects an inverted image on the opposite wall",
                    "A lens magnifies the scene",
                    "Colored filters separate light into an image"
                ],
                correctIndex: 1,
                explanation: "A camera obscura works because light travels in straight lines. A small hole allows light rays from a scene to cross over and project an inverted image on the opposite wall. Leonardo recognized this as the same principle behind human vision — the eye is nature's camera obscura.",
                science: .physics
            )),

            // ── 14. Environment: Workshop ───────────────────────

            .environmentPrompt(LessonEnvironmentPrompt(
                destination: .workshop,
                title: "Stock Leonardo's Workshop",
                description: "Leonardo's workshop needed lime mortar for walls, timber beams for workbenches and easels, glass panes for windows and lenses, and bronze fittings for tools and models. Visit the Workshop to craft these materials.",
                icon: "hammer.fill"
            )),

            // ── 15. Environment: Forest ─────────────────────────

            .environmentPrompt(LessonEnvironmentPrompt(
                destination: .forest,
                title: "Gather Wood for Prototypes",
                description: "Leonardo built scale models of his inventions from wood — flying machines, bridges, war engines, and more. Visit the Forest to gather timber for his workshop prototypes.",
                icon: "tree.fill"
            )),

            // ── 16. MATERIALS: Sfumato Technique ────────────────

            .reading(LessonReading(
                title: "Painting Without Lines",
                body: """
                Leonardo invented a painting technique called **sfumato** (from the \
                Italian word for "smoky"). Instead of drawing clear outlines, he \
                applied dozens of **ultra-thin transparent layers** of paint, each \
                slightly different in color and tone.

                The result is soft, hazy transitions between colors — no visible \
                brushstrokes, no hard edges. The **Mona Lisa's** famous mysterious \
                smile uses sfumato: the corners of her mouth are deliberately \
                blurred, so your brain interprets them differently depending on \
                where you look. Some of his sfumato layers are just **2-5 \
                micrometers** thick — thinner than a human hair!
                """,
                science: .materials,
                illustrationIcon: "paintbrush.pointed.fill"
            )),

            // ── 17. QUESTION: Materials ─────────────────────────

            .question(LessonQuestion(
                question: "What makes Leonardo's sfumato technique unique?",
                options: [
                    "Using only primary colors",
                    "Ultra-thin transparent layers that create soft transitions without visible lines",
                    "Painting only on wet plaster",
                    "Using gold leaf for highlights"
                ],
                correctIndex: 1,
                explanation: "Sfumato involves applying dozens of extremely thin transparent paint layers, creating imperceptible transitions between tones. This eliminates hard edges and brushstrokes, producing the dreamlike quality seen in the Mona Lisa. Some layers measured just 2-5 micrometers — requiring incredible patience and skill.",
                science: .materials
            )),

            // ── 18. ENGINEERING: Legacy ─────────────────────────

            .reading(LessonReading(
                title: "500 Years Ahead",
                body: """
                Many of Leonardo's inventions were **centuries ahead of their time**. \
                His helicopter design anticipated rotary flight by **400 years**. His \
                diving suit predated scuba gear by **450 years**. His self-propelled \
                cart was the first robot concept.

                What made Leonardo special wasn't just his genius — it was his \
                **method**. He observed nature carefully, asked "why?" constantly, \
                tested ideas with experiments, and recorded everything in his \
                notebooks. This is the **scientific method** in action, decades \
                before anyone gave it that name.
                """,
                science: .engineering,
                illustrationIcon: "sparkles"
            )),
        ]
    )

    // MARK: - Flying Machine (#15)

    static let flyingMachineLesson = BuildingLesson(
        buildingName: "Flying Machine",
        title: "The Dream of Flight",
        sections: [

            // ── 1. PHYSICS: Introduction ────────────────────────

            .reading(LessonReading(
                title: "Why Can't Humans Fly?",
                body: """
                For thousands of years, humans looked at birds and dreamed of flying. \
                **Leonardo da Vinci** was the first person to approach this dream \
                **scientifically**. Starting around **1485**, he spent years studying \
                birds, recording their flight patterns, and designing machines to \
                imitate them.

                His key insight was that flight isn't magic — it's **physics**. A bird \
                stays aloft because of two forces: **lift** (the upward push of air on \
                the wings) and **thrust** (the forward push of flapping). These must \
                overcome **gravity** (pulling down) and **drag** (air resistance pushing \
                back). If lift + thrust > gravity + drag, you fly.
                """,
                science: .physics,
                illustrationIcon: "bird.fill"
            )),

            // ── 2. Fun Fact: The Codex ──────────────────────────

            .funFact(LessonFunFact(
                text: """
                Leonardo wrote an entire notebook dedicated to flight — the **Codex on \
                the Flight of Birds** (Codice sul volo degli uccelli), completed around \
                **1505**. It contains **18 pages** of detailed observations: how birds \
                change wing angle to turn, how they use thermals (rising warm air) to \
                soar without flapping, and how tail feathers work as rudders. He even \
                calculated the **wingbeat frequency** of different species. Modern \
                ornithologists (bird scientists) confirm that most of his observations \
                were **remarkably accurate**.
                """
            )),

            // ── 3. QUESTION: Physics ────────────────────────────

            .question(LessonQuestion(
                question: "What four forces act on a flying object?",
                options: [
                    "Lift, thrust, gravity, and drag",
                    "Push, pull, spin, and stop",
                    "Wind, weight, speed, and height",
                    "Pressure, friction, momentum, and inertia"
                ],
                correctIndex: 0,
                explanation: "The four forces of flight are: lift (upward, from wing shape), thrust (forward, from flapping or propulsion), gravity (downward, pulling toward Earth), and drag (backward, air resistance). For flight to occur, lift must exceed gravity and thrust must exceed drag.",
                science: .physics
            )),

            // ── 4. PHYSICS: How Wings Create Lift ───────────────

            .reading(LessonReading(
                title: "The Secret of Wing Shape",
                body: """
                Leonardo noticed that bird wings are **curved on top** and **flatter on \
                the bottom**. This shape — now called an **airfoil** — is the key to \
                lift. Here's why:

                When air flows over a curved wing, it must travel **farther** over the \
                top than under the bottom. Since the air on top covers more distance in \
                the same time, it moves **faster**. Faster-moving air has **lower \
                pressure** (this is **Bernoulli's principle**). So the higher pressure \
                below pushes the wing **up** — creating lift!

                Leonardo drew this concept in his notebooks, centuries before Daniel \
                Bernoulli mathematically explained it in 1738.
                """,
                science: .physics,
                illustrationIcon: "wind"
            )),

            // ── 5. QUESTION: Physics ────────────────────────────

            .question(LessonQuestion(
                question: "Why does air moving faster over the top of a wing create lift?",
                options: [
                    "Faster air is heavier and pushes down",
                    "Faster air has lower pressure, so higher pressure below pushes up",
                    "Faster air is hotter and rises",
                    "Faster air creates a vacuum that sucks the wing up"
                ],
                correctIndex: 1,
                explanation: "According to Bernoulli's principle, faster-moving air has lower pressure. The curved upper surface of a wing forces air to move faster over it, creating lower pressure above and higher pressure below. This pressure difference produces an upward force — lift.",
                science: .physics
            )),

            // ── 6. ENGINEERING: The Ornithopter ─────────────────

            .reading(LessonReading(
                title: "Flapping Wings: The Ornithopter",
                body: """
                Leonardo's most ambitious design was the **ornithopter** — a \
                flying machine with **flapping wings** powered by a human pilot. \
                The name comes from Greek: "ornithos" (bird) + "pteron" (wing).

                The pilot would lie face-down on a board, pushing foot pedals that \
                moved a system of **cranks and pulleys** connected to the wings. \
                The wings were made of a light wooden frame covered in **starched \
                silk** or thin leather.

                Leonardo designed several versions between **1485 and 1490**. But \
                there was a fundamental problem he hadn't solved: human leg muscles \
                simply aren't strong enough to generate the required lift. A human \
                produces about **75 watts** of sustained power, but a bird the \
                weight of a human would need over **1,500 watts** — **20 times more**!
                """,
                science: .engineering,
                illustrationIcon: "figure.strengthtraining.traditional"
            )),

            // ── 7. MATH: Wing Area Calculation ──────────────────

            .question(LessonQuestion(
                question: "Leonardo calculated that an ornithopter for a 75 kg person would need wings spanning about 12 meters tip to tip. If each wing is approximately triangular with a base of 6m and height of 2.5m, what is the total wing area? (Area of triangle = ½ × base × height)",
                options: [
                    "15.0 m²",
                    "30.0 m²",
                    "7.5 m²",
                    "12.0 m²"
                ],
                correctIndex: 0,
                explanation: "Each wing: A = ½ × 6 × 2.5 = 7.5 m². Two wings: 7.5 × 2 = 15.0 m². For comparison, a hang glider has about 15-18 m² of wing area — so Leonardo's calculations were surprisingly close to what actually works for unpowered gliding flight!",
                science: .mathematics,
                hints: [
                    "Use the triangle formula: A = ½ × base × height for one wing.",
                    "One wing: A = ½ × 6 × 2.5 = 7.5 m². Now double it for both wings.",
                    "Two wings: 7.5 × 2 = 15.0 m²"
                ]
            )),

            // ── 8. ENGINEERING: The Glider ──────────────────────

            .reading(LessonReading(
                title: "From Flapping to Gliding",
                body: """
                As Leonardo studied birds more carefully, he noticed that large birds \
                like **eagles** and **hawks** don't constantly flap — they spend most \
                of their time **soaring** with wings spread wide, riding columns of \
                rising warm air called **thermals**.

                This observation led Leonardo to shift from flapping machines to \
                **fixed-wing gliders**. His later designs looked much more like \
                modern hang gliders: a rigid frame with fabric stretched over it, \
                controlled by the pilot shifting their body weight. These designs \
                were **much more practical** than the ornithopter — and in 2000, \
                a reconstruction actually **flew successfully**!
                """,
                science: .engineering,
                illustrationIcon: "paperplane.fill"
            )),

            // ── 9. Fun Fact: The Air Screw ──────────────────────

            .funFact(LessonFunFact(
                text: """
                In **1489**, Leonardo sketched the **aerial screw** — a helical (corkscrew-shaped) \
                device meant to compress air downward and lift off the ground. It's often called \
                the first **helicopter design**. The structure was a spiral of starched linen on \
                a wire frame, about **4.8 meters** in diameter. Leonardo wrote: "If this \
                instrument made with a screw be well made — that is to say, made of linen \
                of which the pores are stopped up with starch — and be turned swiftly, \
                the said screw will make its spiral in the air and it will rise high." \
                It wouldn't have worked (no motor), but the concept was **400 years early**.
                """
            )),

            // ── 10. QUESTION: Engineering ───────────────────────

            .question(LessonQuestion(
                question: "Why did Leonardo's later flight designs shift from flapping ornithopters to fixed-wing gliders?",
                options: [
                    "Gliders were cheaper to build",
                    "He observed that large birds soar on thermals without constant flapping",
                    "The Duke of Milan preferred gliders",
                    "Silk for flapping wings was too expensive"
                ],
                correctIndex: 1,
                explanation: "Leonardo's careful observation of eagles and hawks showed that large birds spend most of their flight soaring on thermals with wings spread, rarely flapping. This insight led him to realize that a fixed-wing design was more practical — and it was correct. Modern hang gliders work on exactly this principle.",
                science: .engineering
            )),

            // ── 11. MATH: Power Ratio ───────────────────────────

            .question(LessonQuestion(
                question: "A human can sustain about 75 watts of power, but a human-weight bird would need 1,500 watts. How many times more powerful would a human need to be to fly by flapping wings?",
                options: [
                    "10 times",
                    "15 times",
                    "20 times",
                    "25 times"
                ],
                correctIndex: 2,
                explanation: "1,500 ÷ 75 = 20 times. This is why no human-powered ornithopter has ever achieved sustained flight through flapping alone. Human-powered aircraft that have flown (like the Gossamer Albatross in 1979) use propellers, which are much more efficient than flapping wings.",
                science: .mathematics,
                hints: [
                    "Divide the power needed by the power available.",
                    "1,500 ÷ 75 = ?",
                    "1,500 ÷ 75 = 20. A human would need to be 20× more powerful!"
                ]
            )),

            // ── 12. FILL IN BLANKS: Physics ─────────────────────

            .fillInBlanks(LessonFillInBlanks(
                title: "Complete the Passage",
                text: """
                The four forces of flight are {{lift}}, {{thrust}}, gravity, and drag. \
                A wing's curved shape is called an {{airfoil}}. Leonardo's flapping-wing \
                machine is called an {{ornithopter}}. His helicopter precursor is \
                called the {{air screw}}.
                """,
                distractors: ["weight", "spin", "fuselage", "propeller", "turbine"],
                science: .physics
            )),

            // ── 13. Environment: Workshop ───────────────────────

            .environmentPrompt(LessonEnvironmentPrompt(
                destination: .workshop,
                title: "Build the Flying Machine",
                description: "Leonardo's flying machines required timber beams for the frame, silk fabric for the wing covering, and bronze fittings for the mechanical joints and cranks. Visit the Workshop to craft these materials.",
                icon: "hammer.fill"
            )),

            // ── 14. Environment: Forest ─────────────────────────

            .environmentPrompt(LessonEnvironmentPrompt(
                destination: .forest,
                title: "Find Lightweight Wood",
                description: "Leonardo preferred lightweight woods like willow and pine for his flying machine frames — every gram mattered when trying to achieve flight. Visit the Forest to gather the lightest timber available.",
                icon: "tree.fill"
            )),

            // ── 15. PHYSICS: Legacy ─────────────────────────────

            .reading(LessonReading(
                title: "The Dream Lives On",
                body: """
                Leonardo never achieved powered flight — the technology of his time \
                simply couldn't provide enough power. But his **method** — careful \
                observation of nature, mathematical analysis, prototype building, and \
                systematic testing — is exactly how the **Wright Brothers** finally \
                achieved powered flight in **1903**, over 400 years later.

                In **2000**, a British hang glider champion built a replica of \
                Leonardo's glider design and flew it successfully, reaching a height \
                of **10 meters** over a distance of **100 meters**. Leonardo's \
                understanding of aerodynamics was sound — he was just born too early \
                for the technology to match his vision.
                """,
                science: .physics,
                illustrationIcon: "sparkles"
            )),
        ]
    )

    // MARK: - Vatican Observatory (#16)

    static let vaticanObservatoryLesson = BuildingLesson(
        buildingName: "Vatican Observatory",
        title: "Measuring the Heavens",
        sections: [

            // ── 1. ASTRONOMY: Introduction ──────────────────────

            .reading(LessonReading(
                title: "The Tower of the Winds",
                body: """
                High above the Vatican, a tower called the **Torre dei Venti** (Tower \
                of the Winds) served as one of the world's earliest **observatories**. \
                Built in **1580** by Pope **Gregory XIII**, its main purpose was to fix \
                a serious problem: the **calendar was wrong**.

                The old **Julian Calendar** (created by Julius Caesar in 46 BC) was off \
                by about **11 minutes per year**. That doesn't sound like much, but over \
                1,600 years it had added up to a **10-day error**! Spring was arriving \
                10 days late according to the calendar, which was a big problem for \
                calculating the date of **Easter**.
                """,
                science: .astronomy,
                illustrationIcon: "moon.stars.fill"
            )),

            // ── 2. Fun Fact: The Lost Days ──────────────────────

            .funFact(LessonFunFact(
                text: """
                To fix the calendar, Pope Gregory XIII made an extraordinary decision: \
                in October **1582**, he simply **deleted 10 days**. People went to sleep \
                on **October 4th** and woke up on **October 15th**! The new **Gregorian \
                Calendar** added a clever rule about leap years: century years (like 1700, \
                1800, 1900) are NOT leap years UNLESS they're divisible by 400. That's why \
                **2000 was a leap year** but 1900 wasn't. This correction keeps the calendar \
                accurate to within **1 day every 3,236 years**.
                """
            )),

            // ── 3. QUESTION: Astronomy ──────────────────────────

            .question(LessonQuestion(
                question: "Why did Pope Gregory XIII need to reform the calendar?",
                options: [
                    "He wanted to add more holidays",
                    "The Julian Calendar had drifted 10 days from the actual solar year",
                    "The old calendar didn't include months",
                    "He wanted to honor a different Roman emperor"
                ],
                correctIndex: 1,
                explanation: "The Julian Calendar gained about 11 minutes per year compared to the actual solar year. Over 1,600 years, this accumulated to 10 extra days — meaning the calendar no longer matched the seasons. This affected the calculation of Easter and agricultural planning.",
                science: .astronomy
            )),

            // ── 4. MATH: Calendar Drift ─────────────────────────

            .question(LessonQuestion(
                question: "The Julian Calendar gained about 11 minutes per year. How many years does it take for this error to add up to one full day (1,440 minutes)?",
                options: [
                    "≈ 131 years",
                    "≈ 100 years",
                    "≈ 200 years",
                    "≈ 365 years"
                ],
                correctIndex: 0,
                explanation: "1,440 minutes ÷ 11 minutes/year ≈ 130.9 years, or about 131 years for each extra day. Over 1,600 years (from 46 BC to 1582 AD): 1,600 ÷ 131 ≈ 12.2 days of drift. The actual drift was about 10 days because the error isn't exactly 11 minutes.",
                science: .mathematics,
                hints: [
                    "One day = 24 hours × 60 minutes = 1,440 minutes.",
                    "Divide total minutes in a day by the yearly drift.",
                    "1,440 ÷ 11 ≈ 130.9, so about 131 years per day of drift."
                ]
            )),

            // ── 5. OPTICS: The Meridian Line ────────────────────

            .reading(LessonReading(
                title: "A Sundial on the Floor",
                body: """
                Inside the Tower of the Winds, astronomers built a **meridian line** — \
                a strip of metal set into the marble floor running exactly **north to \
                south**. A small hole in the wall allowed a beam of sunlight to enter \
                and hit the floor.

                As the seasons change, the sun's height in the sky changes. In summer, \
                the sun is high, so the beam hits the floor **close to the wall**. In \
                winter, the sun is low, so the beam reaches **far across the room**. \
                By marking exactly where the beam fell on the **summer solstice** and \
                **winter solstice**, astronomers could measure the length of the year \
                with incredible precision.

                This is basically a giant **camera obscura** turned into a scientific \
                instrument!
                """,
                science: .optics,
                illustrationIcon: "sun.max.fill"
            )),

            // ── 6. QUESTION: Optics ─────────────────────────────

            .question(LessonQuestion(
                question: "How does a meridian line measure the length of a year?",
                options: [
                    "It counts the number of sunny days",
                    "It tracks where sunlight hits the floor across seasons",
                    "It measures the brightness of sunlight",
                    "It reflects moonlight to calculate months"
                ],
                correctIndex: 1,
                explanation: "A beam of sunlight enters through a small hole and hits the floor at different positions depending on the sun's height in the sky. By precisely marking the position on successive summer solstices, astronomers could measure the exact time between them — the length of one solar year.",
                science: .optics
            )),

            // ── 7. ASTRONOMY: Galileo's Telescope ───────────────

            .reading(LessonReading(
                title: "A New Eye on the Heavens",
                body: """
                In **1609**, **Galileo Galilei** heard about a new invention from the \
                Netherlands: a tube with two glass lenses that made distant things look \
                closer. He immediately built his own version — and improved it to \
                **20× magnification** (the Dutch version only managed 3×).

                When Galileo pointed his **telescope** at the sky, he discovered things \
                that shook the world: **four moons** orbiting Jupiter (proving not \
                everything orbits Earth), **mountains and craters** on the Moon (showing \
                it wasn't a perfect sphere), **phases of Venus** (proving Venus orbits \
                the Sun), and countless new **stars** in the Milky Way.
                """,
                science: .astronomy,
                illustrationIcon: "scope"
            )),

            // ── 8. Fun Fact: Galileo's Trouble ──────────────────

            .funFact(LessonFunFact(
                text: """
                Galileo's discoveries supported the **heliocentric model** — the idea \
                that Earth orbits the Sun, not the other way around. This contradicted \
                the Church's teaching, and in **1633**, Galileo was put on trial by the \
                **Inquisition** and forced to recant (take back) his findings. He spent \
                the last 9 years of his life under **house arrest**. Legend says that as \
                he left the courtroom, he muttered: **"Eppur si muove"** — "And yet it \
                moves." The Church didn't formally acknowledge his findings were correct \
                until **1992** — 359 years later!
                """
            )),

            // ── 9. OPTICS: How Telescopes Work ──────────────────

            .reading(LessonReading(
                title: "Bending Light to See Far",
                body: """
                Galileo's telescope used two lenses. The large **objective lens** at \
                the front collects light and bends it (using **refraction**) to create \
                a small, focused image. The smaller **eyepiece lens** near your eye \
                then magnifies that image.

                The key is that a **convex lens** (thicker in the middle) bends light \
                inward, focusing it to a point. By combining lenses of different curves, \
                you can magnify objects many times over. Remember the Venetian \
                glassmakers from the Glassworks lesson? Without their **cristallo** \
                glass, Galileo couldn't have made clear enough lenses for his discoveries!
                """,
                science: .optics,
                illustrationIcon: "eye.fill"
            )),

            // ── 10. QUESTION: Optics ────────────────────────────

            .question(LessonQuestion(
                question: "What optical principle allows a telescope's lenses to magnify distant objects?",
                options: [
                    "Reflection of light off curved mirrors",
                    "Refraction — bending light through curved lenses",
                    "Diffraction — spreading light through narrow slits",
                    "Absorption — filtering out unwanted light"
                ],
                correctIndex: 1,
                explanation: "Galileo's refracting telescope used refraction — the bending of light as it passes through glass lenses. A convex objective lens collects and focuses light, while an eyepiece lens magnifies the resulting image. This same principle (using cristallo glass from Murano) enabled Galileo's revolutionary discoveries.",
                science: .optics
            )),

            // ── 11. MATH: Angular Size ──────────────────────────

            .question(LessonQuestion(
                question: "The full Moon appears about 0.5° wide in the sky. Galileo's telescope magnified 20×. How wide did the Moon appear through his telescope?",
                options: [
                    "5°",
                    "10°",
                    "20°",
                    "1°"
                ],
                correctIndex: 1,
                explanation: "Angular size through telescope = actual angular size × magnification. 0.5° × 20 = 10°. For comparison, your fist held at arm's length covers about 10° of sky — so the Moon through Galileo's telescope filled about the width of your fist. This was enough to clearly see craters and mountains.",
                science: .mathematics,
                hints: [
                    "Multiply the Moon's apparent size by the magnification.",
                    "0.5° × 20 = ?",
                    "0.5 × 20 = 10°. The Moon appeared 10° wide through the telescope."
                ]
            )),

            // ── 12. FILL IN BLANKS: Astronomy ───────────────────

            .fillInBlanks(LessonFillInBlanks(
                title: "Complete the Passage",
                text: """
                Pope {{Gregory}} XIII reformed the calendar in {{1582}} by deleting \
                10 days. A {{meridian}} line on the floor tracked the sun's position. \
                Galileo's telescope achieved {{20}} times magnification using \
                {{refraction}} through glass lenses.
                """,
                distractors: ["Urban", "1492", "equator", "10", "reflection"],
                science: .astronomy
            )),

            // ── 13. Environment: Workshop ───────────────────────

            .environmentPrompt(LessonEnvironmentPrompt(
                destination: .workshop,
                title: "Craft Observatory Materials",
                description: "The Vatican Observatory needed lead sheeting for the tower roof, blue fresco pigment for the decorative ceiling, glass panes for precision optical instruments, and marble for the meridian line floor. Visit the Workshop to craft these materials.",
                icon: "hammer.fill"
            )),

            // ── 14. ASTRONOMY: Legacy ───────────────────────────

            .reading(LessonReading(
                title: "Counting the Cosmos",
                body: """
                The Vatican Observatory is one of the **oldest astronomical institutions** \
                in the world. The Gregorian calendar it helped create is now used by \
                virtually every country on Earth. The meridian lines inspired precise \
                timekeeping that led to **modern clocks** and **GPS navigation**.

                And the telescope technology that Galileo perfected with Venetian glass \
                has evolved into instruments like the **Hubble Space Telescope** and the \
                **James Webb Space Telescope**, which can see galaxies **billions of \
                light-years** away. It all started with a small hole in a wall and \
                a beam of sunlight on a marble floor.
                """,
                science: .astronomy,
                illustrationIcon: "sparkles"
            )),

            // ── 15. QUESTION: Astronomy ─────────────────────────

            .question(LessonQuestion(
                question: "What Galileo discovery proved that not everything in space orbits Earth?",
                options: [
                    "Craters on the Moon",
                    "The Milky Way has many stars",
                    "Four moons orbiting Jupiter",
                    "Sunspots on the Sun"
                ],
                correctIndex: 2,
                explanation: "By observing four moons orbiting Jupiter (now called the Galilean moons: Io, Europa, Ganymede, and Callisto), Galileo proved that celestial bodies could orbit something other than Earth. This was powerful evidence against the geocentric (Earth-centered) model of the universe.",
                science: .astronomy
            )),
        ]
    )

    // MARK: - Printing Press (#17)

    static let printingPressLesson = BuildingLesson(
        buildingName: "Printing Press",
        title: "Words That Changed the World",
        sections: [

            // ── 1. ENGINEERING: Introduction ────────────────────

            .reading(LessonReading(
                title: "Before the Press",
                body: """
                Imagine a world where every book had to be **copied by hand**. That's \
                how it was in Europe before the **1440s**. A single Bible took a monk \
                about **2 years** to copy, and might cost as much as a **house**. Only \
                the wealthy, the Church, and universities could afford books. Most \
                people never held one in their entire lives.

                Then a German goldsmith named **Johannes Gutenberg** combined several \
                existing ideas into one revolutionary machine: the **printing press with \
                movable type**. By **1455**, he had printed the famous **Gutenberg Bible** \
                — and the world would never be the same.
                """,
                science: .engineering,
                illustrationIcon: "book.fill"
            )),

            // ── 2. Fun Fact: Gutenberg's Debt ───────────────────

            .funFact(LessonFunFact(
                text: """
                Gutenberg was a terrible businessman. He borrowed **800 guilders** from \
                a moneylender named **Johann Fust** to finance his printing operation. \
                When Gutenberg couldn't repay the loan, Fust sued him and **took over \
                the entire workshop** — including all the presses, type, and even the \
                nearly-finished Bibles! Fust went on to make a fortune selling Gutenberg's \
                Bibles, while Gutenberg died in **1468** in relative poverty. The invention \
                that changed the world barely benefited its inventor.
                """
            )),

            // ── 3. ENGINEERING: How It Works ────────────────────

            .reading(LessonReading(
                title: "The Mechanics of Printing",
                body: """
                Gutenberg's genius was combining several technologies:

                **1. Movable type**: Individual letter blocks that can be rearranged to \
                spell any text — then reused for the next page.

                **2. The screw press**: Adapted from **wine presses** and **olive presses**, \
                it uses a large screw to apply even, heavy pressure across an entire page.

                **3. Oil-based ink**: Regular water-based ink wouldn't stick to metal type. \
                Gutenberg invented a new ink using **lampblack** (soot) mixed with \
                **linseed oil** that clung perfectly to the metal letters.

                Together, these let a printer produce about **250 pages per hour** — \
                compared to a monk's rate of maybe **1 page per day**.
                """,
                science: .engineering,
                illustrationIcon: "gearshape.fill"
            )),

            // ── 4. QUESTION: Engineering ────────────────────────

            .question(LessonQuestion(
                question: "What existing technology did Gutenberg adapt to create his printing press?",
                options: [
                    "A water wheel",
                    "A wine or olive press",
                    "A blacksmith's forge",
                    "A weaving loom"
                ],
                correctIndex: 1,
                explanation: "Gutenberg adapted the screw press used for making wine and olive oil. By turning a large screw, it applied heavy, even pressure across the entire page — transferring ink from the raised metal type to paper uniformly. This mechanical advantage was key to producing clear, consistent prints.",
                science: .engineering
            )),

            // ── 5. CHEMISTRY: The Type Metal Alloy ──────────────

            .reading(LessonReading(
                title: "The Perfect Metal Recipe",
                body: """
                Gutenberg needed a metal that could be **melted easily**, poured into \
                tiny **letter molds**, and then survive being **stamped thousands of \
                times** without wearing down. No single metal could do all three.

                His solution was an **alloy** — a mixture of metals:
                - **Lead (83%)**: Low melting point (327°C), easy to cast
                - **Tin (12%)**: Adds hardness and reduces shrinkage during cooling
                - **Antimony (5%)**: Expands slightly as it solidifies, ensuring the type \
                fills every corner of the mold perfectly

                This recipe was so good that **type metal** was used virtually unchanged \
                for **over 500 years**, until digital printing replaced it.
                """,
                science: .chemistry,
                illustrationIcon: "testtube.2"
            )),

            // ── 6. Fun Fact: The Matrix ─────────────────────────

            .funFact(LessonFunFact(
                text: """
                To create identical copies of each letter, Gutenberg invented the \
                **hand mold** system. First, a letter was carved in reverse on a steel \
                punch. This punch was hammered into a soft copper block to create a \
                **matrix** (an impression of the letter). Molten type metal was poured \
                into the matrix, creating a perfect metal letter. This process could \
                produce **hundreds of identical letters per hour** — and every "A" was \
                exactly the same as every other "A." The word "matrix" (meaning "mold" \
                or "womb") later became famous in mathematics and, of course, movies!
                """
            )),

            // ── 7. QUESTION: Chemistry ──────────────────────────

            .question(LessonQuestion(
                question: "Why was antimony included in the type metal alloy?",
                options: [
                    "To make the metal shinier",
                    "To lower the melting point further",
                    "To expand slightly during solidification, filling the mold completely",
                    "To add color to the metal"
                ],
                correctIndex: 2,
                explanation: "Most metals shrink when they cool and solidify, leaving tiny gaps. Antimony has the unusual property of expanding slightly during solidification, ensuring the molten alloy fills every fine detail of the letter mold. This gave Gutenberg's type its crisp, precise letter forms.",
                science: .chemistry
            )),

            // ── 8. CHEMISTRY: Ink Science ───────────────────────

            .reading(LessonReading(
                title: "Black Gold: The Ink",
                body: """
                Medieval scribes used **water-based inks** made from oak galls (growths \
                on trees caused by wasps). This worked fine on parchment with a quill \
                pen, but it wouldn't stick to **metal type** — it just beaded up and \
                slid off.

                Gutenberg's solution was **oil-based ink**. He mixed **lampblack** \
                (the fine soot collected from burning oil lamps) with **linseed oil** \
                (pressed from flax seeds). The oil base made the ink **sticky enough** \
                to cling to metal type, and the lampblack gave it an intense, permanent \
                **black color**. This formula was a key innovation — without it, the \
                movable type would have been useless.
                """,
                science: .chemistry,
                illustrationIcon: "drop.fill"
            )),

            // ── 9. QUESTION: Chemistry ──────────────────────────

            .question(LessonQuestion(
                question: "Why couldn't traditional water-based ink be used with metal movable type?",
                options: [
                    "It was too expensive",
                    "It faded too quickly",
                    "It wouldn't adhere to the metal surface",
                    "It took too long to dry"
                ],
                correctIndex: 2,
                explanation: "Water-based ink beads up on metal surfaces due to surface tension — the water molecules are more attracted to each other than to the metal. Oil-based ink, being sticky and viscous, clings to metal type and transfers cleanly to paper under pressure. This was a crucial innovation.",
                science: .chemistry
            )),

            // ── 10. PHYSICS: The Screw Press ────────────────────

            .reading(LessonReading(
                title: "The Power of the Screw",
                body: """
                The printing press uses a **screw** to convert **rotational force** \
                (turning) into **linear force** (pressing down). When the printer \
                turns the handle, the screw threads translate the circular motion \
                into a powerful downward push.

                This is a form of **mechanical advantage**: a small force applied \
                over many turns of the screw becomes a large force pressing straight \
                down. The screw's **pitch** (the distance between threads) determines \
                the multiplication — a tighter pitch means more force but slower \
                movement. Gutenberg's press could apply over **140 kg per square \
                centimeter** of pressure — enough to transfer ink cleanly and evenly \
                across every letter on the page.
                """,
                science: .physics,
                illustrationIcon: "arrow.down.to.line"
            )),

            // ── 11. QUESTION: Physics ───────────────────────────

            .question(LessonQuestion(
                question: "How does a screw press multiply force?",
                options: [
                    "It uses electricity to amplify pressure",
                    "It converts rotational motion into strong linear force through the screw threads",
                    "It heats the metal to make it softer",
                    "It uses magnets to pull the press down"
                ],
                correctIndex: 1,
                explanation: "A screw press converts rotational force (turning the handle) into linear force (pressing down) through the inclined plane of the screw threads. Each full turn moves the press down a small distance (the pitch), concentrating force into a powerful, controlled downward push.",
                science: .physics
            )),

            // ── 12. FILL IN BLANKS: Engineering ─────────────────

            .fillInBlanks(LessonFillInBlanks(
                title: "Complete the Passage",
                text: """
                Gutenberg's type metal alloy contained {{lead}}, {{tin}}, and antimony. \
                He invented oil-based ink using {{lampblack}} and linseed oil. Individual \
                letter blocks called {{movable type}} could be rearranged and reused. \
                A letter carved in copper is called a {{matrix}}.
                """,
                distractors: ["iron", "copper", "charcoal", "woodblocks", "stamp"],
                science: .engineering
            )),

            // ── 13. Environment: Workshop ───────────────────────

            .environmentPrompt(LessonEnvironmentPrompt(
                destination: .workshop,
                title: "Build the Printing Press",
                description: "The printing press required timber beams for the frame, lead sheeting for type metal, glass panes for workshop windows, and carved wood for the ornamental press body. Visit the Workshop to craft these materials.",
                icon: "hammer.fill"
            )),

            // ── 14. ENGINEERING: Impact ─────────────────────────

            .reading(LessonReading(
                title: "An Explosion of Knowledge",
                body: """
                The impact of the printing press was like the internet of its day — \
                but even more dramatic. Before Gutenberg, Europe had maybe **30,000 \
                books** total. By **1500** (just 50 years later), there were over \
                **20 million** printed volumes in circulation.

                In Venice, the printer **Aldus Manutius** revolutionized publishing \
                further: he invented **italic type** (which saved space and paper), \
                created the **pocket-sized book** (so people could read anywhere), \
                and published affordable editions of Greek and Latin classics. His \
                innovation made knowledge accessible to ordinary people for the first \
                time in history.
                """,
                science: .engineering,
                illustrationIcon: "books.vertical.fill"
            )),

            // ── 15. Fun Fact: Speed of Spread ───────────────────

            .funFact(LessonFunFact(
                text: """
                The printing press spread across Europe with astonishing speed. By **1480** \
                — just 25 years after the Gutenberg Bible — there were printing presses in \
                over **110 cities** across 12 countries. Martin Luther's **95 Theses** (1517) \
                were printed and distributed across Germany within **two weeks** — something \
                that would have taken months or years by hand copying. The printing press \
                didn't just spread information faster — it made the Protestant Reformation, \
                the Scientific Revolution, and the Age of Exploration possible.
                """
            )),

            // ── 16. QUESTION: Engineering ───────────────────────

            .question(LessonQuestion(
                question: "How did the printing press change European society?",
                options: [
                    "It made books available only to the wealthy",
                    "It replaced hand-writing entirely within 10 years",
                    "It dramatically increased the number of books, making knowledge accessible to ordinary people",
                    "It was mainly used for printing money"
                ],
                correctIndex: 2,
                explanation: "The printing press increased Europe's book supply from about 30,000 volumes to over 20 million within 50 years. Affordable printed books allowed ordinary people to access knowledge that was previously restricted to the wealthy, the clergy, and universities — democratizing information on an unprecedented scale.",
                science: .engineering
            )),
        ]
    )
}
