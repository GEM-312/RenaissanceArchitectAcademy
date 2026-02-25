import SwiftUI

/// Router that selects the correct animated math diagram based on MathVisualType
struct MathVisualView: View {
    let visual: LessonMathVisual
    @Binding var currentStep: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            Text(visual.title)
                .font(.custom("EBGaramond-SemiBold", size: 22))
                .foregroundStyle(RenaissanceColors.sepiaInk)

            // Science badge
            HStack(spacing: 4) {
                if let imageName = visual.science.customImageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                } else {
                    Image(systemName: visual.science.sfSymbolName)
                        .font(.custom("EBGaramond-Regular", size: 11, relativeTo: .caption))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                }
                Text(visual.science.rawValue)
                    .font(.custom("EBGaramond-Regular", size: 11))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(RenaissanceColors.ochre.opacity(0.1))
            )

            // Diagram — route to correct visual
            diagramView

            // Caption
            Text(visual.caption)
                .font(.custom("EBGaramond-Regular", size: 14))
                .foregroundStyle(RenaissanceColors.sepiaInk)
                .lineSpacing(2)

            // Step dots + Next Step button
            HStack {
                // Step dots
                HStack(spacing: 6) {
                    ForEach(1...visual.totalSteps, id: \.self) { step in
                        Circle()
                            .fill(step <= currentStep
                                  ? RenaissanceColors.ochre
                                  : RenaissanceColors.ochre.opacity(0.2))
                            .frame(width: 8, height: 8)
                    }
                }

                Spacer()

                // Next Step button
                if currentStep < visual.totalSteps {
                    Button {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentStep += 1
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text("Next Step")
                                .font(.custom("EBGaramond-SemiBold", size: 14))
                            Image(systemName: "chevron.right")
                                .font(.custom("EBGaramond-SemiBold", size: 12, relativeTo: .caption))
                        }
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(RenaissanceColors.ochre.opacity(0.1))
                        )
                        .borderCard(radius: 10)
                    }
                    .buttonStyle(.plain)
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.custom("EBGaramond-Regular", size: 14, relativeTo: .footnote))
                            .foregroundStyle(RenaissanceColors.sageGreen)
                        Text("Complete")
                            .font(.custom("EBGaramond-SemiBold", size: 14))
                            .foregroundStyle(RenaissanceColors.sageGreen)
                    }
                }
            }
        }
    }

    // MARK: - Diagram Router

    @ViewBuilder
    private var diagramView: some View {
        switch visual.type {

        // ── Aqueduct (custom) ──
        case .aqueductGradient:
            GradientSlopeVisual(currentStep: $currentStep)
        case .aqueductFlowRate:
            FlowRateVisual(currentStep: $currentStep)

        // ── Colosseum ──
        case .colosseumArchForce:
            ForceArrowVisual(currentStep: $currentStep, config: .init(
                structureName: "arch", downForce: "Weight pushes down",
                upForce: "Foundations push up", sideForces: "Compression spreads sideways",
                resultText: "Forces flow through the arch into the ground"
            ))
        case .colosseumSoundWave:
            GraphCurveVisual(currentStep: $currentStep, config: .init(
                xLabel: "Distance (m)", yLabel: "Sound Level (dB)",
                curveType: .sine, peakLabel: "Resonance peaks",
                formulaText: "Sound reflects off curved walls",
                resultText: "The bowl shape focuses sound to every seat"
            ))

        // ── Roman Baths ──
        case .bathsHeatTransfer:
            FlowCycleVisual(currentStep: $currentStep, config: .init(
                stages: ["Fire", "Hot Air", "Floor", "Room"],
                inputLabel: "Heat from furnace", outputLabel: "Warm air rises",
                centerLabel: "Hypocaust", resultText: "Hot air flows under raised floors, heating the room above"
            ))
        case .bathsWaterVolume:
            RatioDiagramVisual(currentStep: $currentStep, config: .init(
                leftLabel: "Depth", rightLabel: "Length × Width",
                leftValue: "1.5 m", rightValue: "10 × 5 m",
                ratio: "V = 75 m³", structureIcon: "drop.fill",
                resultText: "Volume = length × width × depth = 75 cubic meters"
            ))

        // ── Pantheon ──
        case .pantheonDomeGeometry:
            GeometryDiagramVisual(currentStep: $currentStep, config: .init(
                shapeType: .hemisphere,
                measurements: [("Radius", "21.7 m"), ("Height = Radius", "21.7 m")],
                formulaText: "Perfect hemisphere: h = r",
                resultText: "A perfect sphere fits inside — height equals radius"
            ))
        case .pantheonOculusLight:
            GeometryDiagramVisual(currentStep: $currentStep, config: .init(
                shapeType: .circle,
                measurements: [("Oculus diameter", "8.7 m"), ("Light angle", "varies by hour")],
                formulaText: "Sunlight enters at angle θ",
                resultText: "The oculus acts as a sundial — light moves across the floor"
            ))

        // ── Roman Roads ──
        case .roadsLayerCross:
            LayerStackVisual(currentStep: $currentStep, config: .init(
                layers: [
                    ("Statumen (foundation stones)", 0.3, RenaissanceColors.stoneGray),
                    ("Rudus (gravel + lime)", 0.25, RenaissanceColors.warmBrown),
                    ("Nucleus (fine cement)", 0.2, RenaissanceColors.ochre),
                    ("Summa Crusta (paving stones)", 0.15, RenaissanceColors.terracotta)
                ],
                totalLabel: "Total: ~1.5 m deep",
                resultText: "Four layers made roads last 2,000+ years"
            ))
        case .roadsLoadDistribution:
            ForceArrowVisual(currentStep: $currentStep, config: .init(
                structureName: "road surface", downForce: "Cart: 500 kg",
                upForce: "Ground reaction", sideForces: "Weight spreads through layers",
                resultText: "Crowned surface + layers distribute weight evenly"
            ))

        // ── Harbor ──
        case .harborBuoyancy:
            ForceArrowVisual(currentStep: $currentStep, config: .init(
                structureName: "ship hull", downForce: "Weight: 200 tons",
                upForce: "Buoyancy: 200 tons", sideForces: "Displaced water = ship weight",
                resultText: "Archimedes: an object floats when it displaces its own weight in water"
            ))
        case .harborTidalForce:
            GraphCurveVisual(currentStep: $currentStep, config: .init(
                xLabel: "Time (hours)", yLabel: "Force (kN)",
                curveType: .sine, peakLabel: "Peak wave force",
                formulaText: "F = ½ρv²A (wave pressure)",
                resultText: "Breakwaters must resist rhythmic wave forces"
            ))

        // ── Siege Workshop ──
        case .siegeProjectile:
            GraphCurveVisual(currentStep: $currentStep, config: .init(
                xLabel: "Distance (m)", yLabel: "Height (m)",
                curveType: .parabola, peakLabel: "Max height: 45 m",
                formulaText: "h = v₀t − ½gt²",
                resultText: "A 45° launch angle maximizes range"
            ))
        case .siegeLeverArm:
            MechanismVisual(currentStep: $currentStep, config: .init(
                mechanismType: .lever, inputLabel: "Effort: 50 kg",
                outputLabel: "Load: 200 kg", advantageLabel: "MA = 4×",
                formulaText: "Effort × distance = Load × distance",
                resultText: "A longer effort arm means less force needed"
            ))

        // ── Insula ──
        case .insulaFloorLoading:
            LayerStackVisual(currentStep: $currentStep, config: .init(
                layers: [
                    ("Ground floor (shops)", 0.3, RenaissanceColors.warmBrown),
                    ("2nd floor (wealthy)", 0.25, RenaissanceColors.ochre),
                    ("3rd floor", 0.2, RenaissanceColors.terracotta),
                    ("4th floor", 0.15, RenaissanceColors.stoneGray),
                    ("5th floor (poorest)", 0.1, RenaissanceColors.stoneGray)
                ],
                totalLabel: "~20 m tall",
                resultText: "Each floor adds weight — ground walls must support everything above"
            ))
        case .insulaHeightRatio:
            RatioDiagramVisual(currentStep: $currentStep, config: .init(
                leftLabel: "Height", rightLabel: "Base width",
                leftValue: "20 m", rightValue: "6 m",
                ratio: "3.3 : 1", structureIcon: "building.fill",
                resultText: "Augustus limited insulae to 20 m — too tall and they collapsed"
            ))

        // ── Duomo ──
        case .duomoCurvature:
            GeometryDiagramVisual(currentStep: $currentStep, config: .init(
                shapeType: .hemisphere,
                measurements: [("Inner shell", "44 m span"), ("Outer shell", "adds rigidity")],
                formulaText: "Double shell = strength without weight",
                resultText: "Brunelleschi's double dome: inner + outer shell with herringbone bricks"
            ))
        case .duomoForceRing:
            ForceArrowVisual(currentStep: $currentStep, config: .init(
                structureName: "dome ring", downForce: "Dome weight: 37,000 tons",
                upForce: "Stone + iron chains resist", sideForces: "Compression ring holds dome closed",
                resultText: "Horizontal chains + herringbone bricks prevent the dome from spreading"
            ))

        // ── Botanical Garden ──
        case .gardenPhotosynthesis:
            FlowCycleVisual(currentStep: $currentStep, config: .init(
                stages: ["Sunlight", "CO₂ absorbed", "Water uptake", "Glucose made"],
                inputLabel: "CO₂ + H₂O", outputLabel: "C₆H₁₂O₆ + O₂",
                centerLabel: "Chlorophyll", resultText: "6CO₂ + 6H₂O + light → C₆H₁₂O₆ + 6O₂"
            ))
        case .gardenGrowthRate:
            GraphCurveVisual(currentStep: $currentStep, config: .init(
                xLabel: "Months", yLabel: "Height (cm)",
                curveType: .exponential, peakLabel: "Mature height",
                formulaText: "Growth = nutrients × sunlight × water",
                resultText: "Plants grow fastest when young, then plateau at maturity"
            ))

        // ── Glassworks ──
        case .glassTemperature:
            GraphCurveVisual(currentStep: $currentStep, config: .init(
                xLabel: "Temperature (°C)", yLabel: "Viscosity",
                curveType: .exponential, peakLabel: "Working range: 700-1000°C",
                formulaText: "SiO₂ melts at 1,700°C → add soda to lower it",
                resultText: "Murano glass: silica + soda ash + lime, worked at 700-1000°C"
            ))
        case .glassRefraction:
            GeometryDiagramVisual(currentStep: $currentStep, config: .init(
                shapeType: .lens,
                measurements: [("Angle of incidence", "θ₁"), ("Angle of refraction", "θ₂")],
                formulaText: "n₁ sin θ₁ = n₂ sin θ₂ (Snell's law)",
                resultText: "Light bends when entering glass — this creates lenses and prisms"
            ))

        // ── Arsenal ──
        case .arsenalPulleySystem:
            MechanismVisual(currentStep: $currentStep, config: .init(
                mechanismType: .pulley, inputLabel: "Pull: 100 kg",
                outputLabel: "Lift: 400 kg", advantageLabel: "MA = 4×",
                formulaText: "More pulleys = less force needed",
                resultText: "Block and tackle: 4 pulleys lift 4× the weight"
            ))
        case .arsenalProductionRate:
            GraphCurveVisual(currentStep: $currentStep, config: .init(
                xLabel: "Workers", yLabel: "Ships per month",
                curveType: .linear, peakLabel: "16,000 workers → 1 ship/day",
                formulaText: "Assembly line: divide tasks = multiply output",
                resultText: "Venice's Arsenal built a full warship in a single day"
            ))

        // ── Anatomy Theater ──
        case .anatomyProportion:
            GeometryDiagramVisual(currentStep: $currentStep, config: .init(
                shapeType: .rectangle,
                measurements: [("Head:Body", "1:8 ratio"), ("Arm span", "= height")],
                formulaText: "Vitruvian proportions: arm span = height",
                resultText: "Leonardo measured: the ideal body fits in a circle and a square"
            ))
        case .anatomyCirculation:
            FlowCycleVisual(currentStep: $currentStep, config: .init(
                stages: ["Heart pumps", "Arteries carry", "Organs receive", "Veins return"],
                inputLabel: "Oxygenated blood", outputLabel: "Deoxygenated blood",
                centerLabel: "Heart", resultText: "Blood circulates in a loop — Harvey proved this in 1628"
            ))

        // ── Leonardo's Workshop ──
        case .leonardoGearRatio:
            MechanismVisual(currentStep: $currentStep, config: .init(
                mechanismType: .gear, inputLabel: "Driver: 12 teeth",
                outputLabel: "Driven: 36 teeth", advantageLabel: "3:1 ratio",
                formulaText: "Gear ratio = driven teeth / driver teeth",
                resultText: "A 3:1 ratio triples torque but reduces speed by ⅓"
            ))
        case .leonardoGoldenSpiral:
            GeometryDiagramVisual(currentStep: $currentStep, config: .init(
                shapeType: .spiral,
                measurements: [("Ratio", "φ = 1.618..."), ("a+b/a", "= a/b = φ")],
                formulaText: "φ = (1 + √5) / 2 ≈ 1.618",
                resultText: "The golden ratio appears in nature, art, and architecture"
            ))

        // ── Flying Machine ──
        case .flyingLiftFormula:
            ForceArrowVisual(currentStep: $currentStep, config: .init(
                structureName: "wing", downForce: "Weight (gravity)",
                upForce: "Lift (air pressure)", sideForces: "Drag slows forward motion",
                resultText: "Lift must exceed weight — Leonardo's wings were too heavy"
            ))
        case .flyingWingArea:
            RatioDiagramVisual(currentStep: $currentStep, config: .init(
                leftLabel: "Body weight", rightLabel: "Wing area",
                leftValue: "75 kg", rightValue: "15 m²",
                ratio: "5 kg/m²", structureIcon: "airplane",
                resultText: "Wing loading: a human needs ~15 m² of wing to glide"
            ))

        // ── Vatican Observatory ──
        case .observatoryMagnification:
            GeometryDiagramVisual(currentStep: $currentStep, config: .init(
                shapeType: .lens,
                measurements: [("Objective focal length", "100 cm"), ("Eyepiece focal length", "5 cm")],
                formulaText: "Magnification = f_objective / f_eyepiece",
                resultText: "100 cm / 5 cm = 20× magnification — Galileo saw Jupiter's moons"
            ))
        case .observatoryParallax:
            GeometryDiagramVisual(currentStep: $currentStep, config: .init(
                shapeType: .circle,
                measurements: [("Baseline", "Earth's orbit"), ("Shift angle", "< 1 arcsecond")],
                formulaText: "d = 1 / parallax angle (parsecs)",
                resultText: "Nearby stars shift against distant ones as Earth orbits the Sun"
            ))

        // ── Printing Press ──
        case .pressForceMultiplier:
            MechanismVisual(currentStep: $currentStep, config: .init(
                mechanismType: .press, inputLabel: "Turn: 5 kg force",
                outputLabel: "Press: 150 kg force", advantageLabel: "30× force",
                formulaText: "Screw converts rotation → linear pressure",
                resultText: "A screw press multiplies force 30× — enough to print cleanly"
            ))
        case .pressTypeSetting:
            RatioDiagramVisual(currentStep: $currentStep, config: .init(
                leftLabel: "Characters", rightLabel: "Pages/hour",
                leftValue: "~2,500", rightValue: "~20 pages",
                ratio: "vs. 1 page/day by hand", structureIcon: "book.fill",
                resultText: "Movable type: 20× faster than hand copying"
            ))
        }
    }
}
