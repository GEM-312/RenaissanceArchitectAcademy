import SwiftUI

/// Navigation options in the sidebar
enum SidebarDestination: Hashable {
    case cityMap        // NEW: SpriteKit isometric city view
    case allBuildings   // Grid view of all buildings
    case era(Era)
    case profile
}

struct SidebarView: View {
    @Binding var selectedDestination: SidebarDestination?
    var onBackToMenu: () -> Void

    var body: some View {
        List {
            // City Map Section (NEW - SpriteKit view)
            Section {
                SidebarRow(
                    title: "City Map",
                    icon: "map.fill",
                    isSelected: selectedDestination == .cityMap
                ) {
                    selectedDestination = .cityMap
                }

                SidebarRow(
                    title: "All Buildings",
                    icon: "building.2",
                    isSelected: selectedDestination == .allBuildings
                ) {
                    selectedDestination = .allBuildings
                }
            } header: {
                Label("City", systemImage: "map")
                    .font(.caption)
                    .foregroundStyle(RenaissanceColors.warmBrown)
            }

            // Eras Section
            Section {
                ForEach(Era.allCases, id: \.self) { era in
                    SidebarRow(
                        title: era.rawValue,
                        icon: era.iconName,
                        isSelected: selectedDestination == .era(era)
                    ) {
                        selectedDestination = .era(era)
                    }
                }
            } header: {
                Label("Eras", systemImage: "clock.arrow.circlepath")
                    .font(.caption)
                    .foregroundStyle(RenaissanceColors.warmBrown)
            }

            // Profile Section
            Section {
                SidebarRow(
                    title: "Codex Personalis",
                    icon: "person.crop.circle.fill",
                    isSelected: selectedDestination == .profile
                ) {
                    selectedDestination = .profile
                }
            } header: {
                Label("Student", systemImage: "graduationcap")
                    .font(.caption)
                    .foregroundStyle(RenaissanceColors.warmBrown)
            }

            // Home
            Section {
                Button(action: onBackToMenu) {
                    HStack {
                        Image("NavHome")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                            .contrast(1.5)
                            .saturation(1)
                        Text("Home")
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                    }
                }
                .buttonStyle(.plain)
                #if os(macOS)
                .keyboardShortcut("m", modifiers: [.command])
                #endif
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Academy")
        #if os(macOS)
        .navigationSplitViewColumnWidth(min: 200, ideal: 250)
        #endif
        .scrollContentBackground(.hidden)
        .background(RenaissanceColors.parchment)
    }
}

/// Styled sidebar row with Renaissance aesthetic
struct SidebarRow: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(isSelected ? RenaissanceColors.ochre : RenaissanceColors.warmBrown)
                    .frame(width: 24)

                Text(title)
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .listRowBackground(
            isSelected
                ? RenaissanceColors.ochre.opacity(0.2)
                : Color.clear
        )
    }
}

// Add iconName to Era
extension Era {
    var iconName: String {
        switch self {
        case .ancientRome: return "building.columns"
        case .renaissance: return "paintpalette"
        }
    }
}

#Preview {
    NavigationSplitView {
        SidebarView(selectedDestination: .constant(.allBuildings), onBackToMenu: {})
    } detail: {
        Text("Detail")
    }
}
