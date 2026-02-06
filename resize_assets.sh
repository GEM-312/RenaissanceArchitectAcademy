#!/bin/bash

# Asset Resize Script for Renaissance Architect Academy
# Uses macOS built-in sips command (no need to install anything)

ASSETS_DIR="/Users/pollakmarina/RenaissanceArchitectAcademy/RenaissanceArchitectAcademy"

echo "🎨 Resizing assets for Renaissance Architect Academy..."
echo ""

# Create backup folder
BACKUP_DIR="$ASSETS_DIR/OriginalAssets_Backup"
mkdir -p "$BACKUP_DIR"

# Function to resize images
resize_folder() {
    local folder="$1"
    local size="$2"
    local name="$3"

    if [ -d "$folder" ]; then
        echo "📁 Processing $name (resizing to ${size}px)..."

        # Backup originals
        cp -r "$folder" "$BACKUP_DIR/"

        # Resize each image using find
        find "$folder" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) | while read img; do
            filename=$(basename "$img")
            echo "   Resizing: $filename"
            sips -Z "$size" "$img" --out "$img" > /dev/null 2>&1
        done
        echo "   ✅ Done!"
        echo ""
    else
        echo "⚠️  Folder not found: $folder"
        echo ""
    fi
}

# Resize each asset category
resize_folder "$ASSETS_DIR/Science Icons" 180 "Science Icons"
resize_folder "$ASSETS_DIR/GameStateIcons" 160 "Game State Icons"
resize_folder "$ASSETS_DIR/City Icons" 512 "City Icons"
resize_folder "$ASSETS_DIR/UINavigation" 120 "UI Navigation Icons"

echo "✨ All assets resized!"
echo ""
echo "📦 Original files backed up to: $BACKUP_DIR"
echo ""

# Show new file sizes
echo "📊 New file sizes:"
du -sh "$ASSETS_DIR/Science Icons" 2>/dev/null
du -sh "$ASSETS_DIR/GameStateIcons" 2>/dev/null
du -sh "$ASSETS_DIR/City Icons" 2>/dev/null
du -sh "$ASSETS_DIR/UINavigation" 2>/dev/null

echo ""
echo "🎉 Done! Your app bundle will be much smaller now."
