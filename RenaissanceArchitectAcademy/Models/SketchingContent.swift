import Foundation

/// Static sketching challenge data per building
/// Same pattern as ChallengeContent in Challenge.swift
enum SketchingContent {

    /// Look up the sketching challenge for a building by name
    static func sketchingChallenge(for buildingName: String) -> SketchingChallenge? {
        switch buildingName {
        case "Pantheon":
            return pantheonSketching
        case "Colosseum":
            return colosseumSketching
        case "Aqueduct":
            return aqueductSketching
        case "Duomo", "Il Duomo":
            return duomoSketching
        default:
            return nil
        }
    }

    // MARK: - Pantheon

    static let pantheonSketching = SketchingChallenge(
        buildingName: "Pantheon",
        introduction: "The Pantheon is one of the most perfectly preserved Roman buildings. Its rotunda is a perfect circle — the dome's diameter equals the building's interior height. Emperor Hadrian's architects used the simplest ratio in nature: 1:1.\n\nAs the architect, you will draw the floor plan (pianta) of this masterpiece.",
        phases: [
            SketchingPhase(
                phaseType: .pianta,
                title: "Pianta: Floor Plan",
                introduction: "The Pantheon's rotunda is a perfect circle — the dome sits on a cylindrical drum. The entry portico is a rectangle with columns in front.\n\nUse the Circle tool to draw the rotunda, then the Wall tool for the rectangular portico. Place columns at the portico entrance.",
                sciencesFocused: [.geometry, .mathematics, .architecture],
                phaseData: .pianta(PiantaPhaseData(
                    gridSize: 12,
                    targetRooms: [
                        RoomDefinition(
                            label: "Rotunda",
                            origin: GridCoord(row: 5, col: 6),  // center of circle
                            width: 6,                           // diameter = 6 cells
                            height: 6,
                            requiredRatio: ProportionalRatio(numerator: 1, denominator: 1),
                            shape: .circle
                        ),
                        RoomDefinition(
                            label: "Portico",
                            origin: GridCoord(row: 8, col: 4),
                            width: 4,
                            height: 2,
                            requiredRatio: ProportionalRatio(numerator: 2, denominator: 1),
                            shape: .rectangle
                        )
                    ],
                    targetColumns: [
                        // Front row of portico columns
                        GridCoord(row: 10, col: 4),
                        GridCoord(row: 10, col: 5),
                        GridCoord(row: 10, col: 7),
                        GridCoord(row: 10, col: 8)
                    ],
                    symmetryAxis: .vertical,
                    proportionalRatios: [
                        ProportionalRatio(numerator: 1, denominator: 1),  // Rotunda (circle)
                        ProportionalRatio(numerator: 2, denominator: 1)   // Portico
                    ],
                    hint: "Use the Circle tool to draw the rotunda — a perfect circle in the center of the grid. The dome's diameter equals its height: a 1:1 ratio.",
                    educationalText: "The Pantheon's dome spans 43.3 meters — the same as its height from floor to oculus. This 1:1 ratio creates a perfect sphere that could fit inside the building. Roman architects used this harmony of proportion to represent the cosmos.",
                    historicalContext: "Emperor Hadrian rebuilt the Pantheon around 126 AD. The original was built by Marcus Agrippa in 27 BC but burned down twice. The inscription on the portico still reads 'M·AGRIPPA·L·F·COS·TERTIVM·FECIT' — crediting Agrippa, though Hadrian designed the current building."
                ))
            )
        ],
        educationalSummary: "You've designed the floor plan of one of history's most influential buildings. The Pantheon's proportional system — a perfect sphere inscribed in a cylinder — influenced architects for 2000 years, from Brunelleschi's Duomo to the US Capitol."
    )

    // MARK: - Colosseum

    static let colosseumSketching = SketchingChallenge(
        buildingName: "Colosseum",
        introduction: "The Flavian Amphitheater — the Colosseum — is an engineering marvel. Its elliptical shape was calculated using geometry to give 50,000 spectators optimal sightlines. The architects used a 5:4 ratio for the arena's axes.\n\nDesign the floor plan of this iconic arena.",
        phases: [
            SketchingPhase(
                phaseType: .pianta,
                title: "Pianta: Floor Plan",
                introduction: "The Colosseum's arena is an ellipse, but on our grid we approximate it as a rectangle. The outer wall forms a larger rectangle around it. The arena's length-to-width ratio is approximately 5:4.\n\nDraw the outer walls and the inner arena. Place columns at the four main entrances.",
                sciencesFocused: [.geometry, .architecture, .engineering],
                phaseData: .pianta(PiantaPhaseData(
                    gridSize: 12,
                    targetRooms: [
                        RoomDefinition(
                            label: "Outer Wall",
                            origin: GridCoord(row: 1, col: 1),
                            width: 10,
                            height: 10,
                            requiredRatio: ProportionalRatio(numerator: 1, denominator: 1)
                        ),
                        RoomDefinition(
                            label: "Arena",
                            origin: GridCoord(row: 3, col: 3),
                            width: 6,
                            height: 5,
                            requiredRatio: ProportionalRatio(numerator: 6, denominator: 5)
                        )
                    ],
                    targetColumns: [
                        // Four main entrance columns
                        GridCoord(row: 1, col: 6),   // North
                        GridCoord(row: 11, col: 6),   // South
                        GridCoord(row: 6, col: 1),    // West
                        GridCoord(row: 6, col: 11)    // East
                    ],
                    symmetryAxis: .both,
                    proportionalRatios: [
                        ProportionalRatio(numerator: 1, denominator: 1),
                        ProportionalRatio(numerator: 6, denominator: 5)
                    ],
                    hint: "Start with the large outer wall — a square that fills most of the grid. Then draw a smaller rectangle inside for the arena floor.",
                    educationalText: "The Colosseum's 80 entrance arches (vomitoria) were precisely calculated so that all 50,000 spectators could exit in just 15 minutes. Each arch was numbered — spectators received tokens with their arch number, like modern stadium tickets.",
                    historicalContext: "Construction began under Emperor Vespasian in 72 AD and was completed by his son Titus in 80 AD. The inauguration featured 100 days of games. The Colosseum's real name is the 'Amphitheatrum Flavium' — it was called 'Colosseum' because of a colossal statue of Nero that stood nearby."
                ))
            )
        ],
        educationalSummary: "The Colosseum's design influenced every stadium built since. Its system of numbered entrances, tiered seating with optimal sightlines, and underground machinery (the hypogeum) represent the peak of Roman engineering."
    )

    // MARK: - Aqueduct

    static let aqueductSketching = SketchingChallenge(
        buildingName: "Aqueduct",
        introduction: "Roman aqueducts carried water across valleys using precisely calculated gradients. The Pont du Gard drops just 2.5 cm per kilometer — a slope so gentle it's nearly invisible. The architects used repeating arched bays with careful proportional ratios.\n\nDesign the floor plan of an aqueduct section.",
        phases: [
            SketchingPhase(
                phaseType: .pianta,
                title: "Pianta: Floor Plan",
                introduction: "An aqueduct's plan view shows the water channel (specus) running along the top, supported by thick piers. The channel is narrow and long — a 4:1 ratio.\n\nDraw the water channel and place columns where the supporting piers stand.",
                sciencesFocused: [.engineering, .hydraulics, .mathematics],
                phaseData: .pianta(PiantaPhaseData(
                    gridSize: 12,
                    targetRooms: [
                        RoomDefinition(
                            label: "Water Channel",
                            origin: GridCoord(row: 5, col: 1),
                            width: 10,
                            height: 2,
                            requiredRatio: ProportionalRatio(numerator: 5, denominator: 1)
                        )
                    ],
                    targetColumns: [
                        // Pier positions along the channel
                        GridCoord(row: 7, col: 2),
                        GridCoord(row: 7, col: 5),
                        GridCoord(row: 7, col: 8),
                        GridCoord(row: 7, col: 11)
                    ],
                    symmetryAxis: nil,
                    proportionalRatios: [
                        ProportionalRatio(numerator: 5, denominator: 1)
                    ],
                    hint: "The water channel runs horizontally across the grid. It should be long and narrow — think of a river flowing through your plan.",
                    educationalText: "Roman engineers achieved a gradient of just 1:4000 (25cm drop per kilometer). They used a tool called a chorobates — a 6-meter wooden frame with a water level — to measure this tiny slope across miles of terrain.",
                    historicalContext: "Rome had 11 major aqueducts supplying over 1 million cubic meters of water daily — more per capita than many modern cities. The Aqua Claudia ran 69 km, mostly underground, with 15 km of visible arched bridges."
                ))
            )
        ],
        educationalSummary: "Roman aqueducts demonstrate that great engineering is often invisible. The gentle gradients, waterproof mortar, and settling tanks show how Roman engineers combined hydraulics, mathematics, and materials science to solve practical problems."
    )

    // MARK: - Duomo (Florence Cathedral)

    static let duomoSketching = SketchingChallenge(
        buildingName: "Duomo",
        introduction: "Brunelleschi's dome for Florence Cathedral is the largest masonry dome ever built — 42 meters across, rising 114 meters from the ground. He won the commission in a 1418 competition against his rival Ghiberti.\n\nDesign the floor plan of this Renaissance masterpiece.",
        phases: [
            SketchingPhase(
                phaseType: .pianta,
                title: "Pianta: Floor Plan",
                introduction: "The Duomo has a cruciform (cross-shaped) plan typical of Gothic cathedrals, but Brunelleschi's octagonal dome sits at the crossing. The nave is long and narrow (4:1), with the crossing forming a square.\n\nDraw the nave, transept, and crossing. The crossing must be a perfect square (1:1).",
                sciencesFocused: [.geometry, .architecture, .physics],
                phaseData: .pianta(PiantaPhaseData(
                    gridSize: 12,
                    targetRooms: [
                        RoomDefinition(
                            label: "Nave",
                            origin: GridCoord(row: 4, col: 1),
                            width: 4,
                            height: 4,
                            requiredRatio: ProportionalRatio(numerator: 1, denominator: 1)
                        ),
                        RoomDefinition(
                            label: "Crossing",
                            origin: GridCoord(row: 4, col: 5),
                            width: 3,
                            height: 3,
                            requiredRatio: ProportionalRatio(numerator: 1, denominator: 1)
                        ),
                        RoomDefinition(
                            label: "Apse",
                            origin: GridCoord(row: 4, col: 8),
                            width: 3,
                            height: 3,
                            requiredRatio: ProportionalRatio(numerator: 1, denominator: 1)
                        )
                    ],
                    targetColumns: [
                        // Columns at crossing corners
                        GridCoord(row: 4, col: 5),
                        GridCoord(row: 4, col: 7),
                        GridCoord(row: 7, col: 5),
                        GridCoord(row: 7, col: 7)
                    ],
                    symmetryAxis: .horizontal,
                    proportionalRatios: [
                        ProportionalRatio(numerator: 1, denominator: 1)
                    ],
                    hint: "Start with the crossing — the square where the dome sits. Then extend the nave to the left and the apse to the right.",
                    educationalText: "Brunelleschi built the dome without scaffolding — an impossible feat that required inventing new construction techniques. He used a herringbone brick pattern that made each ring of bricks self-supporting, and a double-shell design that reduced the dome's weight by 25%.",
                    historicalContext: "The Florence Cathedral was begun in 1296 but the dome opening sat uncovered for over 100 years — no one knew how to span it. In 1418 the city held a competition with a prize of 200 gold florins. Brunelleschi, a goldsmith by training, won with his daring double-shell design."
                ))
            )
        ],
        educationalSummary: "Brunelleschi's dome proved that innovation comes from understanding both ancient wisdom and new thinking. By studying the Pantheon's concrete dome and inventing new brick techniques, he created the defining symbol of the Renaissance."
    )
}
