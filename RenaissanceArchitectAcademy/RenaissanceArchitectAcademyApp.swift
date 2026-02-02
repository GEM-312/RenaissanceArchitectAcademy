import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

@main
struct RenaissanceArchitectAcademyApp: App {

    init() {
        // Debug: Print available fonts to check if custom fonts loaded
        #if DEBUG
        printAvailableFonts()
        #endif
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

    /// Debug helper to check fonts
    private func printAvailableFonts() {
        print("")
        print("🔍 === FONT DEBUG === 🔍")

        // Check if font files exist in bundle
        let fontFiles = ["Cinzel-Bold.ttf", "EBGaramond-Regular.ttf", "PetitFormalScript-Regular.ttf"]

        print("Checking font files in bundle:")
        for fontFile in fontFiles {
            // Try root level
            if Bundle.main.url(forResource: fontFile.replacingOccurrences(of: ".ttf", with: ""), withExtension: "ttf") != nil {
                print("  ✅ Found: \(fontFile)")
            }
            // Try in Fonts folder
            else if Bundle.main.url(forResource: fontFile.replacingOccurrences(of: ".ttf", with: ""), withExtension: "ttf", subdirectory: "Fonts") != nil {
                print("  ✅ Found: Fonts/\(fontFile)")
            }
            else {
                print("  ❌ NOT FOUND: \(fontFile)")
            }
        }

        // List what's in the bundle
        print("")
        print("Bundle contents:")
        if let resourcePath = Bundle.main.resourcePath {
            let fileManager = FileManager.default
            if let contents = try? fileManager.contentsOfDirectory(atPath: resourcePath) {
                for item in contents.prefix(15) {
                    print("  - \(item)")
                }
            }
        }

        // Check registered fonts
        print("")
        print("Checking font families:")
        #if canImport(UIKit)
        let families = UIFont.familyNames.filter {
            $0.contains("Cinzel") || $0.contains("Garamond") || $0.contains("Petit")
        }
        if families.isEmpty {
            print("  ❌ No custom font families registered")
        } else {
            for family in families {
                print("  ✅ \(family)")
            }
        }
        #endif

        print("🔍 === END DEBUG === 🔍")
        print("")
    }
}
