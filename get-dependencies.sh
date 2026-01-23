#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
# Cannot build Rust appa with llvm-libs-mini
get-debloated-pkgs --add-common --prefer-nano ! llvm-libs

echo "Building package and its dependencies..."
echo "---------------------------------------------------------------"
make-aur-package --archlinux-pkg rnote
