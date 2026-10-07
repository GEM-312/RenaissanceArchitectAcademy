#target photoshop
// Camera Raw Auto — Renaissance Architect Academy
//
// Turns the active layer into a Smart Object, then opens Filter > Camera Raw Filter on it.
// In Camera Raw press Auto (⌘U), adjust if needed, then OK. Because it's a Smart Filter,
// double-click "Camera Raw Filter" in the Layers panel to change it later, or toggle its eye.
//
// Why you press Auto yourself: scripts can't trigger Camera Raw's Auto button — a recorded
// Camera Raw step replays the fixed numbers from the image it was recorded on, not a fresh Auto.
// Run: select the layer, then File > Scripts > Browse… > pick this file.

function convertToSmartObject() {
    executeAction(stringIDToTypeID("newPlacedLayer"), undefined, DialogModes.NO);
}

/// Filter > Camera Raw Filter with its window open
function openCameraRawFilter() {
    executeAction(stringIDToTypeID("Adobe Camera Raw Filter"), new ActionDescriptor(), DialogModes.ALL);
}

(function run() {
    if (app.documents.length === 0) {
        alert("Open an image first.");
        return;
    }
    var layer = app.activeDocument.activeLayer;
    if (layer.typename != "ArtLayer") {
        alert("Select a single image layer (not a group) and run again.");
        return;
    }
    try {
        if (layer.kind != LayerKind.SMARTOBJECT) convertToSmartObject();
        openCameraRawFilter();
    } catch (e) {
        // Cancel in the Camera Raw window lands here too — nothing to report
        if (e.number != 8007) alert("Camera Raw Auto failed:\n" + e.message);
    }
})();
