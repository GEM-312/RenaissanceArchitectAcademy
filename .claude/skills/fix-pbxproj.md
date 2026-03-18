---
name: fix-pbxproj
description: Add a new Swift file to the Xcode project file (pbxproj)
---

Help add new Swift files to the Xcode pbxproj. Ask the user which file(s) need adding, then:

1. Read the full `RenaissanceArchitectAcademy.xcodeproj/project.pbxproj`
2. Follow these rules for pbxproj editing:
   - Uses TABS for indentation
   - New files need entries in 4 sections: PBXBuildFile, PBXFileReference, PBXGroup, PBXSourcesBuildPhase
   - **SpriteKit files** go in group 301 (main group), with `name = X; path = Views/SpriteKit/X` pattern
   - **Views** go in group 303 with just `path = X` since group has `path = Views`
   - **Models** go in the Models group
   - Use unique 24-char hex IDs that don't collide with existing ones
   - Keep alphabetical ordering within each section

Always verify the build succeeds after editing pbxproj.
