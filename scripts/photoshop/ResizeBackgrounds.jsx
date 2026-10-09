#target photoshop
// Resize Backgrounds — Renaissance Architect Academy
//
// Pick one or more Midjourney exports; each one opens in Photoshop resized to the zone
// terrain size, 4500×3214 (the size of PaduaTerrain and Forest1, see docs/zone-terrain-prompts.md).
// Scales to COVER the target, then trims the overflow evenly from the centre. Never stretches.
// A --ar 7:5 export loses a pixel or two at most; any other ratio loses the excess edges.
// The documents are left open and UNSAVED, so you can edit them and then save them yourself.
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
    // Smoother when enlarging (Midjourney exports are smaller than the target), Sharper when shrinking
    var method = scale > 1 ? ResampleMethod.BICUBICSMOOTHER : ResampleMethod.BICUBICSHARPER;
    doc.resizeImage(UnitValue(newW, "px"), UnitValue(newH, "px"), doc.resolution, method);
    // A smaller canvas crops: trims the overflow evenly from both sides
    doc.resizeCanvas(UnitValue(TARGET_WIDTH, "px"), UnitValue(TARGET_HEIGHT, "px"), AnchorPosition.MIDDLECENTER);
}

(function run() {
    var files = Folder("~/Downloads").openDlg("Pick the backgrounds to resize", isImage, true);
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
            } catch (e) {
                failed.push(decodeURI(files[i].name) + ": " + e.message);
            }
        }
    } finally {
        app.preferences.rulerUnits = savedUnits;
    }
    if (failed.length > 0) alert("Could not resize:\n" + failed.join("\n"));
})();
