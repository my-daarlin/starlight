#!/bin/bash

set -euo pipefail

# === Config ===
PACK_NAME="starlight"
TEMP_DIR=".tmp_packwiz_export"
EXPORT_DIR="generated"
EXPORT_FILE="$EXPORT_DIR/$PACK_NAME.mrpack"

# === Logging ===
log() {
    echo " 📦 $1"
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

mkdir -p "$EXPORT_DIR"
rm -rf "$TEMP_DIR"
mkdir "$TEMP_DIR"

log "Copying base files (excluding overrides)..."
for entry in * .*; do
    [[ "$entry" == "." || "$entry" == ".." ]] && continue
    [[ "$entry" == "$TEMP_DIR" || "$entry" == "$EXPORT_DIR" || "$entry" == "overrides" ]] && continue
    cp -a "$entry" "$TEMP_DIR/" 2>/dev/null || true
done

# === Merge overrides if they exist ===
if [[ -d "overrides" ]]; then
    log "Merging overrides into temp directory..."
    find overrides -type f | while read -r filepath; do
        rel_path="${filepath#overrides/}"
        dest_path="$TEMP_DIR/$rel_path"
        mkdir -p "$(dirname "$dest_path")"
        cp -f "$filepath" "$dest_path"
    done
else
    log "No overrides found, skipping override merge."
fi

log "Exporting modpack with packwiz..."
cd "$TEMP_DIR"
packwiz modrinth export -o "../$EXPORT_FILE" >/dev/null 2>&1 || error "Packwiz export failed"
cd - >/dev/null

log "Cleaning up temp files..."
rm -rf "$TEMP_DIR"

echo " ✅ Export complete: $EXPORT_FILE"
