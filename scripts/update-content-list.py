#!/usr/bin/env python3

import os
import re
import sys
from pathlib import Path

# ───────────────────────────────────────────────────────────────────────────────
# Modrinth modlist generation script (Python version)
# Generates a modlist for the README file from mod .toml files in the mods
# directory, and then pastes it into the README in between specified markers.
# ───────────────────────────────────────────────────────────────────────────────

# ─── Configuration ─────────────────────────────────────────────────────────────

PACK_NAME = "Modrinth Modpack"                                                # Name of the modpack
MODS_DIR = Path("mods")                                                       # Directory containing mod .toml files
RESOURCEPACKS_DIR = Path("resourcepacks")                                     # Directory containing resourcepack .toml files
README_FILE = Path("README.md")                                               # Path to the README
MODLIST_START = "<!-- MODLIST_START -->"                                      # Start marker for modlist in README
MODLIST_END = "<!-- MODLIST_END -->"                                          # End marker for modlist in README
MODLIST_HEADER = "| Name | Type | Source |\n|------|------|--------|"         # Header for the modlist table

# ─── Logging with colors ───────────────────────────────────────────────────────

class Colors:
    INFO = '\033[94m'    # Blue
    SUCCESS = '\033[92m' # Green
    ERROR = '\033[91m'   # Red
    RESET = '\033[0m'    # Reset color

def log(message):
    print(f"{Colors.INFO} 📦 {message}{Colors.RESET}")

def success(message):
    print(f"{Colors.SUCCESS} ✅ {message}{Colors.RESET}")

def error(message):
    print(f"{Colors.ERROR} ❌ {message}{Colors.RESET}", file=sys.stderr)
    sys.exit(1)

# ─── Helper functions ──────────────────────────────────────────────────────────

def extract_fields(toml_path):
    """
    Extract 'name' and 'mod-id' fields from a .toml file.
    Returns (name, modid) or raises an error if missing.
    """
    name = None
    modid = None
    name_pattern = re.compile(r'^name\s*=\s*"(.*)"')
    modid_pattern = re.compile(r'^mod-id\s*=\s*"(.*)"')

    try:
        with open(toml_path, 'r', encoding='utf-8') as f:
            for line in f:
                if name is None:
                    match = name_pattern.match(line.strip())
                    if match:
                        # Unescape quotes
                        name = match.group(1).replace('\\"', '"')
                if modid is None:
                    match = modid_pattern.match(line.strip())
                    if match:
                        modid = match.group(1)
                if name is not None and modid is not None:
                    break
    except Exception as e:
        error(f"Failed to read file: {toml_path} ({e})")

    if not name or not modid:
        error(f"Error at file: {toml_path} (missing name or mod-id)")
    return name, modid

def generate_modlist_table(mods_dir, resourcepacks_dir, project_root):
    """
    Generate the markdown table of mods and resourcepacks.
    """
    lines = [MODLIST_HEADER]

    # Process mods
    log("Going through mods...")
    if mods_dir.exists() and mods_dir.is_dir():
        for toml_file in sorted(mods_dir.glob("*.toml")):
            if toml_file.is_file():
                try:
                    relative_path = toml_file.relative_to(project_root)
                except ValueError:
                    relative_path = toml_file.name
                log(f"Processing file: {relative_path}")
                name, modid = extract_fields(toml_file)
                success(f"Found mod: {name} (mod-id: {modid})")
                lines.append(f"| {name} | Mod | [Modrinth](https://modrinth.com/mod/{modid}) |")
    else:
        log(f"Mods directory '{mods_dir}' does not exist or is not a directory.")

    # Process resourcepacks
    log("Going through texturepacks...")
    if resourcepacks_dir.exists() and resourcepacks_dir.is_dir():
        for toml_file in sorted(resourcepacks_dir.glob("*.toml")):
            if toml_file.is_file():
                try:
                    relative_path = toml_file.relative_to(project_root)
                except ValueError:
                    relative_path = toml_file.name
                log(f"Processing texturepack file: {relative_path}")
                name, modid = extract_fields(toml_file)
                success(f"Found texturepack: {name} (mod-id: {modid})")
                lines.append(f"| {name} | Texturepack | [Modrinth](https://modrinth.com/mod/{modid}) |")
    else:
        log(f"Resourcepacks directory '{resourcepacks_dir}' does not exist or is not a directory.")

    return "\n".join(lines)

# ─── Main ───────────────────────────────────────────────────────────────────────

def main():
    # Resolve paths relative to project root
    script_dir = Path(__file__).resolve().parent
    project_root = script_dir.parent

    mods_dir = project_root / MODS_DIR
    resourcepacks_dir = project_root / RESOURCEPACKS_DIR
    readme_file = (project_root / README_FILE).resolve()

    # Print header info
    mod_count = len(list(mods_dir.glob("*.toml"))) if mods_dir.exists() else 0
    resourcepack_count = len(list(resourcepacks_dir.glob("*.toml"))) if resourcepacks_dir.exists() else 0

    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print(f" 🌌 Modpack: {PACK_NAME}")
    print(f" 📦 {mod_count} mods")
    print(f" 🎨 {resourcepack_count} resource packs")
    print(f" 🛠 Target: {readme_file}")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    log("Starting modlist generation...")
    modlist_table = generate_modlist_table(mods_dir, resourcepacks_dir, project_root)

    # Read README and replace content between markers
    try:
        with open(readme_file, "r", encoding="utf-8") as f:
            content = f.read()
    except Exception as e:
        error(f"Failed to read README file: {readme_file} ({e})")

    start_index = content.find(MODLIST_START)
    end_index = content.find(MODLIST_END)

    if start_index == -1 or end_index == -1 or end_index < start_index:
        error(f"Markers {MODLIST_START} and {MODLIST_END} not found or in wrong order in {readme_file}")

    start_index += len(MODLIST_START)

    new_content = content[:start_index] + "\n" + modlist_table + "\n" + content[end_index:]

    try:
        with open(readme_file, "w", encoding="utf-8") as f:
            f.write(new_content)
    except Exception as e:
        error(f"Failed to write to README file: {readme_file} ({e})")

    success(f"Modlist generation completed and saved to {readme_file}")

if __name__ == "__main__":
    main()
