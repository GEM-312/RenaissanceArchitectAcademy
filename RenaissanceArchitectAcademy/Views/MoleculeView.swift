import SwiftUI

// MARK: - Atom Font Size

/// Fixed font size for all atom labels — same as formula text
private let atomFontSize: CGFloat = 22

// MARK: - AtomLabel

/// Text-only atom label with optional superscript charge
struct AtomLabel: View {
    let atom: MoleculeAtom
    let position: CGPoint

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Text(atom.symbol)
                .font(.custom("Mulish-Light", size: atomFontSize))
                .foregroundColor(RenaissanceColors.sepiaInk)

            if let charge = atom.charge {
                Text(charge)
                    .font(.custom("Mulish-Light", size: atomFontSize * 0.5))
                    .foregroundColor(RenaissanceColors.sepiaInk)
                    .baselineOffset(atomFontSize * 0.35)
            }
        }
        .position(position)
    }
}

// MARK: - BondLineView

/// Sepia bond lines — all solid, consistent style
struct BondLineView: View {
    let bonds: [MoleculeBond]
    let atoms: [MoleculeAtom]
    let size: CGSize

    /// Fixed inset — bonds stop this far from atom center
    private let atomInset: CGFloat = 16

    var body: some View {
        Canvas { context, _ in
            for bond in bonds {
                let rawFrom = pixelPos(atoms[bond.fromAtomIndex].position)
                let rawTo = pixelPos(atoms[bond.toAtomIndex].position)
                let (from, to) = shortenLine(from: rawFrom, to: rawTo, inset: atomInset)

                switch bond.bondType {
                case .single, .ionic:
                    drawBond(context: context, from: from, to: to)
                case .double:
                    let (l1f, l1t, l2f, l2t) = offsetPair(from: from, to: to, offset: 3)
                    drawBond(context: context, from: l1f, to: l1t)
                    drawBond(context: context, from: l2f, to: l2t)
                case .triple:
                    drawBond(context: context, from: from, to: to)
                    let (l1f, l1t, l2f, l2t) = offsetPair(from: from, to: to, offset: 4)
                    drawBond(context: context, from: l1f, to: l1t)
                    drawBond(context: context, from: l2f, to: l2t)
                }
            }
        }
        .frame(width: size.width, height: size.height)
    }

    private func pixelPos(_ p: CGPoint) -> CGPoint {
        CGPoint(x: p.x * size.width, y: p.y * size.height)
    }

    /// Shorten a line from both ends so it doesn't overlap atom text
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

    private func drawBond(context: GraphicsContext, from: CGPoint, to: CGPoint) {
        var path = Path()
        path.move(to: from)
        path.addLine(to: to)
        context.stroke(path, with: .color(RenaissanceColors.sepiaInk.opacity(0.5)), lineWidth: 1.5)
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

// MARK: - BenzeneRingOverlay

struct BenzeneRingOverlay: View {
    let center: CGPoint
    let radius: CGFloat

    var body: some View {
        Circle()
            .stroke(
                RenaissanceColors.sepiaInk.opacity(0.3),
                style: StrokeStyle(lineWidth: 1, dash: [4, 3])
            )
            .frame(width: radius * 2, height: radius * 2)
            .position(center)
    }
}

// MARK: - MoleculeCanvas

struct MoleculeCanvas: View {
    let molecule: MoleculeData
    let bondProgress: CGFloat
    let atomProgress: CGFloat

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                let visibleBonds = max(0, Int(CGFloat(molecule.bonds.count) * bondProgress))
                BondLineView(
                    bonds: Array(molecule.bonds.prefix(visibleBonds)),
                    atoms: molecule.atoms,
                    size: geo.size
                )

                if molecule.formula == "C\u{2086}H\u{2086}" {
                    BenzeneRingOverlay(
                        center: CGPoint(x: w * 0.5, y: h * 0.45),
                        radius: w * 0.14
                    )
                    .opacity(Double(bondProgress))
                }

                let visibleAtoms = max(0, Int(CGFloat(molecule.atoms.count) * atomProgress))
                ForEach(0..<visibleAtoms, id: \.self) { i in
                    let atom = molecule.atoms[i]
                    AtomLabel(
                        atom: atom,
                        position: CGPoint(x: atom.position.x * w, y: atom.position.y * h)
                    )
                }
            }
        }
    }
}

// MARK: - MoleculeView

/// Molecule structural diagram — text labels with ion charges, matching formula font
struct MoleculeView: View {
    let molecule: MoleculeData
    var showLabel: Bool = true
    var animate: Bool = true

    @State private var bondProgress: CGFloat = 0
    @State private var atomProgress: CGFloat = 0
    @State private var appeared = false

    private var currentBondProgress: CGFloat {
        appeared ? 1 : (animate ? bondProgress : 1)
    }

    private var currentAtomProgress: CGFloat {
        appeared ? 1 : (animate ? atomProgress : 1)
    }

    var body: some View {
        VStack(spacing: 8) {
            MoleculeCanvas(
                molecule: molecule,
                bondProgress: currentBondProgress,
                atomProgress: currentAtomProgress
            )

            if showLabel {
                formulaLabel
            }
        }
        .padding(16)
        .onAppear(perform: animateIn)
    }

    private var formulaLabel: some View {
        VStack(spacing: 2) {
            Text(molecule.formula)
                .font(.custom("Cinzel-Regular", size: 16))
                .foregroundColor(RenaissanceColors.sepiaInk)

            Text(molecule.name)
                .font(.custom("Mulish-Light", size: 13))
                .foregroundColor(RenaissanceColors.sepiaInk)
        }
    }

    private func animateIn() {
        guard animate else {
            appeared = true
            return
        }
        let bondDuration = 0.08 * Double(molecule.bonds.count)
        withAnimation(.easeInOut(duration: bondDuration)) {
            bondProgress = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + bondDuration + 0.1) {
            let atomDuration = 0.1 * Double(molecule.atoms.count)
            withAnimation(.spring(duration: atomDuration)) {
                atomProgress = 1
            }
        }
        let totalDuration = bondDuration + 0.1 + 0.1 * Double(molecule.atoms.count) + 0.2
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            appeared = true
        }
    }
}

// MARK: - Previews

#Preview("Calcium Hydroxide") {
    MoleculeView(molecule: .calciumHydroxide, animate: false)
        .frame(width: 360, height: 280)
        .padding()
        .background(RenaissanceColors.parchment)
}

#Preview("All Molecules") {
    ScrollView {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16),
        ], spacing: 16) {
            ForEach(Array(MoleculeData.all.enumerated()), id: \.offset) { _, molecule in
                MoleculeView(molecule: molecule, animate: false)
                    .frame(height: 260)
            }
        }
        .padding()
    }
    .background(RenaissanceColors.parchment)
}
