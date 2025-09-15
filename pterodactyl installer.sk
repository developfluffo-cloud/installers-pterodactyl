#!/usr/bin/env bash
# -----------------------------------------------------
# Developfluff Single-file Installer (all-in-one)
# Version: 1.0.0
# Author: Developfluff (Developer)
# YouTube: https://youtube.com/@Developer
# License: MIT
# -----------------------------------------------------
set -euo pipefail
IFS=$'\n\t'

APP_NAME="DevelopPanel"
VERSION="1.0.0"
BRANDING="Powered by Developfluff"
INSTALL_DIR="/opt/${APP_NAME}"
SERVICE_NAME="developpanel"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

# Small payload contents (easy to customize)
README_CONTENT=$'This is DevelopPanel.\nInstalled using the official Developfluff installer.\nNot a copy. Original work.\n'
LOGO_CONTENT=$'🔥 DEVELOPFLUFF ORIGINAL INSTALLER 🔥\n'
ABOUT_TEXT=$"${BRANDING} - Created by Developfluff\nYouTube: https://youtube.com/@Developer\nThis installer is original and distributed under MIT."

info(){ printf '\n[INFO] %s\n' "$*"; }
warn(){ printf '\n[WARN] %s\n' "$*"; }
err(){ printf '\n[ERROR] %s\n' "$*' >&2; exit 1; }

banner(){
  cat <<EOF

====================================================
  ${APP_NAME} installer    v${VERSION}
  ${BRANDING}
  Author: Developfluff (Developer)
  YouTube: https://youtube.com/@Developer
====================================================

EOF
}

usage(){
  cat <<EOF
Usage: bash install.sh [options]

Options:
  --help        Show this help
  --version     Print version
  --about       Print about/credits
  --dir PATH    Install to PATH (default: ${INSTALL_DIR})
  --no-service  Do not install or enable systemd demo service
  --dry-run     Show actions without executing (for demo)
EOF
}

# create install directory and payload files
create_payload(){
  local dst="$1"
  info "Creating install directory: $dst"
  if [[ "$DRY_RUN" == "yes" ]]; then
    printf "DRY RUN: mkdir -p %s\n" "$dst"
  else
    sudo mkdir -p "$dst"
    sudo chown "$(id -u):$(id -g)" "$dst"
  fi

  info "Writing payload files..."
  if [[ "$DRY_RUN" == "yes" ]]; then
    printf "DRY RUN: create %s/README.txt\n" "$dst"
    printf "DRY RUN: create %s/logo.txt\n" "$dst"
  else
    printf "%s" "$README_CONTENT" > /tmp/develop_readme.txt
    printf "%s" "$LOGO_CONTENT" > /tmp/develop_logo.txt

    sudo mv /tmp/develop_readme.txt "$dst/README.txt"
    sudo mv /tmp/develop_logo.txt "$dst/logo.txt"

    # set safe perms
    sudo chmod 644 "$dst/README.txt" "$dst/logo.txt"
  fi
}

install_service(){
  # simple demo systemd service that prints a message periodically
  local srv="$SERVICE_FILE"
  cat > /tmp/${SERVICE_NAME}.service <<'SERVICE_EOF'
[Unit]
Description=DevelopPanel Demo Service
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash -c 'while true; do logger -t developpanel "DevelopPanel Running (powered by Developfluff)"; sleep 30; done'
Restart=always
User=root

[Install]
WantedBy=multi-user.target
SERVICE_EOF

  if [[ "$DRY_RUN" == "yes" ]]; then
    info "DRY RUN: would install systemd service to $srv"
  else
    info "Installing systemd service: $srv"
    sudo mv /tmp/${SERVICE_NAME}.service "$srv"
    sudo chmod 644 "$srv"
    info "Reloading systemd daemon and enabling service"
    sudo systemctl daemon-reload
    sudo systemctl enable --now "$SERVICE_NAME" || warn "Failed to start/enable service; check systemctl status ${SERVICE_NAME}.service"
  fi
}

verify_install(){
  local dst="$1"
  info "Verifying installation..."
  if [[ "$DRY_RUN" == "yes" ]]; then
    printf "DRY RUN: list %s\n" "$dst"
  else
    if [[ -d "$dst" ]]; then
      printf "%s installed files:\n" "$dst"
      ls -la "$dst"
    else
      err "Install directory not found: $dst"
    fi
  fi
}

# ----------------------------
# Parse args
# ----------------------------
DRY_RUN="no"
INSTALL_SERVICE="yes"
CUSTOM_DIR=""

while [[ "${1:-}" != "" ]]; do
  case "$1" in
    --help) usage; exit 0 ;;
    --version) echo "$VERSION"; exit 0 ;;
    --about) echo -e "$ABOUT_TEXT"; exit 0 ;;
    --no-service) INSTALL_SERVICE="no"; shift ;;
    --dry-run) DRY_RUN="yes"; shift ;;
    --dir) shift; CUSTOM_DIR="${1:-}"; shift ;;
    *) warn "Unknown option: $1"; usage; exit 1 ;;
  esac
done

# allow custom dir
if [[ -n "$CUSTOM_DIR" ]]; then
  INSTALL_DIR="$CUSTOM_DIR"
fi

# ----------------------------
# Run
# ----------------------------
banner
info "Installer starting..."

# check required commands only when not dry-run
if [[ "$DRY_RUN" == "no" ]]; then
  for cmd in sudo systemctl logger; do
    if ! command -v $cmd >/dev/null 2>&1; then
      warn "Command not found: $cmd (some features may fail)."
    fi
  done
fi

create_payload "$INSTALL_DIR"

if [[ "$INSTALL_SERVICE" == "yes" ]]; then
  # only try to install service if systemd is present
  if [[ "$DRY_RUN" == "no" && -d /run/systemd/system ]]; then
    install_service
  else
    if [[ "$DRY_RUN" == "yes" ]]; then
      info "DRY RUN: would check systemd and install service"
    else
      warn "systemd not detected; skipping service installation."
    fi
  fi
else
  info "User requested no service installation."
fi

verify_install "$INSTALL_DIR"

# final message
cat <<EOF

======== INSTALL COMPLETE ========

${APP_NAME} installed to: ${INSTALL_DIR}
${BRANDING}
Author: Developfluff (Developer)
YouTube: https://youtube.com/@Developer

To view about/credits:
  bash install.sh --about

To check service (if installed):
  sudo systemctl status ${SERVICE_NAME}

To uninstall (manual):
  sudo systemctl stop ${SERVICE_NAME} || true
  sudo systemctl disable ${SERVICE_NAME} || true
  sudo rm -f ${SERVICE_FILE} || true
  sudo rm -rf "${INSTALL_DIR}" || true
  sudo systemctl daemon-reload

===================================

EOF

exit 0
