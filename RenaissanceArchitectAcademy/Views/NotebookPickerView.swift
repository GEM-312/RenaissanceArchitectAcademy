import SwiftUI

/// Picker that lists every notebook with at least one entry — building notebooks
/// AND the cross-cutting "Discoveries" notebook (sentinel ID 0). Tapping a row
/// opens that notebook in the standard `NotebookView`.
///
/// Replaces the previous behavior where the "Notes" nav button always opened
/// Pantheon's notebook regardless of which buildings the player had touched.
struct NotebookPickerView: View {
    var viewModel: CityViewModel
    var notebookState: NotebookState
    var onPickBuilding: (Int) -> Void
    var onDismiss: () -> Void

    private var settings: GameSettings { GameSettings.shared }

    /// Entries shown in the picker, sorted by `lastModified` descending.
    private var rows: [Row] {
        let nonEmpty = notebookState.notebooks.values.filter { !$0.entries.isEmpty }
        return nonEmpty
            .sorted { $0.lastModified > $1.lastModified }
            .map { notebook in
                let isDiscoveries = notebook.id == NotebookState.discoveriesNotebookID
                let title: String = isDiscoveries
                    ? NotebookState.discoveriesNotebookName
                    : (viewModel.buildingPlots.first(where: { $0.id == notebook.id })?.building.name
                       ?? notebook.buildingName)
                let icon: String = isDiscoveries ? "sparkles" : "book.closed.fill"
                let accent: Color = isDiscoveries
                    ? RenaissanceColors.ochre
                    : (notebook.id <= 8 ? RenaissanceColors.terracotta : RenaissanceColors.deepTeal)
                return Row(
                    id: notebook.id,
                    title: title,
                    icon: icon,
                    accentColor: accent,
                    entryCount: notebook.entries.count,
                    lastModified: notebook.lastModified
                )
            }
    }

    var body: some View {
        ZStack {
            RenaissanceColors.parchment.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                if rows.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(rows) { row in
                                pickerRow(row)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 80)
                    }
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button(action: onDismiss) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .font(RenaissanceFont.bodyMedium)
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
            }
            .padding(.leading, 20)

            Spacer()

            VStack(spacing: 2) {
                Text("My Notebook")
                    .font(RenaissanceFont.title2Bold)
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                Text("Tap a section to read")
                    .font(.custom("EBGaramond-Italic", size: 13))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
            }

            Spacer()

            // Spacer column to keep the title centered
            Color.clear.frame(width: 60, height: 1)
        }
        .padding(.vertical, 16)
        .background(
            RenaissanceColors.parchment
                .shadow(color: RenaissanceColors.sepiaInk.opacity(0.08), radius: 4, y: 2)
        )
    }

    // MARK: - Row

    private func pickerRow(_ row: Row) -> some View {
        Button {
            onPickBuilding(row.id)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: row.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(row.accentColor)
                    .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 4) {
                    Text(row.title)
                        .font(.custom("Cinzel-Bold", size: 17))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text("\(row.entryCount) " + (row.entryCount == 1 ? "entry" : "entries") + " · " + relativeDate(row.lastModified))
                        .font(RenaissanceFont.caption)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.4))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(settings.dialogBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(row.accentColor.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: RenaissanceColors.sepiaInk.opacity(0.06), radius: 3, y: 2)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "book.closed")
                .font(.system(size: 56))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.3))
            Text("Your notebook is empty.")
                .font(.custom("Cinzel-Bold", size: 18))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
            Text("Read building lessons, complete knowledge cards, sketch floor plans, and discover stations — they'll all appear here.")
                .font(RenaissanceFont.bodySmall)
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.55))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
    }

    // MARK: - Helpers

    private struct Row: Identifiable {
        let id: Int
        let title: String
        let icon: String
        let accentColor: Color
        let entryCount: Int
        let lastModified: Date
    }

    private func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
