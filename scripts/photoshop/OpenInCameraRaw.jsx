#target photoshop
// Open In Camera Raw — Renaissance Architect Academy
//
// Pick one or more images, and each one opens with the Camera Raw window already up, one after
// the other: press Auto (⌘U), adjust if needed, then OK and the next image's window appears.
// Each image becomes a Smart Object with Camera Raw as a Smart Filter, so double-click
// "Camera Raw Filter" in the Layers panel to change it later, or toggle its eye.
// Every document is left OPEN and UNSAVED — even one whose Camera Raw window you cancel.
//
// Why the filter and not File > Open As > Camera Raw: Midjourney exports are PNG, and the
// filter works on any format, so every file goes through the same path.
// Why you press Auto yourself: scripts can't trigger Camera Raw's Auto button (see CameraRawAuto.jsx).
// Run: File > Scripts > Browse… > pick this file.

function isImage(f) {
    return f instanceof Folder || /\.(png|jpe?g|webp|tiff?|psd)$/i.test(f.name);
}

function convertToSmartObject() {
    executeAction(stringIDToTypeID("newPlacedLayer"), undefined, DialogModes.NO);
}

/// Filter > Camera Raw Filter with its window open
function openCameraRawFilter() {
    executeAction(stringIDToTypeID("Adobe Camera Raw Filter"), new ActionDescriptor(), DialogModes.ALL);
}

(function run() {
    var files = Folder("~/Downloads").openDlg("Pick the images to open in Camera Raw", isImage, true);
    if (!files || files.length === 0) return;

    var failed = [];
    for (var i = 0; i < files.length; i++) {
        try {
            var doc = app.open(files[i]);
            doc.activeLayer = doc.layers[0];
            if (doc.activeLayer.kind != LayerKind.SMARTOBJECT) convertToSmartObject();
            openCameraRawFilter();
        } catch (e) {
            // Cancel in the Camera Raw window lands here too — the image stays open, nothing to report
            if (e.number != 8007) failed.push(decodeURI(files[i].name) + ": " + e.message);
        }
    }
    if (failed.length > 0) alert("Could not process:\n" + failed.join("\n"));
})();
