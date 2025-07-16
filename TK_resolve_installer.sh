#!/usr/bin/env bash
# DaVinci Resolve / Resolve Studio automated installer
set -euo pipefail
IFS=$'\n\t'

# GLOBALS
DOWNLOADS_DIR="${HOME}/Downloads"
LIB_PATH="/usr/lib/x86_64-linux-gnu"
RESOLVE_LIBS_PATH="/opt/resolve/libs"
RESOLVE_PREFIX="DaVinci_Resolve"
STUDIO_TAG="Studio"

die() { printf '%s\n' "$*" >&2; return 1; }

find_latest_zip() {
    local zip
    zip=$(find "$DOWNLOADS_DIR" -maxdepth 1 -type f \
        \( -name "${RESOLVE_PREFIX}_${STUDIO_TAG}_*_Linux.zip" -o -name "${RESOLVE_PREFIX}_*_Linux.zip" \) |
        sort -V | tail -n1) || return 1
    [[ -n ${zip// } ]] || die "No DaVinci Resolve ZIP found in ${DOWNLOADS_DIR}"
    printf '%s' "$zip"
}

extract_version() {
    local file="$1" ver
    ver=$(grep -oP '(?<=DaVinci_Resolve_(Studio_)?)[0-9]+\.[0-9]+(\.[0-9]+)?' <<<"$file") || true
    [[ -n ${ver// } ]] || die "Unable to determine Resolve version from: $file"
    printf '%s' "$ver"
}

unpack_zip() {
    local zip="$1" dest="$2"
    mkdir -p "$dest"
    unzip -o "$zip" -d "$dest" >/dev/null || { rm -r "$dest"; die "Failed to unzip $zip"; }
}

install_dependencies() {
    sudo apt update
    sudo apt install -y libapr1t64 libaprutil1t64 libxcb-composite0 libxcb-xinerama0 libfuse2 libqt6core6
}

find_installer_run() {
    local dir="$1" run
    run=$(find "$dir" -maxdepth 1 -type f -name "${RESOLVE_PREFIX}*_Linux.run" | sort -V | head -n1) || return 1
    [[ -n ${run// } && -x $run ]] || die "Installer .run not found in $dir"
    printf '%s' "$run"
}

run_installer() {
    local runfile="$1"
    sudo SKIP_PACKAGE_CHECK=1 "$runfile" -i
}

copy_required_libs() {
    local libs=(libgio-2.0.so.0 libgmodule-2.0.so.0 libglib-2.0.so.0)
    for lib in "${libs[@]}"; do
        if [[ -f "${LIB_PATH}/${lib}" ]]; then
            sudo cp "${LIB_PATH}/${lib}" "${RESOLVE_LIBS_PATH}/"
        else
            printf 'Warning: %s missing in %s\n' "$lib" "$LIB_PATH" >&2
        fi
    done
}

cleanup() { rm -r "$1"; }

main() {
    local zip version work_dir runfile
    zip=$(find_latest_zip)
    echo "Found: $zip"
    version=$(extract_version "$zip")
    echo "Version: $version"
    work_dir="${DOWNLOADS_DIR}/${RESOLVE_PREFIX}_${version}_Linux"
    echo "Unpacking .zip archive..."
    unpack_zip "$zip" "$work_dir"
    echo "Installing dependencies..."
    install_dependencies
    echo "Locating the installer..."
    runfile=$(find_installer_run "$work_dir")
    echo "Running the installer..."
    run_installer "$runfile"
    echo "Copying required libraries to Resolve's lib directory..."
    copy_required_libs
    echo "Cleaning Up..."
    cleanup "$work_dir"
    echo "All done! You can open Resolve now. Have fun! ~TKtheDEV"
}

main "$@"
