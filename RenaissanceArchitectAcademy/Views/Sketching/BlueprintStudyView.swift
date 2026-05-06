import SwiftUI

/// Full-page scrollable blueprint reader for iPhone + macOS.
///
/// iPhone has no Apple Pencil and a small screen — sketching with a finger
/// on a tiny canvas is bad UX, so on compact size classes we present a
/// read-only study experience instead. The "Mark as Studied" button grants
/// the same completion credit as finishing a sketch on iPad.
struct BlueprintStudyView: View {
    let phaseData: PiantaPhaseData
    let buildingName: String
    var notebookState: NotebookState? = nil
    var buildingId: Int? = nil
    let onComplete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var zoom: CGFloat = 1.0
    @State private var savedToastVisible = false

    var body: some View {
        ZStack(alignment: .bottom) {
            RenaissanceColors.parchment.ignoresSafeArea()

            if savedToastVisible {
                VStack {
                    savedToast
                    Spacer()
                }
                .zIndex(5)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    blueprintImage
                    card(title: "Pianta: Floor Plan", body: phaseData.hint ?? "")
                        .opacity(phaseData.hint == nil ? 0 : 1)
                    card(title: "In Context", body: phaseData.educationalText)
                    card(title: "Historical Context", body: phaseData.historicalContext)
                    // Reserve space so the fixed bottom button doesn't cover text
                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }

            markStudiedButton
        }
    }

    // MARK: - Sections

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(buildingName)
                    .font(RenaissanceFont.title2Bold)
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                Text("Pianta: Floor Plan")
                    .font(.custom("EBGaramond-Italic", size: 14))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
            }
            Spacer()
        }
    }

    @ViewBuilder
    private var blueprintImage: some View {
        let name = phaseData.referencePlanImageName
        #if os(iOS)
        let hasImage = UIImage(named: name) != nil
        #else
        let hasImage = NSImage(named: name) != nil
        #endif

        if hasImage {
            Image(name)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                .scaleEffect(zoom)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            zoom = min(max(value, 1.0), 3.0)
                        }
                        .onEnded { _ in
                            withAnimation(.spring()) { zoom = 1.0 }
                        }
                )
        } else {
            RoundedRectangle(cornerRadius: 10)
                .fill(RenaissanceColors.parchment.opacity(0.6))
                .overlay(
                    VStack(spacing: 10) {
                        Image(systemName: "doc.richtext")
                            .font(.system(size: 48))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.3))
                        Text("Blueprint for \(buildingName) coming soon")
                            .font(RenaissanceFont.italicSmall)
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
                    }
                    .padding(20)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(RenaissanceColors.sepiaInk.opacity(0.15), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                )
                .frame(height: 280)
        }
    }

    private func card(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(RenaissanceFont.visualTitle)
                .foregroundStyle(RenaissanceColors.sepiaInk)
            Text(body)
                .font(RenaissanceFont.bodyMedium)
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.9))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.55))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(RenaissanceColors.sepiaInk.opacity(0.12), lineWidth: 1))
        )
    }

    private var savedToast: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(RenaissanceColors.sageGreen)
            Text("Saved to your notebook")
                .font(RenaissanceFont.buttonSmall)
                .foregroundStyle(RenaissanceColors.sepiaInk)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(RenaissanceColors.parchment)
                .overlay(RoundedRectangle(cornerRadius: 20)
                    .stroke(RenaissanceColors.sageGreen.opacity(0.4), lineWidth: 1))
                .shadow(color: .black.opacity(0.15), radius: 6, y: 2)
        )
        .padding(.top, 16)
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private func saveStudyEntry() {
        guard let notebookState, let buildingId else { return }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        notebookState.addSketchEntry(
            buildingId: buildingId,
            buildingName: buildingName,
            title: "Pianta — \(buildingName)",
            body: "Studied the master blueprint \(formatter.string(from: Date()))."
        )
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            savedToastVisible = true
        }
    }

    private var markStudiedButton: some View {
        Button {
            saveStudyEntry()
            // Small delay so the toast animates before we dismiss
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                onComplete()
                dismiss()
            }
        } label: {
            Text("Mark as Studied")
                .font(RenaissanceFont.bodySemibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: 10).fill(RenaissanceColors.warmBrown))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
        .background(
            LinearGradient(
                colors: [RenaissanceColors.parchment.opacity(0), RenaissanceColors.parchment],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea(edges: .bottom)
            .allowsHitTesting(false)
        )
    }
}

#Preview {
    BlueprintStudyView(
        phaseData: PiantaPhaseData(
            gridSize: 12,
            hint: "Circular rotunda + rectangular portico with 16 columns.",
            educationalText: "The Pantheon's dome spans 43.3 meters.",
            historicalContext: "Built by Emperor Hadrian around 126 AD.",
            referencePlanImageName: "PantheonBlueprint"
        ),
        buildingName: "Pantheon",
        onComplete: {}
    )
}
