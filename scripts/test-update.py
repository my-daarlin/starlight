#!/usr/bin/env python3

"""
Starlight - Script to check if Modrinth mods have versions compatible with a target Minecraft version.
Supports Modrinth mods only.
"""

import sys
import requests
import tomllib
from pathlib import Path
import argparse

# ─── Config ───────────────────────────────────────────────────────────────────

PACK_MC_VERSION = "1.21"
REPO_ROOT = Path(__file__).resolve().parent.parent
MODS_DIR = REPO_ROOT / "mods"

# ─── Colors ───────────────────────────────────────────────────────────────────

class Colors:
    HEADER = "\033[95m"
    OK = "\033[92m"
    WARNING = "\033[93m"
    ERROR = "\033[91m"
    INFO = "\033[96m"
    RESET = "\033[0m"
    BOLD = "\033[1m"

# ─── Utility Functions ─────────────────────────────────────────────────────────

def version_tuple(version: str):
    return tuple(int(x) for x in version.split("."))

def get_future_versions(target_version: str):
    """Return a list of all Minecraft release versions >= target_version."""
    url = "https://launchermeta.mojang.com/mc/game/version_manifest.json"
    r = requests.get(url)
    r.raise_for_status()
    data = r.json()
    release_versions = [v["id"] for v in data["versions"] if v["type"] == "release"]
    target_tuple = version_tuple(target_version)
    filtered = sorted([v for v in release_versions if version_tuple(v) >= target_tuple], key=version_tuple)
    return filtered

def check_modrinth_mod(mod_id: str, mc_version: str) -> tuple[bool | None, str | None]:
    """Check if a Modrinth mod has a version for a specific Minecraft version."""
    url = f"https://api.modrinth.com/v2/project/{mod_id}/version"
    try:
        r = requests.get(url, timeout=10)
        r.raise_for_status()
        data = r.json()
    except requests.RequestException as e:
        return None, f"Network error: {e}"

    for version in data:
        if mc_version in version.get("game_versions", []):
            return True, None
    return False, None

def print_status(file: str, status: str, message: str = ""):
    """Print the file status with colors."""
    symbols = {"ok": "✅", "warning": "⚠️", "error": "❌", "info": "📦"}
    colors = {"ok": Colors.OK, "warning": Colors.WARNING, "error": Colors.ERROR, "info": Colors.INFO}
    color = colors.get(status, Colors.INFO)
    symbol = symbols.get(status, "📦")
    print(f"{symbol} {color}{file}{Colors.RESET}: {message}")

# ─── Main Script ──────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="Check mods for Minecraft compatibility.")
    parser.add_argument("-v", "--version", default=PACK_MC_VERSION, help="Target Minecraft version")
    parser.add_argument("-f", "--future", action="store_true", help="Check all future versions >= target")
    args = parser.parse_args()

    target_versions = [args.version]
    if args.future:
        target_versions = get_future_versions(args.version)
        print(f"{Colors.HEADER}{Colors.BOLD}🌌 Checking mods for all future MC versions >= {args.version}{Colors.RESET}\n")

    if not MODS_DIR.exists() or not MODS_DIR.is_dir():
        print_status(str(MODS_DIR), "error", "Mods directory does not exist!")
        sys.exit(1)

    all_missing = {}

    for mc_version in target_versions:
        missing = []
        total = 0

        if not args.future:
            print(f"{Colors.HEADER}{Colors.BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print(f" 🌌 Checking mods for Minecraft {mc_version}")
            print(f"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{Colors.RESET}\n")

        for file in MODS_DIR.iterdir():
            if not file.is_file() or not file.name.endswith(".pw.toml"):
                continue

            try:
                with file.open("rb") as f:
                    moddata = tomllib.load(f)
            except Exception as e:
                missing.append((file.name, f"Failed to parse TOML: {e}"))
                if not args.future:
                    print_status(file.name, "error", f"Failed to parse TOML: {e}")
                continue

            if moddata.get("type") == "resource_pack":
                if not args.future:
                    print_status(file.name, "info", "Resource pack detected, skipping version check.")
                continue

            total += 1
            modrinth_id = moddata.get("update", {}).get("modrinth", {}).get("mod-id")

            if modrinth_id:
                has_version, error = check_modrinth_mod(modrinth_id, mc_version)
                if error:
                    missing.append((file.name, f"Modrinth API error: {error}"))
                    if not args.future:
                        print_status(file.name, "error", f"Modrinth API error: {error}")
                elif not has_version:
                    missing.append((file.name, "No version for target MC"))
                    if not args.future:
                        print_status(file.name, "warning", f"No compatible version for Minecraft {mc_version}")
                else:
                    if not args.future:
                        print_status(file.name, "ok", f"Compatible with Minecraft {mc_version}")
                continue

            missing.append((file.name, "No recognized mod ID (Modrinth) found"))
            if not args.future:
                print_status(file.name, "warning", "No recognized mod ID (Modrinth) found")

        print(f"\n{Colors.HEADER}{Colors.BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{Colors.RESET}")
        print(f"Checked {total} mods for Minecraft {mc_version}")
        if missing:
            print_status("Summary", "error", f"{len(missing)} mod(s) need attention")
        else:
            print_status("Summary", "ok", "All mods have a compatible version!")

        for mod_name, reason in missing:
            all_missing[mod_name] = reason

    if all_missing:
        print(f"\n{Colors.HEADER}{Colors.BOLD}Final list of missing mods:{Colors.RESET}")
        for mod_name, reason in all_missing.items():
            print(f"{Colors.WARNING}{mod_name}{Colors.RESET}: {reason}")

if __name__ == "__main__":
    main()
