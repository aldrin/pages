#!/bin/bash
set -euo pipefail

# Tools
brew install pandoc typst

# Python (uv manages the venv and dependencies via pyproject.toml)
brew install uv

# Fonts: IBM Plex family (SIL OFL, freely redistributable).
brew install --cask font-ibm-plex-serif font-ibm-plex-sans font-ibm-plex-mono

# Set up the Python environment
cd "$(dirname "$0")/plots"
uv sync
