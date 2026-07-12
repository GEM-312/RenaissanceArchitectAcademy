---
name: add-swift-file
description: Register a new Swift file into the Xcode project (project.pbxproj) so it compiles. Use when a new .swift file was created (or needs creating) and Xcode doesn't see it yet, or when the user says "add this file to the project", "wire it into the build", "/add-swift-file", or a new file causes "cannot find X in scope" / "no such module" build errors.
---

# add-swift-file

Adds new Swift file(s) to `RenaissanceArchitectAcademy.xcodeproj/project.pbxproj` so Xcode compiles them. A `.swift` file on disk is invisible to the build until it has entries in **4 pbxproj sections**. Missing any one → "cannot find X in scope" errors that look like real code bugs.

> Supersedes the old `fix-pbxproj` skill. Two rules that skill got wrong: this project does **NOT** use 24-char hex UUIDs, and you must **never edit pbxproj with `sed`** (see below).

## Non-negotiable rules

- **Use the Edit tool, never `sed`.** macOS BSD sed treats `\(` as a group, not a literal paren; pbxproj is full of `/* ... */` and `()`. Silent sed failures look identical to successes and have burned this project before. Edit tool = exact-match, no regex surprises.
- **Read the full pbxproj first.** It's ~1340 lines. You need to see the real IDs to avoid collisions and to match ordering.
- **This project uses short custom IDs, not hex UUIDs.** Examples in use: `101`, `149`, `1A0`, `1EA`, `3E8`, `BA1`, `ATC2`. Older Xcode-generated files still have 24-char hex IDs (`544299AD2F36A8D000F92073`) — leave those alone, but new files follow the short scheme.

## The ID convention

Every source file needs **two** IDs: a build-file ID and a file-reference ID. Historically paired as `0XX` ↔ `1XX`:

| File | build-file ID | file-ref ID |
|------|--------------|-------------|
| ForestScene.swift | `049` | `149` |
| BuildingLessonView.swift | `052` | `152` |

The `0XX/1XX` block is mostly consumed. For new files, pick **two short tokens not already in the file** (verify by grep). Either continue an unused `0XX/1XX` pair, or use any unused short hex-ish token like the recent additions (`1A0`, `1EA`, `3E8`). They only need to be unique and internally consistent (the build-file entry's `fileRef` must point at the file-ref ID you chose).

**Check a candidate ID is free before using it:**
```bash
cd /Users/pollakmarina/RenaissanceArchitectAcademy/RenaissanceArchitectAcademy.xcodeproj
grep -c "\b1B0\b" project.pbxproj   # 0 = free. Repeat for both IDs (build + fileRef).
```

## Group placement (this decides the file-ref format)

| File kind | Lives in group | file-ref format |
|-----------|----------------|-----------------|
| **View** (Views/*.swift) | `303 /* Views */` (has `path = Views`) | `path = Name.swift` only |
| **ViewModel** | `304 /* ViewModels */` | `path = Name.swift` only |
| **Model** | `305 /* Models */` | `path = Name.swift` only |
| **Service** | `307 /* Services */` | `path = Name.swift` only |
| **SpriteKit** (Views/SpriteKit/*.swift) | `301 /* RenaissanceArchitectAcademy */` (the main group, `path = RenaissanceArchitectAcademy`) | `name = Name.swift; path = Views/SpriteKit/Name.swift` |

Rule of thumb: if the file's group already has a `path =` that matches its folder, use **`path = Name.swift`** only. SpriteKit files sit in the main group (whose path is the project root), so they need the **full relative `name = ...; path = Views/SpriteKit/...`** form.

## The 4 edits (example: adding a new View `FooView.swift`, IDs `0F1`/`1F1`)

**1. PBXBuildFile section** (near top, after line ~10) — add a sibling line:
```
		0F1 /* FooView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 1F1 /* FooView.swift */; };
```

**2. PBXFileReference section** — a View (path-only):
```
		1F1 /* FooView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = FooView.swift; sourceTree = "<group>"; };
```
For a **SpriteKit** file instead:
```
		1F1 /* FooScene.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; name = FooScene.swift; path = Views/SpriteKit/FooScene.swift; sourceTree = "<group>"; };
```

**3. PBXGroup section** — add the **file-ref ID** to the right group's `children = ( ... )`. For a View, inside `303 /* Views */`:
```
					1F1 /* FooView.swift */,
```
For a SpriteKit file, add it inside `301 /* RenaissanceArchitectAcademy */` instead.

**4. PBXSourcesBuildPhase section** (group `401 /* Sources */`) — add the **build-file ID** to `files = ( ... )`:
```
				0F1 /* FooView.swift in Sources */,
```

To make each Edit's `old_string` unique, anchor on an adjacent existing entry (e.g. the line for the file alphabetically/positionally next to yours) and include your new line in the replacement.

## Verify (mandatory — this is the whole point)

Both checks, in order. Do not skip the numstat check — it's the cheap guard against a malformed edit.

```bash
cd /Users/pollakmarina/RenaissanceArchitectAcademy
# 1. Confirm exactly the intended lines changed (expect +4 additions, 0 deletions per file added)
git diff --numstat -- RenaissanceArchitectAcademy.xcodeproj/project.pbxproj
```

```bash
# 2. Build ONE at a time, capture exit code, grep result — never pipe to tail (masks exit code)
xcodebuild -scheme RenaissanceArchitectAcademy -destination 'platform=macOS' build > /tmp/raa_build.log 2>&1; echo "EXIT=$?"; grep -E "BUILD SUCCEEDED|BUILD FAILED|error:" /tmp/raa_build.log | head -20
```

- `EXIT=0` + `BUILD SUCCEEDED` → done. Report it plainly.
- Any `error:` → read `/tmp/raa_build.log`. A "cannot find X in scope" for the new file's own symbols usually means one of the 4 sections is missing or an ID is mismatched. Re-check all four.
- If a concurrent `xcodebuild` is already running, wait — two at once produce a false `BUILD FAILED` (`actool: Failed to decode version info`).

## Multiple files

Do all edits for all files first (unique ID pair per file), then run **one** build to verify the batch. Expect `+4 × N` additions in numstat.
