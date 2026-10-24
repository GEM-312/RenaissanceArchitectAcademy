import SpriteKit

/// Tap target for a signpost at the edge of an outdoor Workshop area. Walking to it
/// loads the area it points to.
///
/// The signpost is painted into the terrain, so — like `ResourceNode` with
/// `hideSprites` — this is an invisible hit circle plus a name pill.
/// Deliberately not a `ResourceStationType` case: that enum is switched on across
/// materials, tools, sounds, Game Center and knowledge cards, none of which apply here.
class AreaExitNode: SKNode {

    let exit: WorkshopAreaExit

    init(exit: WorkshopAreaExit, label: String) {
        self.exit = exit
        super.init()

        // Same invisible hit area as a hidden-sprite station
        let hitArea = SKShapeNode(circleOfRadius: 80)
        hitArea.fillColor = .clear
        hitArea.strokeColor = .clear
        addChild(hitArea)

        // Same pill as the station labels
        addChild(SKNode.makePillLabel(
            text: label,
            fontSize: 28,
            position: CGPoint(x: 0, y: -140),
            zPosition: 9
        ))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
