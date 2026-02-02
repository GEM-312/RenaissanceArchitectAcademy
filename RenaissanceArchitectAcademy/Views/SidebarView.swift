import SwiftUI

struct SidebarView: View {
    @Binding var selectedEra: Era?
    var onBackToMenu: () -> Void

    var body: some View {
        List(selection: $selectedEra) {
            Section {
                Button(action: { selectedEra = nil }) {
                    Label("All Buildings", systemImage: "building.2")
                }
                .listRowBackground(
                    selectedEra == nil ? RenaissanceColors.ochre.opacity(0.2) : Color.clear
                )
            }

            Section("Eras") {
                ForEach(Era.allCases, id: \.self) { era in
                    Button(action: { selectedEra = era }) {
                        Label {
                            Text(era.rawValue)
                        } icon: {
                            Image(systemName: era.iconName)
                        }
                    }
                    .listRowBackground(
                        selectedEra == era ? RenaissanceColors.ochre.opacity(0.2) : Color.clear
                    )
                }
            }

            Section {
                Button(action: onBackToMenu) {
                    Label("Main Menu", systemImage: "house")
                }
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
        SidebarView(selectedEra: .constant(nil), onBackToMenu: {})
    } detail: {
        Text("Detail")
    }
}
