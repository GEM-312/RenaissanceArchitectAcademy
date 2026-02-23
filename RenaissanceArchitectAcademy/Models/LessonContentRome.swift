import Foundation

// MARK: - Ancient Rome Lessons (Buildings 1-3, 5-8)

extension LessonContent {

    // MARK: - Aqueduct (#1)

    static let aqueductLesson = BuildingLesson(
        buildingName: "Aqueduct",
        title: "Rivers in the Sky",
        sections: [

            // ── 1. Hook ───────────────────────────────────────

            .reading(LessonReading(
                title: "Rivers in the Sky",
                body: """
                Turn on a faucet. Water comes out. You don't think about it.

                Now imagine there are no faucets. No pipes. No pumps. Nothing.

                That was Rome. A million people, and the nearest clean water \
                was up in the mountains, far from the city.

                So the Romans did something bold. They built long stone \
                channels — called **aqueducts** — that carried water from \
                mountain springs all the way into the city.

                No engines. No electricity. Just the gentle pull of **gravity**.
                """,
                science: .engineering,
                illustrationIcon: "drop.fill"
            )),

            .curiosity(LessonCuriosity(questions: [
                CuriosityQA(
                    question: "Why didn't the Romans just build their city near a river?",
                    answer: "Rome was built near the **Tiber River**, but a million people need way more water than one river can safely provide. The Tiber was also polluted with sewage. Mountain springs were cleaner and more reliable."
                ),
                CuriosityQA(
                    question: "Do aqueducts still exist today?",
                    answer: "Yes! Some Roman aqueducts still carry water. The **Acqua Vergine** in Rome has been running since 19 BC — over 2,000 years. Modern cities use the same idea, just with metal pipes instead of stone channels."
                )
            ])),

            // ── 2. The Slope Trick ────────────────────────────

            .reading(LessonReading(
                title: "The Slope Trick",
                body: """
                Here is the secret: the channel was tilted. Just barely.

                The Romans angled it slightly downhill. This tiny tilt is \
                called the **gradient**.

                Think of a playground slide. If it is too steep, you fly \
                off. If it is too flat, you don't move. The Romans needed \
                the perfect in-between — just enough tilt for water to \
                flow smoothly, mile after mile.

                Too steep? Water rushes and destroys the stone. Too flat? \
                Water sits still and turns green. Getting it right was the \
                whole game.
                """,
                science: .mathematics,
                illustrationIcon: "arrow.down.right"
            )),

            .curiosity(LessonCuriosity(questions: [
                CuriosityQA(
                    question: "How did they measure such a tiny slope without modern tools?",
                    answer: "They used a tool called a **chorobates** — a long wooden table with a groove of water on top. Basically the world's first spirit level. If the water in the groove was even, the surface was flat. Tilt it a tiny bit, and you have your gradient."
                ),
                CuriosityQA(
                    question: "What happens if they got the gradient wrong?",
                    answer: "Too steep and the water would rush like a waterfall, tearing the stone apart. Too flat and the water would stop moving and grow algae. Either way, the aqueduct would fail. That is why planning sometimes took **years** before building even started."
                )
            ])),

            // ── 3. Fun Fact ───────────────────────────────────

            .funFact(LessonFunFact(
                text: """
                The **Aqua Claudia** — one of Rome's greatest aqueducts — \
                stretched **69 kilometers**. But here is the surprise: only \
                16 km rode on top of tall stone arches. The rest? Hidden \
                underground, tunneled straight through hillsides.
                """
            )),

            // ── 4. Question ───────────────────────────────────

            .question(LessonQuestion(
                question: "How did Roman aqueducts move water without any pumps?",
                options: [
                    "They used windmills to push the water",
                    "Gravity pulled the water down a gentle slope",
                    "Slaves carried buckets along the channel",
                    "They heated the water to make steam"
                ],
                correctIndex: 1,
                explanation: "The whole trick was gravity. By tilting the channel just slightly downhill, water flowed on its own — no machines needed. Simple idea, incredible execution.",
                science: .engineering
            )),

            // ── 5. The Gradient — Math Concept ────────────────

            .reading(LessonReading(
                title: "Measuring the Tilt",
                body: """
                The Romans measured their slope as a **ratio**.

                A gradient of **1:200** means: for every 200 steps forward, \
                the channel drops by 1 step.

                That is tiny. Like tilting a football field by the height \
                of a ruler. But that tiny tilt was enough to keep water \
                moving across entire countries.

                In the quiz, you will calculate how much water drops over \
                a real aqueduct distance. The math is just division — the \
                hard part was getting it right 2,000 years ago.
                """,
                science: .mathematics,
                illustrationIcon: "ruler"
            )),

            // ── 5b. Gradient Visual ──────────────────────────

            .mathVisual(LessonMathVisual(
                type: .aqueductGradient,
                title: "Visualize the Gradient",
                science: .mathematics,
                totalSteps: 5,
                caption: "A gradient of 1:200 means for every 200 meters forward, the channel drops 1 meter. This tiny tilt is the secret to Roman aqueducts."
            )),

            // ── 6. The Water Channel ──────────────────────────

            .reading(LessonReading(
                title: "The Channel",
                body: """
                The water flowed through a stone channel called the \
                **specus** (say: SPECK-us).

                Picture a long stone bathtub with a lid on top. That is \
                basically it.

                The inside was coated with a special **waterproof plaster** \
                made from crushed pottery. Every drop was precious. They \
                could not afford leaks.

                The channel was big enough for a person to walk inside — \
                because someone had to clean it.
                """,
                science: .engineering,
                illustrationIcon: "rectangle.split.3x1"
            )),

            .curiosity(LessonCuriosity(questions: [
                CuriosityQA(
                    question: "What was the waterproof plaster made of?",
                    answer: "It was called **opus signinum** — crushed pottery mixed into Roman concrete. The tiny pieces of broken clay sealed the pores and made the surface waterproof. Romans recycled broken pots into building material."
                ),
                CuriosityQA(
                    question: "How long did it take to build one aqueduct?",
                    answer: "A major aqueduct could take **10 to 20 years** to build. The planning alone took years. Thousands of workers — including soldiers — cut stone, dug tunnels, and stacked arches by hand."
                )
            ])),

            // ── 7. Crossing Valleys ───────────────────────────

            .reading(LessonReading(
                title: "The Valley Problem",
                body: """
                Here is a problem. The channel needs to go downhill. \
                Always downhill. Never up.

                But what happens when you reach a valley?

                You cannot dip the channel down and back up. Water does \
                not climb.

                So the Romans built giant **stone arcades** — rows of \
                arches stacked on top of each other — to carry the channel \
                across the valley at the same height.

                The most famous one is the **Pont du Gard** in France. \
                Three levels of arches, nearly **50 meters tall**. It is \
                still standing today.
                """,
                science: .engineering,
                illustrationIcon: "archway"
            )),

            // ── 8. Fun Fact ───────────────────────────────────

            .funFact(LessonFunFact(
                text: """
                The **Pont du Gard** was built without any glue or mortar \
                between the stones. The blocks — some weighing as much as \
                an elephant — were cut so perfectly that **friction alone** \
                holds them together. Two thousand years later, it still stands.
                """
            )),

            // ── 9. Question ───────────────────────────────────

            .question(LessonQuestion(
                question: "Why did the Romans build tall stone arcades across valleys?",
                options: [
                    "To impress the people in the valley below",
                    "To keep the water channel at the right height so gravity still worked",
                    "To protect the water from enemy attacks",
                    "To let boats pass underneath"
                ],
                correctIndex: 1,
                explanation: "The water had to keep flowing downhill. When the land dipped into a valley, the arcades held the channel up high so the gentle slope never broke. No slope, no flow.",
                science: .hydraulics
            )),

            // ── 10. The Straw Trick ──────────────────────────

            .reading(LessonReading(
                title: "The Straw Trick",
                body: """
                Sometimes a valley was just too wide for arches.

                The Romans had a backup plan: the **inverted siphon**.

                Imagine drinking through a bendy straw. The water goes \
                down, then comes back up. It works because of **pressure**.

                The Romans did the same thing — but with huge **lead pipes**. \
                Water plunged down one side of the valley and shot back \
                up the other side. As long as the exit was a little lower \
                than the entrance, pressure did the rest.
                """,
                science: .hydraulics,
                illustrationIcon: "arrow.down.to.line"
            )),

            .curiosity(LessonCuriosity(questions: [
                CuriosityQA(
                    question: "Isn't lead poisonous? Did the water make people sick?",
                    answer: "Good question! Yes, lead is toxic. But the Romans got a bit lucky — mineral buildup inside the pipes created a natural coating that mostly blocked the lead from dissolving into the water. Still, some historians think low-level lead exposure was a real problem in Rome."
                ),
                CuriosityQA(
                    question: "Why didn't the pipes burst from the pressure?",
                    answer: "Sometimes they did! The pressure at the bottom of a deep valley was enormous. Romans used extra-thick lead pipes reinforced with stone casings. Maintaining siphons was one of the hardest jobs in the whole system."
                )
            ])),

            // ── 11. Splitting the Water ──────────────────────

            .reading(LessonReading(
                title: "Sharing the Water",
                body: """
                The water finally arrives in the city. Now what?

                It flows into a big stone basin called a **castellum**. \
                Think of it like a roundabout — but for water.

                From there, the water splits into smaller pipes. Some go \
                to public fountains. Some go to bathhouses. Some go to \
                rich people's homes.

                The Romans even had water meters. The size of your pipe \
                decided how much water you got. Bigger pipe, more water.
                """,
                science: .hydraulics,
                illustrationIcon: "arrow.triangle.branch"
            )),

            // ── 12. Question ─────────────────────────────────

            .question(LessonQuestion(
                question: "What does a castellum do?",
                options: [
                    "It is a fort that guards the aqueduct",
                    "It splits the water into pipes going to different places",
                    "It stores water on top of a hill",
                    "It filters dirt out of the water"
                ],
                correctIndex: 1,
                explanation: "The castellum was the city's water roundabout — a stone basin where the incoming flow was split into separate pipes heading to fountains, baths, and homes all across Rome.",
                science: .hydraulics
            )),

            // ── 13. Concrete — with Workshop prompt ──────────

            .reading(LessonReading(
                title: "Concrete That Lasts Forever",
                body: """
                Modern concrete cracks and crumbles after about 50 years.

                Roman concrete has lasted over **2,000 years**. Some of it \
                is stronger today than when it was poured.

                What is the difference?

                The secret is **volcanic ash** — a powder called \
                **pozzolana** from near Mount Vesuvius. Mix it with \
                **lime** and water, and something amazing happens. The ash \
                creates tiny crystals that grow stronger over time.

                It even hardens underwater. Perfect for aqueducts.
                """,
                science: .materials,
                illustrationIcon: "cube.fill"
            )),

            .curiosity(LessonCuriosity(questions: [
                CuriosityQA(
                    question: "Why don't we use Roman concrete today?",
                    answer: "We actually are starting to! In 2023, **MIT researchers** figured out the Romans used **hot mixing** — combining quicklime and ash at very high temperatures. This created tiny lumps that can **heal cracks on their own**. Scientists are now trying to bring this back into modern building."
                ),
                CuriosityQA(
                    question: "Where did they get the volcanic ash?",
                    answer: "From the area around **Mount Vesuvius** and other volcanic regions in Italy. The ash is called **pozzolana**, named after the town of **Pozzuoli** near Naples. Romans shipped it all over their empire."
                )
            ])),

            // ── 14. Workshop prompt — right after concrete ───

            .environmentPrompt(LessonEnvironmentPrompt(
                destination: .workshop,
                title: "Collect Volcanic Ash & Limestone",
                description: "You just learned about Roman concrete. Visit the Workshop to collect volcanic ash from the volcano and limestone from the quarry — mix them to make your own concrete.",
                icon: "hammer.fill"
            )),

            // ── 15. Fill in Blanks ───────────────────────────

            .fillInBlanks(LessonFillInBlanks(
                title: "Complete the Passage",
                text: """
                An aqueduct moves water using {{gravity}} instead of \
                pumps. The water flows through a stone channel called \
                the {{specus}}. When the channel crosses a valley, it \
                rides on top of stone {{arcades}}. At the city, a \
                {{castellum}} splits the water into separate pipes.
                """,
                distractors: ["pumps", "columns", "bridges", "forum"],
                science: .engineering
            )),

            // ── 16. Flow Math Concept ────────────────────────

            .reading(LessonReading(
                title: "How Much Water?",
                body: """
                Here is a fun way to think about aqueduct math.

                If water flows at a steady speed — say, 500 cups per \
                second — and you want to know how much arrives in an \
                hour, you just multiply.

                **Speed times time equals total.**

                That is it. That is the whole formula. You will use it \
                in the quiz to figure out how much water Rome actually \
                got every day. The numbers are wild.
                """,
                science: .mathematics,
                illustrationIcon: "drop.fill"
            )),

            // ── 16b. Flow Rate Visual ──────────────────────

            .mathVisual(LessonMathVisual(
                type: .aqueductFlowRate,
                title: "Visualize the Flow",
                science: .mathematics,
                totalSteps: 5,
                caption: "Speed times time equals total. At 500 cups per second for one hour, that is 1,800,000 cups — enough to fill thousands of bathtubs."
            )),

            // ── 17. Fun Fact ─────────────────────────────────

            .funFact(LessonFunFact(
                text: """
                By the 3rd century, Rome had **11 aqueducts** delivering \
                about **1 million cubic meters** of water per day. That \
                is roughly **400 Olympic swimming pools** — every single \
                day. For a civilization with no electricity.
                """
            )),

            // ── 18. Keeping It Running ───────────────────────

            .reading(LessonReading(
                title: "Keeping It Running",
                body: """
                Building the aqueduct was hard. Keeping it working? \
                Just as hard.

                Mineral buildup — like the crusty stuff inside an old \
                teakettle — would clog the channels over time.

                Workers called **aquarii** crawled through the tunnels \
                to scrape the walls clean. It was dark, tight, and \
                never-ending work.

                A Roman water commissioner named **Frontinus** wrote an \
                entire book about managing the system. It is one of the \
                oldest engineering manuals that still exists.
                """,
                science: .engineering,
                illustrationIcon: "wrench.and.screwdriver"
            )),

            // ── 19. Forest prompt — right when timber is needed

            .reading(LessonReading(
                title: "Building the Arches",
                body: """
                One last thing. Those stone arches did not build themselves.

                Workers needed **massive wooden scaffolding** to hold the \
                stones in place while building. Imagine a wooden skeleton \
                shaped like an arch — stones are placed on top, and once \
                the keystone locks them together, the wood is removed.

                That means **timber**. Lots of it. Some scaffolding stood \
                50 meters tall.
                """,
                science: .engineering,
                illustrationIcon: "tree.fill"
            )),

            .environmentPrompt(LessonEnvironmentPrompt(
                destination: .forest,
                title: "Gather Timber for Scaffolding",
                description: "You need timber beams to build the scaffolding for your aqueduct arches. Head into the forest to collect wood.",
                icon: "leaf.fill"
            )),

            // ── 20. Crafting Room prompt ─────────────────────

            .environmentPrompt(LessonEnvironmentPrompt(
                destination: .craftingRoom,
                title: "Craft Your Building Materials",
                description: "You have raw materials — now turn them into building supplies. Visit the Crafting Room to mix concrete, prepare lime mortar, and shape lead pipes.",
                icon: "hammer.fill"
            ))
        ]
    )

    // MARK: - Colosseum (#2)

    static let colosseumLesson = BuildingLesson(
        buildingName: "Colosseum",
        title: "The Arena of Wonders",
        sections: [
            .reading(LessonReading(
                title: "The Biggest Show on Earth",
                body: "The **Colosseum** is the largest amphitheater ever built — a giant oval arena in the heart of Rome that could hold **50,000 spectators**. Emperor Vespasian began construction in **72 AD**, and his son Titus opened it just eight years later with 100 days of games. Its real name is the **Flavian Amphitheatre**, after the Flavian dynasty of emperors who built it. For nearly 500 years, it hosted gladiator battles, animal hunts, and even mock sea battles!",
                science: .architecture,
                illustrationIcon: "building.columns"
            )),

            .curiosity(LessonCuriosity(questions: [
                CuriosityQA(
                    question: "Why did the Romans build the Colosseum on such a massive scale?",
                    answer: "It was a political move as much as an engineering one. Emperor Vespasian built it on the site of **Nero's private palace lake** — turning one tyrant's luxury into entertainment for the people. The message was clear: this space belongs to Rome now, not to one emperor. Bigger meant more public goodwill."
                ),
                CuriosityQA(
                    question: "How did they build something this huge in only 8 years?",
                    answer: "The Romans were masters of **modular construction**. The Colosseum is basically the same arch-and-vault unit repeated 80 times around an oval. Think of it like stacking identical LEGO modules in a ring. Multiple crews could work on different sections simultaneously. Plus, they had an estimated **60,000 to 100,000 laborers** working at once."
                )
            ])),

            .reading(LessonReading(
                title: "The Elliptical Design",
                body: "The Colosseum is shaped like a giant **ellipse** — a stretched circle, like an egg viewed from above. It measures **188 meters long** and **156 meters wide**, with walls rising **48 meters** high (about as tall as a 15-story building). The elliptical shape is not just for looks — it gives every spectator a better view of the action than a simple circle would, and it makes the structure stronger because forces spread evenly around the curve.",
                science: .architecture,
                illustrationIcon: "oval"
            )),
            .question(LessonQuestion(
                question: "The Colosseum is an ellipse measuring 188 m × 156 m. The area of an ellipse is A = π × a × b, where a and b are half the length and width. What is the approximate arena area?",
                options: ["18,000 m²", "23,000 m²", "46,000 m²", "92,000 m²"],
                correctIndex: 1,
                explanation: "Half of 188 is 94, and half of 156 is 78. A = π × 94 × 78 ≈ 3.14159 × 7,332 ≈ 23,032 m². That is about the size of three football fields!",
                science: .mathematics,
                hints: [
                    "First find the semi-axes: a = 188 ÷ 2 and b = 156 ÷ 2.",
                    "a = 94 and b = 78. Now multiply: π × 94 × 78.",
                    "3.14159 × 94 × 78 ≈ 23,032 m². The closest answer is 23,000 m²."
                ]
            )),
            .reading(LessonReading(
                title: "80 Arches, 4 Stories",
                body: "The outer wall of the Colosseum has **80 arches on each level**, stacked four stories high. Each story uses a different style of column, following the Greek architectural orders: **Doric** (simple and strong) on the ground floor, **Ionic** (with scroll-shaped capitals) on the second, **Corinthian** (decorated with acanthus leaves) on the third, and flat **pilasters** on the top. This layered system is called the **superimposed order** — the heaviest, simplest columns carry the most weight at the bottom.",
                science: .architecture,
                illustrationIcon: "square.grid.3x3"
            )),

            .mathVisual(LessonMathVisual(
                type: .colosseumArchForce,
                title: "Visualize the Forces",
                science: .engineering,
                totalSteps: 5,
                caption: "Each arch transfers weight sideways and downward through the stones. The keystone at the top locks everything in place — remove it and the whole arch collapses."
            )),

            .funFact(LessonFunFact(
                text: "The Colosseum had **76 numbered entrances** called **vomitoria** (from the Latin word meaning \"to spew forth\"). These cleverly designed passages could fill the entire arena in just **15 minutes** and empty it in about **5 minutes** — better crowd flow than most modern stadiums!"
            )),
            .question(LessonQuestion(
                question: "Why did the Romans use different column orders on each story of the Colosseum?",
                options: [
                    "Each emperor chose a different style",
                    "Heavier, stronger columns support more weight at the bottom",
                    "They ran out of one type of stone",
                    "Different columns represent different gods"
                ],
                correctIndex: 1,
                explanation: "The superimposed order places the strongest, simplest columns (Doric) at the bottom where the weight is greatest, and lighter, more decorative columns higher up. It is both structurally smart and visually elegant!",
                science: .engineering
            )),
            .reading(LessonReading(
                title: "Travertine and Iron Clamps",
                body: "The Colosseum's skeleton is made of **travertine limestone** — a creamy-white stone quarried from Tivoli, about 30 kilometers away. The blocks were held together not with mortar but with **iron clamps** — metal pins shaped like staples that locked each stone to its neighbor. Over **300 tonnes of iron** were used! Sadly, medieval scavengers pried out many of these clamps, which is why the outer wall has so many holes today.",
                science: .engineering,
                illustrationIcon: "link"
            )),
            .reading(LessonReading(
                title: "The Hypogeum — Underground Secrets",
                body: "Beneath the arena floor lay the **hypogeum** (say: high-po-JEE-um), a hidden underground world of tunnels, cages, and machinery. It was like the backstage of a theater! **Trap doors** in the arena floor could pop open to release wild animals. **Wooden elevators**, powered by teams of workers pulling ropes and pulleys, lifted heavy cages from below. There were **36 trap doors** and **28 elevator platforms** — imagine the surprise when a lion suddenly appeared from the ground!",
                science: .engineering,
                illustrationIcon: "arrow.up.square"
            )),

            .curiosity(LessonCuriosity(questions: [
                CuriosityQA(
                    question: "How did the elevator system actually work without electricity?",
                    answer: "Pure human power and clever engineering. Teams of workers turned **capstans** — large wooden drums — that wound ropes around pulleys. The mechanical advantage of the pulley system meant a few workers could lift a cage with a **500-kilogram lion** inside. It is the same physics behind modern cranes, just powered by muscle instead of motors."
                ),
                CuriosityQA(
                    question: "What happened to all the animals used in the arena?",
                    answer: "The numbers were staggering and tragic. During the 100-day opening games alone, an estimated **9,000 animals** were killed. Over the centuries, Roman arena games drove several species to **local extinction** in North Africa, including lions, hippos, and elephants. It was one of the ancient world's greatest ecological disasters."
                )
            ])),

            .funFact(LessonFunFact(
                text: "During the opening games in **80 AD**, the Romans flooded the arena to stage a **naumachia** — a mock sea battle with real warships! They later built the permanent hypogeum below, which made flooding impossible, but those first sea battles must have been an incredible sight."
            )),
            .reading(LessonReading(
                title: "The Velarium — A Retractable Roof",
                body: "On hot days, a massive **velarium** — a retractable canvas awning — could be stretched across the top of the Colosseum to shade the spectators. It was supported by **240 wooden masts** mounted on the top wall, with ropes running down to stone bollards anchored in the ground outside. Operating it required a team of **1,000 sailors** from the Roman navy, because only they had the skill to handle such enormous rigging. Think of it like the world's largest sail!",
                science: .engineering,
                illustrationIcon: "tent"
            )),
            .question(LessonQuestion(
                question: "What was the velarium?",
                options: [
                    "The underground tunnel system",
                    "A retractable canvas awning that shaded spectators",
                    "The VIP seating area for the emperor",
                    "A type of gladiator armor"
                ],
                correctIndex: 1,
                explanation: "The velarium was a massive retractable canvas shade stretched across the open top of the Colosseum. It was operated by 1,000 sailors using ropes and masts — like rigging a giant ship's sail!",
                science: .engineering
            )),
            .reading(LessonReading(
                title: "Sound in the Arena",
                body: "With 50,000 people cheering, the Colosseum needed to handle a LOT of noise. The **elliptical shape** actually helped with **acoustics** — the science of sound. Sound waves bouncing off the curved walls created a natural amplification effect, so announcements could be heard across the arena. The stone surfaces reflected sound efficiently, and the tiered seating meant that even people at the top row could hear what was happening below. It worked like a giant stone megaphone.",
                science: .acoustics,
                illustrationIcon: "speaker.wave.3"
            )),

            .mathVisual(LessonMathVisual(
                type: .colosseumSoundWave,
                title: "Visualize Sound Waves",
                science: .acoustics,
                totalSteps: 5,
                caption: "Sound waves bounce off the curved stone walls and converge toward the seating tiers. The elliptical shape focuses sound the way a satellite dish focuses radio signals."
            )),

            .reading(LessonReading(
                title: "Seating by Social Class",
                body: "Seating in the Colosseum was strictly organized by social class. The **emperor's box** (pulvinar) was at the center of the long side, with the best view. **Senators** sat in the front rows on marble seats. Behind them came the **equestrians** (wealthy businessmen), then ordinary **citizens**, and at the very top — the **women and the poor**, sitting on wooden benches under the velarium masts. Even in entertainment, Rome was a society of strict hierarchy!",
                science: .architecture,
                illustrationIcon: "person.3.sequence"
            )),
            .fillInBlanks(LessonFillInBlanks(
                title: "Complete the Passage",
                text: "The Colosseum is shaped like an {{ellipse}} and could seat {{50,000}} spectators. Its walls are made of {{travertine}} limestone held together with iron {{clamps}}. Below the arena floor, the {{hypogeum}} contained tunnels and elevators for staging dramatic entrances.",
                distractors: ["circle", "marble", "mortar", "basement"],
                science: .architecture
            )),
            .reading(LessonReading(
                title: "Roman Concrete Inside",
                body: "While the outer walls used travertine blocks, the interior walls and vaults relied heavily on **Roman concrete** — the same volcanic ash mixture used in the aqueducts. Concrete was perfect for the curved vaults that supported the seating tiers because it could be poured into wooden molds of any shape. The inner walls also used **tufa** (soft volcanic rock) and **brick**, which are lighter than travertine and helped reduce the enormous weight of the structure.",
                science: .materials,
                illustrationIcon: "square.stack.3d.up"
            )),

            .curiosity(LessonCuriosity(questions: [
                CuriosityQA(
                    question: "Why use three different materials instead of just one?",
                    answer: "Each material had a specific job. **Travertine** was strong and beautiful for the outer facade. **Concrete** could be poured into any shape for curved vaults. **Tufa and brick** were lighter for upper levels. Using the right material in the right place is like choosing the right tool for each job — it saves weight, money, and makes the whole structure stronger."
                ),
                CuriosityQA(
                    question: "How did they make curved concrete vaults without modern molds?",
                    answer: "They built temporary wooden frames called **centering** in the exact shape of the vault. Concrete was poured over the wooden frame and left to harden. Once the concrete set, the wood was removed and reused for the next vault. The Colosseum has hundreds of identical vaults — so they recycled the same wooden forms over and over."
                )
            ])),

            .funFact(LessonFunFact(
                text: "Building the Colosseum required about **100,000 cubic meters** of travertine, roughly **6,000 tonnes** of concrete, and **300 tonnes** of iron clamps. An estimated **60,000 to 100,000** Jewish slaves captured after the siege of Jerusalem did much of the construction work."
            )),
            .question(LessonQuestion(
                question: "If each of the 80 arches on one level is 4.2 meters wide, what is the approximate outer circumference of that level?",
                options: ["168 meters", "336 meters", "527 meters", "640 meters"],
                correctIndex: 2,
                explanation: "The arches account for most of the circumference, but there are also pillar widths between them. The actual outer circumference of the Colosseum is about 527 meters. The ellipse perimeter formula gives a similar result: π × (188 + 156) / 2 × correction ≈ 527 m.",
                science: .mathematics,
                hints: [
                    "This is tricky — 80 arches × 4.2 m = 336 m, but that does not include the pillars between arches.",
                    "The actual circumference of an ellipse is longer than just the arches. Use the approximate formula: π × (a + b) where a = 94 and b = 78.",
                    "π × (94 + 78) ≈ 3.14 × 172 ≈ 540 m. The closest answer accounting for the actual measured perimeter is 527 meters."
                ]
            )),
            .reading(LessonReading(
                title: "Materials for Your Colosseum",
                body: "Ready to build your own Colosseum? You will need **Roman concrete** for the massive interior vaults and foundations. **Silk fabric** represents the velarium awning that shaded thousands of spectators. **Marble slabs** will line the senator seating and decorative facades. And **bronze fittings** are needed for the pulleys, hinges, and mechanisms of the hypogeum elevator system. Let us gather what we need!",
                science: .materials,
                illustrationIcon: "shippingbox"
            )),
            .environmentPrompt(LessonEnvironmentPrompt(
                destination: .workshop,
                title: "Gather Building Materials",
                description: "Visit the workshop to collect travertine from the quarry, mix volcanic ash for concrete, and gather bronze for the elevator mechanisms of the hypogeum.",
                icon: "hammer.fill"
            )),
            .environmentPrompt(LessonEnvironmentPrompt(
                destination: .forest,
                title: "Timber for the Velarium",
                description: "The massive velarium needed 240 wooden masts! Head to the forest to gather strong timber for the masts and scaffolding frames.",
                icon: "leaf.fill"
            ))
        ]
    )

    // MARK: - Roman Baths (#3)

    static let romanBathsLesson = BuildingLesson(
        buildingName: "Roman Baths",
        title: "The Social Hub of Rome",
        sections: [
            .reading(LessonReading(
                title: "More Than Just a Bath",
                body: "When Romans said they were going to the **baths** (thermae), they did not just mean a quick scrub! Roman bathhouses were like ancient community centers — enormous complexes with swimming pools, exercise yards, libraries, gardens, and snack bars. The **Baths of Caracalla**, one of the largest, could hold **1,600 bathers** at once and covered an area the size of **6 football fields**. Going to the baths was a daily social ritual for rich and poor alike.",
                science: .materials,
                illustrationIcon: "drop.halffull"
            )),

            .curiosity(LessonCuriosity(questions: [
                CuriosityQA(
                    question: "Did Romans have soap?",
                    answer: "Not really! Instead of soap, Romans rubbed **olive oil** all over their skin, then scraped it off with a curved metal tool called a **strigil**. The oil pulled dirt and sweat away with it. Soap existed in the ancient world, but Romans considered it a barbarian product. They preferred their oil-and-scrape method."
                ),
                CuriosityQA(
                    question: "Were Roman baths mixed or separated by gender?",
                    answer: "It changed over time. Early baths had **separate hours** for men and women — women bathed in the morning, men in the afternoon. Some larger bath complexes built **duplicate facilities** side by side. Emperor Hadrian officially banned mixed bathing, though enforcement was spotty."
                )
            ])),

            .reading(LessonReading(
                title: "Three Rooms, Three Temperatures",
                body: "A typical Roman bath visit followed a set path through three main rooms. First, the **tepidarium** (say: tep-ih-DAR-ee-um) — a warm room to help your body adjust. Next, the **caldarium** — a steamy hot room with heated pools, like a modern hot tub. Finally, the **frigidarium** — a cold plunge pool to refresh and close your pores. Some bathers went back and forth between hot and cold several times! This hot-cold therapy is the ancestor of modern spa treatments.",
                science: .chemistry,
                illustrationIcon: "thermometer"
            )),
            .question(LessonQuestion(
                question: "What is the correct order of rooms in a Roman bath visit?",
                options: [
                    "Frigidarium → Caldarium → Tepidarium",
                    "Caldarium → Tepidarium → Frigidarium",
                    "Tepidarium → Caldarium → Frigidarium",
                    "Frigidarium → Tepidarium → Caldarium"
                ],
                correctIndex: 2,
                explanation: "Bathers started in the warm tepidarium to acclimate, moved to the hot caldarium for a deep heat soak, and finished in the cold frigidarium for a refreshing plunge. The gradual temperature change was easier on the body!",
                science: .chemistry
            )),
            .reading(LessonReading(
                title: "The Hypocaust — Underfloor Heating",
                body: "How did the Romans heat an entire building without radiators or electricity? With the **hypocaust** system! The floor of the caldarium was raised on stacks of small brick pillars called **pilae**, creating a gap about **60 centimeters** high underneath. A large furnace called a **praefurnium** burned wood to create hot air, which flowed under the raised floor and up through hollow channels in the walls called **tubuli**. The floor got so hot that bathers wore wooden sandals to protect their feet!",
                science: .hydraulics,
                illustrationIcon: "flame"
            )),
            .funFact(LessonFunFact(
                text: "The hypocaust system is the ancestor of modern **radiant floor heating**! Some luxury homes today use the exact same principle — hot water or air flowing beneath the floor to warm the room from the ground up. The Romans figured it out over 2,000 years ago."
            )),
            .reading(LessonReading(
                title: "Hot Air Rises — The Science of Convection",
                body: "The hypocaust works because of a principle called **convection**: hot air rises and cold air sinks. When the furnace heats the air under the floor, that hot air naturally flows upward through the wall tubes (tubuli) and escapes through vents in the roof. As hot air leaves, it pulls in fresh air through the furnace, keeping the cycle going. This creates a continuous loop of heating — no fans or pumps needed! It is the same reason hot air balloons float.",
                science: .chemistry,
                illustrationIcon: "wind"
            )),

            .mathVisual(LessonMathVisual(
                type: .bathsHeatTransfer,
                title: "Visualize Heat Transfer",
                science: .chemistry,
                totalSteps: 5,
                caption: "Hot air from the furnace flows under the raised floor, rises through hollow wall tubes (tubuli), and exits through roof vents. The cycle repeats as cool air gets pulled back into the furnace."
            )),

            .question(LessonQuestion(
                question: "Why were the bath floors raised on brick pillars?",
                options: [
                    "To prevent flooding from the pools",
                    "To create space for hot air to circulate underneath",
                    "To store firewood beneath the floor",
                    "To make the building taller and more impressive"
                ],
                correctIndex: 1,
                explanation: "The pilae (brick pillars) created a gap under the floor where hot air from the furnace could circulate freely. This heated the floor from below, which then warmed the room above — the clever hypocaust system!",
                science: .hydraulics
            )),
            .reading(LessonReading(
                title: "Waterproof Concrete and Lead Pipes",
                body: "Bathhouses needed to hold millions of liters of water without leaking. The Romans used their famous **waterproof concrete** made with volcanic ash (pozzolana) for the pools and walls. Water was delivered through **lead pipes** called **fistulae**, connected to the aqueduct system. The lead was soft enough to bend into shape and strong enough to withstand water pressure. Each pipe was stamped with the name of the building it served — ancient plumbing records!",
                science: .materials,
                illustrationIcon: "pipe.and.drop"
            )),

            .curiosity(LessonCuriosity(questions: [
                CuriosityQA(
                    question: "How much water did a Roman bathhouse use per day?",
                    answer: "The Baths of Caracalla consumed an estimated **8 million liters per day** — roughly the same as 3,200 modern households. That is why the baths needed their own dedicated **aqueduct branch**. The water was constantly flowing through, not sitting still, which kept it relatively clean."
                ),
                CuriosityQA(
                    question: "Did the Romans know lead pipes were dangerous?",
                    answer: "The architect **Vitruvius** actually warned about lead in his writings. He noticed that lead workers looked pale and sickly, and recommended **terracotta pipes** instead. But lead was so much easier to shape that most builders used it anyway. Luckily, mineral buildup inside the pipes created a natural coating that reduced direct contact with the water."
                )
            ])),

            .reading(LessonReading(
                title: "Mosaic Floors — Art Meets Engineering",
                body: "The floors and walls of Roman baths were decorated with stunning **mosaics** — pictures made from thousands of tiny colored stone or glass cubes called **tesserae**. But mosaics were not just pretty — they were also practical! The rough surface of the tiny tiles gave bathers grip on wet floors, preventing slipping. Mosaic artists laid a base of Roman concrete, then pressed each tessera into a bed of wet mortar, creating images of sea creatures, athletes, and geometric patterns.",
                science: .materials,
                illustrationIcon: "square.grid.4x3.fill"
            )),

            .mathVisual(LessonMathVisual(
                type: .bathsWaterVolume,
                title: "Visualize the Water Volume",
                science: .hydraulics,
                totalSteps: 5,
                caption: "Volume = length times width times depth. A caldarium pool measuring 10 m by 5 m by 1.5 m holds 75 cubic meters of water — that is 75,000 liters, enough to fill 375 bathtubs."
            )),

            .funFact(LessonFunFact(
                text: "Some Roman baths had **heated swimming pools** large enough for dozens of people. The Baths of Diocletian, the biggest in Rome, could hold over **3,000 bathers** at once and even had a **revolving dining room** that turned slowly so guests could enjoy the view from every angle!"
            )),
            .reading(LessonReading(
                title: "Glass Windows — Ancient Technology",
                body: "Roman baths were among the first buildings to use **glass windows**. The caldarium needed to trap heat inside while still letting in natural light. Roman glassmakers produced flat panes by blowing a glass bubble, cutting it open, and flattening it — a technique called **crown glass**. The panes were small and slightly wavy, but they worked! Large windows in the caldarium faced south or west to capture afternoon sunlight, adding free solar heating to the hypocaust system.",
                science: .materials,
                illustrationIcon: "window.ceiling"
            )),

            .curiosity(LessonCuriosity(questions: [
                CuriosityQA(
                    question: "Is the hypocaust system really the same as modern radiant floor heating?",
                    answer: "Almost identical in principle! Modern radiant heating runs **hot water through tubes** under the floor instead of hot air through an open gap. The physics is the same — heat radiates upward from the floor, warming the room evenly from the ground up. It is considered the most comfortable type of heating because your feet stay warm."
                ),
                CuriosityQA(
                    question: "How hot did the caldarium actually get?",
                    answer: "The floor could reach temperatures above **50 degrees Celsius** — hot enough to burn bare feet, which is why bathers wore thick wooden sandals called **sculponae**. The air temperature hovered around **40 to 50 degrees Celsius**, similar to a modern sauna. The frigidarium plunge pool was a welcome relief after that kind of heat."
                )
            ])),

            .question(LessonQuestion(
                question: "Why did the caldarium windows face south or west?",
                options: [
                    "To give bathers a view of the sunset",
                    "To capture afternoon sunlight for extra heating",
                    "Because the entrance was always on the north side",
                    "To protect the glass from strong winds"
                ],
                correctIndex: 1,
                explanation: "South and west-facing windows captured the most afternoon sunlight, which added free solar heating to the already warm caldarium. This clever orientation reduced the amount of wood the furnace needed to burn!",
                science: .chemistry
            )),
            .fillInBlanks(LessonFillInBlanks(
                title: "Complete the Passage",
                text: "The Roman bath heating system was called a {{hypocaust}}. Hot air from a furnace flowed under a {{raised}} floor supported by brick {{pilae}}. The hot air rose through hollow wall channels called {{tubuli}} and escaped through roof vents. This worked because of {{convection}} — the principle that hot air rises.",
                distractors: ["aqueduct", "flat", "arches", "columns", "gravity"],
                science: .hydraulics
            )),
            .reading(LessonReading(
                title: "Fuel and the Forests",
                body: "There was one big problem with the hypocaust: it needed enormous amounts of **firewood**. The Baths of Caracalla alone burned an estimated **10 tonnes of wood per day** to keep the furnaces going. Over centuries, this demand contributed to **deforestation** around Roman cities. Slaves called **fornacatores** worked in shifts to keep the fires burning day and night. The environmental cost of Roman bathing culture is a reminder that even ancient civilizations faced resource challenges.",
                science: .materials,
                illustrationIcon: "leaf.arrow.triangle.circlepath"
            )),
            .reading(LessonReading(
                title: "Materials for Your Roman Baths",
                body: "Building your own Roman bath complex requires some special materials. **Roman concrete** mixed with volcanic ash will make the pools waterproof. **Timber beams** fuel the hypocaust furnaces and support the roof structure. **Glass panes** let sunlight warm the caldarium naturally. And **marble slabs** provide the elegant finishing touches on walls and columns. Time to get collecting!",
                science: .materials,
                illustrationIcon: "shippingbox"
            )),
            .environmentPrompt(LessonEnvironmentPrompt(
                destination: .workshop,
                title: "Collect Bath Materials",
                description: "Head to the workshop to gather volcanic ash for waterproof concrete, sand for glassmaking, and marble for the elegant bath interiors.",
                icon: "hammer.fill"
            )),
            .environmentPrompt(LessonEnvironmentPrompt(
                destination: .forest,
                title: "Gather Firewood",
                description: "The hypocaust furnaces need enormous amounts of fuel! Visit the forest to collect timber for heating the baths and supporting the roof structure.",
                icon: "leaf.fill"
            ))
        ]
    )

    // MARK: - Roman Roads (#5)

    static let romanRoadsLesson = BuildingLesson(
        buildingName: "Roman Roads",
        title: "All Roads Lead to Rome",
        sections: [
            .reading(LessonReading(
                title: "The Network That Built an Empire",
                body: "The Roman road network was one of the greatest engineering achievements in history. At its peak, it stretched over **80,000 kilometers** — enough to wrap around the Earth twice! These roads connected every corner of the Roman Empire, from Britain in the north to Egypt in the south. The most famous road, the **Via Appia** (Appian Way), was built in **312 BC** and you can still walk on it today, over 2,300 years later. Roman roads were built so well that many modern European roads follow their exact same routes.",
                science: .engineering,
                illustrationIcon: "road.lanes"
            )),

            .curiosity(LessonCuriosity(questions: [
                CuriosityQA(
                    question: "Why were Roman roads so much better than everyone else's?",
                    answer: "Most ancient civilizations just packed down dirt or laid loose gravel. Romans treated roads like **buildings** — engineered structures with foundations, drainage, and a proper surface. They spent the money and labor upfront because they knew a good road pays for itself. A legion that marches twice as fast controls twice the territory."
                ),
                CuriosityQA(
                    question: "Did ordinary people use Roman roads, or just the army?",
                    answer: "Everyone used them! Merchants hauled goods to market, messengers carried mail, families traveled between cities, and farmers drove cattle to sale. The roads created a **connected economy** across the empire. Some roads even had ancient rest stops called **mansiones** where travelers could eat and sleep — like Roman highway service stations."
                )
            ])),

            .reading(LessonReading(
                title: "Four Layers of Engineering",
                body: "A Roman road was not just a flat path — it was a carefully engineered structure built in **four layers**, like a layered cake. First, the **statumen** (say: sta-TOO-men) — a foundation of large, flat stones. Next, the **rudus** — a layer of crushed rock mixed with lime mortar. Then the **nucleus** — a finer layer of gravel and sand packed down hard. Finally, the **summa crusta** (top surface) — large, flat **basalt paving stones** fitted tightly together. Each layer had a specific job, making the road incredibly strong and durable.",
                science: .engineering,
                illustrationIcon: "square.stack"
            )),

            .mathVisual(LessonMathVisual(
                type: .roadsLayerCross,
                title: "Visualize the Road Layers",
                science: .engineering,
                totalSteps: 5,
                caption: "A cross-section reveals four distinct layers, each finer than the one below. The crowned surface slopes gently from center to edges for drainage."
            )),

            .question(LessonQuestion(
                question: "What are the four layers of a Roman road from bottom to top?",
                options: [
                    "Rudus → Statumen → Nucleus → Summa Crusta",
                    "Statumen → Rudus → Nucleus → Summa Crusta",
                    "Nucleus → Statumen → Summa Crusta → Rudus",
                    "Summa Crusta → Nucleus → Rudus → Statumen"
                ],
                correctIndex: 1,
                explanation: "From bottom to top: Statumen (large foundation stones), Rudus (crushed rock with mortar), Nucleus (fine gravel and sand), and Summa Crusta (the top paving stones). Each layer gets finer as you go up!",
                science: .engineering
            )),
            .reading(LessonReading(
                title: "The Drainage Crown",
                body: "Have you ever noticed that roads today are slightly higher in the center? The Romans invented that! They built their roads with a gentle curve called a **crown** — the center of the road was about **15 to 30 centimeters** higher than the edges. When it rained, water would flow off to both sides and into drainage ditches instead of pooling on the road surface. This is why Roman roads lasted so long — water is the number one enemy of any road, and the Romans made sure it could never sit still.",
                science: .engineering,
                illustrationIcon: "cloud.rain"
            )),

            .curiosity(LessonCuriosity(questions: [
                CuriosityQA(
                    question: "Why is water so destructive to roads?",
                    answer: "Water is sneaky. It seeps into tiny cracks, then **freezes and expands** in winter, making the cracks bigger. This is called the **freeze-thaw cycle**. Over time, small cracks become potholes. Water also softens the soil underneath the road, causing it to sink and buckle. Every road engineer today still fights the same battle the Romans did."
                ),
                CuriosityQA(
                    question: "Do modern roads still use the crown design?",
                    answer: "Absolutely. Every highway, street, and parking lot you drive on is **slightly higher in the center**. The standard modern road crown is about a **2 percent slope** — almost identical to what the Romans used. Some things are so well designed that 2,000 years of progress cannot improve on them."
                )
            ])),

            .funFact(LessonFunFact(
                text: "Roman roads were so straight that when modern engineers build new roads along the same routes, they often cannot improve on the Roman alignment! The Romans preferred to go **straight over hills** rather than around them, which made their roads shorter and easier to navigate."
            )),
            .reading(LessonReading(
                title: "Surveying with the Groma",
                body: "Before laying a single stone, Roman surveyors had to plan a perfectly straight route. Their most important tool was the **groma** — a wooden cross mounted on a pole, with weighted strings hanging from each arm. By sighting along the hanging strings, a surveyor could mark perfectly straight lines across miles of terrain. Another tool, the **decempeda**, was a measuring rod exactly **10 Roman feet** long (about 2.96 meters), used to measure distances. Teams of surveyors could lay out a road route in remarkably straight lines across mountains and valleys.",
                science: .geology,
                illustrationIcon: "scope"
            )),
            .reading(LessonReading(
                title: "Basalt — The Perfect Paving Stone",
                body: "The top surface of a Roman road used **basalt**, a dark volcanic rock that is incredibly hard and resistant to wear. Basalt forms when lava cools quickly on the Earth's surface, creating tiny, tightly packed crystals that make it extremely dense. Roman stonecutters shaped basalt blocks into irregular polygons that fitted together like a jigsaw puzzle — this interlocking pattern prevented the stones from shifting under heavy traffic. Italy's volcanic geology provided an abundant supply of this perfect paving material.",
                science: .geology,
                illustrationIcon: "mountain.2"
            )),

            .mathVisual(LessonMathVisual(
                type: .roadsLoadDistribution,
                title: "Visualize Load Distribution",
                science: .engineering,
                totalSteps: 5,
                caption: "When a wagon wheel presses on the surface, the force spreads outward and downward through each layer. By the time it reaches the soil, the load is distributed over a much wider area — preventing the road from sinking."
            )),

            .question(LessonQuestion(
                question: "Why did Roman engineers build roads with a crowned (curved) surface?",
                options: [
                    "To make chariots go faster downhill",
                    "So rainwater would drain off to the sides",
                    "To show the importance of the road",
                    "Because the foundation stones were uneven"
                ],
                correctIndex: 1,
                explanation: "The crown (higher center) caused rainwater to flow off to both sides and into drainage ditches. This prevented water from pooling on the surface, which would have weakened the road over time. Water damage is the biggest threat to any road!",
                science: .engineering
            )),
            .reading(LessonReading(
                title: "Milestones — Ancient GPS",
                body: "Every Roman road had **milestones** (miliaria) placed at intervals of one **Roman mile**, which equaled **1,000 paces** (about **1.48 kilometers**). Each milestone was a stone column inscribed with the distance to the nearest city, the name of the emperor who built or repaired that section, and sometimes the date. They were the ancient world's version of highway signs! The **Milliarium Aureum** (Golden Milestone) in the Roman Forum was the symbolic starting point for all measurements — the original \"mile zero.\"",
                science: .engineering,
                illustrationIcon: "signpost.right"
            )),
            .funFact(LessonFunFact(
                text: "The phrase **\"All roads lead to Rome\"** was literally true! Every major road in the Empire connected to the network, and distances on every milestone were measured from the Golden Milestone in the Roman Forum. No matter where you were in the Empire, the road signs could guide you back to Rome."
            )),
            .reading(LessonReading(
                title: "Lime Mortar — The Ancient Glue",
                body: "What held all those layers of crushed stone together? **Lime mortar** — a mixture of **limestone** heated to very high temperatures (a process called **calcination**), then mixed with water and sand. When limestone is heated, it turns into **quickite** (calcium oxide). Adding water creates **slaked lime** (calcium hydroxide), which slowly reacts with carbon dioxide in the air to harden back into limestone. It is a chemical cycle that takes the rock apart and puts it back together as a glue! Roman lime mortar bound the rudus and nucleus layers into a solid mass.",
                science: .materials,
                illustrationIcon: "drop.triangle"
            )),

            .curiosity(LessonCuriosity(questions: [
                CuriosityQA(
                    question: "Is lime mortar basically the same as modern cement?",
                    answer: "Close but not quite. Modern **Portland cement** uses a different chemistry that sets faster and harder, but it is also more brittle. Lime mortar is **flexible** — it can absorb small movements without cracking, which is why Roman roads survived earthquakes and ground settling. Some modern restoration projects are going back to lime mortar because it works better with old stone."
                ),
                CuriosityQA(
                    question: "How hot does a lime kiln need to be?",
                    answer: "About **900 degrees Celsius** — hot enough to make steel glow bright orange. Roman lime kilns burned wood for days to reach these temperatures. A single kiln might consume an entire **hillside of trees** to produce enough quicklime for a few kilometers of road. It was one of the most energy-intensive processes in the ancient world."
                )
            ])),

            .fillInBlanks(LessonFillInBlanks(
                title: "Complete the Passage",
                text: "Roman roads were built in four layers. The bottom layer of large flat stones is the {{statumen}}. Above that, the {{rudus}} is made of crushed rock and lime mortar. The {{nucleus}} layer uses fine gravel and sand. The top paving surface is called the {{summa crusta}} and was made of hard {{basalt}} stones.",
                distractors: ["concrete", "marble", "foundation", "granite"],
                science: .engineering
            )),
            .reading(LessonReading(
                title: "Building an Army's Highway",
                body: "Roman roads were originally built for **military purposes** — legions needed to march quickly across the empire. A Roman legion could march **30 kilometers per day** on a good road, which was astonishing speed for ancient times. The roads were typically **4 to 6 meters wide**, enough for two wagons to pass each other. Major roads had raised sidewalks for pedestrians and drainage ditches on both sides. An army of soldiers, slaves, and engineers could build about **1.5 kilometers** of road per day.",
                science: .engineering,
                illustrationIcon: "figure.walk"
            )),
            .question(LessonQuestion(
                question: "A Roman mile was 1,000 paces, equal to about 1.48 km. If a road has milestones and you pass 20 of them, approximately how far have you traveled?",
                options: ["14.8 km", "20 km", "29.6 km", "48 km"],
                correctIndex: 2,
                explanation: "Each milestone marks one Roman mile (1.48 km). Passing 20 milestones means you have walked 20 × 1.48 = 29.6 km. That is about the distance of a marathon!",
                science: .geology,
                hints: [
                    "Each milestone represents one Roman mile, which is about 1.48 km.",
                    "Multiply the number of milestones by the distance of one Roman mile: 20 × 1.48.",
                    "20 × 1.48 = 29.6 km. The answer is 29.6 km."
                ]
            )),
            .reading(LessonReading(
                title: "Legacy of Roman Roads",
                body: "The influence of Roman roads stretches far beyond the ancient world. Many modern highways in Europe — including parts of the **A1 motorway** in Italy and the **A5 road** in England — follow routes first laid by Roman engineers. The word **\"street\"** comes from the Latin **strata** (meaning \"paved\"), and **\"mile\"** comes from **mille passus** (thousand paces). Every time you walk on a paved road, you are walking in the footsteps of Roman engineering genius!",
                science: .engineering,
                illustrationIcon: "globe.europe.africa"
            )),
            .reading(LessonReading(
                title: "Materials for Your Roman Road",
                body: "To build your own section of Roman road, you will need several materials. **Roman concrete** provides the strong base for the rudus layer. **Lime mortar** binds the crushed stone layers together into a solid mass. And **marble slabs** can be used for the decorative milestones that mark the distance. Head out and start collecting!",
                science: .materials,
                illustrationIcon: "shippingbox"
            )),
            .environmentPrompt(LessonEnvironmentPrompt(
                destination: .workshop,
                title: "Quarry Stone and Mix Mortar",
                description: "Visit the workshop to quarry basalt for paving stones, collect limestone for lime mortar, and gather volcanic ash for the concrete layers.",
                icon: "hammer.fill"
            ))
        ]
    )

    // MARK: - Harbor (#6)

    static let harborLesson = BuildingLesson(
        buildingName: "Harbor",
        title: "Gateway to the Empire",
        sections: [
            .reading(LessonReading(
                title: "Rome's Lifeline on the Sea",
                body: "Rome was a city of over a million people, and it could not grow enough food to feed them all. Grain ships from Egypt, olive oil from Spain, and wine from Gaul — all arrived by sea. But the Tiber River was too shallow for large ships, so the Romans needed a massive **harbor** on the coast. Emperor Claudius began building **Portus** in **42 AD**, about 30 kilometers from Rome. His successor Trajan later expanded it with an innovative **hexagonal basin**. Portus became the greatest port in the ancient world!",
                science: .engineering,
                illustrationIcon: "ferry"
            )),

            .curiosity(LessonCuriosity(questions: [
                CuriosityQA(
                    question: "How much food did Rome import through its harbors?",
                    answer: "Staggering amounts. Egypt alone shipped about **150,000 tonnes of grain** to Rome every year — enough to feed roughly **a third of the city**. A single large grain ship could carry 1,000 tonnes. Lose the harbor, and Rome starves. That is why Portus was considered as important as the army."
                ),
                CuriosityQA(
                    question: "Why not just grow food closer to Rome?",
                    answer: "The farmland around Rome could not produce nearly enough for a million people. Plus, wealthy Romans had converted much of Italy's farmland into **latifundia** — huge estates growing luxury crops like olives and grapes instead of wheat. It was cheaper to ship grain from Egypt's incredibly fertile Nile Delta than to restructure Italian agriculture."
                )
            ])),

            .reading(LessonReading(
                title: "Breakwaters — Taming the Waves",
                body: "The biggest challenge of building a harbor is protecting ships from ocean waves and storms. Roman engineers built massive **breakwaters** — long walls stretching out into the sea to block incoming waves. The breakwaters at Portus extended over **500 meters** into the Mediterranean. They were built by sinking enormous wooden frames called **caissons** into the water, then filling them with concrete. The calm water behind the breakwaters created a safe anchorage where hundreds of ships could dock at once.",
                science: .engineering,
                illustrationIcon: "water.waves"
            )),
            .funFact(LessonFunFact(
                text: "To build the foundation of his harbor lighthouse, Emperor Claudius sank the **largest ship in the Roman world** — a massive vessel that had carried a 300-tonne Egyptian obelisk to Rome. The ship was filled with concrete and sunk to form an artificial island. Now that is creative recycling!"
            )),
            .reading(LessonReading(
                title: "Underwater Concrete — The Roman Miracle",
                body: "How do you build walls underwater? The Romans discovered something amazing: their concrete made with **pozzolana** (volcanic ash from the area near Pozzuoli) actually **hardens in seawater**! In fact, it gets stronger over time. When pozzolana concrete meets saltwater, a chemical reaction creates a mineral called **tobermorite** that fills tiny cracks and makes the concrete tougher. Modern scientists are still studying this reaction because we cannot easily replicate it. Roman harbor concrete has survived 2,000 years of pounding waves!",
                science: .physics,
                illustrationIcon: "tornado"
            )),

            .mathVisual(LessonMathVisual(
                type: .harborBuoyancy,
                title: "Visualize Buoyancy",
                science: .physics,
                totalSteps: 5,
                caption: "Archimedes' principle: a floating ship displaces water equal to its own weight. A grain ship weighing 1,000 tonnes pushes aside 1,000 tonnes of water — and the water pushes back, keeping the ship afloat."
            )),

            .question(LessonQuestion(
                question: "What makes Roman marine concrete special?",
                options: [
                    "It was painted with waterproof paint",
                    "It contains volcanic ash that actually hardens in seawater",
                    "It was mixed with fish oil to repel water",
                    "It was baked in kilns before being placed underwater"
                ],
                correctIndex: 1,
                explanation: "Roman concrete made with pozzolana (volcanic ash) undergoes a chemical reaction with seawater that creates tobermorite crystals. These crystals make the concrete stronger over time — the opposite of modern concrete, which weakens in saltwater!",
                science: .physics
            )),
            .reading(LessonReading(
                title: "Trajan's Hexagonal Basin",
                body: "Emperor Trajan expanded Portus around **110 AD** with a revolutionary design: a perfectly **hexagonal** (six-sided) inner basin. Why a hexagon? Because it maximized dock space while keeping the basin compact. Each of the six sides served as a wharf where ships could load and unload. The hexagonal shape also distributed wave energy evenly across the walls, preventing damage. The basin was about **358 meters** across and could hold over **100 ships** at once. Warehouses, offices, and a temple surrounded the basin.",
                science: .hydraulics,
                illustrationIcon: "hexagon"
            )),

            .curiosity(LessonCuriosity(questions: [
                CuriosityQA(
                    question: "Why a hexagon and not a circle?",
                    answer: "A circle has more perimeter per area, but it is hard to dock ships against a curved wall. Flat sides make perfect **wharves** — straight edges where ships can pull up parallel and unload easily. A hexagon gives you six long, flat docking walls while still distributing wave forces almost as evenly as a circle. It is the best of both worlds."
                ),
                CuriosityQA(
                    question: "How do we know the harbor was hexagonal?",
                    answer: "The basin's outline is still visible today! **Aerial photographs** taken in the 1920s revealed the perfect hexagonal shape preserved in the landscape near Rome's Fiumicino airport. Archaeological excavations have since confirmed the geometry and uncovered warehouses, offices, and even a **ship graveyard** with preserved Roman vessels."
                )
            ])),

            .reading(LessonReading(
                title: "The Lighthouse — Ancient Navigation",
                body: "Every harbor needed a **lighthouse** to guide ships safely to port, especially at night. The Romans modeled theirs after the famous **Pharos** of Alexandria, one of the Seven Wonders of the Ancient World. The Portus lighthouse was a tall stone tower with a fire burning at the top, amplified by polished bronze mirrors that reflected the light out to sea. Ships could see the beacon from **50 kilometers** away. The tower also served as a landmark during the day, visible above the flat coastline.",
                science: .physics,
                illustrationIcon: "light.beacon.max"
            )),
            .funFact(LessonFunFact(
                text: "The Romans used giant **treadwheel cranes** at their harbors to lift cargo. Workers walked inside a large wooden wheel (like a hamster wheel!), and the turning wheel pulled a rope attached to a hook. A single treadwheel crane could lift loads of up to **6 tonnes** — the weight of an elephant!"
            )),
            .question(LessonQuestion(
                question: "Why did Emperor Trajan choose a hexagonal shape for the inner harbor basin?",
                options: [
                    "Hexagons were considered sacred by the Romans",
                    "It maximized dock space and distributed wave energy evenly",
                    "It was the easiest shape to build with concrete",
                    "The natural coastline was already hexagonal"
                ],
                correctIndex: 1,
                explanation: "A hexagon maximizes the perimeter (dock space) relative to the area, and its six flat sides distribute incoming wave energy evenly across the walls. It was a brilliant combination of practical engineering and geometry!",
                science: .hydraulics
            )),
            .reading(LessonReading(
                title: "Treadwheel Cranes — Simple Machines at Work",
                body: "Loading and unloading cargo ships required heavy lifting. Roman engineers used **treadwheel cranes** — a clever application of **simple machines**. Workers walked inside a large wooden wheel, and their body weight turned it like a hamster wheel. The turning wheel wound a rope around an axle, lifting cargo attached to a hook. This system combined two simple machines — the **wheel and axle** and the **pulley** — to multiply human strength. A single worker could lift loads many times their own weight!",
                science: .physics,
                illustrationIcon: "gearshape.2"
            )),
            .reading(LessonReading(
                title: "Tidal Engineering",
                body: "Roman harbor engineers had to account for **tides** — the rise and fall of sea level caused by the Moon's gravitational pull. In the Mediterranean, tides are relatively small (about **30 centimeters**), but they still affected ship docking. Engineers built quays at just the right height so ships could load at both high and low tide. They also designed **sluice gates** — adjustable wooden doors that controlled water flow in and out of the inner basin, keeping the water level stable for docked ships.",
                science: .hydraulics,
                illustrationIcon: "moon.stars"
            )),

            .mathVisual(LessonMathVisual(
                type: .harborTidalForce,
                title: "Visualize Tidal Forces",
                science: .hydraulics,
                totalSteps: 5,
                caption: "Waves strike the breakwater with enormous force. A 2-meter wave hitting a 500-meter wall generates forces measured in thousands of tonnes. The breakwater must be massive enough to absorb this energy without moving."
            )),

            .reading(LessonReading(
                title: "Lead Sheeting for Waterproofing",
                body: "While Roman concrete handled the big structural elements, many harbor components needed extra waterproofing. **Lead sheeting** was hammered thin and wrapped around underwater wooden structures, pipe joints, and sluice gate frames. Lead is soft, easy to shape, and does not rust in saltwater — making it ideal for marine use. Roman plumbers (the word \"plumber\" comes from **plumbum**, Latin for lead) were skilled at folding and soldering lead sheets into watertight seals.",
                science: .engineering,
                illustrationIcon: "shield.lefthalf.filled"
            )),

            .curiosity(LessonCuriosity(questions: [
                CuriosityQA(
                    question: "How did they sink those huge concrete blocks into the sea?",
                    answer: "They built watertight **wooden caissons** — basically giant boxes — floated them into position, then filled them with concrete. The weight of the wet concrete sank the caisson to the seafloor. Once the concrete hardened underwater, the wooden box rotted away, leaving a solid concrete block. It is remarkably similar to how we build bridge foundations today."
                ),
                CuriosityQA(
                    question: "Could Roman ships survive storms on the open sea?",
                    answer: "Roman merchant ships were surprisingly seaworthy, but they avoided sailing in winter. The **mare clausum** (closed sea) season ran from November to March, when storms made sailing too dangerous. Even during the sailing season, a sudden storm could sink an entire fleet. Archaeologists have found hundreds of **shipwrecks** on the Mediterranean seafloor, many still loaded with cargo."
                )
            ])),

            .fillInBlanks(LessonFillInBlanks(
                title: "Complete the Passage",
                text: "Roman harbor concrete used {{pozzolana}} volcanic ash, which actually hardens in {{seawater}}. Long walls called {{breakwaters}} protected the harbor from waves. Emperor Trajan built a {{hexagonal}} inner basin at Portus. Giant {{treadwheel}} cranes lifted cargo weighing up to 6 tonnes.",
                distractors: ["limestone", "freshwater", "aqueducts", "circular", "lever"],
                science: .engineering
            )),
            .question(LessonQuestion(
                question: "A treadwheel crane uses which two simple machines?",
                options: [
                    "Lever and inclined plane",
                    "Wheel and axle plus pulley",
                    "Screw and wedge",
                    "Lever and pulley"
                ],
                correctIndex: 1,
                explanation: "The treadwheel crane combines a wheel and axle (the treadwheel that workers walk inside) with a pulley system (the rope and hook that lifts cargo). Together, these simple machines multiply human force to lift enormous loads!",
                science: .physics
            )),
            .reading(LessonReading(
                title: "Materials for Your Harbor",
                body: "Ready to build a Roman harbor? You will need **Roman concrete** with pozzolana for underwater construction — the only ancient concrete that hardens in seawater. **Timber beams** are essential for the crane structures, caissons, and dock platforms. **Marble slabs** decorate the lighthouse and the temple buildings around the basin. And **lead sheeting** waterproofs the sluice gates and pipe joints. Time to gather your supplies!",
                science: .materials,
                illustrationIcon: "shippingbox"
            )),
            .environmentPrompt(LessonEnvironmentPrompt(
                destination: .workshop,
                title: "Collect Harbor Materials",
                description: "Visit the workshop to gather pozzolana volcanic ash for underwater concrete, lead for waterproofing, and timber for the mighty treadwheel cranes.",
                icon: "hammer.fill"
            ))
        ]
    )

    // MARK: - Siege Workshop (#7)

    static let siegeWorkshopLesson = BuildingLesson(
        buildingName: "Siege Workshop",
        title: "Machines of War",
        sections: [
            .reading(LessonReading(
                title: "When Walls Stood in the Way",
                body: "Ancient cities were protected by thick stone walls, sometimes **10 meters tall** and **3 meters thick**. When the Roman army needed to capture a walled city, they could not just knock on the door! They needed powerful machines to break through defenses. The **siege workshop** was where military engineers designed and built these incredible devices. Roman siege engineers were some of the most skilled in the ancient world, combining knowledge of **physics**, **engineering**, and **mathematics** to create machines that could topple the mightiest walls.",
                science: .engineering,
                illustrationIcon: "hammer"
            )),

            .curiosity(LessonCuriosity(questions: [
                CuriosityQA(
                    question: "Why didn't armies just climb over the walls with ladders?",
                    answer: "They tried! It was called **escalade**, and it was terrifyingly dangerous. Defenders could push ladders away, pour boiling oil on climbers, or drop heavy stones on their heads. A ladder attack had a very high casualty rate. Siege machines let armies attack from a safe distance or from inside a protected structure — much better odds for the attackers."
                ),
                CuriosityQA(
                    question: "How long could a siege last?",
                    answer: "Some lasted years. The Roman siege of **Numantia** in Spain lasted **8 months**. Julius Caesar's siege of **Alesia** in Gaul involved building **40 kilometers of walls** around the enemy city. The longest recorded siege in antiquity was **Veii**, which took the Romans a grueling **10 years** to capture. Patience was often the deadliest weapon."
                )
            ])),

            .reading(LessonReading(
                title: "The Catapult — Stored Energy Unleashed",
                body: "The **catapult** (or onager) worked by converting **potential energy** into **kinetic energy**. Soldiers cranked back a heavy wooden arm against a tightly wound bundle of rope, storing energy like pulling back a rubber band. When released, all that stored energy converted into motion, hurling a stone projectile over **300 meters**! The science behind this is called **energy transformation** — the energy does not disappear, it just changes from one form (stored tension) to another (movement). A catapult stone could weigh up to **25 kilograms**.",
                science: .physics,
                illustrationIcon: "bolt.fill"
            )),

            .mathVisual(LessonMathVisual(
                type: .siegeProjectile,
                title: "Visualize the Trajectory",
                science: .physics,
                totalSteps: 5,
                caption: "A catapult stone follows a parabolic arc — rising as it leaves the arm, then curving back down under gravity. The launch angle and force determine how far it flies. A 45-degree angle gives the maximum range."
            )),

            .question(LessonQuestion(
                question: "What type of energy transformation occurs when a catapult fires?",
                options: [
                    "Kinetic energy → thermal energy",
                    "Chemical energy → light energy",
                    "Potential (stored) energy → kinetic (movement) energy",
                    "Sound energy → mechanical energy"
                ],
                correctIndex: 2,
                explanation: "When the catapult arm is pulled back, energy is stored as potential energy in the twisted ropes. When released, this potential energy converts into kinetic energy (movement), launching the projectile through the air!",
                science: .physics
            )),
            .reading(LessonReading(
                title: "Levers — The Simplest Machine",
                body: "Many siege machines use **levers** — one of the six **simple machines**. A lever is just a bar that pivots on a fixed point called a **fulcrum**. There are three classes of levers: In a **first-class lever** (like a seesaw), the fulcrum is between the effort and the load. In a **second-class lever** (like a wheelbarrow), the load is between the fulcrum and the effort. In a **third-class lever** (like a fishing rod), the effort is between the fulcrum and the load. Catapult arms are first-class levers — a small force on one end creates a big force on the other!",
                science: .physics,
                illustrationIcon: "arrow.left.and.right"
            )),

            .mathVisual(LessonMathVisual(
                type: .siegeLeverArm,
                title: "Visualize the Lever",
                science: .physics,
                totalSteps: 5,
                caption: "Effort times effort arm equals load times load arm. A 3:1 mechanical advantage means a soldier pushing with 100 kg of force can launch a 300 kg stone — the lever multiplies strength."
            )),

            .question(LessonQuestion(
                question: "If a lever arm is 4 meters long with the fulcrum at 1 meter from the load end, what is the mechanical advantage (effort arm ÷ load arm)?",
                options: ["1", "2", "3", "4"],
                correctIndex: 2,
                explanation: "The effort arm is 3 meters (4 - 1) and the load arm is 1 meter. Mechanical advantage = effort arm ÷ load arm = 3 ÷ 1 = 3. This means you can lift 3 times as much weight as the force you apply!",
                science: .mathematics,
                hints: [
                    "The fulcrum divides the lever into two parts: the effort arm (where you push) and the load arm (where the weight is).",
                    "If the total arm is 4 m and the fulcrum is 1 m from the load, the effort arm is 4 - 1 = 3 m and the load arm is 1 m.",
                    "Mechanical advantage = effort arm ÷ load arm = 3 ÷ 1 = 3."
                ]
            )),
            .reading(LessonReading(
                title: "The Ballista — Ancient Artillery",
                body: "The **ballista** was like a giant crossbow that fired heavy bolts or stone balls with terrifying accuracy. Its power came from **torsion** — twisted bundles of animal sinew (tendons) or horsehair that stored enormous amounts of energy. Two arms were inserted into these twisted bundles, and when the string was pulled back and released, the arms snapped forward with tremendous force. A skilled ballista crew could hit a target from **400 meters** away. Roman legions carried them on carts, making them the world's first mobile artillery.",
                science: .engineering,
                illustrationIcon: "scope"
            )),
            .funFact(LessonFunFact(
                text: "The famous Greek scientist **Archimedes** defended the city of Syracuse against a Roman siege in **213 BC** using incredible machines — including giant cranes that could grab Roman ships and flip them over, and possibly even focused mirrors to set ships on fire! The Romans were so impressed that when they finally captured the city, the general ordered Archimedes to be kept alive (sadly, a soldier killed him by mistake)."
            )),
            .reading(LessonReading(
                title: "The Siege Tower",
                body: "When walls were too strong to break, the Romans went OVER them! A **siege tower** was a massive wooden structure on wheels, as tall as the city walls (sometimes **20 meters** or more). Soldiers hid inside the tower as it was rolled up to the wall. At the top, a **drawbridge** dropped onto the wall, and soldiers charged across. The front of the tower was covered in wet animal hides to prevent fire arrows from setting it ablaze. Building one required hundreds of timber beams and days of carpentry work.",
                science: .engineering,
                illustrationIcon: "building"
            )),

            .curiosity(LessonCuriosity(questions: [
                CuriosityQA(
                    question: "How did they move a 20-meter wooden tower?",
                    answer: "Very slowly and with great difficulty. The tower sat on **massive wooden wheels** or rollers, and dozens or even hundreds of soldiers pushed it from behind. The ground in front had to be leveled first — any ditch or bump could tip the whole structure over. Defenders would dig trenches specifically to stop siege towers from reaching the walls."
                ),
                CuriosityQA(
                    question: "What stopped defenders from just burning the tower?",
                    answer: "Fire was the biggest threat. Romans covered the front and sides with **fresh animal hides** soaked in water or vinegar, which resisted burning. Some towers had metal plating. They also positioned archers and ballistae to suppress the defenders while the tower advanced. It was a race — could the tower reach the wall before the defenders set it ablaze?"
                )
            ])),

            .reading(LessonReading(
                title: "The Battering Ram",
                body: "The **battering ram** was the simplest but most effective siege weapon. It was a massive tree trunk, sometimes tipped with an iron head shaped like a ram's horns (that is where the name comes from!). The trunk hung from ropes inside a wheeled wooden shed called a **testudo** (tortoise), which protected the operators from arrows and boiling oil. Soldiers swung the ram back and forth in rhythm, and the repeated impacts could shatter gates and crack stone walls. It is pure **kinetic energy** applied again and again to the same spot.",
                science: .physics,
                illustrationIcon: "rectangle.compress.vertical"
            )),
            .question(LessonQuestion(
                question: "Why was the battering ram housed inside a wheeled shed (testudo)?",
                options: [
                    "To keep the ram dry in rainy weather",
                    "To protect the operators from arrows, rocks, and boiling liquids",
                    "To make the ram swing faster",
                    "To hide the ram so the enemy did not know it was coming"
                ],
                correctIndex: 1,
                explanation: "Defenders on the walls would drop arrows, rocks, and even boiling oil on attackers below. The testudo (tortoise shed) had a strong wooden roof — sometimes covered in wet hides — that shielded the ram operators so they could keep swinging!",
                science: .engineering
            )),
            .reading(LessonReading(
                title: "The Trebuchet — Counterweight Power",
                body: "The **trebuchet** was the ultimate siege weapon, perfected in the medieval period but based on Roman principles. Instead of twisted ropes, it used a heavy **counterweight** on one end of a long arm. When the counterweight dropped, the other end whipped upward, hurling a projectile in a high arc. The heavier the counterweight, the farther the throw. A large trebuchet could launch stones weighing **100 kilograms** over **300 meters**! It is a perfect demonstration of **gravitational potential energy** converting to kinetic energy.",
                science: .physics,
                illustrationIcon: "arrow.up.forward"
            )),

            .curiosity(LessonCuriosity(questions: [
                CuriosityQA(
                    question: "Why is a trebuchet more powerful than a catapult?",
                    answer: "A catapult stores energy in twisted rope, which has limits. A trebuchet uses **gravity** — and you can always add more weight to the counterweight. A 10-tonne counterweight stores far more energy than any rope bundle could. Trebuchets could also be reloaded faster because you just needed to winch the counterweight back up, rather than re-twist rope bundles."
                ),
                CuriosityQA(
                    question: "Are siege weapons still used in any form today?",
                    answer: "The physics absolutely is! Modern **artillery** uses the same principles — converting stored energy into projectile motion. Even spacecraft launches follow the same trajectory math. And believe it or not, **pumpkin-chunking competitions** use trebuchets and catapults to hurl pumpkins hundreds of meters, keeping the ancient engineering alive for fun."
                )
            ])),

            .funFact(LessonFunFact(
                text: "During sieges, the Romans sometimes launched diseased animal carcasses over city walls to spread illness — an early and terrible form of **biological warfare**. They also launched **beehive pots** to cause chaos inside the city. Siege warfare was brutal but incredibly inventive."
            )),
            .fillInBlanks(LessonFillInBlanks(
                title: "Complete the Passage",
                text: "A catapult converts {{potential}} energy into {{kinetic}} energy to launch projectiles. The ballista uses twisted {{sinew}} bundles for power, a mechanism called {{torsion}}. A lever's pivot point is called a {{fulcrum}}. The battering ram uses repeated impacts to break through walls and gates.",
                distractors: ["chemical", "static", "rope", "friction", "axle"],
                science: .physics
            )),
            .question(LessonQuestion(
                question: "A trebuchet has a counterweight of 2,000 kg and a projectile of 50 kg. What is the mass ratio of counterweight to projectile?",
                options: ["10:1", "20:1", "40:1", "50:1"],
                correctIndex: 2,
                explanation: "Divide the counterweight mass by the projectile mass: 2,000 ÷ 50 = 40. So the mass ratio is 40:1. The heavier the counterweight relative to the projectile, the farther and faster the projectile flies!",
                science: .mathematics,
                hints: [
                    "A ratio compares two numbers. Divide the counterweight mass by the projectile mass.",
                    "2,000 ÷ 50 = ? Think of it as: how many times does 50 go into 2,000?",
                    "2,000 ÷ 50 = 40. The ratio is 40:1."
                ]
            )),
            .reading(LessonReading(
                title: "Rope and Sinew — The Power Source",
                body: "The most important material in a siege workshop was not wood or iron — it was **rope**. Twisted ropes of animal sinew, horsehair, or plant fiber stored the enormous tension energy that powered catapults and ballistas. Roman engineers discovered that **sinew** (dried animal tendons) could store more energy per kilogram than any other material available. They even recycled old bowstrings and collected women's hair during desperate sieges. The quality of the torsion bundles determined whether a machine could hit its target.",
                science: .engineering,
                illustrationIcon: "lasso"
            )),
            .reading(LessonReading(
                title: "Materials for Your Siege Workshop",
                body: "Time to equip your siege workshop! You will need **timber beams** for the arms, frames, and wheels of your siege machines. **Terracotta tiles** reinforce the roofing of the workshop and the testudo sheds. **Bronze fittings** create the pins, hinges, and trigger mechanisms. And **carved wood** forms the precision components like ballista rails and trebuchet slings. Let us gather everything!",
                science: .materials,
                illustrationIcon: "shippingbox"
            )),
            .environmentPrompt(LessonEnvironmentPrompt(
                destination: .workshop,
                title: "Build Siege Components",
                description: "Head to the workshop to gather timber for the machine frames, bronze for the trigger mechanisms, and rope fibers for torsion bundles.",
                icon: "hammer.fill"
            )),
            .environmentPrompt(LessonEnvironmentPrompt(
                destination: .forest,
                title: "Harvest Tall Timber",
                description: "Siege towers need to be as tall as city walls — up to 20 meters! Visit the forest to find the tallest, straightest trees for your siege tower frames.",
                icon: "leaf.fill"
            ))
        ]
    )

    // MARK: - Insula (#8)

    static let insulaLesson = BuildingLesson(
        buildingName: "Insula",
        title: "Apartment Living in Rome",
        sections: [
            .reading(LessonReading(
                title: "A City of One Million",
                body: "Ancient Rome was the first city in history to reach a population of about **1 million people** — and fitting them all in was a huge challenge! Most Romans could not afford private houses (domus), so they lived in tall apartment buildings called **insulae** (say: IN-su-lye, meaning \"islands\" because each block was surrounded by streets). An insula could be **6 to 7 stories tall**, packed with dozens of families. Rome had an estimated **46,000 insulae** compared to just **1,800 private houses**. Ancient Rome was a city of apartment dwellers!",
                science: .architecture,
                illustrationIcon: "building.2"
            )),

            .curiosity(LessonCuriosity(questions: [
                CuriosityQA(
                    question: "Were Roman insulae the world's first apartment buildings?",
                    answer: "Pretty much! While some earlier civilizations stacked dwellings (like the mud-brick buildings in ancient Egypt), Roman insulae were the first purpose-built, multi-story **rental apartment buildings** at scale. The concept disappeared after Rome fell and did not return until the **18th and 19th centuries** in cities like Paris and New York."
                ),
                CuriosityQA(
                    question: "How much did it cost to rent an apartment?",
                    answer: "Rent varied wildly by floor. A ground-floor apartment might cost **2,000 sesterces per year** — about a laborer's entire annual wage. A cramped top-floor room could be as cheap as **40 sesterces**. Landlords were infamous for charging high rents for terrible conditions. The poet **Martial** complained bitterly about his tiny, overpriced sixth-floor room."
                )
            ])),

            .reading(LessonReading(
                title: "Ground Floor Shops — The Tabernae",
                body: "The ground floor of every insula was lined with small shops called **tabernae** (say: ta-BER-nye). These were the ancient equivalent of street-level retail — bakeries, wine shops, cobblers, and food stalls. Each taberna opened directly onto the street through a wide doorway with a wooden counter. Some shopkeepers lived in a small loft above their shop called a **pergula**. The tabernae made the ground floor the most valuable and noisy part of the building — the higher you lived, the quieter (but less convenient) it was.",
                science: .architecture,
                illustrationIcon: "storefront"
            )),
            .question(LessonQuestion(
                question: "What were tabernae in a Roman insula?",
                options: [
                    "Storage rooms for grain",
                    "Ground-floor shops that opened onto the street",
                    "Shared bathrooms for residents",
                    "Balconies where residents gathered"
                ],
                correctIndex: 1,
                explanation: "Tabernae were ground-floor shops and businesses — bakeries, wine shops, food stalls — that opened directly onto the street. They made the insula a mixed-use building, combining housing and commerce just like many modern city buildings!",
                science: .architecture
            )),
            .reading(LessonReading(
                title: "Upper Floor Living — The Cenaculum",
                body: "Above the shops, each floor was divided into apartments called **cenacula** (say: sen-AH-ku-la). The best apartments were on the **first floor** (one flight up) — they were larger, brighter, and sometimes even had running water from the aqueduct. As you climbed higher, apartments got smaller, darker, and cheaper. The top floors were cramped, single-room apartments with no water or toilet. Residents on upper floors had to carry water up in buckets and use chamber pots — life at the top was not glamorous!",
                science: .architecture,
                illustrationIcon: "stairs"
            )),
            .reading(LessonReading(
                title: "Opus Latericium — Brick-Faced Concrete",
                body: "Insulae were built using a technique called **opus latericium** (say: OH-pus la-ter-ISH-ee-um) — walls of Roman concrete faced with flat bricks on both sides. The bricks gave the walls a neat, attractive appearance while the concrete core provided strength. This was faster and cheaper than cutting stone blocks, which is why insulae could be built quickly. However, to save money, many landlords (called **domini**) used thinner walls and cheaper materials on the upper floors, making them dangerously weak.",
                science: .materials,
                illustrationIcon: "rectangle.split.3x1.fill"
            )),

            .curiosity(LessonCuriosity(questions: [
                CuriosityQA(
                    question: "Why did landlords cut corners on building quality?",
                    answer: "Simple economics. Rome had a massive **housing shortage**, so landlords could rent even terrible apartments at high prices. Building cheap and fast maximized profit. There was no building inspection system — the government set height limits but rarely checked construction quality. It is the same tension between profit and safety that modern cities still struggle with."
                ),
                CuriosityQA(
                    question: "How thick were insula walls supposed to be?",
                    answer: "Vitruvius recommended walls of at least **45 centimeters (1.5 Roman feet)** for load-bearing walls. Good insulae had ground-floor walls up to **60 centimeters** thick. But greedy landlords sometimes built upper walls as thin as **20 centimeters** — barely wider than a modern cinder block. No wonder they collapsed."
                )
            ])),

            .funFact(LessonFunFact(
                text: "The poet **Juvenal** complained that Rome's insulae were so poorly built that they collapsed regularly. He wrote: \"We live in a city propped up by thin sticks!\" Even the famous writer **Cicero** owned insulae as investments and grumbled about spending money on repairs."
            )),
            .reading(LessonReading(
                title: "Fire Risk — Rome's Greatest Danger",
                body: "The upper floors of insulae were built with **timber** frames and floors — cheap but incredibly dangerous. Cooking was done over open charcoal braziers (no chimneys!), and oil lamps provided light. With wooden floors, wooden furniture, and open flames everywhere, fires broke out constantly. The **Great Fire of Rome** in **64 AD** burned for nine days and destroyed huge sections of the city, including thousands of insulae. After the fire, Emperor Nero created new building codes requiring wider streets and more stone construction.",
                science: .materials,
                illustrationIcon: "flame.fill"
            )),

            .mathVisual(LessonMathVisual(
                type: .insulaFloorLoading,
                title: "Visualize Floor Loading",
                science: .engineering,
                totalSteps: 5,
                caption: "Each floor carries its own weight plus the weight of every floor above it. The ground floor supports the entire building — that is why it needs the thickest walls and strongest materials."
            )),

            .question(LessonQuestion(
                question: "Why were fires so common in Roman insulae?",
                options: [
                    "The Romans used oil-based paint that was flammable",
                    "Timber upper floors combined with open-flame cooking and oil lamps",
                    "The Romans had no fire department",
                    "Lightning strikes were frequent in Rome"
                ],
                correctIndex: 1,
                explanation: "The combination of wooden upper floors, open charcoal braziers for cooking, and oil lamps for lighting made fires a constant danger. There were no chimneys or fire-resistant materials on the cheap upper stories!",
                science: .materials
            )),
            .reading(LessonReading(
                title: "Height Limits — Ancient Building Codes",
                body: "Insulae kept getting taller and more dangerous until the government stepped in. Emperor Augustus set a **height limit of 70 Roman feet** (about **20 meters**), roughly 6 to 7 stories. Emperor Trajan later lowered this to **60 Roman feet** (about **18 meters**). These were some of the world's first **building codes** — laws about how buildings must be constructed for safety. Despite the rules, many landlords cheated by building extra floors or using substandard materials, hoping no one would notice until it was too late.",
                science: .architecture,
                illustrationIcon: "ruler"
            )),

            .mathVisual(LessonMathVisual(
                type: .insulaHeightRatio,
                title: "Visualize the Height Ratio",
                science: .mathematics,
                totalSteps: 5,
                caption: "A building's height-to-base ratio determines its stability. A 20-meter tall insula on a 10-meter wide base has a 2:1 ratio. Go above 3:1 and the building becomes dangerously top-heavy."
            )),

            .question(LessonQuestion(
                question: "If Augustus's height limit was 70 Roman feet (about 20 meters) and each story is approximately 3 meters tall, how many stories could an insula have?",
                options: ["4 stories", "5 stories", "6 stories", "8 stories"],
                correctIndex: 2,
                explanation: "Divide the maximum height by the height per story: 20 ÷ 3 ≈ 6.67. Since you cannot build a partial story, the maximum was about 6 full stories (with shorter ceilings on upper floors, some builders squeezed in 7).",
                science: .mathematics,
                hints: [
                    "Divide the total allowed height by the height of one story.",
                    "20 meters ÷ 3 meters per story = approximately 6.67.",
                    "You cannot build two-thirds of a story, so the answer rounds down to 6 stories."
                ]
            )),
            .reading(LessonReading(
                title: "Population Density — Ancient Crowding",
                body: "Rome's insulae created **population density** levels that would not be seen again until 19th-century New York City. Historians estimate that some neighborhoods packed over **50,000 people per square kilometer**. For comparison, modern Manhattan has about 27,000 per square kilometer. A single insula block might house **300 to 400 people** in apartments stacked on top of each other. The streets between insulae were narrow — sometimes only **3 meters** wide — making neighborhoods feel like canyons of brick and timber.",
                science: .architecture,
                illustrationIcon: "person.3.fill"
            )),

            .curiosity(LessonCuriosity(questions: [
                CuriosityQA(
                    question: "Did Romans have any kind of sanitation system?",
                    answer: "Rome had impressive **sewers** — the famous **Cloaca Maxima** was large enough to drive a wagon through. But most insulae were not connected to it! Upper-floor residents used **chamber pots** and were supposed to carry them downstairs to public cesspits. In practice, many people just dumped waste out the window. Roman law let you sue someone who hit you with thrown waste, which tells you how often it happened."
                ),
                CuriosityQA(
                    question: "How does ancient Roman density compare to today's most crowded cities?",
                    answer: "Rome's densest neighborhoods (about **50,000 per km squared**) are comparable to today's most crowded places like **Dhaka, Bangladesh** or parts of **Mumbai, India**. Modern New York City's Manhattan averages about 27,000 per km squared. The difference is that modern buildings have elevators, plumbing, fire escapes, and building codes — Romans had none of that."
                )
            ])),

            .funFact(LessonFunFact(
                text: "Romans dealt with so much noise from the crowded insulae that Emperor Julius Caesar **banned wheeled traffic** during daytime hours. This meant that all deliveries by cart had to happen at night — so residents were kept awake by the rumble of wheels on stone streets instead!"
            )),
            .reading(LessonReading(
                title: "Terracotta Tiles and Roofing",
                body: "The roofs of insulae were covered with **terracotta tiles** — baked clay tiles that were fireproof and waterproof. Terracotta (meaning \"baked earth\" in Italian) is made by shaping wet clay and firing it in a kiln at high temperatures. The tiles overlapped in rows, channeling rainwater down to the street. Terracotta was also used for the flat bricks in opus latericium walls and for roof decorations. It was one of the most versatile and affordable building materials in ancient Rome.",
                science: .materials,
                illustrationIcon: "rectangle.on.rectangle.angled"
            )),
            .reading(LessonReading(
                title: "Glass Windows — A Luxury",
                body: "Only the wealthiest insula apartments had **glass windows**. Most residents covered their window openings with wooden shutters, animal skins, or thin sheets of **selenite** (a translucent mineral). Glass panes let in light without cold drafts, but they were expensive and fragile. Ground-floor tabernae sometimes had glass display panels to show their goods. The highest-floor apartments often had the smallest windows — just narrow slits that let in minimal light and air.",
                science: .materials,
                illustrationIcon: "window.vertical.open"
            )),
            .fillInBlanks(LessonFillInBlanks(
                title: "Complete the Passage",
                text: "Roman apartment buildings called {{insulae}} could be up to 7 stories tall. The ground floor had shops called {{tabernae}} and upper apartments were called {{cenacula}}. Walls were made of concrete faced with {{bricks}} using a technique called opus latericium. Emperor Augustus set a height limit of about {{20}} meters to improve safety.",
                distractors: ["domus", "forums", "atria", "marble", "50"],
                science: .architecture
            )),
            .reading(LessonReading(
                title: "Materials for Your Insula",
                body: "To construct your own Roman apartment block, you will need several key materials. **Lime mortar** binds the bricks and concrete together for strong walls. **Terracotta tiles** cover the roof and face the walls in opus latericium. **Timber beams** provide the floor joists and upper-story framing (just keep them away from open flames!). And **glass panes** give the first-floor luxury apartments their coveted windows. Time to start building!",
                science: .materials,
                illustrationIcon: "shippingbox"
            )),
            .environmentPrompt(LessonEnvironmentPrompt(
                destination: .workshop,
                title: "Gather Insula Materials",
                description: "Head to the workshop to fire terracotta bricks and tiles, mix lime mortar, and collect glass for the apartment windows.",
                icon: "hammer.fill"
            ))
        ]
    )
}
