# Asset Size Plan — Renaissance Architect Academy

**Date:** 2026-09-16
**Repo state:** clone of `main` at `c603246` ("Scripts: Photoshop brand-color script…")
**Scope:** research + measurement only. No Swift, asset, or `project.pbxproj` file was modified.

---

## 1. Verdict

**Do the boring thing first: recompress. Do not build the CDN pipeline yet.**

Every PNG in `Assets.xcassets` is stored as full-depth RGBA, and every long-form audio
cue is a 24-bit/48–96 kHz WAV. Re-encoding the catalog with Xcode's **lossy** imageset
compression and the four big WAVs to AAC is a settings-and-re-export job with **no new
code, no new target, no App Store Connect workflow, and no offline failure mode** — and
by direct measurement on these exact files it takes **468 MB of source PNG down to
roughly 46 MB, and 95 MB of audio down to roughly 8 MB**. Marina's specific idea —
stream the 15-frame building animations from Apple's CDN and evict all but the final
frame after a building completes — targets 89 MB of build frames, of which lossy
recompression alone removes ~77 MB while leaving the animation fully playable offline
forever. **The CDN work is strictly more effort for strictly less benefit, and it can
only ever be applied to assets that recompression has already shrunk.**

Background Assets is genuinely the right technology for RAA *if* the catalog ever grows
past what recompression can hold — it is the supported, non-deprecated path (On-Demand
Resources is deprecated as of iOS 27), `AssetPackManager` is iOS 26.0+ which matches the
project's deployment target exactly, and `remove(assetPackWithID:)` does exactly the
eviction Marina described. Phase 4 below keeps that door open and specifies the design.
But the first hour of work should be spent on a checkbox, not on an extension target.

**Estimated total saving from Phases 0–2 (no CDN): ~350–420 MB of the current ~420 MB
shipped payload.** See §7 for the phased numbers and §6 for the honest caveats about
which of those numbers are measured and which are estimated.

---

## 2. Step 1 — What actually ships (verified against `project.pbxproj`)

### 2.1 Method

`RenaissanceArchitectAcademy.xcodeproj/project.pbxproj` was read in full. The file
contains **no `PBXFileSystemSynchronizedRootGroup`** — Xcode 16-style folders that
auto-include everything on disk. Every one of the 285 `PBXFileReference` entries is
explicit, and the single `PBXResourcesBuildPhase` (`402 /* Resources */`, lines
1043–1143) has exactly **92 entries**. That means membership is exactly what is listed,
and nothing is pulled in implicitly.

### 2.2 Answers

| Marina's question | Answer | Evidence |
|---|---|---|
| Does `OriginalAssets_Backup/` (198 MB) ship? | **No.** It is not in the clone at all, has zero references in `project.pbxproj`, and is gitignored twice (`.gitignore:75` `*_Backup/`, `.gitignore:82`). | `grep -i "OriginalAssets\|Backup" project.pbxproj` → no matches |
| Do the loose `.mp4` files ship? | **No.** `GirkWalkingRight1.mp4` / `GirlWalkingLeft.mp4` are not in the clone. Four *other* `.mp4`s are on disk (`FlyingSittingBird.mp4` 11 MB, `WorkshopInvitation.mp4` 2.2 MB, `GirlAvatarTransition.mp4` 2.0 MB, `SittingBlinking.mp4` 0.8 MB = 16 MB) and **none of them ship either** — zero `.mp4` references in `project.pbxproj`, and `.gitignore:112` excludes `RenaissanceArchitectAcademy/*.mp4`. | `grep -i "mp4" project.pbxproj` → no matches |
| Does every audio file ship? | **Almost.** 56 audio files on disk (95.0 MB); **53 are in the Resources phase (94.64 MB)**. Three are not: `city_ambient.mp3`, `footstep_old.wav`, `mine_call_forza.mp3` (0.40 MB combined). | Set difference of Resources-phase names vs. disk |

**So the cheapest-win hypothesis does not hold.** There is no 198 MB backup folder and no
29 MB stray video riding along in the binary — those live on Marina's disk and in her
working tree, not in the app. The size problem is entirely in `Assets.xcassets` and the
audio, both of which genuinely ship.

### 2.3 What *is* in the Resources build phase

| Item | Count | Size |
|---|---|---|
| `Assets.xcassets` | 1 | 485 MB on disk → **~315 MB compiled `Assets.car`** (Marina's measurement) |
| Audio files (`.wav` / `.mp3` / `.m4a`) | 53 unique | **94.6 MB** |
| Fonts (`.ttf`) | 31 | **9.0 MB** |
| `.atlasc` folder references | 3 (`RiverHouse` 924 KB, `Woodcutter` 304 KB, `Fisherman` 60 KB) | **1.3 MB** |

**Shipped payload ≈ 420 MB** (315 MB `.car` + 94.6 + 9.0 + 1.3).

### 2.4 Three project-hygiene bugs found on the way

These cost ~0 MB (Xcode de-duplicates to the same output path and emits a warning), but
they are real and worth 10 minutes:

1. **`crafting_ambient.wav` is in the Resources phase three times**, via three *distinct*
   `PBXFileReference` entries that all have `path = crafting_ambient.wav`
   (`project.pbxproj:528`, `:533`, `:573`). Build files `5466B5BF…`, `AC7`, `5466B5B8…`.
2. **`volcano_rumble_ambient.mp3` is in the Resources phase twice**, same pattern
   (`project.pbxproj:532`, `:538`).
3. **Two resources are listed in the `Sources` (compile) phase**: `GirlIntroAudio.m4a`
   (`082`) and `card_flip.mp3` (`083`), at `project.pbxproj:1151–1152`. Both are *also*
   correctly in Resources. Audio in a compile phase is a misconfiguration.

### 2.5 Where this clone differs from Marina's measurements

| Metric | Marina (today, her machine) | This clone | Note |
|---|---|---|---|
| `Assets.xcassets` on disk | 527 MB | **485 MB** (`du`); **468.4 MB** of actual PNG bytes | Difference is most likely uncommitted work + `du` block rounding. Imageset count matches exactly, so no category is missing. |
| Standalone imagesets | 498 | **498** ✅ | Exact match |
| `.spriteatlas` folders | 131 MB | **134 MB**, 27 folders, 379 member imagesets | Match |
| 8 `*Build` atlases | "may be missing from your clone" | **All 8 present**, 15 frames each, **89.3 MB of PNG** (95.1 MB by `du`) | Nothing missing — the numbers below are measured on the real frames |
| Tree-growth atlases | "4 atlases, 12–13 frames, ~3 MB each ≈ 12 MB" | **5 atlases** (`OakGrow` too, 14 frames), **7.7 MB total**. `CypressGrow` is 0.4 MB and `PoplarGrow` 0.6 MB, not 3 MB each. | Correcting the inventory downward: trees are a rounding error, not a target |

---

## 3. Step 2 — Research findings

All URLs are listed in full in §11.

### 3.a Background Assets: managed + Apple-hosted

Background Assets (framework introduced iOS 16 / macOS 13) gained a **managed** mode in
iOS 26 that is what Marina wants. The relevant symbols:

| Symbol | Declaration | Availability |
|---|---|---|
| `AssetPackManager` | `actor AssetPackManager` | **iOS 26.0**, iPadOS 26.0, Mac Catalyst 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0 |
| `AssetPack` | `struct AssetPack` | iOS 26.0 / macOS 26.0 |
| `AssetPackManifest` | `struct AssetPackManifest` | iOS 26.0 / macOS 26.0 |
| `ManagedDownloaderExtension` | `protocol ManagedDownloaderExtension : BADownloaderExtension where Self.Configuration : ManagedDownloaderExtensionConfiguration` | iOS 26.0 / macOS 26.0 |
| `AssetPackManager.ensureLocalAvailability(of:)` | `func ensureLocalAvailability(of assetPack: AssetPack) async throws` | iOS 26.0 |
| `AssetPackManager.remove(assetPackWithID:)` | `func remove(assetPackWithID assetPackID: String) async throws` | iOS 26.0 |
| `AssetPackManager.contents(at:searchingInAssetPackWithID:options:)` | `nonisolated func contents(at path: FilePath, searchingInAssetPackWithID assetPackID: String? = nil, options: Data.ReadingOptions = .mappedIfSafe) throws -> Data` | iOS 26.0 |
| `AssetPackManager.url(for:)` | `nonisolated func url(for path: FilePath) throws -> URL` | iOS 26.0 |
| `AssetPackManager.status(ofAssetPackWithID:)` | `func status(ofAssetPackWithID assetPackID: String) async throws -> AssetPack.Status` | iOS 26.0 |
| `AssetPackManager.localStatus(ofAssetPackWithID:)` | `func localStatus(ofAssetPackWithID assetPackID: String) async -> AssetPack.Status` | **iOS 26.4** |
| `AssetPackManager.assetPackIsAvailableLocally(withID:)` | `nonisolated func assetPackIsAvailableLocally(withID assetPackID: String) -> Bool` | **iOS 26.4** |
| `AssetPack.downloadSize` | `let downloadSize: Int` | iOS 26.0 |

**RAA targets iOS 26+ / macOS 14+.** The iOS side is clear. **The macOS side is not:
`AssetPackManager` requires macOS 26.0, and RAA's deployment target is macOS 14.0.** Any
Background Assets adoption must be `@available`-gated on macOS or the macOS deployment
target must move to 26. That is a decision only Marina can make (§10).

Note also that the two most convenient *offline* checks —
`assetPackIsAvailableLocally(withID:)` and `localStatus(ofAssetPackWithID:)` — are
**iOS 26.4**, not 26.0. On 26.0–26.3 the only way to ask "is this pack here?" is
`status(ofAssetPackWithID:)`, which the docs say "attempts to get the latest asset-pack
information from the server" — i.e. it is not usable as an offline probe. The offline
fallback therefore has to be written as "try, and handle the throw" rather than
"check first" (§8).

**Required `Info.plist` keys for Apple-hosted managed packs — exactly three:**

| Key | Value |
|---|---|
| `BAAppGroupID` | the app group shared between the app target and the downloader-extension target |
| `BAHasManagedAssetPacks` | `YES` |
| `BAUsesAppleHosting` | `YES` |

Apple is explicit: *"For apps that use Apple-Hosted Background Assets, omit all other
Background Assets information property list keys from your project."*

**Project setup:** add a target → Application Extension → **Background Download**
template → extension type **"Apple-Hosted, Managed"**; put the app target and the
extension target in a shared App Group. If you do not need to filter downloads at
runtime, delete the generated `shouldDownload(_:)` and take the system default.

**Download policies** are set per pack in the pack's own `Manifest.json`, under a
`downloadPolicy` object with exactly one key:

| Policy | Behaviour |
|---|---|
| `essential` | Downloaded as part of app installation; counts toward the App Store download progress the player sees. App is not launchable until it lands. Requires an `installationEventTypes` list (e.g. `["firstInstallation"]`). |
| `prefetch` | Download *starts* during installation but may continue in the background after install finishes. Requires `installationEventTypes`. |
| `onDemand` | Nothing happens until the app calls `ensureLocalAvailability(of:)`. Value must be an empty object `{}`. |

Authoring a pack:

```sh
xcrun ba-package template -o Manifest.json     # generate a commented template
# edit assetPackID, downloadPolicy, fileSelectors (file: / directory:), platforms
cd <repo root>                                  # paths in the manifest are relative to CWD
xcrun ba-package Manifest.json -o PantheonBuild.aar
```

Then upload the `.aar` to App Store Connect (Transporter, the `xcrun` tooling,
iTMSTransporter, or the App Store Connect API) **independently of app builds**.

### 3.b Hard limits

| Limit | Value | Source |
|---|---|---|
| Total Apple-hosted assets per app record | **200 GB** | App Store Connect Help, *Apple-hosted asset pack size limits* |
| Asset pack **count** per app record | **200 packs** | same |
| Per-asset-pack maximum size | **Apple publishes none.** The help page lists only the two rows above. | same |
| Per-file maximum size inside a pack | **Apple publishes none.** | same |
| Notification threshold | email + ASC banner at 80 % of 200 GB (160 GB) | same |
| iOS app bundle (uncompressed) | **4 GB** | App Store Connect Help, *Maximum build file sizes* |
| iOS executable `__TEXT` total | **80 MB** | same |
| macOS app bundle (uncompressed) | **200 GB** | same |

`BAEssentialMaxInstallSize` (iOS 18.0+) and `BAMaxInstallSize` (iOS 16.0+) are
`Info.plist` keys declaring, in bytes, the combined maximum **uncompressed** size of the
essential assets downloaded before first launch and of the non-essential assets
downloaded right after install. Apple: *"The App Store uses this key to show the size of
your app on the product page, so provide an accurate value. If you compress the assets,
use the uncompressed size of the files for this value. Don't overstate the disk space you
require."* Both pages say *"This key is required to use Background Assets."*

**Important nuance:** those two keys belong to the **unmanaged** Background Assets path.
The Apple-hosted managed path lists only the three keys in §3.a and instructs you to omit
everything else. The two statements in Apple's own docs are in tension. **UNVERIFIED —
which of the two wins for an Apple-hosted managed app is not resolvable from the
documentation; test it against App Store Connect validation before submitting.**

**Relative to RAA these limits are irrelevant.** 200 GB and 200 packs against a plan
needing ~13 packs and well under 1 GB. The limits are not the constraint; the effort is.

### 3.c File formats — can a `.car` or a `.spriteatlas` live in a pack?

**No, not in any documented way.** An asset pack is built by `xcrun ba-package` from a
manifest whose `fileSelectors` name **individual files (`file:`) and folders
(`directory:`)** on disk. At runtime the system merges all downloaded packs into one
shared logical namespace and you address content by **relative path** —
`contents(at:)` → `Data`, `descriptor(for:)` → `FileDescriptor`, `url(for:)` → `URL`.

An Xcode `.spriteatlas` is not a file you ship; it is a *source* directory that the Xcode
build system compiles into the app's `Assets.car`. `SKTextureAtlas(named:)` resolves
against the main bundle's compiled catalog (or a legacy `.atlas` folder in the bundle).
**There is no API that points `SKTextureAtlas(named:)` at an external `.car`.** Apple also
notes the compiled atlas format "is private and subject to change."

**UNVERIFIED workaround:** you could run `actool` yourself to produce a `MyPack.bundle`
containing an `Assets.car`, put that bundle in an asset pack, and load images with
`UIImage(named:in:compatibleWith:)` against `Bundle(url:)`. Each piece is individually
documented; the combination is not documented as supported for Background Assets and
should not be relied on without testing.

**The supported route is loose PNGs + a runtime atlas.** Signature:

```swift
convenience init(dictionary properties: [String : Any])   // iOS 8.0+
```

Keys are texture names; values may be an `NSString` filesystem path, an `NSURL`, a
`UIImage`, or an `NSImage`. (Marina's note said `SKTextureAtlas(dictionaryNamed:)` — that
initializer does not exist; the real one is `init(dictionary:)`.) `SKTexture(image:)` is
available as the per-texture fallback, and `atlas.preload()` /
`preload(completionHandler:)` warms them on a background task.

**What you lose by leaving the asset catalog:**

- **Xcode's atlas packing.** Xcode bin-packs an atlas's member images into one or more
  large sheets so SpriteKit can batch draws. `init(dictionary:)` hands SpriteKit loose
  images to pack at runtime — Apple calls it *"a potentially expensive operation best
  performed when your game loop is not running."* For a 15-frame full-screen-ish building
  animation the draw-call benefit is near zero anyway (one sprite on screen at a time), so
  this loss is theoretical for the build/grow case and would matter for the
  character/animal atlases.
- **Trimming / `provides-namespace` behaviour.** RAA's build atlases already set
  `"provides-namespace": false`, so frame names are flat and would carry over unchanged.
- **`@2x`/`@3x` selection and app thinning.** The catalog picks the right scale per device
  and the App Store slices out the rest. A pack ships one copy to everyone. RAA's frames
  are single-scale today (one PNG per imageset, no `@2x`), so nothing is lost *now* — but
  it forecloses per-device thinning later.
- **Asset-catalog lossy compression** — which, per §6, is the single biggest lever
  available. Leaving the catalog means re-implementing that by hand-encoding HEIC files.

**Runtime cost:** a texture that comes from a memory-mapped `Data` or a `URL` outside the
catalog is decoded on first use rather than being ready in the compiled catalog, so budget
a `preload()` before the animation plays rather than mid-animation.

### 3.d Eviction — the core question

This is the part that works exactly the way Marina hoped, with one significant asterisk.

- **Removal API:** `func remove(assetPackWithID assetPackID: String) async throws`.
  Apple's own worked example is literally this use case: *"when you are done with an asset
  pack, call the `remove(assetPackWithID:)` method on the shared asset-pack manager to
  free up storage space on the device. For example, remove the tutorial asset pack when a
  person finishes playing the tutorial."*
- **No system auto-purging:** *"The system tracks which asset packs you download and
  automatically keeps them up to date in the background. However, **the system won't
  automatically remove your asset packs while your app is installed.**"* This is the
  opposite of On-Demand Resources, which the OS purges under disk pressure. It means
  eviction in RAA must be an explicit app decision — and that a pack downloaded once and
  never removed is permanent dead weight on the device.
- **Re-downloading:** *"To redownload an asset pack, call the `ensureLocalAvailability(of:)`
  method again."* There is no charge and no per-app quota on re-downloads; the cost is the
  player's bandwidth and wait. `AssetPack.downloadSize` lets you show it.
- **★ The asterisk: granularity is the whole pack. There is no API to keep one file and
  evict the rest of the pack that contains it.** `remove(assetPackWithID:)` takes a pack
  ID; nothing in `AssetPackManager` takes a file path. **So Marina's "keep only the final
  frame, evict the rest" cannot be done inside a pack.** It has to be done by *layout*:
  the final frame lives somewhere that is never evicted (in RAA's case, the app bundle),
  and the intermediate frames are alone in an evictable pack.
- **One pack per building vs. one big pack — this decides everything.** One 89 MB
  `AllBuildAnimations` pack can only be removed once all 8 buildings are done, so a player
  who finishes the Pantheon carries the other seven buildings' frames until the very end.
  Eight per-building packs (`PantheonBuild`, `AqueductBuild`, …) can each be removed the
  moment that building completes, which is the behaviour Marina described. **Use one pack
  per building.** The 200-pack limit makes this free.
- **Device restore / new device:** **UNVERIFIED.** Apple's documentation does not state
  whether downloaded asset packs survive an iCloud or finder restore, or whether a restored
  device re-downloads `essential`/`prefetch` packs automatically. Design so that the answer
  does not matter: a missing pack must always degrade to "no animation," never to "broken
  building" (§8).

### 3.e On-Demand Resources on iOS 26 — and which fits RAA

`NSBundleResourceRequest` (iOS 9.0+) still exists and still works on iOS 26. But
Apple's App Store Connect Help states plainly:

> **On-demand resources has been deprecated on Apple platforms as of iOS 27, iPadOS 27,
> tvOS 27, and visionOS 27, and support will be removed in future releases. Migrating to
> Background Assets is recommended.**

ODR limits, for completeness (iOS 18+): 512 MB → **8 GB** per asset pack, 1000 packs,
**70 GB** hosted total, no limit on in-use ODR. macOS does **not** support ODR at all —
which alone disqualifies it for RAA, a SwiftUI app that also ships on the Mac.

ODR's purging model is the mirror image of Background Assets': the system *does*
auto-purge ODR tags under disk pressure, `NSBundleResourceRequest` holds a tag in place
only while the request object lives, and `Bundle.setPreservationPriority(_:forTags:)`
lets you hint which tags to purge first. That is attractive — the OS does the eviction for
you — but it also means you cannot guarantee a pack is present, and it is being removed
from the platform.

**Verdict: Background Assets, Apple-hosted, managed.** It is not deprecated, it matches
the iOS 26 floor, it works on macOS 26, and `remove(assetPackWithID:)` gives explicit
control that suits a game where "this building is finished forever" is a durable fact.
ODR is a dead end.

### 3.f Testing, TestFlight, App Review

**Local testing** uses a mock HTTPS server, no App Store Connect round-trip:

```sh
xcrun ba-serve --host localhost PantheonBuild.aar AqueductBuild.aar
```

Background Assets requires HTTPS for all downloads, so you must issue an SSL certificate
for the mock server. The full procedure (Keychain Access → create a self-signed root CA →
Apple Configurator profile → install and trust on test devices → issue a server cert) is
documented; on device, enable Developer Mode then **Settings → Developer → Development
Overrides → Background Assets Testing → URL Override** and enter the server's base URL.
On macOS: `xcrun ba-serve url-override https://<host>`. **Budget half a day for the
certificate dance the first time** — it is the least fun part of this whole plan.

**TestFlight:** Apple-hosted Background Assets is available for apps on TestFlight as well
as the App Store. Packs are uploaded to App Store Connect independently of builds, and
must be **submitted for review** before external TestFlight testers or App Store users can
receive them.

**App Review:** the guideline people worry about is **2.5.2**:

> *Apps should be self-contained in their bundles, and may not read or write data outside
> the designated container area, nor may they download, install, or execute code which
> introduces or changes features or functionality of the app, including other apps.*

That clause is about **code**, not art. Downloading textures and audio through Apple's own
Background Assets service is exactly what the service exists for, and Apple's marketing of
it names "texture files, machine learning models, Metal shader libraries, and videos" as
intended payloads. The practical review risk is different and smaller: a reviewer on a
throttled network who cannot get the packs must still see a working app. That is precisely
the constraint Marina already set (completed buildings and grown trees stay in the
bundle), and the fallback in §8 preserves it.

---

## 4. Inventory and verdicts

All PNG figures are **actual bytes of the source PNG files in this clone**, measured with
Pillow. The "lossy est." column is a **WebP q80 re-encode used as a stand-in for Xcode's
lossy (HEIF) asset-catalog compression** — same class of codec, not the same codec. Treat
it as an estimate accurate to roughly ±30 %, not a promise (§6, §9).

| # | Category | Files | Current | Verdict | Est. after | Saved |
|---|---|---|---|---|---|---|
| 1 | Four oversized backgrounds: `WorkshopBackground` (8866×5000, 40.2 MB), `Forest1` (4500×3214, 29.1 MB), `Terrain` (28.8 MB), `WorkshopTerrain` (27.2 MB) | 4 | **125.3 MB** | **Recompress** (lossy) + review whether 8866 px wide is needed | ~8.2 MB | **~117 MB** |
| 2 | 8 building-construction atlases (`*Build`, 15 frames each, 781–995 px) | 120 | **89.3 MB** | **Recompress** (lossy — textbook case: short on-screen duration). Optionally stream later (§5) | ~12.3 MB | **~77 MB** |
| 3 | 14 character/animal atlases (`ApprenticeWalk`, `BirdFlySit`, `Pig*`, `FrogCroak`, `DeerGraze`, `OwlLook`, …) | 196 | **18.7 MB** | **Ship in app** — these loop constantly; never stream. Recompress only. | ~2.9 MB | **~16 MB** |
| 4 | 5 tree-growth atlases (`Chestnut` 2.6, `Walnut` 2.3, `Oak` 2.2, `Poplar` 0.6, `Cypress` 0.4) | 63 | **7.7 MB** | **Ship in app.** Too small to be worth a CDN pack; recompress only. | ~1.5 MB | **~6 MB** |
| 5 | All other standalone imagesets (icons, blueprints, letter frames, station art, UI) | 493 | **227.4 MB** | **Recompress**; audit `PantheonStep1Infographic` (5.9 MB) and the 44 `LorenzoLetterFrame*` (~1.5 MB each) for over-resolution | ~21.0 MB | **~206 MB** |
| — | **Asset catalog subtotal** | **876** | **468.4 MB** | | **~45.9 MB** | **~422 MB** |
| 6 | 4 long-form WAVs: `music_lesson` (22.9 MB, 48 kHz/24-bit/stereo/83 s), `forest_ambient` (22.8 MB, 48 kHz/24-bit/mono/166 s), `crafting_ambient` (18.2 MB, **96 kHz**/24-bit/stereo/33 s), `workshop_ambient` (15.3 MB, **96 kHz**/24-bit/stereo/28 s) | 4 | **79.1 MB** | **Recompress to AAC/M4A.** 96 kHz 24-bit stereo for a 28-second ambience loop is ~200× the bits a game needs. | ~4.7 MB @128 kbps | **~74 MB** |
| 7 | 49 other shipped audio files (SFX + narration) | 49 | **15.5 MB** | **Recompress** the 24-bit WAV SFX to AAC; leave the small `.mp3`s | ~3 MB | **~12 MB** |
| 8 | Fonts: both variable fonts *and* full static families for EBGaramond (12 files) and Cinzel (6) | 31 | **9.0 MB** | **Trim** — pick variable *or* statics per family, not both. Needs care: `RenaissanceArchitectAcademyApp.swift` registers by name via CoreText. | ~5 MB | **~4 MB** |
| 9 | `.atlasc` folder references (`RiverHouse`, `Woodcutter`, `Fisherman`) | 3 | **1.3 MB** | **Ship in app.** Not worth touching. | 1.3 MB | 0 |
| 10 | `OriginalAssets_Backup/`, all `.mp4` files | — | **0 MB shipped** | **Already excluded.** Delete from disk to reclaim Marina's local space; no app-size effect. | 0 | **0** |
| 11 | Duplicate/misplaced build-file entries (§2.4) | 5 | **~0 MB** | **Fix anyway** — build warnings and a latent footgun | 0 | **0** |
| 12 | `city_ambient.mp3`, `footstep_old.wav`, `mine_call_forza.mp3` | 3 | **0 MB shipped** | **Decide:** either wire them up or delete. `footstep_old.wav` looks like dead art. | 0 | **0** |

**Caveat that matters:** rows 1–5 sum to 468 MB of *source PNG*, but the compiled
`Assets.car` is already only ~315 MB — the catalog compiler is already saving ~33 % with
lossless encoding. So the realistic `.car` after lossy compression is **not** 46 MB; it is
somewhere in the **50–70 MB** range. **UNVERIFIED — this must be measured with a real
archive build on Marina's Mac (§9).** The ~422 MB "saved" figure is a source-PNG delta and
will over-state the shipped delta; the *shipped* delta is more like **245–265 MB** from
the catalog. The audio figures (rows 6–7) are shipped-byte-accurate because audio files
are copied verbatim, not recompiled.

**Bottom line on shipped payload:**

| | Now | After Phases 0–2 |
|---|---|---|
| `Assets.car` | ~315 MB | **~50–70 MB** (UNVERIFIED) |
| Audio | 94.6 MB | **~8 MB** |
| Fonts | 9.0 MB | ~5 MB |
| `.atlasc` | 1.3 MB | 1.3 MB |
| **Total** | **~420 MB** | **~65–85 MB** |

---

## 5. Pack layout (if and when Phase 4 happens)

**Non-negotiable constraint, restated:** every building's completed sprite and every
tree's final frame stay in the app bundle, so an offline player sees a finished city and a
finished forest.

**Two things in the current code make that constraint bigger than it looks:**

1. `BuildingNode.setupUnbuiltBuilding()` (`BuildingNode.swift:397–408`) draws **frame 00**
   of the build atlas for the `.available`, `.sketched` and `.construction` states. So
   **frame 00 must stay in the bundle too**, not just the completed sprite — otherwise an
   offline player sees an empty plot where an unbuilt building should be.
2. **Trees have no final-frame asset at all.** `ForestScene.setupPOIs()`
   (`ForestScene.swift:599–608`) builds the frame array from `<Name>GrowFrame00…` and
   `growTree(at:)` (`:889–893`) just animates and stops on the last frame. There is no
   `ChestnutGrown` imageset — `ls Assets.xcassets/*Grown*` returns nothing. **Satisfying
   Marina's constraint for trees requires authoring 5 new final-frame imagesets first.**

Given that, and given trees total only 7.7 MB, **do not make packs for trees.** They stay
in the bundle whole.

### Stays in the app bundle, always

| Asset | Why |
|---|---|
| `Pantheon`, `Aqueduct`, `Harbor`, `Insula`, `RomanRoad`, `SiegeWorkshop`, `Glassworks`, `Duomo` imagesets (8 × ~0.8 MB ≈ 6.6 MB) | Completed city must render offline |
| **`<Name>BuildFrame00` for all 8** (~6 MB) | Unbuilt/sketched/construction states render offline |
| All 5 `*Grow` atlases whole (7.7 MB) | Too small to stream; no final-frame asset exists |
| All 14 character/animal atlases (18.7 MB) | Play repeatedly; streaming would be a regression |
| Everything else in the catalog | Not the problem |

### Asset packs — 8 packs, one per building

| Pack ID | Contents | Policy |
|---|---|---|
| `PantheonBuild` | `BuildFrames/PantheonBuild/PantheonBuildFrame01.heic … Frame14.heic` (14 frames — **frame 00 is excluded**, it lives in the bundle) | `onDemand` |
| `AqueductBuild` | `BuildFrames/AqueductBuild/Frame01…14` | `onDemand` |
| `HarborBuild` | ” | `onDemand` |
| `InsulaBuild` | ” | `onDemand` |
| `RomanRoadBuild` | ” | `onDemand` |
| `SiegeWorkshopBuild` | ” | `onDemand` |
| `GlassworksBuild` | ” | `onDemand` |
| `DuomoBuild` | ” | `onDemand` |

**Why `onDemand` and not `prefetch`:** `prefetch` downloads everything right after
install, which for a player who only ever builds the Pantheon means paying for eight
buildings' frames. `onDemand` downloads a pack the first time a player is actually about
to build that building. The cost is a wait at that moment — which is why §8 specifies
prefetching the *next* building's pack in the background once the previous one completes.

**Never use `essential` here.** `essential` blocks app launch on the download, which would
be a strictly worse first-run experience than shipping the frames in the bundle.

**Manifest shape** (one per building, paths relative to repo root):

```json
{
  "assetPackID": "PantheonBuild",
  "downloadPolicy": { "onDemand": {} },
  "fileSelectors": [
    { "directory": "AssetPackSources/BuildFrames/PantheonBuild" }
  ],
  "platforms": ["iOS", "iPadOS", "macOS"]
}
```

**Size after Phase 1 recompression:** 14 frames × ~0.10 MB ≈ **1.4 MB per pack, ~11 MB
across all 8.** Which is the whole argument against Phase 4 in one number — see §6.

---

## 6. Eviction design

### The rule

`remove(assetPackWithID:)` removes a whole pack; it cannot keep one file. So the design is
**layout, not surgery**: frame 00 and the completed sprite are in the bundle and are never
evictable; frames 01–14 are alone in a pack that is removed the moment the building's
state reaches `.complete`.

```swift
// Called from CityViewModel once the building's state is persisted as .complete.
func evictBuildFramesIfPossible(for buildingId: String) async {
    guard #available(iOS 26.0, macOS 26.0, *),
          let packID = BuildingNode.buildAnimationPackID(for: buildingId) else { return }
    do {
        try await AssetPackManager.shared.remove(assetPackWithID: packID)
    } catch {
        // Nothing the player can do about it; the pack is just dead weight until next time.
        print("[Assets] could not evict \(packID): \(error)")
    }
}
```

**Evict on persisted completion, never on animation-finished.** If the app is killed
between the animation ending and the save landing, an evict-on-animation design leaves a
building that is not-complete *and* has no frames.

### Does the player ever see it twice?

Today, **yes, and more often than Marina probably expects** — which is the real bug this
work would surface.

- **Buildings:** `hasPlayedConstructionBuild` is a plain instance property on `BuildingNode`
  (`BuildingNode.swift:26`) that is reset to `false` on every `updateState(_:)` call
  (`:60`). Once a building is `.complete`, `updateState(.complete)` routes to
  `setupCompletedBuilding()` and the animation is not replayed — so in practice a completed
  building does *not* re-animate. Evicting after `.complete` is therefore safe **as long as
  nothing re-enters `.construction`**. The one path that would is a "reset progress" or
  debug action; `BuildingNode.debugShowAllComplete` exists but only forces the completed
  visual, so it is not affected.
- **Trees:** `growingTrees` is rebuilt from scratch in `setupPOIs()` every time the forest
  scene is created, with `tree.isHidden = true` — and `willMove(from:)` clears it
  (`ForestScene.swift:941`). **Grown-tree state is not persisted anywhere.** A player who
  grows a chestnut, leaves the forest, and comes back finds an empty planting spot. That is
  a pre-existing bug, unrelated to asset size, and it is why §4 says leave trees in the
  bundle: eviction on top of non-persisted state would turn a cosmetic reset into a
  permanently blank spot.

**Replay after eviction, when it happens:** `ensureLocalAvailability(of:)` re-downloads for
free. Treat replay as "download if missing, else animate; if the download fails, skip
straight to complete."

### On device restore

**UNVERIFIED** whether packs survive a restore. Design so it does not matter: the fallback
in §8 makes a missing pack indistinguishable from a slow network — the building completes,
just without the stone-by-stone flourish. A restored player who replays a building would
simply re-download 1.4 MB.

### Prefetch the next one

Once a building completes and its pack is evicted, kick off a background
`ensureLocalAvailability` for the pack of the next unlocked building, so the wait is
absorbed while the player is reading a lesson rather than staring at a plot.

---

## 7. Code changes

Keyed to symbols read in this clone. **None of this was applied** — these are sketches for
Phase 4, and they are deliberately additive so the existing offline path stays the default.

### 7.1 `BuildingNode.swift` — pack ID alongside the atlas name

`buildAnimationAtlasName()` (`:170–182`) already maps `buildingId` → `(atlas, frameCount)`.
Add the pack ID next to it rather than inventing a parallel map:

```swift
/// Asset-pack ID holding frames 01…14 for this building. Frame 00 and the completed
/// sprite stay in the app bundle, so this pack is safe to evict once built.
static func buildAnimationPackID(for buildingId: String) -> String? {
    switch buildingId {
    case "pantheon":      return "PantheonBuild"
    case "aqueduct":      return "AqueductBuild"
    case "harbor":        return "HarborBuild"
    case "insula":        return "InsulaBuild"
    case "romanRoads":    return "RomanRoadBuild"
    case "siegeWorkshop": return "SiegeWorkshopBuild"
    case "glassworks":    return "GlassworksBuild"
    case "duomo":         return "DuomoBuild"
    default:              return nil
    }
}
```

### 7.2 `BuildingNode.swift` — frame loading with a bundle-first fallback

Today `playConstructionBuild` (`:307–325`) and `setupUnbuiltBuilding` (`:397–408`) both do
`SKTextureAtlas(named: build.atlas)`. Replace the frame *lookup* only; the animation code
is unchanged.

```swift
/// Frames 01…14 for `build`, or nil when the pack isn't on the device.
/// Frame 00 always comes from the app bundle, so unbuilt buildings never disappear.
@available(iOS 26.0, macOS 26.0, *)
private static func streamedBuildFrames(_ build: (atlas: String, frameCount: Int)) -> [SKTexture]? {
    var images: [String: Any] = [:]
    for i in 1..<build.frameCount {
        let name = String(format: "%@Frame%02d", build.atlas, i)
        // contents(at:) throws when the pack isn't local — that's the whole offline check.
        guard let url = try? AssetPackManager.shared.url(
            for: FilePath("AssetPackSources/BuildFrames/\(build.atlas)/\(name).heic")
        ) else { return nil }
        images[name] = url as NSURL
    }
    guard !images.isEmpty else { return nil }
    let atlas = SKTextureAtlas(dictionary: images)          // iOS 8.0+; values may be NSURL
    let bundleFrame00 = SKTexture(imageNamed: String(format: "%@Frame00", build.atlas))
    return [bundleFrame00] + (1..<build.frameCount).map {
        atlas.textureNamed(String(format: "%@Frame%02d", build.atlas, $0))
    }
}

/// Bundle-only frames. Used when the pack is absent, and on macOS < 26.
private func bundleBuildFrames(_ build: (atlas: String, frameCount: Int)) -> [SKTexture] {
    let atlas = SKTextureAtlas(named: build.atlas)
    return (0..<build.frameCount).map {
        atlas.textureNamed(String(format: "%@Frame%02d", build.atlas, $0))
    }
}
```

### 7.3 `BuildingNode.swift` — `playConstructionBuild` must always call `completion`

This is the fallback that keeps construction *completing* offline. The guard at `:308`
already calls `completion()` for buildings with no build art; extend the same discipline to
a missing pack.

```swift
func playConstructionBuild(completion: @escaping () -> Void) {
    guard let build = buildAnimationAtlasName() else { completion(); return }

    var frames: [SKTexture]?
    if #available(iOS 26.0, macOS 26.0, *) {
        frames = BuildingNode.streamedBuildFrames(build)
    }
    // Pack missing / not downloaded / pre-26 macOS → no animation, but construction
    // still completes. This is the App Review and airplane-mode path.
    guard let frames, let first = frames.first else {
        completion()
        return
    }

    visualContainer.removeAllChildren()
    let sprite = SKSpriteNode(texture: first)
    sprite.size = aspectFittedSpriteSize(for: first)
    visualContainer.addChild(sprite)

    sprite.run(SKAction.sequence([
        SKAction.animate(with: frames, timePerFrame: buildFrameTime, resize: false, restore: false),
        SKAction.run(completion)
    ]))
}
```

`playCompletionBloom()` (`:327–389`) needs **no change**: it calls
`playConstructionBuild { self?.playCompletionBloom() }` at `:331` and that closure now runs
immediately on the offline path, so the bloom, the `buildingComplete` sound, and the
`updateState(.complete)` at `:386` all still fire. `setupUnbuiltBuilding()` (`:397`) also
needs **no change** — it only ever touches frame 00, which stays in the bundle.

### 7.4 Download before building, with progress

Called when the player commits to constructing, not at map load:

```swift
@available(iOS 26.0, macOS 26.0, *)
func prepareBuildAnimation(for buildingId: String) async -> Bool {
    guard let packID = BuildingNode.buildAnimationPackID(for: buildingId) else { return false }
    do {
        let pack = try await AssetPackManager.shared.assetPack(withID: packID)
        try await AssetPackManager.shared.ensureLocalAvailability(of: pack)
        return true
    } catch {
        return false          // offline → §7.3 skips the animation, construction proceeds
    }
}
```

Show progress with `AssetPackManager.shared.statusUpdates(forAssetPackWithID: packID)`
(`.began` / `.downloading(_, Progress)` / `.finished` / `.failed`). At ~1.4 MB a pack this
will usually be invisible; the UI matters only on a bad connection.

### 7.5 `ForestScene.swift` — **no change recommended**

`treeGrowths` (`:128–139`), `setupPOIs()` (`:599–608`) and `growTree(at:)` (`:889–893`)
should be left alone for asset-size purposes: 7.7 MB total, no final-frame assets exist,
and grown state is not persisted. If Marina wants trees streamed later, the prerequisite
work is (a) author `<Name>Grown` imagesets, (b) persist grown tree indices, (c) have
`setupPOIs` show `<Name>Grown` for already-grown trees instead of frame 0 — and only then
(d) move frames 01…N into packs. That is a bigger change than the 6 MB it would save.

---

## 8. Cheaper alternatives, compared honestly

All measured on this clone's real files. "Lossy est." = WebP q80 as a proxy for Xcode's
lossy HEIF asset-catalog compression.

| Option | Build frames (89.3 MB) | Whole catalog (468.4 MB) | Effort | Code changes | Offline risk |
|---|---|---|---|---|---|
| **Xcode lossy compression on imagesets** | **12.3 MB (−86 %)** | **45.9 MB (−90 %)** | ~2 h to set + a build to verify | **none** | **none** |
| 256-colour palette PNG | 16.9 MB (−81 %) | 76.3 MB (−84 %) | ~3 h (re-export script) | none | none |
| Re-render at 0.75× current (≈0.56 of source) | 54.9 MB (−39 %) | — | ~4 h re-export + visual check | none | none |
| Re-render at 0.50× current | 26.3 MB (−71 %) | — | ~4 h + real quality loss at zoom 3.5 | none | none |
| Lossy **and** 0.75× | **8.4 MB (−91 %)** | — | ~5 h | none | none |
| 15 frames → 8 frames | 47.6 MB (−47 %) | — | ~3 h re-cut, animation gets choppier | `frameCount` constants | none |
| **Background Assets CDN + eviction** | **~11 MB stays hosted; ~6 MB of frame 00s remain in bundle** | — | **~3–5 days** | extension target, app group, 3 plist keys, ASC uploads, ~150 lines Swift, cert dance | **real** — needs the fallback in §7.3, and a reviewer on bad wifi sees no animation |
| Audio → AAC 128 kbps | — | 94.6 MB → ~8 MB | ~2 h | none (AVAudioPlayer reads m4a) | none |

**Read the first and last rows together.** Lossy compression takes the build frames from
89.3 MB to ~12.3 MB in about two hours with zero code. The entire CDN project, after
several days of work, would then be fighting over what remains of that 12.3 MB — of which
~6 MB (the frame 00s) has to stay in the bundle anyway. **The CDN's marginal saving over
just recompressing is on the order of 6 MB.**

**So: the boring option wins, decisively, and it is not close.** Lossy asset-catalog
compression is also exactly what Apple recommends for this content — their guidance is that
lossy suits "image artwork that have fairly short on-screen duration, such as artwork shown
on splash screens or through animations and effects," which describes a 2.4-second
construction sequence precisely.

Two more things the numbers make obvious:

- **The backgrounds, not the animations, are the biggest single target.** Four files —
  `WorkshopBackground`, `Forest1`, `Terrain`, `WorkshopTerrain` — are 125.3 MB, more than
  the eight build atlases combined. `WorkshopBackground` is 8866×5000; that is 44
  megapixels for a background on a device whose screen is at most ~3 megapixels.
- **The audio is nearly free money.** 79.1 MB in four files, two of which are **96 kHz
  24-bit stereo** ambience loops under 35 seconds. No player will hear the difference at
  128 kbps AAC, and that is a 94 % cut with no code change at all.

---

## 9. Phased rollout, ordered by MB saved per hour

| Phase | Work | Est. effort | Est. MB saved | MB/hour |
|---|---|---|---|---|
| **0** | **Fix the pbxproj hygiene** (§2.4): drop the two duplicate `crafting_ambient.wav` build files and the duplicate `volcano_rumble_ambient.mp3`; remove `GirlIntroAudio.m4a` and `card_flip.mp3` from the Sources phase; decide on the 3 orphaned audio files | 0.5 h | ~0 | — (do it anyway; it's 30 min and removes build warnings) |
| **1** | **Audio → AAC.** Re-encode the 4 long WAVs at 128 kbps and the 24-bit SFX WAVs at 96 kbps mono. Verify `SoundManager` paths. | 2 h | **~86 MB** | **43** |
| **2** | **Asset-catalog lossy compression.** Set imageset compression to lossy across the catalog — start with the 8 `*Build` atlases, the 5 `*Grow` atlases, and the 4 big backgrounds, then the rest. **Measure a real archive build before and after.** | 3 h | **~245–265 MB shipped** (see §4 caveat) | **~85** |
| **3** | **Downscale the four backgrounds.** `WorkshopBackground` at 44 MP is the outlier; decide a real target resolution from the max camera zoom (3.5×) and re-export. | 3 h | ~4 MB on top of Phase 2 | 1.3 |
| **4** | **Font trim** (§4 row 8) — pick variable or static per family | 1.5 h | ~4 MB | 2.7 |
| **5** | **Background Assets, if still wanted after Phases 1–3.** Extension target + app group + 3 plist keys; re-export frames 01–14 as loose HEIC; write §7's code; certificate + `ba-serve` setup; ASC upload and review | **3–5 days** | **~6 MB over Phase 2** | **~0.2** |

**Stop after Phase 3.** Phases 0–3 take roughly one working day and land the app at
**~65–85 MB**. Phase 5 is a 3–5 day project for ~6 MB more and a new class of runtime
failure. Revisit it only if the art grows several-fold, or if Marina wants per-building DLC
or post-launch art updates without shipping a build — those are good reasons to adopt
Background Assets, and they are product reasons, not size reasons.

**Verification for every phase** (per CLAUDE.md: this project has no XCTest suite):
`xcodebuild … > /tmp/log 2>&1`, one build at a time, then an iPad-simulator smoke test of
the city map (build a building end-to-end), the forest (grow a tree), the workshop, and
the lesson audio. For Phase 2 specifically, the check is an **archive** build with the
size report, not a debug build — the `.car` numbers in §4 are otherwise unverifiable.

---

## 10. Risks, open questions, and Marina's decisions

### Risks

1. **The lossy-compression estimate is a proxy, not a measurement.** All "est. after"
   figures use WebP q80 to stand in for Xcode's lossy HEIF. The direction is certain and
   the magnitude is roughly right, but **the real number can only come from an archive
   build on a Mac.** Do Phase 2 on the 8 build atlases alone first, measure, then decide
   whether to roll it across the other 493 imagesets.
2. **Lossy compression is visible on some art.** Flat-colour UI, blueprints with thin
   lines, and text-bearing images (the 44 `LorenzoLetterFrame*`) can band or ring under
   lossy encoding. Watercolour backgrounds and building frames will not. Apply per-imageset,
   not catalog-wide-and-hope.
3. **macOS 14 vs. `AssetPackManager`'s macOS 26 floor.** Any Background Assets adoption
   either raises the macOS deployment target by 12 versions or `@available`-gates the whole
   feature so Mac users always get the bundle path.
4. **`assetPackIsAvailableLocally` is iOS 26.4.** On 26.0–26.3 there is no cheap offline
   presence check; the code must be written as try-and-catch (§7.2 does this).
5. **Background Assets packs are never auto-purged.** A pack downloaded and not explicitly
   removed is permanent. A bug in the eviction path makes the app *larger* on disk than
   shipping the frames would have been.
6. **`SKTextureAtlas(dictionary:)` packs at runtime** — Apple calls it "potentially
   expensive… best performed when your game loop is not running." Build it during the
   download, not on the frame the animation starts.
7. **The tree-grown-state bug is real and independent of all this** (§6). Worth a ticket
   regardless of what happens to asset size.

### Open questions (UNVERIFIED — flagged rather than guessed)

- Whether `BAEssentialMaxInstallSize` / `BAMaxInstallSize` are required for an
  Apple-hosted **managed** app. Apple's plist pages say "required to use Background
  Assets"; the Apple-hosted guide says to omit all keys but the three in §3.a. Resolve
  against App Store Connect validation, not against the docs.
- Whether downloaded asset packs survive an iCloud/device restore, and whether a restored
  device re-downloads `essential`/`prefetch` packs automatically. Not documented.
- Whether a compiled `Assets.car` inside a `.bundle` inside an asset pack, loaded via
  `Bundle(url:)` + `UIImage(named:in:)`, works. Each piece is documented; the combination
  is not, and the compiled atlas format is explicitly "private and subject to change."
- Exact per-asset-pack and per-file size limits for Apple-hosted packs. **Apple publishes
  none** — only the 200 GB total and 200-pack count.
- What RAA's *App Store download* size is today, as opposed to the ~420 MB on-disk payload.
  Only App Store Connect's size report answers this, and it is the number that actually
  matters to a student on a school network.

### Decisions only Marina can make

1. **Accept lossy compression on the art?** This is a visual-quality decision on a
   watercolour-and-blueprint aesthetic, and per CLAUDE.md nobody else gets to make it. The
   recommendation is: yes for the build/grow frames and the four backgrounds, and
   case-by-case for the blueprints and letter frames.
2. **Target resolution for `WorkshopBackground`** (currently 8866×5000). Needs a call on
   max camera zoom versus sharpness.
3. **macOS deployment target** — stay at 14 and gate Background Assets off on Mac, or move
   to 26?
4. **Is Background Assets wanted for reasons other than size** — post-launch art updates,
   per-building DLC, a seasonal content drop? If yes, Phase 5 is worth doing on its own
   merits and the size saving is a bonus. If no, §8 says skip it.
5. **The 3 orphaned audio files** — wire up or delete?
6. **Fonts** — variable or static per family? Affects the CoreText registration in
   `RenaissanceArchitectAcademyApp.swift`.

---

## 11. Documentation URLs used

**Background Assets**
- https://developer.apple.com/documentation/backgroundassets
- https://developer.apple.com/documentation/backgroundassets/creating-managed-asset-packs
- https://developer.apple.com/documentation/backgroundassets/downloading-apple-hosted-asset-packs
- https://developer.apple.com/documentation/backgroundassets/testing-asset-packs-locally
- https://developer.apple.com/documentation/backgroundassets/reducing-download-and-storage-demands-with-localized-asset-packs
- https://developer.apple.com/documentation/backgroundassets/assetpackmanager
- https://developer.apple.com/documentation/backgroundassets/assetpack
- https://developer.apple.com/documentation/backgroundassets/assetpackmanifest
- https://developer.apple.com/documentation/backgroundassets/manageddownloaderextension
- https://developer.apple.com/documentation/backgroundassets/assetpackmanager/remove(assetpackwithid:)
- https://developer.apple.com/documentation/backgroundassets/assetpackmanager/ensurelocalavailability(of:)
- https://developer.apple.com/documentation/backgroundassets/assetpackmanager/contents(at:searchinginassetpackwithid:options:)
- https://developer.apple.com/documentation/backgroundassets/assetpackmanager/url(for:)
- https://developer.apple.com/documentation/backgroundassets/assetpackmanager/status(ofassetpackwithid:)
- https://developer.apple.com/documentation/backgroundassets/assetpackmanager/localstatus(ofassetpackwithid:)
- https://developer.apple.com/documentation/backgroundassets/assetpackmanager/assetpackisavailablelocally(withid:)
- https://developer.apple.com/documentation/backgroundassets/assetpackmanager/statusupdates
- https://developer.apple.com/documentation/backgroundassets/assetpack/downloadsize

**Info.plist keys**
- https://developer.apple.com/documentation/bundleresources/information-property-list/bahasmanagedassetpacks
- https://developer.apple.com/documentation/bundleresources/information-property-list/bausesapplehosting
- https://developer.apple.com/documentation/bundleresources/information-property-list/baappgroupid
- https://developer.apple.com/documentation/bundleresources/information-property-list/baessentialmaxinstallsize
- https://developer.apple.com/documentation/bundleresources/information-property-list/bamaxinstallsize

**Limits and App Store Connect**
- https://developer.apple.com/help/app-store-connect/reference/apple-hosted-asset-pack-size-limits
- https://developer.apple.com/help/app-store-connect/reference/maximum-build-file-sizes
- https://developer.apple.com/help/app-store-connect/reference/app-uploads/on-demand-resources-size-limits
- https://developer.apple.com/documentation/AppStoreConnectAPI/managing-apple-hosted-background-assets

**On-Demand Resources**
- https://developer.apple.com/documentation/foundation/nsbundleresourcerequest

**SpriteKit**
- https://developer.apple.com/documentation/spritekit/sktextureatlas
- https://developer.apple.com/documentation/spritekit/about-texture-atlases
- https://developer.apple.com/documentation/spritekit/sktextureatlas/init(dictionary:)
- https://developer.apple.com/documentation/spritekit/sktextureatlas/preload(completionhandler:)
- https://developer.apple.com/documentation/spritekit/sktexture/init(image:)

**App size and review**
- https://developer.apple.com/documentation/xcode/doing-basic-optimization-to-reduce-your-app-s-size
- https://developer.apple.com/documentation/xcode/reducing-your-app-s-size
- https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_ref-Asset_Catalog_Format/ImageSetType.html
- https://developer.apple.com/app-store/review/guidelines/

**WWDC**
- https://developer.apple.com/videos/play/wwdc2025/325/ — Discover Apple-Hosted Background Assets
- https://developer.apple.com/videos/play/wwdc2019/419/ — Optimizing Storage in Your App
- https://developer.apple.com/videos/play/wwdc2018/227/ — Optimizing App Assets
