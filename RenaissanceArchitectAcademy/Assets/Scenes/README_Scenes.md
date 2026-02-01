# Scene Setup Guide - Renaissance Architect Academy

## Quick Setup

In Unity, go to **Tools > Renaissance Academy** menu:

1. **Setup Main Menu Scene** - Creates complete MainMenu with all UI
2. **Setup Florence City Scene** - Creates city view with 6 building plots
3. **Open Setup Window** - Full setup panel with color preview

---

## Main Menu Scene Structure

```
MainMenu (Scene)
├── Main Camera
│   └── Background: Parchment color
├── --- MANAGERS ---
│   ├── GameManager
│   ├── ResourceManager
│   ├── SealRewardSystem
│   └── BuildingAnimator
├── MainMenuCanvas
│   ├── UIManager (component)
│   ├── BackgroundPanel (Parchment)
│   └── MainMenuPanel
│       ├── MainMenuController (component)
│       ├── CanvasGroup (for fade animations)
│       ├── TitleText: "Renaissance Architect Academy"
│       ├── SubtitleText: "Learn Like Leonardo..."
│       ├── TaglineText: "A fusion of Art..."
│       ├── PlayButton (Terracotta)
│       ├── SettingsButton (Ochre)
│       ├── CreditsButton (Sage Green)
│       └── QuitButton (Sepia)
└── EventSystem
```

## Florence City Scene Structure

```
Florence_City (Scene)
├── Main Camera
│   ├── IsometricCameraController
│   └── Orthographic, size 8
├── --- MANAGERS ---
│   ├── GameManager
│   ├── ResourceManager
│   ├── SealRewardSystem
│   └── BuildingAnimator
├── CityManager
├── ChallengeManager
├── ScienceVisualizationOverlay
├── --- BUILDING PLOTS ---
│   ├── BuildingPlot_1 (position: -6, 2)
│   ├── BuildingPlot_2 (position: 0, 2)
│   ├── BuildingPlot_3 (position: 6, 2)
│   ├── BuildingPlot_4 (position: -6, -2)
│   ├── BuildingPlot_5 (position: 0, -2)
│   └── BuildingPlot_6 (position: 6, -2)
├── GameUICanvas
│   ├── UIManager
│   ├── HUDPanel (top bar)
│   │   ├── GoldText
│   │   ├── StoneText
│   │   └── WoodText
│   ├── BuildingMenuPanel (hidden)
│   │   └── BuildingSelectionMenu
│   └── ChallengePanel (hidden)
│       └── ChallengeManager references
└── EventSystem
```

---

## Manual Setup (if needed)

### 1. Create Main Menu Scene Manually

1. Create new scene: `File > New Scene`
2. Set camera:
   - Background Color: `#F5E6D3` (Parchment)
   - Orthographic: Yes
3. Create Canvas:
   - Add `Canvas Scaler` (Scale With Screen Size)
   - Add `UIManager` component
4. Create UI elements following structure above
5. Save as `Assets/Scenes/MainMenu.unity`

### 2. Create Florence City Scene Manually

1. Create new scene
2. Set camera for isometric view:
   - Background: `#F5E6D3`
   - Orthographic Size: `8`
   - Add `IsometricCameraController`
3. Create manager objects with components
4. Create 6 BuildingPlot objects with:
   - `SpriteRenderer`
   - `BoxCollider2D` (size 4x3)
   - `BuildingPlot` component
5. Create UI Canvas with HUD and menu panels
6. Save as `Assets/Scenes/Florence_City.unity`

---

## Button Styling

Use the `RenaissanceButton` component for proper styling:

| Style | Color | Use For |
|-------|-------|---------|
| Standard | Terracotta | Primary actions (Play) |
| Secondary | Ochre | Secondary actions (Settings) |
| Accent | Renaissance Blue | Special highlights |
| Success | Sage Green | Positive actions |
| Neutral | Sepia | Cancel, Back |
| WaxSeal | Wax Seal Red | Achievement badges |

---

## Transitions

Use `PageCurlTransition` for panel transitions:

```csharp
// Transition between panels
PageCurlTransition.Instance.TransitionPanels(fromPanel, toPanel);

// Show panel with curl
PageCurlTransition.Instance.CurlIn(panel);

// Hide panel with curl
PageCurlTransition.Instance.CurlOut(panel);
```

---

## Build Settings

Add scenes in this order:
1. `Scenes/MainMenu`
2. `Scenes/Florence_City`

## Required Packages

- TextMeshPro (should be included)
- 2D Sprite (for SpriteRenderer)

## Fonts to Import

Download and import as TMP Font Assets:
1. **Cinzel** - For headings
2. **EB Garamond** - For body text
3. **Dancing Script** or similar - For annotations
