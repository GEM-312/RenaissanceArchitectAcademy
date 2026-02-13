import SwiftUI

/// Workshop mini-game — outdoor gathering + indoor crafting
/// Outdoor: SpriteKit map where apprentice collects materials from resource stations
/// Indoor: Crafting room with workbench, furnace, pigment table, storage shelf
struct WorkshopView: View {
    var workshop: WorkshopState

    @State private var showInterior = false

    var body: some View {
        ZStack {
            if showInterior {
                WorkshopInteriorView(workshop: workshop) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showInterior = false
                    }
                }
                .transition(.move(edge: .trailing))
            } else {
                WorkshopMapView(workshop: workshop, onEnterInterior: {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showInterior = true
                    }
                })
                .transition(.move(edge: .leading))
            }
        }
        .onAppear { workshop.startRespawnTimer() }
        .onDisappear { workshop.stopRespawnTimer() }
    }
}

#Preview {
    WorkshopView(workshop: WorkshopState())
}
