---
name: build
description: Build the Xcode project and report errors
---

Build the RenaissanceArchitectAcademy Xcode project for macOS and report any errors:

```bash
xcodebuild -scheme RenaissanceArchitectAcademy -destination 'platform=macOS' build 2>&1 | tail -50
```

If the build fails, analyze the errors and fix them. If it succeeds, report "Build succeeded."
