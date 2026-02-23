import SwiftUI
import SwiftData
import CoreText

@main
struct RenaissanceArchitectAcademyApp: App {

    let modelContainer: ModelContainer

    init() {
        // Set up SwiftData persistence first (stored property must be initialized)
        do {
            let schema = Schema([PlayerSave.self, BuildingProgressRecord.self, LessonRecord.self])
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }

        // Register custom fonts at app launch
        registerCustomFonts()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1200, height: 800)
        #endif
    }

    /// Register all custom fonts from the bundle using CoreText
    private func registerCustomFonts() {
        let fontFiles = [
            "Cinzel-Regular", "Cinzel-Medium", "Cinzel-SemiBold", "Cinzel-Bold",
            "Cinzel-ExtraBold", "Cinzel-Black", "Cinzel-VariableFont_wght",
            "EBGaramond-Regular", "EBGaramond-Italic", "EBGaramond-Medium",
            "EBGaramond-MediumItalic", "EBGaramond-SemiBold", "EBGaramond-SemiBoldItalic",
            "EBGaramond-Bold", "EBGaramond-BoldItalic", "EBGaramond-ExtraBold",
            "EBGaramond-ExtraBoldItalic", "EBGaramond-VariableFont_wght",
            "EBGaramond-Italic-VariableFont_wght", "PetitFormalScript-Regular",
            "GreatVibes-Regular", "Amellina",
            "LibreBaskerville-Bold", "LibreBaskerville-Regular",
            "LibreBaskerville-Italic", "LibreBaskerville-SemiBold",
            "LibreFranklin-Regular", "LibreFranklin-Bold",
            "LibreFranklin-Medium", "LibreFranklin-SemiBold", "LibreFranklin-Italic",
            "Delius-Regular", "Mulish-Light", "Mulish-Regular",
            "Mulish-Medium", "Mulish-SemiBold", "Mulish-Bold",
            "Mulish-Italic", "Mulish-LightItalic"
        ]

        for fontFile in fontFiles {
            if let fontURL = Bundle.main.url(forResource: fontFile, withExtension: "ttf") {
                CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
            }
        }
    }
}
