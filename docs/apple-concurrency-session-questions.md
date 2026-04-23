# Apple Concurrency Session — Questions & Code Snippets

**App:** Renaissance Architect Academy (educational iPad game, SwiftUI + SpriteKit, iOS 17+, targeting Swift 6 readiness before App Store submission).

**Architecture summary:** `@Observable` class-based services on `@MainActor`, async/await for AI network calls (Claude, fal.ai), SpriteKit scenes bridged into SwiftUI, multiple singleton services, long polling patterns for queue-based APIs.

Six questions ordered by expected value, plus a bonus. Each has a real code snippet from the codebase you can share with the Apple engineer.

---

## Question 1 — Swift 6 migration: `@Observable` + `@MainActor` service conforming to a shared protocol

### The ask
> *"My services are `@MainActor @Observable class`es that conform to a shared protocol `AIService`. Swift 6 strict concurrency warns that the protocol conformance crosses into main-actor-isolated code. What's the idiomatic fix — mark the whole protocol `@MainActor`, add `nonisolated` to specific conformance points, use `nonisolated(unsafe)`, or restructure the protocol entirely? What's the long-term best practice?"*

### Current code (`Services/ClaudeService.swift`)

```swift
@MainActor
@Observable class ClaudeService: AIService {
    static let apiKey = APIKeys.claude
    var messages: [ChatMessage] = []
    var isLoading = false
    var error: String?

    func sendMessage(_ text: String) async {
        // ...
    }
}
```

### Protocol (`Services/AIService.swift`)

```swift
protocol AIService: AnyObject {
    var messages: [ChatMessage] { get set }
    var isLoading: Bool { get }
    var error: String? { get }
    var lastError: String? { get }
    // ...
    func sendMessage(_ text: String) async
}
```

### The warning
```
conformance of 'ClaudeService' to protocol 'AIService' crosses into
main actor-isolated code and can cause data races; this is an error
in the Swift 6 language mode
```

### What would help most
A concrete, idiomatic fix that scales to 3 sibling services (`ClaudeService`, `AppleAIService`, `MockAIService`), all expected to run on main. Tradeoffs between `@MainActor protocol`, `nonisolated` members, and restructuring.

---

## Question 2 — Task cancellation when a SwiftUI view dismisses mid-async

### The ask
> *"I launch an async task from a SwiftUI view that calls a shared `@Observable` service. If the user dismisses the view before the task finishes, what's the idiomatic way to cancel it so the URLSession request is actually dropped (not just abandoned) and no UI state mutation happens post-dismiss? Is `.task { }` always the right answer, or do I need manual Task handles?"*

### Current code (`Views/Sketching/PiantaCanvasView.swift`)

```swift
@MainActor
private func triggerAIValidation(cellSize: CGFloat) {
    // ... snapshot sketch, load reference ...
    isAIValidating = true
    Task { @MainActor in
        defer { isAIValidating = false }
        do {
            let result = try await SketchValidator.shared.validate(
                studentSketch: studentImage,
                referencePlan: referenceImage,
                buildingName: buildingName
            )
            withAnimation(.easeInOut(duration: 0.3)) {
                aiValidationResult = result
            }
        } catch {
            // ... error handling ...
        }
    }
}
```

### What would help most
- Does the `Task { }` auto-cancel when the view is removed? (No — I believe this only applies to `.task { }` modifier.)
- If I switch to `.task { }`, does the URLSession call inside honor cancellation?
- Specifically: how does `URLSession.shared.data(for:)` behave under `Task.isCancelled`? Does it cancel the HTTP request or just throw?

---

## Question 3 — SpriteKit `update(_:)` game loop + async work

### The ask
> *"SpriteKit's `update(_:)` runs on the main actor every frame at 60fps. I trigger async network calls from tap handlers in the scene (e.g. hint generation, AI validation). What's the pattern to tie a `Task`'s lifetime to an `SKNode`'s lifetime so when the scene tears down or the node is removed, the task is cancelled? Is there a modern replacement for the `[weak self]` dance inside `SKAction.run` completion blocks?"*

### Current code (`Views/SpriteKit/WorkshopScene.swift`, illustrative)

```swift
class WorkshopScene: SKScene {
    override func update(_ currentTime: TimeInterval) {
        // Camera smoothing, terrain blur, player walking — runs 60fps on main
        terrainBlur.updateBlur(cameraScale: cameraNode.xScale)
    }

    func handleStationTap(_ station: ResourceStationType) {
        // Current pattern — unstructured Task
        Task { @MainActor in
            let hint = await AIService.shared.generateHint(for: station)
            self.showHintBubble(hint)  // what if scene is gone?
        }
    }

    override func willMove(from view: SKView) {
        terrainBlur.cleanup()
        // How do I cancel in-flight Tasks here?
    }
}
```

### What would help most
- Is there a structured-concurrency analog to `[weak self]` for async work in SpriteKit scenes?
- Is there an officially blessed pattern for scene-scoped task cancellation?

---

## Question 4 — `Sendable` for services holding `UIImage` / `URLSession` / `Data`

### The ask
> *"My `@Observable` services hold non-Sendable types like `URLSession`, `UIImage` (typealiased `PlatformImage`), and cached `Data`. Passing these across async boundaries in Swift 6 strict mode triggers Sendable warnings. Is `@unchecked Sendable` acceptable for Apple-framework-backed types that Apple docs claim are thread-safe internally? What's the recommended pattern for passing images through an async pipeline?"*

### Current code (`Services/SketchValidator.swift`)

```swift
@MainActor
@Observable final class SketchValidator {
    static let shared = SketchValidator()

    func validate(studentSketch: PlatformImage,        // PlatformImage = UIImage
                  referencePlan: PlatformImage,
                  buildingName: String) async throws -> Result {

        guard let studentData = studentSketch.pngData(),      // Data crossing actors
              let referenceData = referencePlan.pngData() else {
            throw ValidationError.encodingFailed
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        // ...
    }
}
```

### What would help most
- Is `UIImage` considered `Sendable` by Apple in practice, or must I convert to `Data` / `CGImage` before crossing?
- `URLSession.shared` is used from many actors — is that safe, or should each actor have its own session?

---

## Question 5 — `TaskGroup` for parallel AI requests

### The ask
> *"When a student completes a sketch, I may want to (a) validate the sketch against a reference plan via Claude vision, AND simultaneously (b) pre-fetch the next card's data so the UI is ready. Is `withThrowingTaskGroup` the right primitive, and what are the cancellation semantics — if task (b) throws, does (a) get cancelled? How do I propagate partial results?"*

### Hypothetical code (what we'd want)

```swift
func postSketchPipeline(snapshot: PlatformImage, buildingName: String) async throws -> PostSketchResult {
    try await withThrowingTaskGroup(of: Partial.self) { group in
        group.addTask {
            let result = try await SketchValidator.shared.validate(...)
            return .validation(result)
        }
        group.addTask {
            let next = try await CardService.shared.prefetchNext(for: buildingName)
            return .nextCard(next)
        }
        var partial = PostSketchResult()
        for try await item in group { partial.merge(item) }
        return partial
    }
}
```

### What would help most
- Is this the right primitive or should I use `async let`?
- If one child fails, what's best practice — cancel the group or let siblings finish?

---

## Question 6 — `ImageRenderer` on background tasks

### The ask
> *"`ImageRenderer<Content>` is relatively new. I use it to snapshot a SwiftUI view (a student's sketch canvas) before sending to an AI API. Is it safe to call `renderer.uiImage` from a non-main actor, or strictly main? Same question for `UIGraphicsImageRenderer` — any differences?"*

### Current code (`Views/Sketching/PiantaCanvasView.swift`)

```swift
@MainActor
private func renderStudentSnapshot(cellSize: CGFloat) -> PlatformImage? {
    let canvasSize = cellSize * CGFloat(gridSize)
    let snapshot = ZStack {
        gridBackground(cellSize: cellSize, canvasSize: canvasSize)
        ForEach(placedWalls) { wall in wallPath(wall, cellSize: cellSize) }
        ForEach(placedCircles) { circle in circleShape(circle, cellSize: cellSize) }
        ForEach(placedColumns) { col in columnMarker(col, cellSize: cellSize) }
    }
    .frame(width: canvasSize, height: canvasSize)

    let renderer = ImageRenderer(content: snapshot)
    renderer.scale = 2.0
    #if os(iOS)
    return renderer.uiImage
    #else
    return renderer.nsImage
    #endif
}
```

### What would help most
- Can I move the `renderer.uiImage` call to a background task to avoid blocking main during render? If not, what's the cost profile — is 2x scale on a 400×400 view going to drop frames?

---

## Bonus question if time allows

### Question 7 — `GameSettings.shared.cardTextScale` read from computed `Font` properties

I have:
```swift
@MainActor static var ivLabel: Font {
    .custom("EBGaramond-SemiBold",
            size: 28 * GameSettings.shared.cardTextScale,
            relativeTo: .body)
}
```

Every SwiftUI view that uses `RenaissanceFont.ivLabel` should re-render when `GameSettings.cardTextScale` changes (since `GameSettings` is `@Observable`). Does SwiftUI observation register this access inside a computed `static var`, or does the observer registration only work from instance property access?

---

## Meeting logistics

- Show them the build warnings (`var error: String?` / `conformance of 'X' to protocol 'AIService' crosses into main actor-isolated code`) — those are real and will block Swift 6 migration.
- Mention you're shipping to App Store within the academic term — Swift 6 readiness matters.
- Ask if there's an Apple-provided sample project that demonstrates `@Observable` + `@MainActor` services + network polling in one place.

Good luck!
