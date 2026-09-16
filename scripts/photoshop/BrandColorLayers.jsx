#target photoshop
// Brand Color Layers — Renaissance Architect Academy
//
// Runs Select Subject and adds one Solid Color fill layer per RenaissanceColors token,
// each masked to the subject and hidden. Toggle the eye icons in the "Brand Colors"
// group to preview each tint.
//
//   • A document is open → choose it, or choose a folder instead
//   • Nothing open       → choose a folder
//   Folder mode opens every image in the folder, adds the layers, and saves a layered PSD
//   into a "Brand Colors" subfolder — each PSD stays open for adjusting. Originals are never modified.
//
// Colors are read live from RenaissanceColors.swift, so the script always matches the app.
// Run: Photoshop > File > Scripts > Browse… > pick this file.

var COLORS_FILE = "~/RenaissanceArchitectAcademy/RenaissanceArchitectAcademy/Services/Styles/RenaissanceColors.swift";

// Color keeps the painting's light/shadow and line work, and swaps in the brand hue.
// Change to BlendMode.NORMAL for flat solid fills.
var FILL_BLEND_MODE = BlendMode.COLORBLEND;

var IMAGE_FILE = /\.(png|jpe?g|psd|tiff?|webp)$/i;
var OUTPUT_FOLDER_NAME = "Brand Colors";

/// Parses `static let name = Color(red: r, green: g, blue: b)` lines, grouped by `// MARK: - Section`.
function readBrandColors() {
    var file = new File(COLORS_FILE);
    if (!file.exists) throw new Error("Can't find the colors file:\n" + file.fsName);
    file.open("r");
    var lines = file.read().split("\n");
    file.close();

    var sections = [];
    var current = null;
    var seen = {};
    for (var i = 0; i < lines.length; i++) {
        var mark = lines[i].match(/\/\/ MARK: - (.+)$/);
        if (mark) {
            current = { name: mark[1], colors: [] };
            sections.push(current);
            continue;
        }
        var m = lines[i].match(/static let (\w+)\s*=\s*Color\(red: ([\d.]+), green: ([\d.]+), blue: ([\d.]+)\)/);
        if (!m || !current) continue;
        var r = Math.round(parseFloat(m[2]) * 255);
        var g = Math.round(parseFloat(m[3]) * 255);
        var b = Math.round(parseFloat(m[4]) * 255);
        var key = r + "," + g + "," + b;
        if (seen[key]) continue;  // e.g. gardenGreen is identical to sageGreen
        seen[key] = true;
        current.colors.push({ name: m[1], r: r, g: g, b: b });
    }

    var result = [];
    for (var s = 0; s < sections.length; s++) {
        if (sections[s].colors.length > 0) result.push(sections[s]);
    }
    return result;
}

function selectSubject() {
    var desc = new ActionDescriptor();
    desc.putBoolean(stringIDToTypeID("sampleAllLayers"), false);
    executeAction(stringIDToTypeID("autoCutout"), desc, DialogModes.NO);
}

function hasSelection(doc) {
    try { doc.selection.bounds; return true; } catch (e) { return false; }
}

/// Select > Save Selection — keeps the subject so every fill layer gets the same mask
function saveSelection(name) {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putProperty(charIDToTypeID("Chnl"), charIDToTypeID("fsel"));
    desc.putReference(charIDToTypeID("null"), ref);
    desc.putString(charIDToTypeID("Nm  "), name);
    executeAction(charIDToTypeID("Dplc"), desc, DialogModes.NO);
}

/// Layer > New Fill Layer > Solid Color — an active selection becomes the layer mask
function makeSolidColorLayer(name, r, g, b) {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putClass(stringIDToTypeID("contentLayer"));
    desc.putReference(charIDToTypeID("null"), ref);

    var color = new ActionDescriptor();
    color.putDouble(charIDToTypeID("Rd  "), r);
    color.putDouble(charIDToTypeID("Grn "), g);
    color.putDouble(charIDToTypeID("Bl  "), b);
    var fill = new ActionDescriptor();
    fill.putObject(charIDToTypeID("Clr "), charIDToTypeID("RGBC"), color);
    var layer = new ActionDescriptor();
    layer.putString(charIDToTypeID("Nm  "), name);
    layer.putObject(charIDToTypeID("Type"), stringIDToTypeID("solidColorLayer"), fill);
    desc.putObject(charIDToTypeID("Usng"), stringIDToTypeID("contentLayer"), layer);

    executeAction(charIDToTypeID("Mk  "), desc, DialogModes.NO);
    return app.activeDocument.activeLayer;
}

/// Adds the "Brand Colors" group to the active document. Returns false if Select Subject found nothing.
function addBrandColorLayers(sections) {
    var doc = app.activeDocument;

    if (doc.mode != DocumentMode.RGB) doc.changeMode(ChangeMode.RGB);

    selectSubject();
    if (!hasSelection(doc)) return false;
    var channelName = "Brand Colors Subject";
    saveSelection(channelName);
    var subject = doc.channels.getByName(channelName);

    var group = doc.layerSets.add();
    group.name = "Brand Colors";

    // Walk backwards — moving a layer INSIDE a group puts it on top, so this keeps file order
    for (var s = sections.length - 1; s >= 0; s--) {
        var section = group.layerSets.add();
        section.name = sections[s].name;
        for (var c = sections[s].colors.length - 1; c >= 0; c--) {
            var color = sections[s].colors[c];
            doc.selection.load(subject, SelectionType.REPLACE);
            var fillLayer = makeSolidColorLayer(color.name, color.r, color.g, color.b);
            fillLayer.blendMode = FILL_BLEND_MODE;
            fillLayer.visible = false;
            fillLayer.move(section, ElementPlacement.INSIDE);
        }
    }

    subject.remove();
    doc.selection.deselect();
    doc.activeLayer = group;
    return true;
}

// suspendHistory evaluates a code string in global scope, so the single-document run passes through globals
var brandSections;
var brandResult;

function runOnActiveDocument(sections) {
    brandSections = sections;
    brandResult = false;
    // One history step — a single Undo removes everything the script added
    app.activeDocument.suspendHistory("Brand Color Layers", "brandResult = addBrandColorLayers(brandSections)");
    if (!brandResult) alert("Select Subject didn't find a subject in this image.");
}

function runOnFolder(folder, sections) {
    var files = folder.getFiles(function (f) {
        return f instanceof File && f.name.charAt(0) != "." && IMAGE_FILE.test(f.name);
    });
    if (files.length === 0) {
        alert("No images found in:\n" + folder.fsName);
        return;
    }
    files.sort(function (a, b) { return a.name < b.name ? -1 : (a.name > b.name ? 1 : 0); });

    var output = new Folder(folder.fsName + "/" + OUTPUT_FOLDER_NAME);
    if (!output.exists) output.create();

    var saveOptions = new PhotoshopSaveOptions();
    saveOptions.layers = true;

    var saved = 0;
    var skipped = [];
    for (var i = 0; i < files.length; i++) {
        var doc = null;
        try {
            doc = app.open(files[i]);
            if (addBrandColorLayers(sections)) {
                var baseName = files[i].name.replace(/\.[^.]+$/, "");
                // Not a copy — the open document becomes the saved PSD, so it stays open for adjusting
                doc.saveAs(new File(output.fsName + "/" + baseName + ".psd"), saveOptions, false, Extension.LOWERCASE);
                saved++;
                doc = null;
            } else {
                skipped.push(files[i].name + " — no subject found");
            }
        } catch (e) {
            skipped.push(files[i].name + " — " + e.message);
        }
        if (doc) doc.close(SaveOptions.DONOTSAVECHANGES);  // skipped images don't stay open
    }

    var summary = "Saved " + saved + " of " + files.length + " images to:\n" + output.fsName;
    if (skipped.length > 0) summary += "\n\nSkipped:\n" + skipped.join("\n");
    alert(summary);
}

(function run() {
    var savedDialogs = app.displayDialogs;
    try {
        var sections = readBrandColors();
        var useOpenDocument = app.documents.length > 0 &&
            confirm("Add brand colors to \"" + app.activeDocument.name + "\"?\n\nChoose No to pick a folder of images instead.");
        var folder = useOpenDocument ? null : Folder.selectDialog("Choose a folder of images to add brand colors to");

        app.displayDialogs = DialogModes.NO;
        if (useOpenDocument) {
            runOnActiveDocument(sections);
        } else if (folder) {
            runOnFolder(folder, sections);
        }
    } catch (e) {
        alert("Brand Color Layers failed:\n" + e.message);
    } finally {
        app.displayDialogs = savedDialogs;
    }
})();
