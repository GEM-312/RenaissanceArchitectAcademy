# Font Setup Guide - Renaissance Architect Academy

## Fonts Included

| Font | Use | Style Guide Reference |
|------|-----|----------------------|
| **Cinzel** | Headings, Titles | "Evoking the permanence of Roman stone inscriptions" |
| **EB Garamond** | Body Text | "Highly readable, evoking the clarity of early print" |
| **Playwrite GB J Guides** | Annotations, Notes | "The personal hand of the master" (cursive) |

---

## Creating TMP Font Assets in Unity

### Step 1: Open Font Asset Creator
1. Go to **Window > TextMeshPro > Font Asset Creator**

### Step 2: Create Each Font Asset

#### For Cinzel (Headings):
1. **Source Font File**: Drag `Cinzel/static/Cinzel-SemiBold.ttf`
2. **Sampling Point Size**: `72`
3. **Padding**: `5`
4. **Atlas Resolution**: `2048 x 2048`
5. Click **Generate Font Atlas**
6. Click **Save** → Name it `Cinzel-SemiBold SDF`

#### For EB Garamond (Body):
1. **Source Font File**: Drag `EB_Garamond/static/EBGaramond-Regular.ttf`
2. **Sampling Point Size**: `48`
3. **Padding**: `5`
4. **Atlas Resolution**: `2048 x 2048`
5. Click **Generate Font Atlas**
6. Click **Save** → Name it `EBGaramond-Regular SDF`

#### For Playwrite (Annotations):
1. **Source Font File**: Drag `Playwrite_GB_J_Guides/PlaywriteGBJGuides-Regular.ttf`
2. **Sampling Point Size**: `48`
3. **Padding**: `5`
4. **Atlas Resolution**: `2048 x 2048`
5. Click **Generate Font Atlas**
6. Click **Save** → Name it `Playwrite-Regular SDF`

---

## Step 3: Assign to FontManager

1. Find or create a **FontManager** object in your scene
2. In the Inspector, assign:
   - **Cinzel Font**: `Cinzel-SemiBold SDF`
   - **EB Garamond Font**: `EBGaramond-Regular SDF`
   - **Cursive Font**: `Playwrite-Regular SDF`

---

## Recommended Font Weights

### Cinzel (for different uses):
- `Cinzel-Regular.ttf` - Subtitles
- `Cinzel-SemiBold.ttf` - Main headings ⭐
- `Cinzel-Bold.ttf` - Emphasis

### EB Garamond (for different uses):
- `EBGaramond-Regular.ttf` - Body text ⭐
- `EBGaramond-Italic.ttf` - Quotes, emphasis
- `EBGaramond-SemiBold.ttf` - Important text

### Playwrite:
- `PlaywriteGBJGuides-Regular.ttf` - Annotations ⭐
- `PlaywriteGBJGuides-Italic.ttf` - Hints, notes

---

## Typography Hierarchy (from Style Guide)

```
TITLE (Cinzel, 48-72pt)
"Renaissance Architect Academy"

Subtitle (Cinzel, 24-36pt)
"Learn Like Leonardo. Build Like Brunelleschi."

Body Text (EB Garamond, 16-20pt)
Description and educational content goes here.

Annotation (Playwrite, 14-18pt, italic)
"Note: Ensure stable foundation" - handwritten style
```

---

## Quick Reference - Font Sizes

| Element | Font | Size |
|---------|------|------|
| Main Title | Cinzel | 72 |
| Section Heading | Cinzel | 48 |
| Menu Button | Cinzel | 24 |
| Body Text | EB Garamond | 18 |
| Description | EB Garamond | 16 |
| Annotation | Playwrite | 16 |
| Tooltip | EB Garamond | 14 |
