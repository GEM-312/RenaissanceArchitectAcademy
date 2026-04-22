import SwiftUI
#if os(iOS)
import UIKit
#endif

/// An interactive Renaissance recipe book. Apprentice flips through pages to discover
/// crafting recipes (mortars, pigments, metalwork, glass) and tool-forging recipes.
///
/// Pages:
///   0 — cover
///   1 .. (1 + recipeCount) — crafting recipes from Recipe.allRecipes
///   (1 + recipeCount) .. end — tool recipes from ToolRecipe.allRecipes
///
/// Usage: present from the workbench overlay, a scene prop, or Barovier's pointer.
struct RecipeBookView: View {

    let onClose: () -> Void

    @State private var pageIndex: Int = 0
    @Environment(\.horizontalSizeClass) private var sizeClass
    private var isLarge: Bool { sizeClass == .regular }

    private enum Page {
        case cover
        case recipe(Recipe)
        case toolRecipe(ToolRecipe)
    }

    private var pages: [Page] {
        [.cover]
        + Recipe.allRecipes.map { .recipe($0) }
        + ToolRecipe.allRecipes.map { .toolRecipe($0) }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture { onClose() }

            VStack(spacing: 14) {
                bookCard
                navigationBar
            }
            .padding(.horizontal, isLarge ? 40 : 16)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }

    // MARK: - Book Card

    /// The book card — on iOS uses UIPageViewController with pageCurl (iBooks-style paper flip).
    /// On macOS falls back to a cross-fade since UIKit's pageCurl isn't available.
    private var bookCard: some View {
        let bookWidth: CGFloat = isLarge ? 520 : 360
        let bookHeight: CGFloat = isLarge ? 560 : 560

        // Book cover/page backdrop — prefers the Midjourney "BookBackground" image
        // when present, falls back to a parchment fill + warm gradient.
        let hasCustomBackground: Bool = {
            #if os(iOS)
            return UIImage(named: "BookBackground") != nil
            #else
            return NSImage(named: "BookBackground") != nil
            #endif
        }()

        return ZStack {
            if hasCustomBackground {
                Image("BookBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            } else {
                RoundedRectangle(cornerRadius: 18)
                    .fill(RenaissanceColors.parchment)
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [RenaissanceColors.warmBrown.opacity(0.10), .clear],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
            }

            #if os(iOS)
            PageCurlContainer(pageCount: pages.count, currentPage: $pageIndex) { index in
                pageBody(for: pages[index])
                    .padding(isLarge ? 28 : 20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .background(
                        hasCustomBackground
                            ? AnyView(Color.clear)
                            : AnyView(RenaissanceColors.parchment)
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 18))
            #else
            pageBody(for: pages[pageIndex])
                .padding(isLarge ? 28 : 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .transition(.opacity)
                .id(pageIndex)
            #endif
        }
        .frame(width: bookWidth, height: bookHeight)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(RenaissanceColors.warmBrown.opacity(0.55), lineWidth: 2.5)
        )
        .shadow(color: .black.opacity(0.25), radius: 16, y: 6)
    }

    // MARK: - Page Content

    @ViewBuilder
    private func pageBody(for page: Page) -> some View {
        switch page {
        case .cover:
            coverPage
        case .recipe(let recipe):
            recipePage(recipe)
        case .toolRecipe(let toolRecipe):
            toolRecipePage(toolRecipe)
        }
    }

    private var coverPage: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "book.closed.fill")
                .font(.system(size: 68))
                .foregroundStyle(RenaissanceColors.warmBrown)

            VStack(spacing: 6) {
                Text("The Master's Recipe Book")
                    .font(.custom("Cinzel-Bold", size: isLarge ? 28 : 22))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                    .multilineTextAlignment(.center)
                Text("Il Libro delle Ricette")
                    .font(.custom("EBGaramond-Italic", size: isLarge ? 17 : 14))
                    .foregroundStyle(RenaissanceColors.ochre)
            }

            Rectangle()
                .fill(RenaissanceColors.ochre.opacity(0.5))
                .frame(width: 80, height: 1)

            Text("Every master keeps one. Turn the pages — every recipe is a lesson.\n\nIngredients, heat, patience. That is the craft.")
                .font(.custom("EBGaramond-Regular", size: isLarge ? 15 : 14))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.78))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, 20)

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "arrow.right")
                    .font(.system(size: 11))
                Text("Turn the page")
                    .font(.custom("EBGaramond-Italic", size: 13))
            }
            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
        }
    }

    private func recipePage(_ recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack(spacing: 10) {
                CraftedItemIconView(item: recipe.output, size: 44)
                VStack(alignment: .leading, spacing: 2) {
                    Text(recipe.output.rawValue)
                        .font(.custom("Cinzel-Bold", size: isLarge ? 20 : 17))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text("Crafted item")
                        .font(.custom("EBGaramond-Italic", size: 12))
                        .foregroundStyle(RenaissanceColors.ochre)
                }
                Spacer()
            }

            divider

            // Ingredients
            sectionLabel("Ingredients")
            FlowingIngredients(ingredients: recipe.ingredients)

            // Heat + time
            HStack(spacing: 16) {
                InfoChip(icon: "flame.fill",
                         label: "Heat",
                         value: recipe.temperature.rawValue,
                         tint: RenaissanceColors.terracotta)
                InfoChip(icon: "hourglass",
                         label: "Time",
                         value: "\(Int(recipe.processingTime))s",
                         tint: RenaissanceColors.renaissanceBlue)
            }

            divider

            // Educational text
            ScrollView(.vertical, showsIndicators: false) {
                Text(recipe.educationalText)
                    .font(.custom("EBGaramond-Regular", size: isLarge ? 15 : 14))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.85))
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer(minLength: 0)
        }
    }

    private func toolRecipePage(_ recipe: ToolRecipe) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                ToolIconView(tool: recipe.output, size: 44)
                VStack(alignment: .leading, spacing: 2) {
                    Text(recipe.output.displayName)
                        .font(.custom("Cinzel-Bold", size: isLarge ? 20 : 17))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text(recipe.output.italianName)
                        .font(.custom("EBGaramond-Italic", size: 12))
                        .foregroundStyle(RenaissanceColors.ochre)
                }
                Spacer()
                Text("TOOL")
                    .font(.custom("Cinzel-Bold", size: 9))
                    .tracking(1)
                    .foregroundStyle(RenaissanceColors.ochre)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(RenaissanceColors.ochre.opacity(0.15))
                    )
            }

            divider

            sectionLabel("Materials to Forge")
            FlowingIngredients(ingredients: recipe.ingredients)

            divider

            ScrollView(.vertical, showsIndicators: false) {
                Text(recipe.educationalText)
                    .font(.custom("EBGaramond-Regular", size: isLarge ? 15 : 14))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.85))
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer(minLength: 0)
        }
    }

    // MARK: - Navigation Bar (iBooks-style — swipe for pages, buttons only for close)

    private var navigationBar: some View {
        HStack(spacing: 14) {
            // Hint: swipe to turn pages
            HStack(spacing: 5) {
                Image(systemName: "hand.draw.fill")
                    .font(.system(size: 11))
                Text("Swipe to turn")
                    .font(.custom("EBGaramond-Italic", size: 12))
            }
            .foregroundStyle(RenaissanceColors.parchment.opacity(0.65))

            Spacer()

            Text("\(pageIndex + 1) / \(pages.count)")
                .font(.custom("EBGaramond-Italic", size: 13))
                .foregroundStyle(RenaissanceColors.parchment)

            Spacer()

            Button {
                SoundManager.shared.play(.tapSoft)
                onClose()
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                    Text("Close")
                        .font(.custom("EBGaramond-SemiBold", size: 13))
                }
                .foregroundStyle(RenaissanceColors.parchment)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.35))
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Shared Pieces

    private var divider: some View {
        Rectangle()
            .fill(RenaissanceColors.ochre.opacity(0.35))
            .frame(height: 1)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.custom("Cinzel-Bold", size: 11))
            .tracking(1)
            .foregroundStyle(RenaissanceColors.ochre)
    }
}

// MARK: - Ingredients Row

private struct FlowingIngredients: View {
    let ingredients: [Material: Int]

    private var sortedIngredients: [(material: Material, count: Int)] {
        ingredients
            .sorted { $0.value > $1.value }
            .map { (material: $0.key, count: $0.value) }
    }

    var body: some View {
        RecipeIngredientsGrid(items: sortedIngredients) { entry in
            VStack(spacing: 3) {
                MaterialIconView(material: entry.material, size: 36)
                Text(entry.material.rawValue)
                    .font(.custom("EBGaramond-Regular", size: 11))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                    .lineLimit(1)
                Text("\u{00D7}\(entry.count)")
                    .font(.custom("EBGaramond-Bold", size: 12))
                    .foregroundStyle(RenaissanceColors.ochre)
            }
            .frame(width: 64)
            .padding(.vertical, 6)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(RenaissanceColors.warmBrown.opacity(0.06))
            )
        }
    }
}

// MARK: - Wrapping HStack (manual flow)

private struct RecipeIngredientsGrid<Item, Content: View>: View {
    let items: [Item]
    @ViewBuilder let content: (Item) -> Content

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 70), spacing: 8)],
            spacing: 8
        ) {
            ForEach(items.indices, id: \.self) { i in
                content(items[i])
            }
        }
    }
}

// MARK: - Info Chip

private struct InfoChip: View {
    let icon: String
    let label: String
    let value: String
    let tint: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(tint)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.custom("Cinzel-Bold", size: 9))
                    .tracking(0.5)
                    .foregroundStyle(tint)
                Text(value)
                    .font(.custom("EBGaramond-SemiBold", size: 13))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(tint.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(tint.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Page Curl Container (iOS only — UIKit bridge for UIPageViewController.pageCurl)

#if os(iOS)
/// Wraps UIPageViewController with the `.pageCurl` transition — the same paper-turn
/// animation iBooks uses. Each page is a UIHostingController rendering the SwiftUI page content.
struct PageCurlContainer<PageContent: View>: UIViewControllerRepresentable {
    let pageCount: Int
    @Binding var currentPage: Int
    @ViewBuilder let content: (Int) -> PageContent

    func makeUIViewController(context: Context) -> UIPageViewController {
        let controller = UIPageViewController(
            transitionStyle: .pageCurl,
            navigationOrientation: .horizontal
        )
        controller.dataSource = context.coordinator
        controller.delegate = context.coordinator
        controller.view.backgroundColor = .clear
        let initial = context.coordinator.hostingController(for: currentPage)
        controller.setViewControllers([initial], direction: .forward, animated: false)
        return controller
    }

    func updateUIViewController(_ controller: UIPageViewController, context: Context) {
        context.coordinator.parent = self
        guard let current = controller.viewControllers?.first as? IndexedHostingController,
              current.index != currentPage else { return }
        let direction: UIPageViewController.NavigationDirection =
            currentPage > current.index ? .forward : .reverse
        let newVC = context.coordinator.hostingController(for: currentPage)
        controller.setViewControllers([newVC], direction: direction, animated: true)
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class IndexedHostingController: UIHostingController<AnyView> {
        let index: Int
        init(index: Int, rootView: AnyView) {
            self.index = index
            super.init(rootView: rootView)
        }
        @MainActor required dynamic init?(coder: NSCoder) { fatalError() }
    }

    final class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PageCurlContainer

        init(_ parent: PageCurlContainer) { self.parent = parent }

        func hostingController(for index: Int) -> IndexedHostingController {
            let vc = IndexedHostingController(index: index, rootView: AnyView(parent.content(index)))
            vc.view.backgroundColor = .clear
            return vc
        }

        func pageViewController(_ pvc: UIPageViewController,
                                viewControllerBefore vc: UIViewController) -> UIViewController? {
            guard let hosting = vc as? IndexedHostingController, hosting.index > 0 else { return nil }
            return hostingController(for: hosting.index - 1)
        }

        func pageViewController(_ pvc: UIPageViewController,
                                viewControllerAfter vc: UIViewController) -> UIViewController? {
            guard let hosting = vc as? IndexedHostingController,
                  hosting.index < parent.pageCount - 1 else { return nil }
            return hostingController(for: hosting.index + 1)
        }

        func pageViewController(_ pvc: UIPageViewController,
                                didFinishAnimating finished: Bool,
                                previousViewControllers: [UIViewController],
                                transitionCompleted completed: Bool) {
            guard completed,
                  let current = pvc.viewControllers?.first as? IndexedHostingController else { return }
            if parent.currentPage != current.index {
                DispatchQueue.main.async {
                    self.parent.currentPage = current.index
                }
            }
        }
    }
}
#endif
