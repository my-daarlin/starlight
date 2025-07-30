#!/bin/bash

# ───────────────────────────────────────────────────────────────────────────────
# Modrinth modlist generation script
# Generates a modlist for the README file from mod .toml files in the mods
# directory, and then pastes it into the README in between specified markers.
# ───────────────────────────────────────────────────────────────────────────────


# ─── Configuration ─────────────────────────────────────────────────────────────

MODS_DIR="mods"                                          # Directory containing mod .toml files
README_FILE="../README.md"                               # Path to the README file relative to this script
MODLIST_START="<!-- MODLIST_START -->"                   # Start marker for modlist in README
MODLIST_END="<!-- MODLIST_END -->"                       # End marker for modlist in README
MODLIST_HEADER="| Name | Source |\n|------|----------|"  # Header for the modlist table

# ─── Logging ───────────────────────────────────────────────────────────────────

log() { echo " 📦 $1"; }
success() { echo " ✅ $1"; }
error() {
    echo " ❌ $1" >&2
    exit 1
}

# ─── Header ────────────────────────────────────────────────────────────────────

mod_count=$(($(find mods -maxdepth 1 -type f 2>/dev/null | wc -l | xargs) + override_mod_count))
resourcepack_count=$(($(find resourcepacks -maxdepth 1 -type f 2>/dev/null | wc -l | xargs) + $(find overrides/resourcepacks -maxdepth 1 -type f 2>/dev/null | wc -l | xargs)))

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " 🌌 Building: $PACK_NAME"
echo " 📦 $mod_count mods"
echo " 🎨 $resourcepack_count resource packs"
echo " 🛠 Target: $README_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ─── Initialization ────────────────────────────────────────────────────────────

cd "$(dirname "$0")/.."
output_file="$README_FILE"

# ─── Mods ──────────────────────────────────────────────────────────────────────

log "Starting modlist generation..."
modlist_table="$MODLIST_HEADER"

for file in "$MODS_DIR"/*.toml; do
    log "Processing file: $file"
    name=$(grep '^name = "' "$file" | sed -E 's/name = "(.*)"/\1/' | sed 's/\\"/"/g')
    modid=$(grep 'mod-id = "' "$file" | sed -E 's/mod-id = "(.*)"/\1/')
    if [ -n "$name" ] && [ -n "$modid" ]; then
        log "Found mod: $name (mod-id: $modid)"
        modlist_table="${modlist_table}\n| $name | [Modrinth](https://modrinth.com/mod/$modid) |"
    else
        error "Error at file: $file (missing name or mod-id)"
    fi
done

sed -i '' "/$MODLIST_START/,/$MODLIST_END/c\\
$MODLIST_START\n$modlist_table\n$MODLIST_END
" "$output_file" || error "Failed to write to $output_file"

success "Modlist generation completed and saved to $output_file"
