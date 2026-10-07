#target photoshop
// Export Cut-outs — Renaissance Architect Academy
//
// Saves every layer inside the "Cutouts" group as its own PNG on the FULL canvas —
// untrimmed, so each tree keeps the exact spot it was cut from. scripts/art/place_cutouts.py
// reads that position straight from the transparent margin, no guessing.
//
// Layout the script expects:
//   Cutouts          ← group (name below), one layer per tree / prop
//     Tree A
//     Tree B
//   Terrain          ← anything else is ignored
//
// Output: a "<document name> Cutouts" folder next to the PSD, files named
// 01_Tree-A.png, 02_Tree-B.png … in Layers-panel order, top to bottom.
// Run: Photoshop > File > Scripts > Browse… > pick this file.

var CUTOUTS_GROUP_NAME = "Cutouts";

function findGroup(doc, name) {
    for (var i = 0; i < doc.layerSets.length; i++) {
        if (doc.layerSets[i].name == name) return doc.layerSets[i];
    }
    return null;
}

function safeFileName(name) {
    return name.replace(/[^A-Za-z0-9_-]+/g, "-").replace(/^-+|-+$/g, "") || "layer";
}

function pad2(n) { return (n < 10 ? "0" : "") + n; }

/// Copies one layer into a new transparent document the same size as the source, saves it as PNG.
/// Same canvas size → the layer lands at the same pixel position, so the PNG stays untrimmed.
function exportLayer(source, layer, file) {
    var doc = app.documents.add(
        source.width, source.height, source.resolution, "cutout",
        NewDocumentMode.RGB, DocumentFill.TRANSPARENT, 1, source.bitsPerChannel
    );
    app.activeDocument = source;
    var copy = layer.duplicate(doc, ElementPlacement.PLACEATBEGINNING);
    app.activeDocument = doc;
    copy.visible = true;

    var options = new PNGSaveOptions();
    options.compression = 6;
    options.interlaced = false;
    doc.saveAs(file, options, true, Extension.LOWERCASE);
    doc.close(SaveOptions.DONOTSAVECHANGES);
    app.activeDocument = source;
}

(function run() {
    if (app.documents.length === 0) {
        alert("Open the terrain PSD first.");
        return;
    }
    var source = app.activeDocument;
    var group = findGroup(source, CUTOUTS_GROUP_NAME);
    if (!group) {
        alert("No group named \"" + CUTOUTS_GROUP_NAME + "\".\n\nPut each cut-out on its own layer inside a group with that name.");
        return;
    }
    if (group.artLayers.length === 0) {
        alert("The \"" + CUTOUTS_GROUP_NAME + "\" group has no layers.");
        return;
    }

    var parent;
    try { parent = source.path; } catch (e) { parent = Folder.desktop; }  // unsaved document
    var baseName = source.name.replace(/\.[^.]+$/, "");
    var output = new Folder(parent.fsName + "/" + baseName + " Cutouts");
    if (!output.exists) output.create();

    var savedUnits = app.preferences.rulerUnits;
    var savedDialogs = app.displayDialogs;
    app.preferences.rulerUnits = Units.PIXELS;
    app.displayDialogs = DialogModes.NO;
    var saved = 0;
    try {
        for (var i = 0; i < group.artLayers.length; i++) {
            var layer = group.artLayers[i];
            var file = new File(output.fsName + "/" + pad2(i + 1) + "_" + safeFileName(layer.name) + ".png");
            exportLayer(source, layer, file);
            saved++;
        }
        alert("Exported " + saved + " cut-outs (full canvas, untrimmed) to:\n" + output.fsName);
    } catch (e) {
        alert("Export Cut-outs stopped after " + saved + " files:\n" + e.message);
    } finally {
        app.preferences.rulerUnits = savedUnits;
        app.displayDialogs = savedDialogs;
    }
})();
