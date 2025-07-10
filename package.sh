#!/bin/bash

set -euo pipefail

# === Config ===
PACK_NAME="Starlight"
TEMP_DIR=".tmp_packwiz_export"
EXPORT_DIR="generated"
EXPORT_FILE="$EXPORT_DIR/$PACK_NAME.mrpack"

# === Logging ===
log() {
    echo " 📦 $1"
}

success() {
    echo " ✅ $1"
}

error() {
    echo " ❌ $1" >&2
    exit 1
}

# === Check packwiz ===
if ! command -v packwiz &>/dev/null; then
    error "Packwiz is not installed or not in PATH."
fi

# === Check for required files ===
if [[ ! -f "pack.toml" ]]; then
    error "pack.toml not found! Must be run from the root of the modpack."
fi

# === Display Header Info ===
override_mod_count=$(find overrides/mods -maxdepth 1 -type f 2>/dev/null | wc -l | xargs)
mod_count=$(($(find mods -maxdepth 1 -type f 2>/dev/null | wc -l | xargs) + override_mod_count))
resourcepack_count=$(($(find resourcepacks -maxdepth 1 -type f 2>/dev/null | wc -l | xargs) + $(find overrides/resourcepacks -maxdepth 1 -type f 2>/dev/null | wc -l | xargs)))
override_resourcepack_count=$(find overrides/resourcepacks -maxdepth 1 -type f 2>/dev/null | wc -l | xargs)

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " 🌌 Building: $PACK_NAME"
echo " 📦 Mods: $mod_count total (${override_mod_count} overrides)"
echo " 🎨 Resource Packs: $resourcepack_count total ($override_resourcepack_count overrides)"
echo " 🛠 Using: Packwiz"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# === Prep temp dir ===
mkdir -p "$EXPORT_DIR"
rm -rf "$TEMP_DIR"
mkdir "$TEMP_DIR"

log "Copying base files (excluding overrides)..."
for entry in * .*; do
    [[ "$entry" == "." || "$entry" == ".." ]] && continue
    [[ "$entry" == "$TEMP_DIR" || "$entry" == "$EXPORT_DIR" || "$entry" == "overrides" ]] && continue
    cp -a "$entry" "$TEMP_DIR/" 2>/dev/null || true
done
success "Copied base project files."

# === Merge overrides if they exist ===
if [[ -d "overrides" ]]; then
    log "Merging overrides into temp directory..."
    find overrides -type f | while read -r filepath; do
        rel_path="${filepath#overrides/}"
        dest_path="$TEMP_DIR/$rel_path"
        mkdir -p "$(dirname "$dest_path")"
        cp -f "$filepath" "$dest_path"
    done
    success "Merged overrides (mods & resourcepacks)."
else
    log "No overrides found, skipping override merge."
fi

log "Exporting modpack with packwiz..."
cd "$TEMP_DIR"
packwiz modrinth export -o "../$EXPORT_FILE" >/dev/null 2>&1 || error "Packwiz export failed"
cd - >/dev/null
success "Modpack exported to $EXPORT_FILE"

log "Cleaning up temp files..."
rm -rf "$TEMP_DIR"
success "Temp files cleaned up."

echo " 🎉 Done! Your pack is ready: \"$EXPORT_FILE\""
