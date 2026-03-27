import SwiftUI

/// Manages On-Demand Resources (ODR) for iOS — downloads asset packs per scene.
/// On macOS, all assets are bundled — every request returns immediately as "loaded".
///
/// Usage:
///   await AssetManager.shared.requestAssets(tag: "city-scene")
///   AssetManager.shared.prefetchAssets(tag: "workshop-scene")
///
/// ODR Tags:
///   "city-scene"       — Terrain, BlurredTerrain, Building sprites
///   "workshop-scene"   — WorkshopTerrain, BlurredWorkshopTerrain, Station sprites
///   "crafting-room"    — WorkshopBackground, Interior sprites
///   "forest-scene"     — Forest1
///   "onboarding"       — Avatar frames, GirlIntro frames
///   "bird-animations"  — BirdFlySitFrame, BirdSitBlinkFrame
///   "volcano-minigame" — VolcanoFrame00-14
@MainActor
class AssetManager: ObservableObject {
    static let shared = AssetManager()

    /// Tags currently being downloaded
    @Published private(set) var loadingTags: Set<String> = []

    /// Tags that are ready to use
    @Published private(set) var loadedTags: Set<String> = []

    /// Download errors by tag
    @Published private(set) var loadErrors: [String: String] = [:]

    /// Download progress by tag (0.0 - 1.0)
    @Published private(set) var loadProgress: [String: Double] = [:]

    #if os(iOS)
    /// Active resource requests — must retain to keep assets available
    private var activeRequests: [String: NSBundleResourceRequest] = [:]
    #endif

    private init() {}

    // MARK: - Request Assets (blocks until downloaded)

    /// Request assets for a tag. Returns true when ready, false on failure.
    /// On macOS, always returns true immediately.
    @discardableResult
    func requestAssets(tag: String) async -> Bool {
        // Already loaded
        if loadedTags.contains(tag) { return true }

        #if os(macOS)
        // macOS: all assets bundled, always available
        loadedTags.insert(tag)
        return true
        #else
        // iOS: use NSBundleResourceRequest
        if loadingTags.contains(tag) {
            // Already downloading — wait for it
            while loadingTags.contains(tag) {
                try? await Task.sleep(for: .milliseconds(100))
            }
            return loadedTags.contains(tag)
        }

        loadingTags.insert(tag)
        loadErrors.removeValue(forKey: tag)
        loadProgress[tag] = 0

        let request = NSBundleResourceRequest(tags: [tag])
        activeRequests[tag] = request

        // Observe progress
        let progressObserver = request.progress.observe(\.fractionCompleted) { [weak self] progress, _ in
            Task { @MainActor in
                self?.loadProgress[tag] = progress.fractionCompleted
            }
        }

        do {
            // Check if already available (cached by OS)
            let available = await request.conditionallyBeginAccessingResources()
            if available {
                loadedTags.insert(tag)
                loadingTags.remove(tag)
                loadProgress[tag] = 1.0
                progressObserver.invalidate()
                return true
            }

            // Download
            try await request.beginAccessingResources()
            loadedTags.insert(tag)
            loadingTags.remove(tag)
            loadProgress[tag] = 1.0
            progressObserver.invalidate()
            return true
        } catch {
            // If tag doesn't exist (no assets tagged yet), assets are in the main bundle — treat as loaded
            loadedTags.insert(tag)
            loadingTags.remove(tag)
            loadProgress[tag] = 1.0
            activeRequests.removeValue(forKey: tag)
            progressObserver.invalidate()
            print("AssetManager: '\(tag)' not tagged yet — using bundled assets. (\(error.localizedDescription))")
            return true
        }
        #endif
    }

    // MARK: - Prefetch (non-blocking, fire and forget)

    /// Start downloading assets in the background — doesn't block.
    func prefetchAssets(tag: String) {
        guard !loadedTags.contains(tag), !loadingTags.contains(tag) else { return }
        Task {
            await requestAssets(tag: tag)
        }
    }

    // MARK: - Release Assets

    /// Release assets for a tag when no longer needed (iOS only).
    /// The OS may purge them from cache to free storage.
    func releaseAssets(tag: String) {
        #if os(iOS)
        activeRequests[tag]?.endAccessingResources()
        activeRequests.removeValue(forKey: tag)
        #endif
        loadedTags.remove(tag)
        loadProgress.removeValue(forKey: tag)
    }

    // MARK: - Query

    /// Check if a tag's assets are ready to use
    func isReady(_ tag: String) -> Bool {
        #if os(macOS)
        return true  // Always ready on Mac
        #else
        return loadedTags.contains(tag)
        #endif
    }

    /// Check if a tag is currently downloading
    func isLoading(_ tag: String) -> Bool {
        loadingTags.contains(tag)
    }

    /// Get download progress for a tag (0.0 - 1.0)
    func progress(for tag: String) -> Double {
        loadProgress[tag] ?? 0
    }
}

// MARK: - ODR Tag Constants

extension AssetManager {
    static let cityScene = "city-scene"
    static let workshopScene = "workshop-scene"
    static let craftingRoom = "crafting-room"
    static let forestScene = "forest-scene"
    static let onboarding = "onboarding"
    static let birdAnimations = "bird-animations"
    static let volcanoMinigame = "volcano-minigame"
}

// MARK: - Loading View (shown while ODR downloads)

/// Parchment-styled loading indicator for ODR downloads
struct ODRLoadingView: View {
    let tag: String
    let message: String
    @ObservedObject private var assetManager = AssetManager.shared

    var body: some View {
        VStack(spacing: 16) {
            ProgressView(value: assetManager.progress(for: tag))
                .tint(RenaissanceColors.ochre)
                .frame(width: 200)

            Text(message)
                .font(.custom("EBGaramond-Italic", size: 16))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))

            if let error = assetManager.loadErrors[tag] {
                Text(error)
                    .font(.custom("EBGaramond-Regular", size: 13))
                    .foregroundStyle(RenaissanceColors.errorRed)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Button("Retry") {
                    assetManager.prefetchAssets(tag: tag)
                }
                .font(.custom("EBGaramond-SemiBold", size: 14))
                .foregroundStyle(RenaissanceColors.renaissanceBlue)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RenaissanceColors.parchment)
    }
}
