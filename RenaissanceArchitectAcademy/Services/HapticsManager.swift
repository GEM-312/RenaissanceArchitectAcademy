import SwiftUI
#if os(iOS)
import CoreHaptics
import UIKit
#endif

/// Manages tactile feedback for game interactions
/// iOS only — macOS provides no-op stubs
@MainActor
class HapticsManager {
    static let shared = HapticsManager()

    var isEnabled: Bool = true

    #if os(iOS)
    private var engine: CHHapticEngine?
    private let supportsHaptics: Bool
    private var engineIsRunning: Bool = false
    #endif

    private init() {
        #if os(iOS)
        supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        if supportsHaptics {
            createEngine()
        }
        #endif
    }

    #if os(iOS)
    /// Rebuild the engine + install stopped/reset handlers so we can recover from
    /// iOS auto-shutdown or silent failures (the -4805 error spam).
    private func createEngine() {
        do {
            let newEngine = try CHHapticEngine()
            newEngine.isAutoShutdownEnabled = true

            // When iOS kills the engine (app background, audio route change, etc.),
            // mark it as not-running so the next play() call recreates it.
            newEngine.stoppedHandler = { [weak self] reason in
                print("HapticsManager: engine stopped — \(reason)")
                Task { @MainActor in self?.engineIsRunning = false }
            }
            // On reset (transient system issue), try to restart in place.
            newEngine.resetHandler = { [weak self] in
                print("HapticsManager: engine reset — restarting")
                Task { @MainActor in
                    self?.engineIsRunning = false
                    try? self?.engine?.start()
                    self?.engineIsRunning = true
                }
            }

            engine = newEngine
        } catch {
            print("HapticsManager: engine init failed: \(error)")
            engine = nil
        }
    }

    /// Ensure the engine is running before a pattern play. Retries once if start fails.
    private func ensureEngineRunning() -> Bool {
        guard let engine else { return false }
        if engineIsRunning { return true }
        do {
            try engine.start()
            engineIsRunning = true
            return true
        } catch {
            print("HapticsManager: engine start failed (\(error)) — recreating")
            createEngine()
            do {
                try engine.start()
                engineIsRunning = true
                return true
            } catch {
                print("HapticsManager: engine start failed again: \(error)")
                return false
            }
        }
    }
    #endif

    // MARK: - Haptic Events

    enum HapticEvent {
        case buttonTap          // Light tap — UI buttons
        case cardFlip           // Medium impact — card interactions
        case correctAnswer      // Success — ascending pattern
        case wrongAnswer        // Error — short buzz
        case materialCollected  // Medium + light double tap
        case craftingComplete   // Rich celebration
        case buildingComplete   // Strongest celebration
        case constructionStep   // Rigid impact — drag/drop
    }

    // MARK: - Play

    func play(_ event: HapticEvent) {
        #if os(iOS)
        guard isEnabled, supportsHaptics else { return }

        switch event {
        case .buttonTap:
            simpleImpact(.light)
        case .cardFlip:
            simpleImpact(.medium)
        case .correctAnswer:
            playPattern(correctPattern)
        case .wrongAnswer:
            notificationFeedback(.error)
        case .materialCollected:
            playPattern(collectPattern)
        case .craftingComplete:
            playPattern(craftCompletePattern)
        case .buildingComplete:
            playPattern(buildCompletePattern)
        case .constructionStep:
            simpleImpact(.rigid)
        }
        #endif
    }

    // MARK: - Simple Feedback (UIKit generators)

    #if os(iOS)
    private func simpleImpact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    private func notificationFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    // MARK: - Complex Patterns (CoreHaptics)

    private func playPattern(_ events: [CHHapticEvent]) {
        guard let engine, ensureEngineRunning() else {
            simpleImpact(.medium)
            return
        }
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            // Fallback to simple impact
            print("HapticsManager: pattern play failed: \(error)")
            simpleImpact(.medium)
        }
    }

    /// Success: light → medium → strong ascending taps
    private var correctPattern: [CHHapticEvent] {
        [
            CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
            ], relativeTime: 0),
            CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            ], relativeTime: 0.1),
            CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
            ], relativeTime: 0.2),
        ]
    }

    /// Collect: double tap — medium then light
    private var collectPattern: [CHHapticEvent] {
        [
            CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            ], relativeTime: 0),
            CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
            ], relativeTime: 0.12),
        ]
    }

    /// Crafting complete: three rising taps + sustained buzz
    private var craftCompletePattern: [CHHapticEvent] {
        [
            CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
            ], relativeTime: 0),
            CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            ], relativeTime: 0.1),
            CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
            ], relativeTime: 0.2),
            CHHapticEvent(eventType: .hapticContinuous, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
            ], relativeTime: 0.3, duration: 0.3),
        ]
    }

    /// Building complete: strongest celebration — 5 ascending taps + big sustained buzz
    private var buildCompletePattern: [CHHapticEvent] {
        [
            CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
            ], relativeTime: 0),
            CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
            ], relativeTime: 0.08),
            CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            ], relativeTime: 0.16),
            CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
            ], relativeTime: 0.24),
            CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            ], relativeTime: 0.32),
            CHHapticEvent(eventType: .hapticContinuous, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
            ], relativeTime: 0.4, duration: 0.5),
        ]
    }
    #endif
}

// MARK: - SwiftUI View Extension

extension View {
    /// Trigger haptic feedback when a condition becomes true
    func hapticFeedback(_ event: HapticsManager.HapticEvent, when condition: Bool) -> some View {
        self.onChange(of: condition) { _, newValue in
            if newValue {
                Task { @MainActor in
                    HapticsManager.shared.play(event)
                }
            }
        }
    }
}
