---
name: run-raa
description: Build RenaissanceArchitectAcademy locally to verify a change against the real app. Defaults to macOS (fastest dev loop); switch to iPad Simulator for iOS-specific behavior (SwiftUI sheet quirks, App Attest, on-device touches).
---

# Run RenaissanceArchitectAcademy

## Preferred — macOS (fastest dev loop)

```bash
xcodebuild -scheme RenaissanceArchitectAcademy -destination 'platform=macOS' build
```

Build artifacts land in `~/Library/Developer/Xcode/DerivedData/RenaissanceArchitectAcademy-*/Build/Products/Debug/RenaissanceArchitectAcademy.app`. Open with `open <path>` to launch.

## iPad Simulator — for iOS-specific behavior

```bash
xcodebuild -scheme RenaissanceArchitectAcademy -destination 'platform=iOS Simulator,name=iPad Pro (11-inch)' build
```

Use when verifying:
- SwiftUI sheet / fullScreenCover behavior that differs from macOS
- App Attest (Simulator falls back to `#if DEBUG` `proxyToken`)
- iPad-specific layout (split view, multi-touch)

## Verify the build correctly (discipline)

Run exactly one build at a time and read the exit code — do not eyeball the tail:

```bash
cd /Users/pollakmarina/RenaissanceArchitectAcademy
xcodebuild -scheme RenaissanceArchitectAcademy -destination 'platform=macOS' build > /tmp/raa_build.log 2>&1; echo "EXIT=$?"; grep -E "BUILD SUCCEEDED|BUILD FAILED|error:" /tmp/raa_build.log | head -20
```

- **One `xcodebuild` at a time.** Two concurrent builds produce a false `BUILD FAILED` (`actool: Failed to decode version info`). If one is already running, wait.
- **Never pipe the build to `tail`** — a pipe masks xcodebuild's exit code, so a failure can read as success. Redirect to a log, capture `$?`, then grep.
- `EXIT=0` + `BUILD SUCCEEDED` → green. Any `error:` → read `/tmp/raa_build.log` for the full context.

## Notes

- DEBUG builds ship with the proxyToken fallback baked in (release builds strip it — see APIKeys.swift line 11).
- Don't run from the `cloudflare-worker/` subdirectory; xcodebuild needs the repo root.
- For real on-device App Attest testing, archive + TestFlight (`Product → Archive` in Xcode).
