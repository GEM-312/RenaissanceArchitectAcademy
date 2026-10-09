# Why my SpriteKit maps looked oversaturated on Mac (and the one-line fix)

## The problem

In *Renaissance Architect Academy*, every SpriteKit map (City, Workshop, Forest, Crafting Room, Goldsmith) looked about **15% more saturated on my Mac** than on my iPad and in Photoshop. The iPad matched Photoshop exactly. Only the maps were affected: the SwiftUI cards, buttons and menus on top of them looked correct on both devices.

## What was going on

A colour in an image is just three numbers: red, green and blue. Those numbers only become a real colour once you know **which scale** they are measured on, a bit like a recipe that says "2 of flour" without saying cups or spoons.

- My art is made on the standard scale, **sRGB**.
- My iMac's screen is **Display P3**, a wider scale that can show deeper, more saturated colours.

When a screen is told "these pixels are sRGB", it converts them to fit its own scale and the colours look right. When it is told **nothing**, it takes the numbers as they are on its own wider scale, so every colour gets pushed to look stronger than intended.

That's what happened:

| | Labels its colours as sRGB? | Result on a P3 screen |
|---|---|---|
| **SwiftUI** (Mac and iPad) | Yes | Correct |
| **SpriteKit on iPad** | iOS converts automatically | Correct |
| **SpriteKit on Mac** | **No.** Its Metal drawing layer has no colour space (`nil`) | **Oversaturated** |

On macOS, SpriteKit draws through a `CAMetalLayer`, and that layer's `colorspace` property is `nil` by default. Apple's documentation says a `nil` colour space means *no colour matching is performed*, so the sRGB numbers went straight to the P3 panel unconverted.

## The fix

The pictures don't need converting; the drawing layer needs a label. All my maps go through one shared SwiftUI wrapper around `SKView`, so in its macOS subclass I find SpriteKit's Metal layer once the view is in a window and tag it as sRGB:

```swift
override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()
    guard window != nil,
          let metalLayer = Self.findMetalLayer(in: layer) else { return }
    metalLayer.colorspace = CGColorSpace(name: CGColorSpace.sRGB)
}

private static func findMetalLayer(in layer: CALayer?) -> CAMetalLayer? {
    guard let layer else { return nil }
    if let metal = layer as? CAMetalLayer { return metal }
    for sublayer in layer.sublayers ?? [] {
        if let metal = findMetalLayer(in: sublayer) { return metal }
    }
    return nil
}
```

Now macOS knows the starting scale and does the sRGB → P3 conversion itself, the same way iOS always did. The iOS code is unchanged.

## Proof it was the cause

A debug print logged the layer's colour space before and after:

```
[GameSpriteView] colorspace: CAMetalLayer nil → kCGColorSpaceSRGB
```

`nil` before, sRGB after, and the maps on the Mac now match the iPad and Photoshop.

## Why not just turn the saturation down?

A −15% saturation filter would look *close*, but it's the wrong correction. The gap between sRGB and P3 isn't the same for every colour (oranges and blues stretch differently), so a flat filter over-corrects some colours and under-corrects others. Fixing the label lets the system do the exact colour maths.

## Takeaway

If colours differ between devices, first ask **who is converting the colours, and did anything tell them which colour space the pixels are in?** A missing colour-space label is invisible in code and only shows up on a wide-gamut screen.
