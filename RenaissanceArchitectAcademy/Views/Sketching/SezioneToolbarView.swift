import SwiftUI

/// Layer-based toolbar for the Sezione (cross-section) canvas.
/// Shows layer progress dots + active layer tools + undo button.
struct SezioneToolbarView: View {
    let activeLayer: SezioneLayer
    let completedLayers: Set<SezioneLayer>
    let onUndo: () -> Void
    let onAdvanceLayer: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            // Layer progress dots
            HStack(spacing: 16) {
                ForEach(SezioneLayer.allCases, id: \.self) { layer in
                    layerDot(layer)
                }
            }

            // Toolbar buttons
            HStack(spacing: 12) {
                // Layer label
                HStack(spacing: 6) {
                    Image(systemName: activeLayer.iconName)
                        .font(.system(size: 14))
                    Text(activeLayer.displayName)
                        .font(.custom("EBGaramond-SemiBold", size: 14))
                }
                .foregroundStyle(RenaissanceColors.renaissanceBlue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(RenaissanceColors.renaissanceBlue.opacity(0.12))
                )

                Spacer()

                // Undo
                Button(action: onUndo) {
                    VStack(spacing: 2) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 16))
                        Text("Undo")
                            .font(.custom("EBGaramond-Regular", size: 10))
                    }
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                    .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)

                // Advance layer button (when current layer is complete)
                if completedLayers.contains(activeLayer),
                   activeLayer != .loadPaths {
                    Button(action: onAdvanceLayer) {
                        HStack(spacing: 4) {
                            Text("Next Layer")
                                .font(.custom("EBGaramond-SemiBold", size: 14))
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(RenaissanceColors.sageGreen)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(RenaissanceColors.parchment)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(RenaissanceColors.sepiaInk.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private func layerDot(_ layer: SezioneLayer) -> some View {
        let isComplete = completedLayers.contains(layer)
        let isActive = layer == activeLayer
        let isPending = !isComplete && !isActive

        return VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(isComplete ? RenaissanceColors.sageGreen :
                          isActive ? RenaissanceColors.renaissanceBlue :
                          RenaissanceColors.stoneGray.opacity(0.3))
                    .frame(width: 24, height: 24)

                if isComplete {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Image(systemName: layer.iconName)
                        .font(.system(size: 10))
                        .foregroundStyle(isActive ? .white : RenaissanceColors.sepiaInk.opacity(0.4))
                }
            }

            Text(layer.displayName)
                .font(.custom("EBGaramond-Regular", size: 9))
                .foregroundStyle(isPending ? RenaissanceColors.sepiaInk.opacity(0.4) :
                                 RenaissanceColors.sepiaInk)
        }
    }
}
