---
name: dead-code-purge
description: Find and remove unused Swift methods using graphify leaf-node analysis. Pair with /goal for autonomous batch cleanup. Use when Marina says "purge dead code", "phase 3 cleanup", "/dead-code-purge".
user-invocable: true
---

# Dead Code Purge

A workflow for finding and removing unused Swift methods in RAA using graphify's leaf-node analysis as the input filter, plus grep-verification to weed out false positives.

## When to run this

- After a major feature lands and you suspect there's dead code
- When `/graphify --update` shows new methods becoming weakly-connected
- When you want to follow up on a Phase 2 dead-code batch with a Phase 3

## Prerequisites

- `graphify-out/graph.json` exists in the project root (run `/graphify` first if not)
- Working tree is clean (don't mix purge commits with feature work)
- On a branch (not `main`)

## The Workflow

### Step 1. Extract leaf-node method candidates

Run this jq query against `graph.json` — gives degree-1 method/init nodes, filtered against OS lifecycle callbacks:

```bash
jq -r '
  (.links | reduce .[] as $e ({};
    .[$e.source] = (.[$e.source] // 0) + 1
    | .[$e.target] = (.[$e.target] // 0) + 1
  )) as $deg
  | .nodes
  | map(. + {deg: ($deg[.id] // 0)})
  | map(select(.deg == 1 and (.label | test("\\(\\)$")) and (.file_type == "code")))
  | map(select(.label | test(
      "^\\.?(init|deinit|body|hash|encode|decode|description|debugDescription|callAsFunction|didMove|didChangeSize|didAppear|willMove|willAppear|willUnmount|didUnmount|touchesBegan|touchesEnded|touchesMoved|touchesCancelled|mouseUp|mouseDown|mouseMoved|mouseDragged|mouseEntered|mouseExited|keyDown|keyUp|update|sceneDidLoad|makeUIView|updateUIView|makeNSView|updateNSView|makeUIViewController|updateUIViewController|gameCenterViewControllerDidFinish|makeCoordinator|dismantleUIView|dismantleNSView|canvasViewDrawingDidChange|main|applicationDidFinishLaunching)\\(\\)$"
    ) | not))
  | .[] | "\(.label)|\(.source_file)"
' graphify-out/graph.json | sort -u > /tmp/raa-candidates.txt
```

Expect ~300 candidates after this filter.

### Step 2. Grep-verify each candidate

For each candidate, count callers across all Swift files, excluding the declaration line:

```bash
RAA=/Users/pollakmarina/RenaissanceArchitectAcademy/RenaissanceArchitectAcademy
: > /tmp/raa-dead.txt
: > /tmp/raa-alive.txt

while IFS='|' read -r label srcfile; do
  name="${label#.}"
  name="${name%()}"
  case "$name" in *[^A-Za-z0-9_]*|"") continue ;; esac
  callers=$(grep -rEn "\\b${name}\\(" "$RAA" --include="*.swift" 2>/dev/null \
    | grep -vE "func[[:space:]]+${name}\\b|init\\(.*\\)[[:space:]]*->[[:space:]]+${name}\\b" \
    | wc -l | tr -d ' ')
  if [ "$callers" = "0" ]; then
    echo "$label|$srcfile|0" >> /tmp/raa-dead.txt
  else
    echo "$label|$srcfile|$callers" >> /tmp/raa-alive.txt
  fi
done < /tmp/raa-candidates.txt

echo "DEAD: $(wc -l < /tmp/raa-dead.txt), ALIVE: $(wc -l < /tmp/raa-alive.txt)"
```

### Step 3. Manually verify each "DEAD" before deleting — expect ~50% false positives

The graphify→grep filter is rough. Common false positives:
- **Static call sites** the grep misses: `ActivitySizing.cardHeaderTitleFont(...)` doesn't match `\bcardHeaderTitleFont\(` if there's an `ActivitySizing.` prefix on the same regex hit — actually grep DOES catch this, but if graphify originally rated it as degree-1 it means AST missed the static call linkage. Re-grep manually before deleting.
- **Same-file callers**: AST sometimes misses intra-file calls. If the caller is in the same file as the declaration, both lines show up in grep but the graph showed degree-1 anyway.
- **Generic methods**: `foo<T>(` doesn't match `\bfoo\(` due to the `<T>` between. Check with `grep -rn "\\bfoo\\b" --include="*.swift"`.
- **Protocol conformance**: methods required by protocols (e.g., `==`, `hash(into:)`) look unused but are called via the protocol witness table.
- **SwiftUI button actions**: `.onTapGesture { foo() }` — these match grep. But `Button(action: foo)` (passed as a reference, no parens) does NOT.

**Verification protocol for each candidate before deletion:**

```bash
# Sanity check: any call site at all?
grep -rn "\\b<methodName>\\b" /Users/pollakmarina/RenaissanceArchitectAcademy/RenaissanceArchitectAcademy --include="*.swift"

# If only the declaration shows up: safe to delete
# If multiple lines: re-verify it's actually called, not just shadowed
```

### Step 4. Batch by file, delete, verify

Group dead methods by source file. For each file:

1. Read the FULL file (CLAUDE.md rule: never edit from memory)
2. Delete the dead methods (Edit tool, one per call)
3. Run `xcodebuild -scheme RenaissanceArchitectAcademy -destination 'platform=macOS' build`
4. If green → commit; if red → `git checkout -- <file>` and re-investigate

```bash
# Build check
xcodebuild -scheme RenaissanceArchitectAcademy -destination 'platform=macOS' build 2>&1 | tail -20
```

### Step 5. Commit + push per file (Marina's pattern from Phase 2)

Use commit messages matching the existing style:

```
Phase 3 batch N: <FileName> unused <category> methods
```

Examples from prior batches:
- `Phase 2 batch 5: WallSegment unused computed properties`
- `Phase 2 batch 4: StudentProfile + SubscriptionManager.productID + PersistenceManager.migrateFromUserDefaults`
- `Phase 2 batch 3: 8 unused service functions`

## Pair with /goal for autonomous runs

After running Steps 1-2 (extracting `/tmp/raa-dead.txt`), set this goal at the prompt:

```
/goal Verify each method in /tmp/raa-dead.txt is genuinely dead by grepping the codebase. For confirmed dead ones, remove them in batches grouped by source file. After each batch, run xcodebuild — if it succeeds, commit with message "Phase 3 batch N: <File> unused methods" and continue. If xcodebuild fails, revert that batch with git checkout, log the file as "needs manual review", and continue to the next batch. Stop when /tmp/raa-dead.txt is exhausted or 15 batches have been processed.
```

The evaluator checks the condition each turn. With Auto mode enabled, no per-tool approvals fire. With Remote Control + the iOS app, you can watch from your phone and only intervene if something genuinely needs you.

## Caveats — read before running

1. **Never delete a method that conforms to a protocol** — even if grep shows zero direct callers. Check for `: Equatable`, `: Hashable`, `: Codable`, `: Identifiable`, or any other protocol the parent type adopts. Protocol-required methods are invoked through the witness table.

2. **Never delete `@MainActor` or `@objc` methods** without manual review — these may be called from KVO, NotificationCenter, target/action, or interop code that grep can't see.

3. **Never delete SwiftUI `_` underscore-prefixed methods** — these are runtime internals.

4. **xcodebuild succeeding is NOT sufficient** for safety. A method could be called only at runtime via reflection, NotificationCenter selectors, or `#selector(...)`. After a batch, also smoke-test the affected views in the simulator before merging to `main`.

5. **Skip `ActivitySizing.swift` candidates** until you've grepped for both `ActivitySizing.<name>(` and `\.${name}\b` — many of its methods are called via static reference.

6. **Don't touch SpriteKit scene files** in this pass — `toggleEditorMode()`, `keyDown()`, `mouseUp()`, etc. are editor-mode entry points called only via keyboard events. AST has no way to model that.

## Output artifacts

- `/tmp/raa-candidates.txt` — pre-grep candidates (label + source file)
- `/tmp/raa-dead.txt` — confirmed zero-caller candidates (delete targets)
- `/tmp/raa-alive.txt` — candidates that turned out to have callers (graph false positives)

These get overwritten on each run. Copy them to `~/` if you want to keep a record.

## Related

- `/graphify` — produces the `graph.json` this skill consumes
- `/commit-push` — for shipping each batch
- Phase 2 commits: `git log --oneline --grep "Phase 2"` for style reference
