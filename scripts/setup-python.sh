#!/bin/bash

set -e

# ───────────────────────────────────────────────────────────────────────────────
# Python virtual environment setup script
# This script sets up a Python virtual environment in the project directory,
# installs the required packages, and provides instructions for use.
# ───────────────────────────────────────────────────────────────────────────────

# ─── Run from root ─────────────────────────────────────────────────────────────

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR/.." || exit 1

# ─── Check for Python 3 ─────────────────────────────────────────────────────────

if ! command -v python3 &> /dev/null ; then
    echo "❌ Python 3 is not installed. Please install Python 3.x and try again."
    exit 1
else
    echo "✅ Python 3 is installed"
fi

# ─── Create virtual environment if it doesn't exist ───────────────────────────

if [ ! -d ".venv" ]; then
    echo "Creating virtual environment in .venv/"
    python3 -m venv .venv
else
    echo "Virtual environment already exists in .venv/"
fi

# ─── Activate virtual environment ──────────────────────────────────────────────

# shellcheck disable=SC1091
source .venv/bin/activate

# ─── Upgrade pip and install dependencies ──────────────────────────────────────

echo "Upgrading pip..."
pip install --upgrade pip

echo "Installing dependencies from requirements.txt..."
pip install -r requirements.txt

# ─── Completion message ─────────────────────────────────────────────────────────

echo "✅ Setup complete!"
echo
echo "To activate the virtual environment, run:"
echo "  source .venv/bin/activate"
