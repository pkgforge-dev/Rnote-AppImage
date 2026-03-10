#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

echo "Building package and its dependencies..."
echo "---------------------------------------------------------------"
make-aur-package --archlinux-pkg rnote
