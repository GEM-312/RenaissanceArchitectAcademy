import SwiftUI

/// Which edge of the screen the inventory bar is docked at.
enum InventoryBarEdge: String {
    case top
    case bottom
}

/// Foldable, draggable inventory bar — PKToolPicker-style.
///
/// - Drag the grip handle (leading end) to flip between top and bottom
/// - Tap the chevron to toggle minimize / expand
/// - Minimized pill shows a compact summary: 🔨 tools · 📦 raw · ⭐ crafted
/// - Auto-expands for 1.8 seconds when a new item is collected, then
///   collapses again (only if the student hadn't manually expanded first)
/// - Edge + minimized state persist across launches via `@AppStorage`
///   (global — same position across Workshop / Forest / Crafting Room)
///
/// Positions itself within the parent frame using a VStack + Spacer, so it
/// can be dropped into any ZStack layer without its caller needing to know
/// about the dock edge.
struct FoldableInventoryBar: View {
    let workshop: WorkshopState
    /// Space reserved at the top edge so the bar doesn't collide with the
    /// navigation panel when docked there. The existing top bar on each
    /// map is roughly 60pt tall — 80 adds a small cushion.
    var topInset: CGFloat = 80

    @AppStorage("inventory.edge")
    private var edgeRaw: String = InventoryBarEdge.bottom.rawValue

    @AppStorage("inventory.minimized")
    private var isMinimized: Bool = false

    @GestureState private var dragOffset: CGFloat = 0
    @State private var lastItemTotal: Int = -1
    @State private var autoMinimizeTask: Task<Void, Never>?
    @State private var wasAutoExpanded = false

    private var edge: InventoryBarEdge {
        InventoryBarEdge(rawValue: edgeRaw) ?? .bottom
    }

    private var totalItems: Int {
        workshop.tools.values.reduce(0, +)
            + workshop.rawMaterials.values.reduce(0, +)
            + workshop.craftedMaterials.values.reduce(0, +)
    }

    var body: some View {
        VStack(spacing: 0) {
            if edge == .top {
                Spacer(minLength: topInset)
                bar
                Spacer(minLength: 0)
            } else {
                Spacer(minLength: 0)
                bar
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            lastItemTotal = totalItems
        }
        .onChange(of: totalItems) { oldValue, newValue in
            handleItemTotalChange(from: oldValue, to: newValue)
        }
    }

    // MARK: - Bar content

    @ViewBuilder
    private var bar: some View {
        Group {
            if isMinimized {
                minimizedPill
            } else {
                expandedBar
            }
        }
        .offset(y: dragOffset)
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: isMinimized)
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: edge)
    }

    private var expandedBar: some View {
        HStack(spacing: 6) {
            gripHandle
            InventoryBarView(workshop: workshop)
            minimizeChevron
        }
    }

    private var minimizedPill: some View {
        HStack {
            HStack(spacing: 10) {
                gripHandle
                countsPreview
                expandChevron
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(GameSettings.shared.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(GameSettings.shared.cardBorderColor, lineWidth: 1)
                    )
            )
            .contentShape(Rectangle())
            .onTapGesture {
                toggleMinimizedManually()
            }
            Spacer(minLength: 0)  // compact, leading-aligned
        }
    }

    // MARK: - Grip + chevrons

    private var gripHandle: some View {
        Image(systemName: "line.3.horizontal")
            .font(.caption)
            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
            .padding(.horizontal, 10)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
            .gesture(dragGesture)
    }

    private var minimizeChevron: some View {
        Button {
            toggleMinimizedManually()
        } label: {
            Image(systemName: edge == .bottom ? "chevron.down" : "chevron.up")
                .font(.caption)
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                .padding(.horizontal, 10)
                .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }

    private var expandChevron: some View {
        Image(systemName: edge == .bottom ? "chevron.up" : "chevron.down")
            .font(.caption)
            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
            .padding(.horizontal, 8)
    }

    // MARK: - Minimized counts preview

    private var countsPreview: some View {
        HStack(spacing: 12) {
            countChip(icon: "hammer.fill", count: workshop.tools.values.reduce(0, +))
            countChip(icon: "cube.box.fill", count: workshop.rawMaterials.values.reduce(0, +))
            countChip(icon: "star.fill", count: workshop.craftedMaterials.values.reduce(0, +))
        }
    }

    @ViewBuilder
    private func countChip(icon: String, count: Int) -> some View {
        if count > 0 {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(RenaissanceColors.ochre)
                Text("\(count)")
                    .font(.custom("EBGaramond-SemiBold", size: 13))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }
        }
    }

    // MARK: - Drag

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 5)
            .updating($dragOffset) { value, state, _ in
                state = value.translation.height
            }
            .onEnded { value in
                handleDragEnd(predicted: value.predictedEndTranslation.height)
            }
    }

    private func handleDragEnd(predicted: CGFloat) {
        // Flip edges when the predicted drop point crosses a threshold
        // toward the opposite edge. Otherwise the @GestureState reset
        // springs the bar back to its current edge.
        let threshold: CGFloat = 80
        if edge == .bottom, predicted < -threshold {
            flipEdge(to: .top)
        } else if edge == .top, predicted > threshold {
            flipEdge(to: .bottom)
        }
    }

    private func flipEdge(to newEdge: InventoryBarEdge) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.78)) {
            edgeRaw = newEdge.rawValue
        }
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
    }

    // MARK: - Minimize / auto-expand

    private func toggleMinimizedManually() {
        // Cancel any pending auto-minimize — the student is in control now
        autoMinimizeTask?.cancel()
        wasAutoExpanded = false
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
            isMinimized.toggle()
        }
    }

    private func handleItemTotalChange(from oldValue: Int, to newValue: Int) {
        defer { lastItemTotal = newValue }
        // Skip the initial -1 → N transition on first appear
        guard oldValue >= 0, newValue > oldValue else { return }
        guard isMinimized else { return }
        autoExpandForNewItem()
    }

    private func autoExpandForNewItem() {
        autoMinimizeTask?.cancel()
        wasAutoExpanded = true
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
            isMinimized = false
        }
        autoMinimizeTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            guard !Task.isCancelled, wasAutoExpanded else { return }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                isMinimized = true
            }
            wasAutoExpanded = false
        }
    }
}
