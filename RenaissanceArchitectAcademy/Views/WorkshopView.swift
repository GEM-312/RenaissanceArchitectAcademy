import SwiftUI

/// Workshop mini-game — Township-style SpriteKit crafting experience
/// Da Vinci stick figure walks between resource stations, collects materials, crafts at workbench/furnace
struct WorkshopView: View {
    @State private var workshop = WorkshopState()

    var body: some View {
        WorkshopMapView(workshop: workshop)
            .onAppear { workshop.startRespawnTimer() }
            .onDisappear { workshop.stopRespawnTimer() }
    }
}

#Preview {
    WorkshopView()
}
