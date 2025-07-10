#!/bin/bash

set -euo pipefail

# === Config ===
PACK_NAME="starlight"
TEMP_DIR=".tmp_packwiz_export"
EXPORT_DIR="generated"
EXPORT_FILE="$EXPORT_DIR/$PACK_NAME.mrpack"

# === Helper: logging ===
log() {
    echo -e "[\033[1;36mINFO\033[0m] $1"
}

error() {
    echo -e "[\033[1;31mERROR\033[0m] $1" >&2
    exit 1
}

# === Check directories ===
if [[ ! -f "pack.toml" ]]; then
    error "pack.toml not found! Must be run from root of the modpack."
fi

if [[ ! -d "overrides" ]]; then
    error "overrides/ directory not found."
fi

mkdir -p "$EXPORT_DIR"
rm -rf "$TEMP_DIR"
mkdir "$TEMP_DIR"

log "Copying base files (excluding overrides) to temp directory..."
rsync -av --progress ./ "$TEMP_DIR" \
    --exclude "overrides" \
    --exclude "$TEMP_DIR" \
    --exclude "$EXPORT_DIR"

log "Merging overrides into temp directory (overrides take priority)..."
rsync -av --progress overrides/ "$TEMP_DIR/" \
    --delete --ignore-existing --recursive --update

log "Exporting mrpack from temp directory..."
cd "$TEMP_DIR"
packwiz mr export --no-overrides-dir --output "../$EXPORT_FILE"
cd - >/dev/null

log "Cleaning up temp directory..."
rm -rf "$TEMP_DIR"

log "✅ Export complete: $EXPORT_FILE"
