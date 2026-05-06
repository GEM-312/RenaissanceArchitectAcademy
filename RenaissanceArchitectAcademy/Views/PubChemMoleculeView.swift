import SwiftUI

// MARK: - Element Colors (CPK coloring convention)

extension ChemElement {
    /// Standard CPK molecular coloring
    var color: Color {
        switch self {
        case .hydrogen:  return Color.white
        case .carbon:    return Color(red: 0.3, green: 0.3, blue: 0.3)
        case .nitrogen:  return Color(red: 0.2, green: 0.4, blue: 0.9)
        case .oxygen:    return Color(red: 0.9, green: 0.15, blue: 0.15)
        case .sulfur:    return Color(red: 0.9, green: 0.85, blue: 0.2)
        case .phosphorus: return Color(red: 1.0, green: 0.5, blue: 0.0)
        case .calcium:   return Color(red: 0.3, green: 0.75, blue: 0.3)
        case .silicon:   return Color(red: 0.5, green: 0.6, blue: 0.7)
        case .aluminum:  return Color(red: 0.6, green: 0.65, blue: 0.7)
        case .iron:      return Color(red: 0.7, green: 0.45, blue: 0.15)
        case .sodium:    return Color(red: 0.65, green: 0.35, blue: 0.85)
        case .chlorine:  return Color(red: 0.1, green: 0.85, blue: 0.1)
        case .potassium: return Color(red: 0.55, green: 0.25, blue: 0.85)
        case .magnesium: return Color(red: 0.0, green: 0.65, blue: 0.0)
        case .fluorine:  return Color(red: 0.55, green: 0.85, blue: 0.25)
        case .copper:    return Color(red: 0.78, green: 0.5, blue: 0.2)
        case .zinc:      return Color(red: 0.5, green: 0.5, blue: 0.65)
        case .tin:       return Color(red: 0.4, green: 0.5, blue: 0.5)
        case .lead:      return Color(red: 0.35, green: 0.35, blue: 0.4)
        case .mercury:   return Color(red: 0.7, green: 0.7, blue: 0.8)
        case .gold:      return Color(red: 1.0, green: 0.82, blue: 0.14)
        case .silver:    return Color(red: 0.75, green: 0.75, blue: 0.78)
        case .unknown:   return Color(red: 0.85, green: 0.45, blue: 0.55)
        }
    }

    /// Atom radius scale (relative to hydrogen = 1.0)
    var radiusScale: CGFloat {
        switch self {
        case .hydrogen:  return 0.7
        case .carbon:    return 1.0
        case .nitrogen:  return 0.95
        case .oxygen:    return 0.9
        case .sulfur:    return 1.2
        case .calcium:   return 1.5
        case .silicon:   return 1.3
        case .iron:      return 1.3
        default:         return 1.1
        }
    }
}

// MARK: - PubChem Molecule View (animated)

/// Renders a PubChem molecule with colored atoms, animated bond drawing, and pulsing effects.
/// Designed to fade in during gameplay (e.g. cracks in quarry mini-game).
struct PubChemMoleculeView: View {

    let molecule: PubChemMolecule
    /// 0 → invisible, 1 → fully revealed
    var revealProgress: CGFloat = 1.0
    /// Continuous pulse for bonds (driven by parent timer)
    var bondPulse: CGFloat = 0

    private let baseAtomRadius: CGFloat = 16

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // Layer 1: Bonds (draw progressively)
                bondLayer(width: w, height: h)

                // Layer 2: Atoms (fade in after bonds)
                atomLayer(width: w, height: h)
            }
        }
    }

    // MARK: - Bond Layer

    /// Pre-computed bond segment for Canvas rendering
    private struct BondSegment {
        let from: CGPoint
        let to: CGPoint
        let alpha: Double
    }

    private func bondLayer(width: CGFloat, height: CGFloat) -> some View {
        let totalBonds = molecule.bonds.count
        let visibleCount = max(0, Int(CGFloat(totalBonds) * min(revealProgress * 1.5, 1.0)))
        let inset = baseAtomRadius * 0.8

        // Pre-compute all bond segments outside the Canvas closure
        var segments: [BondSegment] = []
        for i in 0..<visibleCount {
            let bond = molecule.bonds[i]
            let fromAtom = molecule.atoms[bond.from]
            let toAtom = molecule.atoms[bond.to]
            let rawFrom = CGPoint(x: fromAtom.x * width, y: fromAtom.y * height)
            let rawTo = CGPoint(x: toAtom.x * width, y: toAtom.y * height)
            let (f, t) = shortenLine(from: rawFrom, to: rawTo, inset: inset)
            let alpha = 0.5 + 0.3 * sin(bondPulse * .pi * 2 + Double(i) * 0.5)

            if bond.order == 2 {
                let (l1f, l1t, l2f, l2t) = offsetPair(from: f, to: t, offset: 3)
                segments.append(BondSegment(from: l1f, to: l1t, alpha: alpha))
                segments.append(BondSegment(from: l2f, to: l2t, alpha: alpha))
            } else if bond.order == 3 {
                segments.append(BondSegment(from: f, to: t, alpha: alpha))
                let (l1f, l1t, l2f, l2t) = offsetPair(from: f, to: t, offset: 4)
                segments.append(BondSegment(from: l1f, to: l1t, alpha: alpha))
                segments.append(BondSegment(from: l2f, to: l2t, alpha: alpha))
            } else {
                segments.append(BondSegment(from: f, to: t, alpha: alpha))
            }
        }

        return Canvas { context, _ in
            for seg in segments {
                drawAnimatedBond(context: context, from: seg.from, to: seg.to, alpha: seg.alpha)
            }
        }
        .frame(width: width, height: height)
    }

    private func drawAnimatedBond(context: GraphicsContext, from: CGPoint, to: CGPoint, alpha: Double) {
        // Glow layer
        var glowPath = Path()
        glowPath.move(to: from)
        glowPath.addLine(to: to)
        context.stroke(glowPath, with: .color(Color.white.opacity(alpha * 0.3)), lineWidth: 4)

        // Main bond line
        var path = Path()
        path.move(to: from)
        path.addLine(to: to)
        context.stroke(path, with: .color(RenaissanceColors.sepiaInk.opacity(alpha)), lineWidth: 2)
    }

    // MARK: - Atom Layer

    private func atomLayer(width: CGFloat, height: CGFloat) -> some View {
        let atomProgress = max(0, (revealProgress - 0.3) / 0.7)  // atoms start appearing at 30% reveal

        return ForEach(Array(molecule.atoms.enumerated()), id: \.element.id) { index, atom in
            let visible = CGFloat(index) / CGFloat(max(molecule.atoms.count - 1, 1)) < atomProgress
            let pos = CGPoint(x: atom.x * width, y: atom.y * height)
            let radius = baseAtomRadius * atom.element.radiusScale

            if visible {
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [atom.element.color.opacity(0.6), atom.element.color.opacity(0)],
                                center: .center,
                                startRadius: radius * 0.3,
                                endRadius: radius * 1.8
                            )
                        )
                        .frame(width: radius * 3.5, height: radius * 3.5)

                    // Atom sphere
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    atom.element.color.opacity(0.9),
                                    atom.element.color,
                                    atom.element.color.opacity(0.7)
                                ],
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: radius
                            )
                        )
                        .frame(width: radius * 2, height: radius * 2)
                        .overlay(
                            Circle()
                                .stroke(atom.element.color.opacity(0.4), lineWidth: 1)
                        )

                    // Element symbol
                    Text(atom.symbol)
                        .font(.custom("Cinzel-Bold", size: radius * 0.9))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.5), radius: 1)
                }
                .position(pos)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }

    // MARK: - Geometry Helpers

    private func shortenLine(from: CGPoint, to: CGPoint, inset: CGFloat) -> (CGPoint, CGPoint) {
        let dx = to.x - from.x
        let dy = to.y - from.y
        let len = sqrt(dx * dx + dy * dy)
        guard len > inset * 2 else { return (from, to) }
        let ux = dx / len
        let uy = dy / len
        return (
            CGPoint(x: from.x + ux * inset, y: from.y + uy * inset),
            CGPoint(x: to.x - ux * inset, y: to.y - uy * inset)
        )
    }

    private func offsetPair(from: CGPoint, to: CGPoint, offset: CGFloat) -> (CGPoint, CGPoint, CGPoint, CGPoint) {
        let dx = to.x - from.x
        let dy = to.y - from.y
        let len = sqrt(dx * dx + dy * dy)
        guard len > 0 else { return (from, to, from, to) }
        let nx = -dy / len * offset
        let ny = dx / len * offset
        return (
            CGPoint(x: from.x + nx, y: from.y + ny),
            CGPoint(x: to.x + nx, y: to.y + ny),
            CGPoint(x: from.x - nx, y: from.y - ny),
            CGPoint(x: to.x - nx, y: to.y - ny)
        )
    }
}

// MARK: - Molecule Info Card

/// Shows molecule name, formula, and educational text below the structure
struct MoleculeInfoCard: View {
    let molecule: PubChemMolecule
    var show: Bool = true

    var body: some View {
        if show {
            VStack(spacing: 4) {
                Text(molecule.formula)
                    .font(.custom("Cinzel-Bold", size: 18))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                Text(molecule.name)
                    .font(.custom("EBGaramond-Italic", size: 14))
                    .foregroundStyle(RenaissanceColors.warmBrown)
                if !molecule.educationalText.isEmpty {
                    Text(molecule.educationalText)
                        .font(RenaissanceFont.footnoteSmall)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(RenaissanceColors.parchment.opacity(0.9))
            )
            .transition(.opacity.combined(with: .move(edge: .bottom)))
        }
    }
}
