#target photoshop
// Resize And Camera Raw — Renaissance Architect Academy
//
// One run of ResizeBackgrounds.jsx + OpenInCameraRaw.jsx: pick one or more Midjourney map
// exports, and each one opens resized to the zone terrain size, 4500×3214 (cover + centre crop,
// never stretched), as a Smart Object with the Camera Raw window up. Press Auto (⌘U), fix the
// dark spots, then OK, and the next map's window appears.
// Camera Raw stays a Smart Filter: double-click "Camera Raw Filter" in the Layers panel to change it later.
// The documents are left OPEN and UNSAVED — even one whose Camera Raw window you cancel.
// Run: File > Scripts > Browse… > pick this file.

var TARGET_WIDTH = 4500;
var TARGET_HEIGHT = 3214;

function isImage(f) {
    return f instanceof Folder || /\.(png|jpe?g|webp|tiff?|psd)$/i.test(f.name);
}

function resizeToTarget(doc) {
    var w = doc.width.as("px");
    var h = doc.height.as("px");
    var scale = Math.max(TARGET_WIDTH / w, TARGET_HEIGHT / h);
    var newW = Math.max(TARGET_WIDTH, Math.round(w * scale));
    var newH = Math.max(TARGET_HEIGHT, Math.round(h * scale));
    // Smoother when enlarging (Midjourney HD exports are ~2K, smaller than the target), Sharper when shrinking
    var method = scale > 1 ? ResampleMethod.BICUBICSMOOTHER : ResampleMethod.BICUBICSHARPER;
    doc.resizeImage(UnitValue(newW, "px"), UnitValue(newH, "px"), doc.resolution, method);
    // A smaller canvas crops: trims the overflow evenly from both sides
    doc.resizeCanvas(UnitValue(TARGET_WIDTH, "px"), UnitValue(TARGET_HEIGHT, "px"), AnchorPosition.MIDDLECENTER);
}

function convertToSmartObject() {
    executeAction(stringIDToTypeID("newPlacedLayer"), undefined, DialogModes.NO);
}

/// Filter > Camera Raw Filter with its window open
function openCameraRawFilter() {
    executeAction(stringIDToTypeID("Adobe Camera Raw Filter"), new ActionDescriptor(), DialogModes.ALL);
}

(function run() {
    var files = Folder("~/Downloads").openDlg("Pick the maps to resize and open in Camera Raw", isImage, true);
    if (!files || files.length === 0) return;

    var savedUnits = app.preferences.rulerUnits;
    app.preferences.rulerUnits = Units.PIXELS;
    var failed = [];
    try {
        for (var i = 0; i < files.length; i++) {
            try {
                var doc = app.open(files[i]);
                if (doc.mode != DocumentMode.RGB) doc.changeMode(ChangeMode.RGB);
                resizeToTarget(doc);
                doc.activeLayer = doc.layers[0];
                if (doc.activeLayer.kind != LayerKind.SMARTOBJECT) convertToSmartObject();
                openCameraRawFilter();
            } catch (e) {
                // Cancel in the Camera Raw window lands here too — the map stays open, nothing to report
                if (e.number != 8007) failed.push(decodeURI(files[i].name) + ": " + e.message);
            }
        }
    } finally {
        app.preferences.rulerUnits = savedUnits;
    }
    if (failed.length > 0) alert("Could not process:\n" + failed.join("\n"));
})();
