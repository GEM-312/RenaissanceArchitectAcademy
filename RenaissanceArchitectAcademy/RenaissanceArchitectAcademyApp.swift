import SwiftUI
import CoreText

@main
struct RenaissanceArchitectAcademyApp: App {

    init() {
        // Register custom fonts at app launch
        registerCustomFonts()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
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
            "GreatVibes-Regular", "Amellina"
        ]

        for fontFile in fontFiles {
            if let fontURL = Bundle.main.url(forResource: fontFile, withExtension: "ttf") {
                CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
            }
        }
    }
}
