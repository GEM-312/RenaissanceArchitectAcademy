import SpriteKit
import SwiftUI

/// SpriteKit scene for the Italian Forest — biology & environment education
/// Player walks forest trails between 5 Renaissance timber trees, each with unique silhouette
class ForestScene: SKScene {

    // MARK: - Properties

    private var cameraNode: SKCameraNode!
    private var playerNode: PlayerNode!

    /// Player gender — set from SwiftUI before scene appears
    var apprenticeIsBoy: Bool = true

    // Camera control (pan + zoom like workshop/city)
    private var lastPanLocation: CGPoint?
    private var initialCameraScale: CGFloat = 1.0

    // Map size — standard 3500×2500 coordinate space
    private let mapSize = CGSize(width: 3500, height: 2500)

    #if DEBUG
    private lazy var editorMode = SceneEditorMode(scene: self)
    #endif

    /// Points of interest — Renaissance timber trees the player can tap to learn about
    struct ForestPOI {
        let name: String
        let italianName: String
        let position: CGPoint
        let woodType: String           // "Hardwood" / "Softwood"
        let leafType: String           // "Deciduous" / "Evergreen"
        let maxHeight: String          // e.g. "25-30 meters"
        let usedFor: String            // Architecture uses
        let furnitureUse: String       // Furniture/decorative uses
        let modernUse: String          // Where this wood is used today
        let buildings: String
        let description: String
        let biologyFact: String        // Growth, ecology, or biology detail
        let timberYield: Int           // How much timber per collection (1-3)
    }

    private let pointsOfInterest: [ForestPOI] = [
        ForestPOI(name: "Oak", italianName: "Quercia",
                  position: CGPoint(x: 500, y: 1650),
                  woodType: "Hardwood", leafType: "Deciduous", maxHeight: "25-30 m",
                  usedFor: "Roof trusses, load-bearing beams, and heavy doors. Oak spans cathedral naves and supports the massive roof structures of the Colosseum.",
                  furnitureUse: "Dining tables, church pews, carved altarpieces. Oak's tight grain holds intricate carvings for generations.",
                  modernUse: "Hardwood flooring, wine barrels, shipbuilding, and whiskey casks. Still the gold standard for structural timber.",
                  buildings: "ALL buildings (structural)",
                  description: "The strongest Italian hardwood — oak heartwood resists rot for centuries. A single oak beam can support tons of stone.",
                  biologyFact: "Oak trees produce acorns only after 20-50 years of growth. A mature oak can transpire 150 liters of water per day through its leaves, cooling the surrounding forest.",
                  timberYield: 3),
        ForestPOI(name: "Chestnut", italianName: "Castagno",
                  position: CGPoint(x: 2900, y: 1700),
                  woodType: "Hardwood", leafType: "Deciduous", maxHeight: "20-35 m",
                  usedFor: "Window frames, exterior cladding, and water-resistant joinery. Rich in natural tannins that repel insects and moisture.",
                  furnitureUse: "Storage chests, bed frames, and rustic tables. Called 'the bread tree' — its flour fed mountain villages.",
                  modernUse: "Fence posts, outdoor furniture, and garden structures. Tannin content makes it naturally rot-resistant without treatment.",
                  buildings: "Palazzo, Villa",
                  description: "Chestnut's natural tannins make it the most weather-resistant Italian wood — perfect for anything exposed to rain.",
                  biologyFact: "Chestnut trees contain 8-13% tannin in their bark — a natural chemical defense. Medieval builders discovered wood soaked in tannin resists both rot and insects without any treatment.",
                  timberYield: 2),
        ForestPOI(name: "Cypress", italianName: "Cipresso",
                  position: CGPoint(x: 1750, y: 1900),
                  woodType: "Softwood", leafType: "Evergreen", maxHeight: "25-40 m",
                  usedFor: "Church doors, chapel interiors, and ceiling panels. Its aromatic oils repel moths and preserve sacred spaces.",
                  furnitureUse: "Carved chests, wardrobes, and hope chests. The scent protects stored linens and vestments from insects.",
                  modernUse: "Essential oils, garden trellises, and decorative structures. The iconic sentinel tree of Tuscan landscapes.",
                  buildings: "Chapel, Villa",
                  description: "The tall sentinel of Tuscany. Cypress is aromatic and moth-resistant — ancient Romans believed it sacred to the gods.",
                  biologyFact: "Cypress wood contains natural fungicides and insecticides in its resin. The doors of St. Peter's Basilica in Rome, made of cypress, lasted over 1,100 years before replacement.",
                  timberYield: 2),
        ForestPOI(name: "Walnut", italianName: "Noce",
                  position: CGPoint(x: 600, y: 750),
                  woodType: "Hardwood", leafType: "Deciduous", maxHeight: "15-25 m",
                  usedFor: "Inlaid palazzo ceilings, ornamental door frames, and decorative wall panels in the finest Renaissance interiors.",
                  furnitureUse: "Writing desks, portrait frames, and marquetry inlay. The most prized wood for master carvers and cabinet makers.",
                  modernUse: "Gunstocks, luxury veneer, musical instruments, and high-end cabinetry. Still commands premium prices worldwide.",
                  buildings: "Palazzo (luxury)",
                  description: "The most prized wood in Renaissance Italy. Walnut's deep grain and rich color made it the choice of master artisans.",
                  biologyFact: "Walnut roots release juglone, a natural herbicide that inhibits competing plants from growing nearby. This is called allelopathy — chemical warfare between plants.",
                  timberYield: 1),
        ForestPOI(name: "Poplar", italianName: "Pioppo",
                  position: CGPoint(x: 2800, y: 700),
                  woodType: "Softwood", leafType: "Deciduous", maxHeight: "20-30 m",
                  usedFor: "Scaffolding, temporary centering for arches, and formwork. Every Renaissance construction site depended on poplar.",
                  furnitureUse: "Painting panels for tempera art, simple shelving, and crates. Botticelli's 'Birth of Venus' was painted on poplar.",
                  modernUse: "Plywood, paper pulp, matchsticks, and packaging. Fast-growing and sustainable — Italy's most renewable timber.",
                  buildings: "Construction phase + Chapel frescoes",
                  description: "Fast-growing and lightweight, poplar was the builder's workhorse and the artist's canvas — scaffolding by day, painting panels by night.",
                  biologyFact: "Poplar is one of the fastest-growing trees in Europe — up to 3 meters per year. Its rapid growth makes it a carbon sink, absorbing CO2 faster than most other species.",
                  timberYield: 2),
    ]

    private var poiNodes: [SKNode] = []

    // MARK: - Waypoint Graph (forest trail network for pathfinding)

    /// 24 trail junctions — spread across the 3500×2500 forest
    private var waypoints: [CGPoint] = [
        // --- Central clearing ---
        /* 0  */ CGPoint(x: 1750, y: 1250),  // central hub
        /* 1  */ CGPoint(x: 1200, y: 1250),  // west of center
        /* 2  */ CGPoint(x: 2300, y: 1250),  // east of center

        // --- Upper trails (near Oak, Cypress, Chestnut) ---
        /* 3  */ CGPoint(x: 700,  y: 1650),  // near Oak
        /* 4  */ CGPoint(x: 1100, y: 1550),  // Oak trail bend
        /* 5  */ CGPoint(x: 1750, y: 1600),  // near Cypress (below)
        /* 6  */ CGPoint(x: 1750, y: 1800),  // near Cypress (above)
        /* 7  */ CGPoint(x: 2400, y: 1550),  // Chestnut trail bend
        /* 8  */ CGPoint(x: 2750, y: 1700),  // near Chestnut

        // --- Lower trails (near Walnut, Poplar) ---
        /* 9  */ CGPoint(x: 750,  y: 900),   // near Walnut
        /* 10 */ CGPoint(x: 1100, y: 900),   // Walnut trail bend
        /* 11 */ CGPoint(x: 1750, y: 850),   // south center
        /* 12 */ CGPoint(x: 2400, y: 850),   // Poplar trail bend
        /* 13 */ CGPoint(x: 2700, y: 750),   // near Poplar

        // --- Edge trails ---
        /* 14 */ CGPoint(x: 400,  y: 1250),  // far west
        /* 15 */ CGPoint(x: 3100, y: 1250),  // far east
        /* 16 */ CGPoint(x: 1750, y: 2100),  // north center (entry from workshop)
        /* 17 */ CGPoint(x: 1750, y: 500),   // south center

        // --- Diagonal connectors ---
        /* 18 */ CGPoint(x: 550,  y: 1200),  // SW-NW link
        /* 19 */ CGPoint(x: 3000, y: 1200),  // SE-NE link
        /* 20 */ CGPoint(x: 1100, y: 1800),  // NW upper
        /* 21 */ CGPoint(x: 2400, y: 1800),  // NE upper
        /* 22 */ CGPoint(x: 1100, y: 650),   // SW lower
        /* 23 */ CGPoint(x: 2400, y: 650),   // SE lower
    ]

    /// Bidirectional edges: each pair [a, b] means a↔b
    private let waypointEdges: [[Int]] = [
        // Central horizontal spine
        [14, 18], [18, 1], [1, 0], [0, 2], [2, 19], [19, 15],

        // Upper ring (Oak → Cypress → Chestnut)
        [3, 4], [4, 20], [20, 5], [5, 6], [6, 16], [5, 0],
        [6, 21], [21, 7], [7, 8],

        // Lower ring (Walnut → Poplar)
        [9, 10], [10, 22], [22, 11], [11, 17], [11, 0],
        [11, 23], [23, 12], [12, 13],

        // Vertical connectors (upper ↔ center ↔ lower)
        [3, 14], [14, 9], [18, 9],       // west column
        [4, 1], [10, 1],                   // west-center column
        [5, 0], [11, 0],                   // center column
        [7, 2], [12, 2],                   // east-center column
        [8, 15], [15, 13], [19, 13],      // east column

        // Diagonal shortcuts
        [20, 4], [21, 8], [22, 10], [23, 13],
        [1, 4], [1, 10], [2, 7], [2, 12],
    ]

    /// Which waypoints each POI connects to (nearest trail junctions)
    private let poiWaypoints: [[Int]] = [
        /* Oak (0)      */ [3, 4, 14],
        /* Chestnut (1) */ [8, 7, 19],
        /* Cypress (2)  */ [6, 5, 16],
        /* Walnut (3)   */ [9, 18, 10],
        /* Poplar (4)   */ [13, 12, 23],
    ]

    // MARK: - Truffle Discovery

    /// Truffle types that can be found near certain trees
    struct TruffleFind {
        let name: String
        let italianName: String
        let rarity: String               // "Common" / "Rare" / "Legendary"
        let nearTree: String             // Which tree it grows near
        let value: Int                   // Florins earned when sold
        let description: String
        let historyFact: String
        let biologyFact: String
    }

    /// Possible truffle discoveries — each linked to specific tree species
    private let truffleTypes: [TruffleFind] = [
        TruffleFind(
            name: "Black Truffle",
            italianName: "Tartufo Nero",
            rarity: "Common",
            nearTree: "Oak",
            value: 15,
            description: "A dark, earthy truffle with a rich aroma. Found in the root systems of oak trees, where the fungus forms a symbiotic bond with the tree's roots.",
            historyFact: "Bartolomeo Platina's 1474 cookbook 'De honesta voluptate' — the first printed cookbook — included truffle recipes. Renaissance nobles served them at banquets to display their wealth and refined taste.",
            biologyFact: "Truffles are mycorrhizal fungi — they grow on tree roots in a symbiotic relationship. The truffle feeds the tree phosphorus and minerals, while the tree provides the truffle with sugars from photosynthesis."
        ),
        TruffleFind(
            name: "White Truffle",
            italianName: "Tartufo Bianco",
            rarity: "Rare",
            nearTree: "Oak",
            value: 40,
            description: "The legendary white truffle of Alba — the most expensive food in the world. Its intoxicating aroma of garlic, honey, and earth cannot be replicated.",
            historyFact: "Ancient Romans believed truffles were created when lightning struck the earth near tree roots. Pliny the Elder called them 'callosities of the earth.' During the Renaissance, white truffles were worth more than gold by weight.",
            biologyFact: "White truffles (Tuber magnatum) cannot be cultivated — every single one must be found wild. They emit volatile compounds that attract animals to dig them up and spread their spores. Truffle hunters use trained dogs to detect them underground."
        ),
        TruffleFind(
            name: "Summer Truffle",
            italianName: "Tartufo Estivo",
            rarity: "Common",
            nearTree: "Chestnut",
            value: 10,
            description: "A milder truffle found under chestnut trees in the warmer months. Less pungent than its winter cousins, but still prized in Italian cooking.",
            historyFact: "Chestnut forests across Umbria and Tuscany were carefully maintained by Renaissance landowners partly because they harbored truffles. Peasants who found truffles on noble lands were required to surrender them to their lords.",
            biologyFact: "Summer truffles grow closer to the surface than winter varieties — just 5-15 cm deep. The soil above a truffle patch often appears slightly cracked or bare, because the truffle's mycelium inhibits plant growth nearby."
        ),
        TruffleFind(
            name: "Burgundy Truffle",
            italianName: "Tartufo Uncinato",
            rarity: "Rare",
            nearTree: "Walnut",
            value: 25,
            description: "An autumn truffle with a hazelnut aroma, found near walnut tree roots. The juglone chemical in walnut roots creates unique soil conditions that this truffle thrives in.",
            historyFact: "Renaissance apothecaries sold truffles as medicine, believing they cured everything from gout to poor eyesight. The Medici court physician prescribed them as aphrodisiacs — a reputation truffles still carry today.",
            biologyFact: "Walnut trees release juglone, a chemical toxic to most plants — but the Burgundy truffle has evolved to tolerate it. This means walnut groves have less competition for truffles, making them productive hunting grounds."
        ),
    ]

    /// Track how many truffles have been found this session (limit discoveries)
    private var trufflesFoundThisSession = 0
    private let maxTrufflesPerSession = 3

    // MARK: - Callbacks to SwiftUI

    var onPlayerPositionChanged: ((CGPoint, Bool) -> Void)?
    var onBackRequested: (() -> Void)?
    /// Called when a POI is tapped — passes the POI index so SwiftUI shows the info overlay
    var onPOISelected: ((Int) -> Void)?
    /// Called when the player discovers a truffle while exploring
    var onTruffleFound: ((TruffleFind) -> Void)?

    // MARK: - Scene Setup

    override func didMove(to view: SKView) {
        backgroundColor = PlatformColor(RenaissanceColors.parchment)

        setupCamera()
        setupBackground()
        setupGridLines()
        setupTrails()
        setupTitle()
        setupPOIs()
        setupPlayer()

        isUserInteractionEnabled = true

        #if DEBUG
        registerEditorNodes()
        #endif
    }

    // MARK: - Camera

    private func setupCamera() {
        cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: mapSize.width / 2, y: mapSize.height / 2)
        addChild(cameraNode)
        camera = cameraNode
        fitCameraToMap()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        fitCameraToMap()
    }

    /// Standard fitCameraToMap — uses mapSize (not terrain size)
    private func fitCameraToMap() {
        guard let cameraNode = cameraNode else { return }
        let s = self.size
        guard s.width > 0 && s.height > 0 else { return }
        let fitScale = max(mapSize.width / s.width, mapSize.height / s.height)
        cameraNode.setScale(fitScale)
    }

    // MARK: - Camera Clamping

    private func clampCamera() {
        let scale = cameraNode.xScale
        let viewSize = view?.bounds.size ?? CGSize(width: 1024, height: 768)

        let padding: CGFloat = 200

        let visibleWidth = viewSize.width * scale
        let visibleHeight = viewSize.height * scale

        let minX = (visibleWidth / 2) - padding
        let maxX = mapSize.width - (visibleWidth / 2) + padding
        let minY = (visibleHeight / 2) - padding
        let maxY = mapSize.height - (visibleHeight / 2) + padding

        if maxX > minX {
            cameraNode.position.x = max(minX, min(maxX, cameraNode.position.x))
        } else {
            cameraNode.position.x = mapSize.width / 2
        }

        if maxY > minY {
            cameraNode.position.y = max(minY, min(maxY, cameraNode.position.y))
        } else {
            cameraNode.position.y = mapSize.height / 2
        }
    }

    // MARK: - Background (stretched to mapSize per standard)

    private func setupBackground() {
        let terrainTexture = SKTexture(imageNamed: "Forest1")
        let terrain = SKSpriteNode(texture: terrainTexture)
        terrain.size = mapSize  // Stretch to fill map coordinate space
        terrain.position = CGPoint(x: mapSize.width / 2, y: mapSize.height / 2)
        terrain.zPosition = -100
        addChild(terrain)
    }

    // MARK: - Grid Lines (notebook style)

    private func setupGridLines() {
        let gridNode = SKNode()
        gridNode.zPosition = -90

        let lineColor = PlatformColor(RenaissanceColors.sepiaInk.opacity(0.06))

        for x in stride(from: 0, through: mapSize.width, by: 100) {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: mapSize.height))
            let line = SKShapeNode(path: path)
            line.strokeColor = lineColor
            line.lineWidth = 0.5
            gridNode.addChild(line)
        }

        for y in stride(from: 0, through: mapSize.height, by: 100) {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: mapSize.width, y: y))
            let line = SKShapeNode(path: path)
            line.strokeColor = lineColor
            line.lineWidth = 0.5
            gridNode.addChild(line)
        }

        addChild(gridNode)
    }

    // MARK: - Forest Trails (dashed paths between waypoints)

    private func setupTrails() {
        let trailNode = SKNode()
        trailNode.zPosition = -50

        let trailColor = PlatformColor(RenaissanceColors.warmBrown.opacity(0.2))

        for edge in waypointEdges {
            let a = waypoints[edge[0]]
            let b = waypoints[edge[1]]

            let linePath = CGMutablePath()
            linePath.move(to: a)
            linePath.addLine(to: b)

            let dottedLine = SKShapeNode(path: linePath.copy(dashingWithPhase: 0, lengths: [10, 8]))
            dottedLine.strokeColor = trailColor
            dottedLine.lineWidth = 2
            trailNode.addChild(dottedLine)
        }

        // Also draw connector trails from each POI to its nearest waypoints
        for (i, poi) in pointsOfInterest.enumerated() {
            for wp in poiWaypoints[i].prefix(1) {  // Only draw to the nearest waypoint
                let linePath = CGMutablePath()
                linePath.move(to: poi.position)
                linePath.addLine(to: waypoints[wp])

                let dottedLine = SKShapeNode(path: linePath.copy(dashingWithPhase: 0, lengths: [10, 8]))
                dottedLine.strokeColor = PlatformColor(RenaissanceColors.sageGreen.opacity(0.2))
                dottedLine.lineWidth = 2
                trailNode.addChild(dottedLine)
            }
        }

        addChild(trailNode)
    }

    // MARK: - Title

    private func setupTitle() {
        let title = SKLabelNode(text: "THE ITALIAN FOREST")
        title.fontName = "Cinzel-Regular"
        title.fontSize = 28
        title.fontColor = PlatformColor(RenaissanceColors.sepiaInk.opacity(0.4))
        title.position = CGPoint(x: mapSize.width / 2, y: mapSize.height - 50)
        title.zPosition = -80
        addChild(title)
    }

    // MARK: - Points of Interest (with unique tree silhouettes)

    private func setupPOIs() {
        for (index, poi) in pointsOfInterest.enumerated() {
            let container = SKNode()
            container.position = poi.position
            container.zPosition = 10
            container.name = "poi_\(index)"

            // Hand-drawn tree silhouette (unique per species)
            let treeShape = createTreeShape(for: poi.name)
            treeShape.zPosition = 9
            container.addChild(treeShape)

            // Glowing circle background — warm ochre/parchment palette
            let glow = SKShapeNode(circleOfRadius: 40)
            glow.fillColor = PlatformColor(RenaissanceColors.ochre.opacity(0.15))
            glow.strokeColor = PlatformColor(RenaissanceColors.ochre.opacity(0.4))
            glow.lineWidth = 2
            container.addChild(glow)

            // Pulsing animation
            let scaleUp = SKAction.scale(to: 1.15, duration: 1.2)
            scaleUp.timingMode = .easeInEaseOut
            let scaleDown = SKAction.scale(to: 1.0, duration: 1.2)
            scaleDown.timingMode = .easeInEaseOut
            glow.run(SKAction.repeatForever(SKAction.sequence([scaleUp, scaleDown])))

            // Tree name label
            let label = SKLabelNode(text: poi.name)
            label.fontName = "Cinzel-Regular"
            label.fontSize = 15
            label.fontColor = PlatformColor(RenaissanceColors.ochre)
            label.position = CGPoint(x: 0, y: -55)
            label.zPosition = 11
            container.addChild(label)

            // Italian name
            let italianLabel = SKLabelNode(text: poi.italianName)
            italianLabel.fontName = "Mulish-Light"
            italianLabel.fontSize = 13
            italianLabel.fontColor = PlatformColor(RenaissanceColors.warmBrown)
            italianLabel.position = CGPoint(x: 0, y: -72)
            italianLabel.zPosition = 11
            container.addChild(italianLabel)

            addChild(container)
            poiNodes.append(container)
        }
    }

    // MARK: - Tree Silhouettes (hand-drawn SKShapeNode per species)

    private func createTreeShape(for treeName: String) -> SKNode {
        let treeNode = SKNode()
        let trunkColor = PlatformColor(RenaissanceColors.warmBrown)
        let leafColor: PlatformColor

        switch treeName {
        case "Oak":
            leafColor = PlatformColor(RenaissanceColors.sageGreen)
            // Wide spreading crown — the mighty oak
            let trunk = SKShapeNode(rectOf: CGSize(width: 10, height: 40))
            trunk.fillColor = trunkColor
            trunk.strokeColor = trunkColor
            trunk.position = CGPoint(x: 0, y: -50)
            treeNode.addChild(trunk)

            // Broad irregular crown (3 overlapping circles)
            for offset in [CGPoint(x: -18, y: -15), CGPoint(x: 0, y: -5), CGPoint(x: 16, y: -15)] {
                let crown = SKShapeNode(circleOfRadius: 22)
                crown.fillColor = leafColor
                crown.strokeColor = PlatformColor(RenaissanceColors.sageGreen.opacity(0.7))
                crown.lineWidth = 1.5
                crown.position = offset
                treeNode.addChild(crown)
            }

        case "Chestnut":
            leafColor = PlatformColor(RenaissanceColors.gardenGreen)
            // Rounded dome crown
            let trunk = SKShapeNode(rectOf: CGSize(width: 10, height: 35))
            trunk.fillColor = trunkColor
            trunk.strokeColor = trunkColor
            trunk.position = CGPoint(x: 0, y: -48)
            treeNode.addChild(trunk)

            // Dome shape (2 overlapping circles, top-heavy)
            let lower = SKShapeNode(circleOfRadius: 20)
            lower.fillColor = leafColor
            lower.strokeColor = PlatformColor(RenaissanceColors.gardenGreen.opacity(0.7))
            lower.lineWidth = 1.5
            lower.position = CGPoint(x: 0, y: -15)
            treeNode.addChild(lower)

            let upper = SKShapeNode(circleOfRadius: 16)
            upper.fillColor = leafColor
            upper.strokeColor = PlatformColor(RenaissanceColors.gardenGreen.opacity(0.7))
            upper.lineWidth = 1.5
            upper.position = CGPoint(x: 0, y: 0)
            treeNode.addChild(upper)

        case "Cypress":
            leafColor = PlatformColor(RenaissanceColors.deepTeal)
            // Tall narrow columnar shape — the Tuscan sentinel
            let trunk = SKShapeNode(rectOf: CGSize(width: 6, height: 50))
            trunk.fillColor = trunkColor
            trunk.strokeColor = trunkColor
            trunk.position = CGPoint(x: 0, y: -55)
            treeNode.addChild(trunk)

            // Tall narrow ellipse (drawn as a path)
            let cypressPath = CGMutablePath()
            cypressPath.addEllipse(in: CGRect(x: -8, y: -35, width: 16, height: 55))
            let crown = SKShapeNode(path: cypressPath)
            crown.fillColor = leafColor
            crown.strokeColor = PlatformColor(RenaissanceColors.deepTeal.opacity(0.7))
            crown.lineWidth = 1.5
            treeNode.addChild(crown)

        case "Walnut":
            leafColor = PlatformColor(RenaissanceColors.warmBrown)
            // Medium rounded crown with darker coloring
            let trunk = SKShapeNode(rectOf: CGSize(width: 8, height: 30))
            trunk.fillColor = trunkColor
            trunk.strokeColor = trunkColor
            trunk.position = CGPoint(x: 0, y: -42)
            treeNode.addChild(trunk)

            // Round crown
            let crown = SKShapeNode(circleOfRadius: 20)
            crown.fillColor = PlatformColor(RenaissanceColors.sageGreen.opacity(0.8))
            crown.strokeColor = PlatformColor(RenaissanceColors.sageGreen.opacity(0.6))
            crown.lineWidth = 1.5
            crown.position = CGPoint(x: 0, y: -10)
            treeNode.addChild(crown)

            // Walnut fruits (small brown dots)
            for offset in [CGPoint(x: -10, y: -15), CGPoint(x: 8, y: -8), CGPoint(x: -4, y: -3)] {
                let nut = SKShapeNode(circleOfRadius: 3)
                nut.fillColor = trunkColor
                nut.strokeColor = .clear
                nut.position = offset
                treeNode.addChild(nut)
            }

        case "Poplar":
            leafColor = PlatformColor(RenaissanceColors.gardenGreen.opacity(0.8))
            // Tall slender triangular shape
            let trunk = SKShapeNode(rectOf: CGSize(width: 7, height: 45))
            trunk.fillColor = trunkColor
            trunk.strokeColor = trunkColor
            trunk.position = CGPoint(x: 0, y: -52)
            treeNode.addChild(trunk)

            // Triangle crown (tall and narrow)
            let trianglePath = CGMutablePath()
            trianglePath.move(to: CGPoint(x: 0, y: 10))       // top
            trianglePath.addLine(to: CGPoint(x: -14, y: -30))  // bottom left
            trianglePath.addLine(to: CGPoint(x: 14, y: -30))   // bottom right
            trianglePath.closeSubpath()
            let crown = SKShapeNode(path: trianglePath)
            crown.fillColor = leafColor
            crown.strokeColor = PlatformColor(RenaissanceColors.gardenGreen.opacity(0.6))
            crown.lineWidth = 1.5
            treeNode.addChild(crown)

        default:
            // Generic tree
            let trunk = SKShapeNode(rectOf: CGSize(width: 8, height: 30))
            trunk.fillColor = trunkColor
            trunk.strokeColor = trunkColor
            trunk.position = CGPoint(x: 0, y: -40)
            treeNode.addChild(trunk)

            let crown = SKShapeNode(circleOfRadius: 18)
            crown.fillColor = PlatformColor(RenaissanceColors.sageGreen)
            crown.strokeColor = PlatformColor(RenaissanceColors.sageGreen.opacity(0.7))
            crown.lineWidth = 1.5
            crown.position = CGPoint(x: 0, y: -10)
            treeNode.addChild(crown)
        }

        return treeNode
    }

    /// Get POI data by index (for SwiftUI overlay)
    func getPOI(at index: Int) -> ForestPOI? {
        guard index >= 0 && index < pointsOfInterest.count else { return nil }
        return pointsOfInterest[index]
    }

    // MARK: - Player

    private func setupPlayer() {
        playerNode = PlayerNode(isBoy: apprenticeIsBoy)
        // Spawn at north entry (coming from workshop)
        playerNode.position = CGPoint(x: 1750, y: 2100)
        playerNode.zPosition = 50
        addChild(playerNode)
        updatePlayerScreenPosition()
    }

    // MARK: - Position Tracking

    private func updatePlayerScreenPosition() {
        guard let view = self.view, playerNode != nil else { return }
        let viewPoint = convertPoint(toView: playerNode.position)
        let viewSize = view.bounds.size
        let normalizedX = viewPoint.x / viewSize.width
        let normalizedY = viewPoint.y / viewSize.height
        onPlayerPositionChanged?(CGPoint(x: normalizedX, y: normalizedY), playerNode.isWalking)
    }

    override func update(_ currentTime: TimeInterval) {
        updatePlayerScreenPosition()
    }

    // MARK: - Input Handling

    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        #if DEBUG
        if editorMode.handleTapDown(at: location) { return }
        #endif

        handleTapAt(location)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        #if DEBUG
        if editorMode.handleDrag(to: location) { return }
        #endif

        if let last = lastPanLocation {
            handleDragTo(location, from: last)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        #if DEBUG
        if editorMode.handleRelease() { /* fall through */ }
        #endif
        lastPanLocation = nil
    }
    #else
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)

        #if DEBUG
        if editorMode.handleTapDown(at: location) { return }
        #endif

        handleTapAt(location)
    }

    override func mouseDragged(with event: NSEvent) {
        let location = event.location(in: self)

        #if DEBUG
        if editorMode.handleDrag(to: location) { return }
        #endif

        guard let last = lastPanLocation else { return }
        handleDragTo(location, from: last)
    }

    override func mouseUp(with event: NSEvent) {
        #if DEBUG
        if editorMode.handleRelease() { /* fall through */ }
        #endif
        lastPanLocation = nil
    }

    // Scroll wheel/trackpad on macOS — scroll = zoom, Option+scroll = pan
    override func scrollWheel(with event: NSEvent) {
        if event.modifierFlags.contains(.option) {
            // Option + scroll = pan the map
            let scale = cameraNode.xScale
            cameraNode.position.x -= event.deltaX * scale * 2
            cameraNode.position.y += event.deltaY * scale * 2
        } else {
            // Regular scroll = zoom (works with Magic Mouse)
            let zoomFactor: CGFloat = 1.0 - (event.deltaY * 0.05)
            let newScale = cameraNode.xScale * zoomFactor
            let clampedScale = max(0.5, min(3.5, newScale))
            cameraNode.setScale(clampedScale)
        }
        clampCamera()
    }

    // Pinch-to-zoom on trackpad
    override func magnify(with event: NSEvent) {
        let zoomFactor: CGFloat = 1.0 + event.magnification
        let newScale = cameraNode.xScale / zoomFactor
        let clampedScale = max(0.5, min(3.5, newScale))
        cameraNode.setScale(clampedScale)
        clampCamera()
    }

    override func keyDown(with event: NSEvent) {
        #if DEBUG
        if editorMode.handleKeyDown(event.keyCode) { return }
        #endif
    }
    #endif

    // MARK: - Shared Input Logic

    private func handleTapAt(_ location: CGPoint) {
        // Check if a POI was tapped
        let tappedNodes = nodes(at: location)
        for node in tappedNodes {
            if let poiNode = findPOIAncestor(node) {
                walkPlayerToPOI(poiNode)
                return
            }
        }

        // Start pan
        lastPanLocation = location
    }

    private func handleDragTo(_ location: CGPoint, from lastLocation: CGPoint) {
        let deltaX = location.x - lastLocation.x
        let deltaY = location.y - lastLocation.y

        cameraNode.position.x -= deltaX
        cameraNode.position.y -= deltaY

        clampCamera()
        lastPanLocation = location
    }

    func handlePinch(scale: CGFloat) {
        let newScale = cameraNode.xScale / scale
        let clampedScale = max(0.5, min(3.5, newScale))
        cameraNode.setScale(clampedScale)
        clampCamera()
    }

    /// Zoom via scroll delta (Magic Mouse swipe / scroll wheel)
    func handleScrollZoom(deltaY: CGFloat) {
        guard cameraNode != nil else { return }
        let zoomFactor: CGFloat = 1.0 - (deltaY * 0.05)
        let newScale = cameraNode.xScale * zoomFactor
        let clampedScale = max(0.5, min(3.5, newScale))
        cameraNode.setScale(clampedScale)
        clampCamera()
    }

    private func findPOIAncestor(_ node: SKNode) -> SKNode? {
        var current: SKNode? = node
        while let n = current {
            if let name = n.name, name.hasPrefix("poi_") {
                return n
            }
            current = n.parent
        }
        return nil
    }

    // MARK: - Pathfinding (Dijkstra on waypoint graph)

    private func buildAdjacency() -> [[Int]] {
        var adj = [[Int]](repeating: [], count: waypoints.count)
        for edge in waypointEdges {
            adj[edge[0]].append(edge[1])
            adj[edge[1]].append(edge[0])
        }
        return adj
    }

    /// Find the 2 nearest waypoints to a given position
    private func nearestWaypoints(to point: CGPoint, count: Int = 2) -> [Int] {
        let indexed = waypoints.enumerated().map { (index: $0.offset, dist: hypot($0.element.x - point.x, $0.element.y - point.y)) }
        let sorted = indexed.sorted { $0.dist < $1.dist }
        return Array(sorted.prefix(count).map { $0.index })
    }

    /// Dijkstra shortest path on waypoint graph with virtual start/end nodes
    private func findPath(from start: CGPoint, to end: CGPoint, startWaypoints: [Int], endWaypoints: [Int]) -> [CGPoint] {
        let n = waypoints.count
        let startVirtual = n
        let endVirtual = n + 1
        let totalNodes = n + 2

        var adj = [[(node: Int, dist: CGFloat)]](repeating: [], count: totalNodes)

        let baseAdj = buildAdjacency()
        for i in 0..<n {
            for j in baseAdj[i] {
                let d = hypot(waypoints[i].x - waypoints[j].x, waypoints[i].y - waypoints[j].y)
                adj[i].append((j, d))
            }
        }

        for wp in startWaypoints {
            let d = hypot(start.x - waypoints[wp].x, start.y - waypoints[wp].y)
            adj[startVirtual].append((wp, d))
            adj[wp].append((startVirtual, d))
        }

        for wp in endWaypoints {
            let d = hypot(end.x - waypoints[wp].x, end.y - waypoints[wp].y)
            adj[endVirtual].append((wp, d))
            adj[wp].append((endVirtual, d))
        }

        var dist = [CGFloat](repeating: .infinity, count: totalNodes)
        var prev = [Int](repeating: -1, count: totalNodes)
        var visited = [Bool](repeating: false, count: totalNodes)
        dist[startVirtual] = 0

        for _ in 0..<totalNodes {
            var u = -1
            var bestDist: CGFloat = .infinity
            for v in 0..<totalNodes {
                if !visited[v] && dist[v] < bestDist {
                    bestDist = dist[v]
                    u = v
                }
            }
            guard u >= 0 else { break }
            visited[u] = true

            if u == endVirtual { break }

            for (v, w) in adj[u] {
                let newDist = dist[u] + w
                if newDist < dist[v] {
                    dist[v] = newDist
                    prev[v] = u
                }
            }
        }

        guard dist[endVirtual] < .infinity else { return [end] }

        var path: [Int] = []
        var cur = endVirtual
        while cur != -1 {
            path.append(cur)
            cur = prev[cur]
        }
        path.reverse()

        var result: [CGPoint] = []
        for nodeIdx in path {
            if nodeIdx == startVirtual { continue }
            if nodeIdx == endVirtual {
                result.append(end)
            } else {
                result.append(waypoints[nodeIdx])
            }
        }

        return result
    }

    // MARK: - Walk Player to POI

    private func walkPlayerToPOI(_ poiNode: SKNode) {
        guard playerNode != nil,
              let name = poiNode.name,
              let idx = Int(name.replacingOccurrences(of: "poi_", with: "")),
              idx < pointsOfInterest.count else { return }

        let targetPos = CGPoint(x: poiNode.position.x - 60, y: poiNode.position.y - 50)
        let playerPos = playerNode.position

        let directDistance = hypot(targetPos.x - playerPos.x, targetPos.y - playerPos.y)

        let treeName = pointsOfInterest[idx].name

        // Completion: show POI overlay, then maybe discover a truffle
        let onArrival: () -> Void = { [weak self] in
            self?.playerNode.playCollectAnimation {
                self?.onPOISelected?(idx)
                // Roll for truffle discovery near this tree (delayed so POI overlay shows first)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self?.rollForTruffleDiscovery(nearTree: treeName)
                }
            }
        }

        // If very close, walk directly
        if directDistance < 350 {
            let facingRight = targetPos.x > playerPos.x
            playerNode.setFacingDirection(facingRight)
            playerNode.walkTo(destination: targetPos, duration: max(0.3, TimeInterval(directDistance / 467)), completion: onArrival)
            return
        }

        // Use Dijkstra pathfinding through trail waypoints
        let startWPs = nearestWaypoints(to: playerPos)
        let endWPs = poiWaypoints[idx]

        let path = findPath(from: playerPos, to: targetPos, startWaypoints: startWPs, endWaypoints: endWPs)

        guard !path.isEmpty else {
            // Fallback: direct walk
            let facingRight = targetPos.x > playerPos.x
            playerNode.setFacingDirection(facingRight)
            playerNode.walkTo(destination: targetPos, duration: max(0.5, TimeInterval(directDistance / 467)), completion: onArrival)
            return
        }

        // Initial facing direction
        let firstTarget = path[0]
        let facingRight = firstTarget.x > playerPos.x
        playerNode.setFacingDirection(facingRight)

        // Walk along the trail path
        playerNode.walkPath(path, speed: 467, completion: onArrival)
    }

    // MARK: - Truffle Discovery Logic

    /// Roll for a truffle discovery when arriving at a tree POI
    /// ~25% chance per visit, only near trees that host truffles (Oak, Chestnut, Walnut)
    private func rollForTruffleDiscovery(nearTree treeName: String) {
        guard trufflesFoundThisSession < maxTrufflesPerSession else { return }

        // Only certain trees host truffles
        let possibleTruffles = truffleTypes.filter { $0.nearTree == treeName }
        guard !possibleTruffles.isEmpty else { return }

        // 25% base chance — rarer truffles have lower sub-chance
        let roll = Int.random(in: 0..<100)
        guard roll < 25 else { return }

        // Pick which truffle — common truffles more likely than rare ones
        let truffle: TruffleFind
        let subRoll = Int.random(in: 0..<100)
        let rareTruffles = possibleTruffles.filter { $0.rarity == "Rare" }
        let commonTruffles = possibleTruffles.filter { $0.rarity == "Common" }

        if subRoll < 20, let rare = rareTruffles.first {
            truffle = rare  // 20% of discoveries are rare
        } else if let common = commonTruffles.first {
            truffle = common
        } else {
            truffle = possibleTruffles[0]
        }

        trufflesFoundThisSession += 1

        // Spawn a brief truffle sprite animation at the player's feet
        spawnTruffleSprite(at: playerNode.position)

        // Notify SwiftUI after a short delay (let the sprite animation play)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.onTruffleFound?(truffle)
        }
    }

    /// Spawn a small truffle shape at the player's feet with a pop-in animation
    private func spawnTruffleSprite(at position: CGPoint) {
        let truffleNode = SKNode()
        truffleNode.position = CGPoint(x: position.x + 30, y: position.y - 20)
        truffleNode.zPosition = 45
        truffleNode.setScale(0.01)

        // Lumpy truffle shape (irregular circle)
        let trufflePath = CGMutablePath()
        trufflePath.addEllipse(in: CGRect(x: -12, y: -10, width: 24, height: 20))
        let body = SKShapeNode(path: trufflePath)
        body.fillColor = PlatformColor(RenaissanceColors.warmBrown)
        body.strokeColor = PlatformColor(RenaissanceColors.sepiaInk.opacity(0.5))
        body.lineWidth = 1.5
        truffleNode.addChild(body)

        // Small soil specks
        for offset in [CGPoint(x: -6, y: -4), CGPoint(x: 5, y: 3), CGPoint(x: -2, y: 6)] {
            let speck = SKShapeNode(circleOfRadius: 2)
            speck.fillColor = PlatformColor(RenaissanceColors.warmBrown.opacity(0.6))
            speck.strokeColor = .clear
            speck.position = offset
            truffleNode.addChild(speck)
        }

        // Sparkle effect
        let sparkle = SKShapeNode(circleOfRadius: 18)
        sparkle.fillColor = PlatformColor(RenaissanceColors.goldSuccess.opacity(0.3))
        sparkle.strokeColor = PlatformColor(RenaissanceColors.goldSuccess.opacity(0.6))
        sparkle.lineWidth = 1
        sparkle.setScale(0.5)
        truffleNode.addChild(sparkle)

        addChild(truffleNode)

        // Pop-in + sparkle animation
        let popIn = SKAction.scale(to: 1.0, duration: 0.3)
        popIn.timingMode = .easeOut
        let sparkleUp = SKAction.scale(to: 1.5, duration: 0.4)
        let sparkleDown = SKAction.scale(to: 1.0, duration: 0.3)
        let sparkleSeq = SKAction.sequence([sparkleUp, sparkleDown])
        sparkle.run(sparkleSeq)

        let wait = SKAction.wait(forDuration: 2.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()

        truffleNode.run(SKAction.sequence([popIn, wait, fadeOut, remove]))
    }

    // MARK: - Public Animation Methods

    /// Play collecting animation on the player (bend down + sparkles)
    func playPlayerCollectAnimation(completion: (() -> Void)? = nil) {
        guard playerNode != nil else { completion?(); return }
        playerNode.playCollectAnimation(completion: completion)
    }

    /// Play celebrating animation on the player (jump + star burst)
    func playPlayerCelebrateAnimation(completion: (() -> Void)? = nil) {
        guard playerNode != nil else { completion?(); return }
        playerNode.playCelebrateAnimation(completion: completion)
    }

    // MARK: - Editor Mode (DEBUG only)

    #if DEBUG
    private var waypointNodes: [SKNode] = []

    private func registerEditorNodes() {
        for (i, node) in poiNodes.enumerated() {
            editorMode.registerNode(node, name: "poi_\(i)")
        }
        editorMode.registerNode(playerNode, name: "player")

        // Register waypoints for dragging in editor mode
        for (i, wp) in waypoints.enumerated() {
            let dot = SKShapeNode(circleOfRadius: 8)
            dot.fillColor = PlatformColor(RenaissanceColors.blueprintBlue.opacity(0.4))
            dot.strokeColor = PlatformColor(RenaissanceColors.blueprintBlue.opacity(0.7))
            dot.lineWidth = 1
            dot.position = wp
            dot.zPosition = 200
            dot.isHidden = true  // Only visible in editor mode
            addChild(dot)
            waypointNodes.append(dot)
            editorMode.registerNode(dot, name: "wp_\(i)")
        }

        editorMode.onToggle = { [weak self] active in
            guard let self = self else { return }
            // Show/hide waypoint dots
            for dot in self.waypointNodes {
                dot.isHidden = !active
            }
            if !active {
                self.syncWaypointsFromNodes()
                self.dumpPositions()
            }
        }
    }

    private func syncWaypointsFromNodes() {
        for (i, node) in waypointNodes.enumerated() {
            waypoints[i] = node.position
        }
    }

    private func dumpPositions() {
        print("\n// ========== FOREST POI POSITIONS ==========")
        for (i, node) in poiNodes.enumerated() {
            let p = node.position
            let poi = pointsOfInterest[i]
            print("    // \(poi.name): CGPoint(x: \(Int(p.x)), y: \(Int(p.y)))")
        }
        print("\n// ========== FOREST WAYPOINTS ==========")
        for (i, wp) in waypoints.enumerated() {
            print("    /* \(i)  */ CGPoint(x: \(Int(wp.x)), y: \(Int(wp.y))),")
        }
        print("// =============================================\n")
    }
    #endif
}
