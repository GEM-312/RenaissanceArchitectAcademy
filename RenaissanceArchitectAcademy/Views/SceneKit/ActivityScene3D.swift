import SceneKit
import SwiftUI

// MARK: - 3D Activity Scene Builder

/// Creates SceneKit scenes for each knowledge card activity type.
/// Renaissance workshop aesthetic: stone, wood, bronze materials with warm candlelight.
enum ActivityScene3D {

    // MARK: - Shared Setup

    /// Base scene with camera + lighting. All activity builders start from this.
    static func makeBaseScene() -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = PlatformColor(red: 0.961, green: 0.902, blue: 0.827, alpha: 1.0) // parchment

        // Camera — fixed perspective, slight downward angle
        let cameraNode = SCNNode()
        cameraNode.name = "camera"
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 50
        cameraNode.camera?.zNear = 0.1
        cameraNode.camera?.zFar = 100
        cameraNode.position = SCNVector3(0, 1, 9)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(cameraNode)

        // Ambient light — warm fill
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = PlatformColor(red: 1.0, green: 0.92, blue: 0.8, alpha: 1.0) // warm parchment
        ambientLight.light?.intensity = 400
        scene.rootNode.addChildNode(ambientLight)

        // Directional light — amber candlelight from upper-left
        let directional = SCNNode()
        directional.name = "directionalLight"
        directional.light = SCNLight()
        directional.light?.type = .directional
        directional.light?.color = PlatformColor(red: 1.0, green: 0.88, blue: 0.7, alpha: 1.0)
        directional.light?.intensity = 800
        directional.light?.castsShadow = true
        directional.light?.shadowRadius = 4
        directional.light?.shadowColor = PlatformColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        directional.eulerAngles = SCNVector3(-CGFloat.pi / 4, -CGFloat.pi / 6, 0)
        scene.rootNode.addChildNode(directional)

        return scene
    }

    // MARK: - Materials

    static func stoneMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.diffuse.contents = PlatformColor(red: 0.639, green: 0.616, blue: 0.576, alpha: 1.0) // stoneGray
        mat.roughness.contents = NSNumber(value: 0.85)
        mat.lightingModel = .physicallyBased
        return mat
    }

    static func woodMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.diffuse.contents = PlatformColor(red: 0.545, green: 0.435, blue: 0.278, alpha: 1.0) // warmBrown
        mat.roughness.contents = NSNumber(value: 0.7)
        mat.lightingModel = .physicallyBased
        return mat
    }

    static func parchmentMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.diffuse.contents = PlatformColor(red: 0.961, green: 0.902, blue: 0.827, alpha: 1.0) // parchment
        mat.roughness.contents = NSNumber(value: 0.9)
        mat.lightingModel = .physicallyBased
        return mat
    }

    static func goldMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.diffuse.contents = PlatformColor(red: 0.855, green: 0.647, blue: 0.125, alpha: 1.0) // goldSuccess
        mat.metalness.contents = NSNumber(value: 0.8)
        mat.roughness.contents = NSNumber(value: 0.3)
        mat.lightingModel = .physicallyBased
        return mat
    }

    static func errorMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.diffuse.contents = PlatformColor(red: 0.804, green: 0.361, blue: 0.361, alpha: 1.0) // errorRed
        mat.roughness.contents = NSNumber(value: 0.6)
        mat.lightingModel = .physicallyBased
        return mat
    }

    static func terracottaMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.diffuse.contents = PlatformColor(red: 0.831, green: 0.529, blue: 0.420, alpha: 1.0) // terracotta
        mat.roughness.contents = NSNumber(value: 0.75)
        mat.lightingModel = .physicallyBased
        return mat
    }

    static func ochreMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.diffuse.contents = PlatformColor(red: 0.788, green: 0.659, blue: 0.416, alpha: 1.0) // ochre
        mat.roughness.contents = NSNumber(value: 0.7)
        mat.lightingModel = .physicallyBased
        return mat
    }

    static func sageMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.diffuse.contents = PlatformColor(red: 0.478, green: 0.608, blue: 0.463, alpha: 1.0) // sageGreen
        mat.roughness.contents = NSNumber(value: 0.6)
        mat.lightingModel = .physicallyBased
        return mat
    }

    static func waterMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.diffuse.contents = PlatformColor(red: 0.357, green: 0.561, blue: 0.639, alpha: 0.4) // renaissanceBlue
        mat.transparency = 0.5
        mat.roughness.contents = NSNumber(value: 0.1)
        mat.lightingModel = .physicallyBased
        return mat
    }

    static func textMaterial(color: PlatformColor = PlatformColor(red: 0.290, green: 0.251, blue: 0.208, alpha: 1.0)) -> SCNMaterial {
        let mat = SCNMaterial()
        mat.diffuse.contents = color
        mat.lightingModel = .constant
        return mat
    }

    // MARK: - Particle Effects

    static func goldSparkleParticles() -> SCNParticleSystem {
        let particles = SCNParticleSystem()
        particles.particleSize = 0.06
        particles.particleSizeVariation = 0.03
        particles.birthRate = 50
        particles.emissionDuration = 0.5
        particles.loops = false
        particles.particleLifeSpan = 1.0
        particles.particleColor = PlatformColor(red: 0.855, green: 0.647, blue: 0.125, alpha: 1.0)
        particles.particleColorVariation = SCNVector4(0.1, 0.1, 0, 0.2)
        particles.spreadingAngle = 180
        particles.emitterShape = SCNSphere(radius: 0.3)
        particles.particleVelocity = 1.5
        particles.particleVelocityVariation = 0.5
        particles.acceleration = SCNVector3(0, 2, 0)
        particles.particleAngularVelocity = 90
        return particles
    }

    static func redEmberParticles() -> SCNParticleSystem {
        let particles = SCNParticleSystem()
        particles.particleSize = 0.04
        particles.particleSizeVariation = 0.02
        particles.birthRate = 30
        particles.emissionDuration = 0.3
        particles.loops = false
        particles.particleLifeSpan = 0.6
        particles.particleColor = PlatformColor(red: 0.804, green: 0.361, blue: 0.361, alpha: 1.0)
        particles.particleColorVariation = SCNVector4(0.1, 0, 0, 0.2)
        particles.spreadingAngle = 120
        particles.emitterShape = SCNSphere(radius: 0.2)
        particles.particleVelocity = 1.0
        particles.acceleration = SCNVector3(0, -1, 0)
        return particles
    }

    // MARK: - 3D Text Helper

    static func makeTextNode(_ text: String, size: CGFloat = 0.3, color: PlatformColor? = nil) -> SCNNode {
        let textGeom = SCNText(string: text, extrusionDepth: 0.04)
        textGeom.font = PlatformFont(name: "Cinzel-Bold", size: size) ?? PlatformFont.systemFont(ofSize: size)
        textGeom.flatness = 0.1
        textGeom.firstMaterial = textMaterial(color: color ?? PlatformColor(red: 0.290, green: 0.251, blue: 0.208, alpha: 1.0))
        let node = SCNNode(geometry: textGeom)
        // Center the text
        let (min, max) = node.boundingBox
        let dx = (max.x - min.x) / 2
        let dy = (max.y - min.y) / 2
        node.pivot = SCNMatrix4MakeTranslation(dx + min.x, dy + min.y, 0)
        return node
    }

    // MARK: - Word Scramble 3D

    /// Letter tiles as 3D stone blocks on a wooden shelf. Tap a block → it flies to answer slots.
    static func makeWordScrambleScene(letters: [Character], tileNodeNames: inout [String: Character]) -> SCNScene {
        let scene = makeBaseScene()

        // Wooden shelf at bottom
        let shelf = SCNBox(width: 6, height: 0.15, length: 1.2, chamferRadius: 0.03)
        shelf.firstMaterial = woodMaterial()
        let shelfNode = SCNNode(geometry: shelf)
        shelfNode.position = SCNVector3(0, -1.5, 0)
        scene.rootNode.addChildNode(shelfNode)

        // Answer slots at top (empty stone cradles)
        let slotWidth: CGFloat = 0.7
        let totalWidth = CGFloat(letters.count) * slotWidth
        let startX = -totalWidth / 2 + slotWidth / 2

        for i in 0..<letters.count {
            let slot = SCNBox(width: slotWidth - 0.1, height: 0.08, length: 0.6, chamferRadius: 0.02)
            let slotMat = stoneMaterial()
            slotMat.diffuse.contents = PlatformColor(red: 0.7, green: 0.68, blue: 0.65, alpha: 0.5)
            slot.firstMaterial = slotMat
            let slotNode = SCNNode(geometry: slot)
            slotNode.name = "slot_\(i)"
            slotNode.position = SCNVector3(startX + CGFloat(i) * slotWidth, 1.8, 0)
            scene.rootNode.addChildNode(slotNode)

            // Dash marker
            let dash = makeTextNode("_", size: 0.35)
            dash.position = SCNVector3(startX + CGFloat(i) * slotWidth, 1.9, 0.2)
            dash.name = "dash_\(i)"
            scene.rootNode.addChildNode(dash)
        }

        // Scrambled letter blocks on shelf
        let shuffled = letters.enumerated().shuffled()
        let tileWidth: CGFloat = 0.65
        let tTotalWidth = CGFloat(shuffled.count) * tileWidth
        let tStartX = -tTotalWidth / 2 + tileWidth / 2

        for (idx, (_, char)) in shuffled.enumerated() {
            let block = SCNBox(width: 0.55, height: 0.55, length: 0.55, chamferRadius: 0.06)
            block.firstMaterial = stoneMaterial()
            let blockNode = SCNNode(geometry: block)
            let name = "tile_\(idx)"
            blockNode.name = name
            blockNode.position = SCNVector3(tStartX + CGFloat(idx) * tileWidth, -0.9, 0)
            scene.rootNode.addChildNode(blockNode)

            tileNodeNames[name] = char

            // Letter label on front face
            let label = makeTextNode(String(char), size: 0.3)
            label.position = SCNVector3(0, 0, 0.3)
            blockNode.addChildNode(label)
        }

        return scene
    }

    // MARK: - Number Fishing 3D

    /// Number spheres floating/bobbing in a water-like area. Tap correct → rises gold. Wrong → sinks.
    static func makeNumberFishingScene(correctAnswer: Int, decoys: [Int], bubbleNodeNames: inout [String: Int]) -> SCNScene {
        let scene = makeBaseScene()

        // Water plane
        let waterPlane = SCNBox(width: 7, height: 0.05, length: 5, chamferRadius: 0)
        waterPlane.firstMaterial = waterMaterial()
        let waterNode = SCNNode(geometry: waterPlane)
        waterNode.name = "water"
        waterNode.position = SCNVector3(0, -1.2, 0)
        waterNode.opacity = 0.5
        scene.rootNode.addChildNode(waterNode)

        // Ripple circles on water surface
        for i in 0..<3 {
            let ring = SCNTorus(ringRadius: 0.8 + CGFloat(i) * 0.6, pipeRadius: 0.015)
            let ringMat = SCNMaterial()
            ringMat.diffuse.contents = PlatformColor(red: 0.357, green: 0.561, blue: 0.639, alpha: 0.2)
            ringMat.lightingModel = .constant
            ring.firstMaterial = ringMat
            let ringNode = SCNNode(geometry: ring)
            ringNode.position = SCNVector3(CGFloat.random(in: -1.5...1.5), -1.15, CGFloat.random(in: -1...1))
            scene.rootNode.addChildNode(ringNode)
        }

        // Number spheres
        var allNumbers = decoys + [correctAnswer]
        allNumbers.shuffle()

        let positions: [SCNVector3] = generateSpreadPositions(count: allNumbers.count, yBase: 0.0, xRange: -2.5...2.5, zRange: -1.2...1.2)

        for (idx, number) in allNumbers.enumerated() {
            let sphere = SCNSphere(radius: 0.4)
            let sphereMat = SCNMaterial()
            sphereMat.diffuse.contents = PlatformColor(red: 0.357, green: 0.561, blue: 0.639, alpha: 0.3)
            sphereMat.transparency = 0.6
            sphereMat.roughness.contents = NSNumber(value: 0.1)
            sphereMat.lightingModel = .physicallyBased
            sphere.firstMaterial = sphereMat
            let sphereNode = SCNNode(geometry: sphere)
            let name = "bubble_\(idx)"
            sphereNode.name = name
            sphereNode.position = positions[idx]
            scene.rootNode.addChildNode(sphereNode)

            bubbleNodeNames[name] = number

            // Number label
            let label = makeTextNode("\(number)", size: 0.25, color: PlatformColor(red: 0.169, green: 0.478, blue: 0.549, alpha: 1.0))
            label.position = SCNVector3(0, 0, 0.45)
            sphereNode.addChildNode(label)

            // Gentle bob animation
            let bobUp = SCNAction.moveBy(x: 0, y: CGFloat.random(in: 0.15...0.3), z: 0, duration: Double.random(in: 1.8...2.5))
            bobUp.timingMode = .easeInEaseOut
            let bobDown = bobUp.reversed()
            sphereNode.runAction(.repeatForever(.sequence([bobUp, bobDown])))
        }

        return scene
    }

    // MARK: - Hangman 3D

    /// Scaffold from 3D beams. Body parts appear as simple 3D shapes.
    static func makeHangmanScene() -> SCNScene {
        let scene = makeBaseScene()

        // Build scaffold from wood beams
        // Base beam
        let base = SCNBox(width: 2.5, height: 0.15, length: 0.3, chamferRadius: 0.02)
        base.firstMaterial = woodMaterial()
        let baseNode = SCNNode(geometry: base)
        baseNode.name = "scaffold_base"
        baseNode.position = SCNVector3(-0.5, -1.5, 0)
        scene.rootNode.addChildNode(baseNode)

        // Vertical pole
        let pole = SCNBox(width: 0.15, height: 3.5, length: 0.15, chamferRadius: 0.02)
        pole.firstMaterial = woodMaterial()
        let poleNode = SCNNode(geometry: pole)
        poleNode.name = "scaffold_pole"
        poleNode.position = SCNVector3(-1.2, 0.2, 0)
        scene.rootNode.addChildNode(poleNode)

        // Top beam
        let topBeam = SCNBox(width: 2.0, height: 0.12, length: 0.12, chamferRadius: 0.02)
        topBeam.firstMaterial = woodMaterial()
        let topBeamNode = SCNNode(geometry: topBeam)
        topBeamNode.name = "scaffold_top"
        topBeamNode.position = SCNVector3(-0.2, 1.95, 0)
        scene.rootNode.addChildNode(topBeamNode)

        // Rope
        let rope = SCNCylinder(radius: 0.025, height: 0.5)
        rope.firstMaterial = ochreMaterial()
        let ropeNode = SCNNode(geometry: rope)
        ropeNode.name = "scaffold_rope"
        ropeNode.position = SCNVector3(0.6, 1.65, 0)
        scene.rootNode.addChildNode(ropeNode)

        // Body parts — hidden initially, revealed via name lookups
        // Head
        let head = SCNSphere(radius: 0.25)
        head.firstMaterial = parchmentMaterial()
        let headNode = SCNNode(geometry: head)
        headNode.name = "body_1"
        headNode.position = SCNVector3(0.6, 1.15, 0)
        headNode.isHidden = true
        scene.rootNode.addChildNode(headNode)

        // Body
        let body = SCNCylinder(radius: 0.06, height: 0.8)
        body.firstMaterial = parchmentMaterial()
        let bodyNode = SCNNode(geometry: body)
        bodyNode.name = "body_2"
        bodyNode.position = SCNVector3(0.6, 0.5, 0)
        bodyNode.isHidden = true
        scene.rootNode.addChildNode(bodyNode)

        // Left arm
        let lArm = SCNCylinder(radius: 0.04, height: 0.6)
        lArm.firstMaterial = parchmentMaterial()
        let lArmNode = SCNNode(geometry: lArm)
        lArmNode.name = "body_3"
        lArmNode.position = SCNVector3(0.25, 0.65, 0)
        lArmNode.eulerAngles = SCNVector3(0, 0, CGFloat.pi / 4)
        lArmNode.isHidden = true
        scene.rootNode.addChildNode(lArmNode)

        // Right arm
        let rArm = SCNCylinder(radius: 0.04, height: 0.6)
        rArm.firstMaterial = parchmentMaterial()
        let rArmNode = SCNNode(geometry: rArm)
        rArmNode.name = "body_4"
        rArmNode.position = SCNVector3(0.95, 0.65, 0)
        rArmNode.eulerAngles = SCNVector3(0, 0, -CGFloat.pi / 4)
        rArmNode.isHidden = true
        scene.rootNode.addChildNode(rArmNode)

        // Left leg
        let lLeg = SCNCylinder(radius: 0.04, height: 0.65)
        lLeg.firstMaterial = parchmentMaterial()
        let lLegNode = SCNNode(geometry: lLeg)
        lLegNode.name = "body_5"
        lLegNode.position = SCNVector3(0.35, -0.15, 0)
        lLegNode.eulerAngles = SCNVector3(0, 0, CGFloat.pi / 6)
        lLegNode.isHidden = true
        scene.rootNode.addChildNode(lLegNode)

        // Right leg
        let rLeg = SCNCylinder(radius: 0.04, height: 0.65)
        rLeg.firstMaterial = parchmentMaterial()
        let rLegNode = SCNNode(geometry: rLeg)
        rLegNode.name = "body_6"
        rLegNode.position = SCNVector3(0.85, -0.15, 0)
        rLegNode.eulerAngles = SCNVector3(0, 0, -CGFloat.pi / 6)
        rLegNode.isHidden = true
        scene.rootNode.addChildNode(rLegNode)

        return scene
    }

    /// Reveal hangman body part at stage (1-6)
    static func revealBodyPart(scene: SCNScene, stage: Int) {
        guard let part = scene.rootNode.childNode(withName: "body_\(stage)", recursively: false) else { return }
        part.isHidden = false
        part.opacity = 0
        part.scale = SCNVector3(0.5, 0.5, 0.5)
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.4
        part.opacity = 1
        part.scale = SCNVector3(1, 1, 1)
        SCNTransaction.commit()
    }

    // MARK: - Keyword Match 3D

    /// Terms and definitions as 3D stone plaques on left/right sides.
    static func makeKeywordMatchScene(keywords: [String], definitions: [String],
                                       termNames: inout [String: Int], defNames: inout [String: Int]) -> SCNScene {
        let scene = makeBaseScene()
        let count = min(keywords.count, definitions.count)

        // Adjust camera wider
        if let cam = scene.rootNode.childNode(withName: "camera", recursively: false) {
            cam.position = SCNVector3(0, 1.5, 10)
            cam.look(at: SCNVector3(0, 0.5, 0))
        }

        // Terms on left
        let spacing: CGFloat = 1.2
        let startY = CGFloat(count - 1) * spacing / 2

        for i in 0..<count {
            let plaque = SCNBox(width: 2.8, height: 0.7, length: 0.15, chamferRadius: 0.05)
            plaque.firstMaterial = stoneMaterial()
            let node = SCNNode(geometry: plaque)
            let name = "term_\(i)"
            node.name = name
            node.position = SCNVector3(-2.5, startY - CGFloat(i) * spacing, 0)
            scene.rootNode.addChildNode(node)
            termNames[name] = i

            let label = makeTextNode(keywords[i], size: 0.18)
            label.position = SCNVector3(0, 0, 0.1)
            node.addChildNode(label)
        }

        // Definitions on right (shuffled order stored externally)
        for i in 0..<count {
            let plaque = SCNBox(width: 2.8, height: 0.7, length: 0.15, chamferRadius: 0.05)
            plaque.firstMaterial = terracottaMaterial()
            let node = SCNNode(geometry: plaque)
            let name = "def_\(i)"
            node.name = name
            node.position = SCNVector3(2.5, startY - CGFloat(i) * spacing, 0)
            scene.rootNode.addChildNode(node)
            defNames[name] = i

            let label = makeTextNode(definitions[i], size: 0.13)
            label.position = SCNVector3(0, 0, 0.1)
            node.addChildNode(label)
        }

        return scene
    }

    /// Draw golden thread between matched term and definition
    static func connectMatch(scene: SCNScene, termName: String, defName: String) {
        guard let termNode = scene.rootNode.childNode(withName: termName, recursively: false),
              let defNode = scene.rootNode.childNode(withName: defName, recursively: false) else { return }

        // Gold glow on both
        termNode.geometry?.firstMaterial = goldMaterial()
        defNode.geometry?.firstMaterial = goldMaterial()

        // Golden connecting line
        let from = termNode.position
        let to = defNode.position
        let dx = to.x - from.x
        let dy = to.y - from.y
        let length = sqrt(dx * dx + dy * dy)

        let line = SCNCylinder(radius: 0.025, height: length)
        line.firstMaterial = goldMaterial()
        let lineNode = SCNNode(geometry: line)
        lineNode.position = SCNVector3((from.x + to.x) / 2, (from.y + to.y) / 2, 0.1)
        lineNode.eulerAngles.z = atan2(dy, dx) - CGFloat.pi / 2
        scene.rootNode.addChildNode(lineNode)

        // Sparkle on term
        let sparkle = goldSparkleParticles()
        termNode.addParticleSystem(sparkle)
    }

    // MARK: - Multiple Choice 3D

    /// Question on a scroll banner, options as stone tablets.
    static func makeMultipleChoiceScene(question: String, options: [String],
                                         optionNames: inout [String: Int]) -> SCNScene {
        let scene = makeBaseScene()

        // Scroll/banner at top
        let banner = SCNBox(width: 5.5, height: 0.9, length: 0.08, chamferRadius: 0.05)
        banner.firstMaterial = parchmentMaterial()
        let bannerNode = SCNNode(geometry: banner)
        bannerNode.name = "banner"
        bannerNode.position = SCNVector3(0, 2.2, 0)
        scene.rootNode.addChildNode(bannerNode)

        let qLabel = makeTextNode(question, size: 0.16)
        qLabel.position = SCNVector3(0, 0, 0.06)
        bannerNode.addChildNode(qLabel)

        // Option tablets
        let spacing: CGFloat = 1.1
        let startY = CGFloat(options.count - 1) * spacing / 2 - 0.2

        for (i, option) in options.enumerated() {
            let tablet = SCNBox(width: 4.5, height: 0.75, length: 0.12, chamferRadius: 0.04)
            tablet.firstMaterial = stoneMaterial()
            let node = SCNNode(geometry: tablet)
            let name = "option_\(i)"
            node.name = name
            node.position = SCNVector3(0, startY - CGFloat(i) * spacing, 0)
            scene.rootNode.addChildNode(node)
            optionNames[name] = i

            let label = makeTextNode(option, size: 0.15)
            label.position = SCNVector3(0, 0, 0.08)
            node.addChildNode(label)
        }

        return scene
    }

    // MARK: - True/False 3D

    /// Statement on central plaque, two large stone buttons.
    static func makeTrueFalseScene(statement: String) -> SCNScene {
        let scene = makeBaseScene()

        // Statement plaque
        let plaque = SCNBox(width: 5, height: 1.2, length: 0.1, chamferRadius: 0.06)
        plaque.firstMaterial = parchmentMaterial()
        let plaqueNode = SCNNode(geometry: plaque)
        plaqueNode.name = "statement"
        plaqueNode.position = SCNVector3(0, 1.5, 0)
        scene.rootNode.addChildNode(plaqueNode)

        let stmtLabel = makeTextNode(statement, size: 0.14)
        stmtLabel.position = SCNVector3(0, 0, 0.08)
        plaqueNode.addChildNode(stmtLabel)

        // TRUE button — left, green-tinted stone
        let trueBox = SCNBox(width: 2.2, height: 1.5, length: 0.6, chamferRadius: 0.1)
        trueBox.firstMaterial = sageMaterial()
        let trueNode = SCNNode(geometry: trueBox)
        trueNode.name = "true_btn"
        trueNode.position = SCNVector3(-1.8, -0.5, 0)
        scene.rootNode.addChildNode(trueNode)

        let trueLabel = makeTextNode("TRUE", size: 0.3, color: PlatformColor.white)
        trueLabel.position = SCNVector3(0, 0, 0.35)
        trueNode.addChildNode(trueLabel)

        // FALSE button — right, red-tinted stone
        let falseBox = SCNBox(width: 2.2, height: 1.5, length: 0.6, chamferRadius: 0.1)
        falseBox.firstMaterial = terracottaMaterial()
        let falseNode = SCNNode(geometry: falseBox)
        falseNode.name = "false_btn"
        falseNode.position = SCNVector3(1.8, -0.5, 0)
        scene.rootNode.addChildNode(falseNode)

        let falseLabel = makeTextNode("FALSE", size: 0.3, color: PlatformColor.white)
        falseLabel.position = SCNVector3(0, 0, 0.35)
        falseNode.addChildNode(falseLabel)

        return scene
    }

    // MARK: - Animation Helpers

    /// Shake a node side-to-side (wrong answer)
    static func shakeNode(_ node: SCNNode) {
        let shake = CAKeyframeAnimation(keyPath: "position.x")
        let center = node.position.x
        shake.values = [center, center - 0.15, center + 0.15, center - 0.1, center + 0.1, center]
        shake.keyTimes = [0, 0.15, 0.35, 0.55, 0.75, 1.0]
        shake.duration = 0.4
        node.addAnimation(shake, forKey: "shake")
    }

    /// Flash a node's material red briefly
    static func flashRed(_ node: SCNNode) {
        let origMat = node.geometry?.firstMaterial?.copy() as? SCNMaterial
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.15
        node.geometry?.firstMaterial = errorMaterial()
        SCNTransaction.commit()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.2
            node.geometry?.firstMaterial = origMat ?? stoneMaterial()
            SCNTransaction.commit()
        }
    }

    /// Flash a node gold (correct answer)
    static func flashGold(_ node: SCNNode) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.3
        node.geometry?.firstMaterial = goldMaterial()
        SCNTransaction.commit()

        // Add sparkle particles
        node.addParticleSystem(goldSparkleParticles())
    }

    /// Sink a node downward and fade out
    static func sinkNode(_ node: SCNNode) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        SCNTransaction.completionBlock = { node.isHidden = true }
        node.position.y -= 2
        node.opacity = 0
        SCNTransaction.commit()
    }

    /// Rise a node upward with gold glow
    static func riseNode(_ node: SCNNode) {
        flashGold(node)
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.6
        node.position.y += 1.5
        SCNTransaction.commit()
    }

    // MARK: - Utility

    private static func generateSpreadPositions(count: Int, yBase: CGFloat, xRange: ClosedRange<CGFloat>, zRange: ClosedRange<CGFloat>) -> [SCNVector3] {
        var positions: [SCNVector3] = []
        let cols = min(count, 3)
        let rows = (count + cols - 1) / cols
        let xStep = (xRange.upperBound - xRange.lowerBound) / CGFloat(cols + 1)
        let yStep: CGFloat = 1.0

        for i in 0..<count {
            let col = i % cols
            let row = i / cols
            let x = xRange.lowerBound + xStep * CGFloat(col + 1) + CGFloat.random(in: -0.2...0.2)
            let y = yBase + CGFloat(rows / 2 - row) * yStep + CGFloat.random(in: -0.15...0.15)
            let z = CGFloat.random(in: zRange)
            positions.append(SCNVector3(x, y, z))
        }
        return positions
    }
}

// MARK: - Platform Font Alias

#if os(macOS)
typealias PlatformFont = NSFont
#else
typealias PlatformFont = UIFont
#endif
