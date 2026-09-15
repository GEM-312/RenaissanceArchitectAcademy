import SwiftUI

/// Brief animation showing the transition from 3D building to 2D drawing view.
///
/// For Pianta: a building silhouette "unfolds" into a floor plan view (roof lifts away).
/// For Sezione: a vertical slice reveals the cross-section view.
///
/// Auto-advances after 2.5 seconds. Shown between "Begin Drawing" and the teaching steps.
struct ViewTransitionAnimationView: View {
    let phaseType: SketchingPhaseType
    let buildingName: String
    let onComplete: () -> Void

    @State private var animationProgress: CGFloat = 0
    @State private var showLabel = false

    var body: some View {
        ZStack {
            RenaissanceColors.parchmentGradient
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Animated building silhouette
                animatedBuilding
                    .frame(width: 200, height: 200)

                // Phase label
                VStack(spacing: 6) {
                    Text(phaseType.italianTitle)
                        .font(.custom("Cinzel-Bold", size: 28))
                        .foregroundStyle(RenaissanceColors.sepiaInk)

                    Text(phaseType.displayName)
                        .font(RenaissanceFont.italic)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))

                    Text(buildingName)
                        .font(RenaissanceFont.bodySmall)
                        .foregroundStyle(RenaissanceColors.renaissanceBlue)
                }
                .opacity(showLabel ? 1 : 0)
                .offset(y: showLabel ? 0 : 10)

                Spacer()
            }
        }
        .onAppear {
            // Start animation sequence
            withAnimation(.easeInOut(duration: 1.5)) {
                animationProgress = 1.0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.8)) {
                showLabel = true
            }
            // Auto-advance after animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                onComplete()
            }
        }
    }

    // MARK: - Animated Building

    @ViewBuilder
    private var animatedBuilding: some View {
        Canvas { context, size in
            let cx = size.width / 2
            let cy = size.height / 2

            switch phaseType {
            case .pianta:
                drawPiantaTransition(context: context, size: size, cx: cx, cy: cy)
            case .sezione:
                drawSezioneTransition(context: context, size: size, cx: cx, cy: cy)
            }
        }
    }

    /// Pianta: roof lifts away to reveal floor plan outline
    private func drawPiantaTransition(context: GraphicsContext, size: CGSize, cx: CGFloat, cy: CGFloat) {
        let roofLift = animationProgress * 60
        let wallOpacity = 0.3 + animationProgress * 0.5

        // Building walls (stay in place)
        let wallRect = CGRect(x: cx - 50, y: cy - 30, width: 100, height: 80)
        let wallPath = Path(roundedRect: wallRect, cornerRadius: 2)
        context.stroke(wallPath, with: .color(RenaissanceColors.sepiaInk.opacity(wallOpacity)), lineWidth: 2)

        // Interior room divisions (fade in)
        if animationProgress > 0.3 {
            let roomOpacity = (animationProgress - 0.3) / 0.7 * 0.6
            var divider = Path()
            divider.move(to: CGPoint(x: cx, y: cy - 30))
            divider.addLine(to: CGPoint(x: cx, y: cy + 50))
            context.stroke(divider, with: .color(RenaissanceColors.renaissanceBlue.opacity(roomOpacity)),
                          style: StrokeStyle(lineWidth: 1, dash: [4, 3]))

            var hDivider = Path()
            hDivider.move(to: CGPoint(x: cx - 50, y: cy + 10))
            hDivider.addLine(to: CGPoint(x: cx + 50, y: cy + 10))
            context.stroke(hDivider, with: .color(RenaissanceColors.renaissanceBlue.opacity(roomOpacity)),
                          style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
        }

        // Roof triangle (lifts away)
        var roofPath = Path()
        roofPath.move(to: CGPoint(x: cx - 60, y: cy - 30 - roofLift))
        roofPath.addLine(to: CGPoint(x: cx, y: cy - 70 - roofLift))
        roofPath.addLine(to: CGPoint(x: cx + 60, y: cy - 30 - roofLift))
        roofPath.closeSubpath()
        let roofOpacity = max(0, 1.0 - animationProgress * 1.5)
        context.fill(roofPath, with: .color(RenaissanceColors.warmBrown.opacity(roofOpacity * 0.3)))
        context.stroke(roofPath, with: .color(RenaissanceColors.sepiaInk.opacity(roofOpacity)), lineWidth: 2)

        // "Eye" icon at top (viewing from above)
        if animationProgress > 0.5 {
            let eyeOpacity = (animationProgress - 0.5) / 0.5
            context.draw(
                Text(Image(systemName: "eye"))
                    .font(.system(size: 20))
                    .foregroundStyle(RenaissanceColors.renaissanceBlue.opacity(eyeOpacity)),
                at: CGPoint(x: cx, y: cy - 60)
            )
        }
    }

    /// Sezione: vertical slice reveals internal structure
    private func drawSezioneTransition(context: GraphicsContext, size: CGSize, cx: CGFloat, cy: CGFloat) {
        let sliceOffset = animationProgress * 40
        let revealOpacity = animationProgress * 0.6

        // Left half of building (slides left)
        var leftHalf = Path()
        leftHalf.move(to: CGPoint(x: cx - 50 - sliceOffset, y: cy + 50))
        leftHalf.addLine(to: CGPoint(x: cx - 50 - sliceOffset, y: cy - 30))
        leftHalf.addLine(to: CGPoint(x: cx - sliceOffset, y: cy - 60))
        leftHalf.addLine(to: CGPoint(x: cx - sliceOffset, y: cy + 50))
        leftHalf.closeSubpath()
        let halfOpacity = max(0.2, 1.0 - animationProgress * 0.7)
        context.fill(leftHalf, with: .color(RenaissanceColors.warmBrown.opacity(halfOpacity * 0.2)))
        context.stroke(leftHalf, with: .color(RenaissanceColors.sepiaInk.opacity(halfOpacity)), lineWidth: 2)

        // Right half of building (slides right)
        var rightHalf = Path()
        rightHalf.move(to: CGPoint(x: cx + sliceOffset, y: cy + 50))
        rightHalf.addLine(to: CGPoint(x: cx + sliceOffset, y: cy - 60))
        rightHalf.addLine(to: CGPoint(x: cx + 50 + sliceOffset, y: cy - 30))
        rightHalf.addLine(to: CGPoint(x: cx + 50 + sliceOffset, y: cy + 50))
        rightHalf.closeSubpath()
        context.fill(rightHalf, with: .color(RenaissanceColors.warmBrown.opacity(halfOpacity * 0.2)))
        context.stroke(rightHalf, with: .color(RenaissanceColors.sepiaInk.opacity(halfOpacity)), lineWidth: 2)

        // Cross-section reveal in the middle (fades in)
        if animationProgress > 0.2 {
            // Internal wall structure
            var innerWall = Path()
            innerWall.move(to: CGPoint(x: cx - 15, y: cy + 50))
            innerWall.addLine(to: CGPoint(x: cx - 15, y: cy - 20))
            innerWall.addLine(to: CGPoint(x: cx, y: cy - 45))
            innerWall.addLine(to: CGPoint(x: cx + 15, y: cy - 20))
            innerWall.addLine(to: CGPoint(x: cx + 15, y: cy + 50))
            context.stroke(innerWall, with: .color(RenaissanceColors.renaissanceBlue.opacity(revealOpacity)), lineWidth: 1.5)

            // Internal arch
            var arch = Path()
            arch.move(to: CGPoint(x: cx - 12, y: cy + 10))
            arch.addQuadCurve(to: CGPoint(x: cx + 12, y: cy + 10),
                             control: CGPoint(x: cx, y: cy - 10))
            context.stroke(arch, with: .color(RenaissanceColors.renaissanceBlue.opacity(revealOpacity)), lineWidth: 1.5)

            // Foundation line
            var foundation = Path()
            foundation.move(to: CGPoint(x: cx - 20, y: cy + 50))
            foundation.addLine(to: CGPoint(x: cx + 20, y: cy + 50))
            context.stroke(foundation, with: .color(RenaissanceColors.warmBrown.opacity(revealOpacity)), lineWidth: 3)
        }

        // Scissors icon
        if animationProgress > 0.5 {
            let iconOpacity = (animationProgress - 0.5) / 0.5
            context.draw(
                Text(Image(systemName: "scissors"))
                    .font(.system(size: 20))
                    .foregroundStyle(RenaissanceColors.renaissanceBlue.opacity(iconOpacity)),
                at: CGPoint(x: cx, y: cy - 75)
            )
        }
    }
}
