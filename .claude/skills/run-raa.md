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

## Notes

- DEBUG builds ship with the proxyToken fallback baked in (release builds strip it — see APIKeys.swift line 11).
- Don't run from the `cloudflare-worker/` subdirectory; xcodebuild needs the repo root.
- For real on-device App Attest testing, archive + TestFlight (`Product → Archive` in Xcode).
