#target photoshop
// Resize And Desaturate — Renaissance Architect Academy
//
// One run of ResizeBackgrounds.jsx + DesaturateOpenDocs.jsx: pick one or more Midjourney map
// exports, and each one opens resized to the zone terrain size, 4500×3214 (cover + centre crop,
// never stretched), with a Hue/Saturation layer named "Desaturate" on top, ready for hand colouring.
// It asks for the amount once: -100 = fully grey, a smaller number like -30 = just softer colour.
// Non-destructive: the pixels are untouched, so hide or delete the layer to get the colour back.
// The documents are left open and UNSAVED.
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

/// Layer > New Adjustment Layer > Hue/Saturation, placed above the active layer
function addHueSaturationLayer(saturation) {
    var make = new ActionDescriptor();
    var classRef = new ActionReference();
    classRef.putClass(charIDToTypeID("AdjL"));
    make.putReference(charIDToTypeID("null"), classRef);
    var layer = new ActionDescriptor();
    layer.putString(charIDToTypeID("Nm  "), "Desaturate");
    layer.putClass(charIDToTypeID("Type"), charIDToTypeID("HStr"));
    make.putObject(charIDToTypeID("Usng"), charIDToTypeID("AdjL"), layer);
    executeAction(charIDToTypeID("Mk  "), make, DialogModes.NO);

    // Then set its master saturation
    var master = new ActionDescriptor();
    master.putInteger(charIDToTypeID("H   "), 0);
    master.putInteger(charIDToTypeID("Strt"), saturation);
    master.putInteger(charIDToTypeID("Lght"), 0);
    var adjustments = new ActionList();
    adjustments.putObject(charIDToTypeID("Hst2"), master);
    var hueSat = new ActionDescriptor();
    hueSat.putEnumerated(stringIDToTypeID("presetKind"), stringIDToTypeID("presetKindType"), stringIDToTypeID("presetKindCustom"));
    hueSat.putBoolean(charIDToTypeID("Clrz"), false);
    hueSat.putList(charIDToTypeID("Adjs"), adjustments);

    var set = new ActionDescriptor();
    var targetRef = new ActionReference();
    targetRef.putEnumerated(charIDToTypeID("AdjL"), charIDToTypeID("Ordn"), charIDToTypeID("Trgt"));
    set.putReference(charIDToTypeID("null"), targetRef);
    set.putObject(charIDToTypeID("T   "), charIDToTypeID("HStr"), hueSat);
    executeAction(charIDToTypeID("setd"), set, DialogModes.NO);
}

(function run() {
    var files = Folder("~/Downloads").openDlg("Pick the maps to resize and desaturate", isImage, true);
    if (!files || files.length === 0) return;

    var answer = prompt("Saturation for all " + files.length + " maps\n(-100 = fully grey, -30 = softer colour)", "-100");
    if (answer === null) return;
    var saturation = parseInt(answer, 10);
    if (isNaN(saturation) || saturation < -100 || saturation > 0) {
        alert("Enter a number from -100 to 0.");
        return;
    }

    var savedUnits = app.preferences.rulerUnits;
    app.preferences.rulerUnits = Units.PIXELS;
    var failed = [];
    try {
        for (var i = 0; i < files.length; i++) {
            try {
                var doc = app.open(files[i]);
                if (doc.mode != DocumentMode.RGB) doc.changeMode(ChangeMode.RGB);
                resizeToTarget(doc);
                doc.activeLayer = doc.layers[0]; // top of the stack, so it covers every layer
                addHueSaturationLayer(saturation);
            } catch (e) {
                failed.push(decodeURI(files[i].name) + ": " + e.message);
            }
        }
    } finally {
        app.preferences.rulerUnits = savedUnits;
    }
    if (failed.length > 0) alert("Could not process:\n" + failed.join("\n"));
})();
