#!/usr/bin/env bash
# ======================================================
# Pterodactyl Installer by Developfluff
# Version: 1.0.0
# GitHub: https://github.com/developfluffo-cloud/installers-pterodactyl
# YouTube: https://youtube.com/@Developer
# License: MIT
# ======================================================

set -euo pipefail
IFS=$'\n\t'

APP_NAME="DevelopPanel Pterodactyl Installer"
VERSION="1.0.0"
BRANDING="Powered by Developfluff"
INSTALL_DIR="/opt/DevelopPanel"

info(){ printf "\n[INFO] %s\n" "$*"; }
warn(){ printf "\n[WARN] %s\n" "$*"; }
err(){ printf "\n[ERROR] %s\n" "$*" >&2; exit 1; }

banner(){
cat <<EOF

====================================================
  $APP_NAME   v$VERSION
  $BRANDING
  Author: Developfluff
  YouTube: https://youtube.com/@Developer
====================================================

EOF
}

usage(){
cat <<EOF
Usage: bash pterodactyl-installer.sh [options]

Options:
  --help        Show this help message
  --version     Print version
  --about       Show about / credits
  --dir PATH    Install into PATH instead of default ($INSTALL_DIR)
  --dry-run     Show actions without performing them
EOF
}

about(){
cat <<EOF
$BRANDING
Created by Developfluff
YouTube: https://youtube.com/@Developer

This script is original work. Not a copy.
EOF
}

# ----------------------------
# Parse arguments
# ----------------------------
DRY_RUN="no"
CUSTOM_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help) usage; exit 0 ;;
    --version) echo "$VERSION"; exit 0 ;;
    --about) about; exit 0 ;;
    --dir) shift; CUSTOM_DIR="$1"; shift ;;
    --dry-run) DRY_RUN="yes"; shift ;;
    *) warn "Unknown option: $1"; usage; exit 1 ;;
  esac
done

if [[ -n "$CUSTOM_DIR" ]]; then
  INSTALL_DIR="$CUSTOM_DIR"
fi

# ----------------------------
# Main installer
# ----------------------------
banner
info "Starting installer..."

# Create install directory
if [[ "$DRY_RUN" == "no" ]]; then
  sudo mkdir -p "$INSTALL_DIR"
  sudo chown "$(id -u):$(id -g)" "$INSTALL_DIR"
fi

info "Creating sample payload files..."
if [[ "$DRY_RUN" == "no" ]]; then
  echo "This is DevelopPanel. Installed using the official Developfluff installer." > "$INSTALL_DIR/README.txt"
  echo "🔥 DEVELOPFLUFF ORIGINAL INSTALLER 🔥" > "$INSTALL_DIR/logo.txt"
  sudo chmod 644 "$INSTALL_DIR/README.txt" "$INSTALL_DIR/logo.txt"
fi

info "Installation folder: $INSTALL_DIR"

# Final message
cat <<EOF

======== INSTALL COMPLETE ========

$APP_NAME installed to: $INSTALL_DIR
$BRANDING
Author: Developfluff (Developer)
YouTube: https://youtube.com/@Developer

Run 'bash pterodactyl-installer.sh --about' to view credits.
===================================

EOF

exit 0
