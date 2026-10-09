#target photoshop
// Desaturate Open Docs — Renaissance Architect Academy
//
// Adds a Hue/Saturation adjustment layer named "Desaturate" to the top of EVERY open document.
// It asks for the amount once: -100 = fully grey, a smaller number like -30 = just softer colour.
// Non-destructive: the pixels are untouched. Lower the layer's opacity to fine-tune, or hide or
// delete the layer to undo. The documents are left unsaved.
// Run: File > Scripts > Browse… > pick this file.

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
    if (app.documents.length === 0) {
        alert("Open some images first.");
        return;
    }
    var answer = prompt("Saturation for all " + app.documents.length + " open documents\n(-100 = fully grey, -30 = softer colour)", "-100");
    if (answer === null) return;
    var saturation = parseInt(answer, 10);
    if (isNaN(saturation) || saturation < -100 || saturation > 0) {
        alert("Enter a number from -100 to 0.");
        return;
    }

    var startDoc = app.activeDocument;
    var failed = [];
    for (var i = 0; i < app.documents.length; i++) {
        var doc = app.documents[i];
        try {
            app.activeDocument = doc;
            doc.activeLayer = doc.layers[0]; // top of the stack, so it covers every layer
            addHueSaturationLayer(saturation);
        } catch (e) {
            failed.push(doc.name + ": " + e.message);
        }
    }
    app.activeDocument = startDoc;
    if (failed.length > 0) alert("Could not desaturate:\n" + failed.join("\n"));
})();
