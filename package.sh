#!/bin/bash

set -euo pipefail

# ───────────────────────────────────────────────────────────────────────────────
# .mrpack Package Script
# Creates a .mrpack file for a modpack using Packwiz, with an override system.
# The override directory will be merged with the main one, so if I have a mods
# directory in the override folder, custom mod jars from there will be pasted into
# the final main mods directory. Packwiz also ignores server side mods by default,
# but this script overrides this behavior, because it's intended to be also used for
# playing singeplayer or hosting LAN.
# ───────────────────────────────────────────────────────────────────────────────

# ─── Configuration ─────────────────────────────────────────────────────────────

PACK_NAME="Starlight"
EXPORT_DIR="generated"
TEMP_DIR=".tmp_packwiz_export"
EXPORT_FILE="$EXPORT_DIR/$PACK_NAME.mrpack"

# ─── Logging ───────────────────────────────────────────────────────────────────

log() { echo " 📦 $1"; }
success() { echo " ✅ $1"; }
error() {
    echo " ❌ $1" >&2
    exit 1
}

# ─── Dependency checks ─────────────────────────────────────────────────────────

# Packwiz
if ! command -v packwiz &>/dev/null; then
    error "Packwiz is not installed or not in PATH."
fi

# Required files
if [[ ! -f "pack.toml" ]]; then
    error "pack.toml not found! Must be run from the root of the modpack."
fi

# ─── Header ────────────────────────────────────────────────────────────────────

# Handle missing mods and overrides/mods directories
if [[ -d "overrides/mods" ]]; then
    override_mod_count=$(find overrides/mods -maxdepth 1 -type f 2>/dev/null | wc -l | xargs)
else
    override_mod_count=0
fi

if [[ -d "mods" ]]; then
    mod_count=$(($(find mods -maxdepth 1 -type f 2>/dev/null | wc -l | xargs) + override_mod_count))
else
    mod_count=$override_mod_count
fi

if [[ -d "resourcepacks" ]]; then
    resourcepack_base_count=$(find resourcepacks -maxdepth 1 -type f 2>/dev/null | wc -l | xargs)
else
    resourcepack_base_count=0
fi

if [[ -d "overrides/resourcepacks" ]]; then
    override_resourcepack_count=$(find overrides/resourcepacks -maxdepth 1 -type f 2>/dev/null | wc -l | xargs)
else
    override_resourcepack_count=0
fi

resourcepack_count=$((resourcepack_base_count + override_resourcepack_count))

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " 🌌 Building: $PACK_NAME"
echo " 📦 Mods: $mod_count total (${override_mod_count} overrides)"
echo " 🎨 Resource Packs: $resourcepack_count total ($override_resourcepack_count overrides)"
echo " 🛠 Using: Packwiz"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ─── Temp dir setup ────────────────────────────────────────────────────────────

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

# ─── Overrides ─────────────────────────────────────────────────────────────────

if [[ -d "overrides" ]]; then
    log "Merging overrides into temp directory..."
    find overrides -type f | while read -r filepath; do
        rel_path="${filepath#overrides/}"
        dest_path="$TEMP_DIR/$rel_path"
        mkdir -p "$(dirname "$dest_path")"
        cp -f "$filepath" "$dest_path"
    done
    success "Overrides fully merged into project structure."
else
    log "No overrides found, skipping override merge."
fi

# ─── Export ────────────────────────────────────────────────────────────────────

log "Including both client and server mods in the export..."

# Create backup directory for .pw.toml files
PW_TOML_BAK_DIR=".pw_toml_bak"
rm -rf "$PW_TOML_BAK_DIR"
mkdir -p "$PW_TOML_BAK_DIR"
log "Backing up .pw.toml files to $PW_TOML_BAK_DIR..."
find "$TEMP_DIR" -type f -name "*.pw.toml" | while read -r tomlfile; do
    rel_path="${tomlfile#$TEMP_DIR/}"
    bak_path="$PW_TOML_BAK_DIR/$rel_path"
    mkdir -p "$(dirname "$bak_path")"
    cp -f "$tomlfile" "$bak_path"
done
success "Backup of .pw.toml files completed."

log "Replacing side = \"server\" with side = \"both\" in .pw.toml files..."
find "$TEMP_DIR" -type f -name "*.pw.toml" | while read -r tomlfile; do
    sed -i '' 's/side = "server"/side = "both"/g' "$tomlfile"
done
success "Replacements done."

log "Exporting modpack with packwiz modrinth export..."
cd "$TEMP_DIR"
# Export as zip first (default)
packwiz modrinth export -o "../$EXPORT_FILE.zip" >/dev/null 2>&1 || error "Packwiz export failed"
cd - >/dev/null

log "Restoring original .pw.toml files from backup..."
find "$PW_TOML_BAK_DIR" -type f -name "*.pw.toml" | while read -r bakfile; do
    rel_path="${bakfile#$PW_TOML_BAK_DIR/}"
    orig_path="$TEMP_DIR/$rel_path"
    cp -f "$bakfile" "$orig_path"
done
success "Original .pw.toml files restored."

log "Cleaning up .pw.toml backup directory..."
rm -rf "$PW_TOML_BAK_DIR"
success "Backup directory removed."

# ─── Remove leftover .pw.toml.bak files ────────────────────────────────────────
log "Cleaning up leftover .pw.toml.bak files..."
find "$TEMP_DIR" -type f -name "*.pw.toml.bak" -delete
success "Leftover .pw.toml.bak files removed."

# ─── Log missing mod jar files before export ───────────────────────────────────
log_missing_mods() {
    log "Checking for missing mod jar files..."
    missing=0
    find "$TEMP_DIR" -type f -name "*.pw.toml" | while read -r toml; do
        # Extract the mod jar name from the toml (assumes the file field is present)
        mod_jar=$(grep 'file = "' "$toml" | sed -E 's/.*file = "([^"]+)".*/\1/' || true)
        if [[ -n "$mod_jar" ]]; then
            if [[ ! -f "$TEMP_DIR/$mod_jar" && ! -f "$TEMP_DIR/mods/$mod_jar" && ! -f "$TEMP_DIR/overrides/mods/$mod_jar" ]]; then
                echo " ❌ Missing mod jar referenced in $toml: $mod_jar"
                missing=$((missing+1))
            fi
        fi
    done
    if [[ $missing -gt 0 ]]; then
        error "Found $missing missing mod jars. Please add them before export."
    else
        success "All mod jar files found."
    fi
}

log_missing_mods

# Unzip and repackage as .mrpack while preserving metadata
TMP_UNZIP_DIR=".tmp_unzip_mrpack"
rm -rf "$TMP_UNZIP_DIR"
mkdir "$TMP_UNZIP_DIR"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
ditto -xk "$EXPORT_FILE.zip" "$TMP_UNZIP_DIR" || error "Failed to unzip exported pack"

# Rename .zip to .mrpack by re-zipping contents
rm -f "$EXPORT_FILE"
(
    cd "$TMP_UNZIP_DIR"
    zip -qr "../$EXPORT_FILE" . || error "Failed to repackage .mrpack"
)
rm -rf "$TMP_UNZIP_DIR"
rm -f "$EXPORT_FILE.zip"

# Check that the generated .mrpack is not empty
if [[ ! -s "$EXPORT_FILE" ]]; then
    error "Generated .mrpack file is empty! Aborting cleanup."
fi

success "Modpack exported to $EXPORT_FILE"

# ─── Cleanup ───────────────────────────────────────────────────────────────────

log "Cleaning up temp files..."
rm -rf "$TEMP_DIR"
success "Temp files cleaned up."

echo " 🎉 Done! Your pack is ready: \"$EXPORT_FILE\""
