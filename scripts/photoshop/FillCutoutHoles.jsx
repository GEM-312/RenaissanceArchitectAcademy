#target photoshop
// Fill Cut-out Holes — Renaissance Architect Academy
//
// A cut-out tree sways in the game, so whatever is painted UNDER it on the terrain shows
// as a ghost edge. This fills each hole: for every layer in the "Cutouts" group it loads
// the layer's outline, grows it a few pixels, and runs Content-Aware Fill on a COPY of
// the terrain layer. The original terrain layer is never touched.
//
// Layout the script expects (same as Export Cut-outs):
//   Cutouts          ← group, one layer per tree / prop
//   Terrain          ← the painted map — select it before running
//
// Result: a "Terrain (holes filled)" layer above the terrain, Cutouts hidden so you can
// inspect it. One history step — a single Undo removes everything.
// Run: select the terrain layer, then File > Scripts > Browse… > pick this file.

var CUTOUTS_GROUP_NAME = "Cutouts";
var GROW_PIXELS = 6;  // reaches past the cut-out's soft edge so no rim of the old tree survives

function findGroup(doc, name) {
    for (var i = 0; i < doc.layerSets.length; i++) {
        if (doc.layerSets[i].name == name) return doc.layerSets[i];
    }
    return null;
}

/// Select > Load Selection from a layer's transparency (Cmd-click on its thumbnail)
function loadLayerOutline(layer) {
    var desc = new ActionDescriptor();
    var target = new ActionReference();
    target.putProperty(charIDToTypeID("Chnl"), charIDToTypeID("fsel"));
    desc.putReference(charIDToTypeID("null"), target);
    var source = new ActionReference();
    source.putEnumerated(charIDToTypeID("Chnl"), charIDToTypeID("Chnl"), charIDToTypeID("Trsp"));
    source.putIdentifier(charIDToTypeID("Lyr "), layer.id);
    desc.putReference(charIDToTypeID("T   "), source);
    executeAction(charIDToTypeID("setd"), desc, DialogModes.NO);
}

/// Edit > Fill > Content-Aware, 100%, Normal, Color Adaptation on
function contentAwareFill() {
    var desc = new ActionDescriptor();
    desc.putEnumerated(charIDToTypeID("Usng"), charIDToTypeID("FlCn"), stringIDToTypeID("contentAware"));
    desc.putBoolean(stringIDToTypeID("contentAwareColorAdaptationFill"), true);
    desc.putUnitDouble(charIDToTypeID("Opct"), charIDToTypeID("#Prc"), 100);
    desc.putEnumerated(charIDToTypeID("Md  "), charIDToTypeID("BlnM"), charIDToTypeID("Nrml"));
    executeAction(charIDToTypeID("Fl  "), desc, DialogModes.NO);
}

// suspendHistory evaluates a code string in global scope, so state passes through globals
var fillGroup;
var fillTerrain;
var fillCount;

function fillHoles() {
    var doc = app.activeDocument;
    var filled = fillTerrain.duplicate(fillTerrain, ElementPlacement.PLACEBEFORE);
    filled.name = fillTerrain.name + " (holes filled)";
    filled.visible = true;

    fillCount = 0;
    for (var i = 0; i < fillGroup.artLayers.length; i++) {
        loadLayerOutline(fillGroup.artLayers[i]);
        doc.selection.expand(new UnitValue(GROW_PIXELS, "px"));
        doc.activeLayer = filled;
        contentAwareFill();
        fillCount++;
    }
    doc.selection.deselect();
    fillGroup.visible = false;
    doc.activeLayer = filled;
}

(function run() {
    if (app.documents.length === 0) {
        alert("Open the terrain PSD first.");
        return;
    }
    var doc = app.activeDocument;
    fillGroup = findGroup(doc, CUTOUTS_GROUP_NAME);
    if (!fillGroup || fillGroup.artLayers.length === 0) {
        alert("No layers in a group named \"" + CUTOUTS_GROUP_NAME + "\".");
        return;
    }
    fillTerrain = doc.activeLayer;
    if (fillTerrain.typename != "ArtLayer" || fillTerrain.parent == fillGroup) {
        alert("Select the terrain layer (not a group, not a cut-out) and run again.");
        return;
    }

    var savedDialogs = app.displayDialogs;
    app.displayDialogs = DialogModes.NO;
    try {
        doc.suspendHistory("Fill Cut-out Holes", "fillHoles()");
        alert("Filled " + fillCount + " holes on \"" + fillTerrain.name + " (holes filled)\".\n\nCutouts group is hidden — check the terrain for ghost edges.");
    } catch (e) {
        alert("Fill Cut-out Holes failed:\n" + e.message);
    } finally {
        app.displayDialogs = savedDialogs;
    }
})();
