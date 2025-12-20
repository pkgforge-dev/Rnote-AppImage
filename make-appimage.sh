#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q rnote | awk '{print $2; exit}')
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/scalable/apps/com.github.flxzt.rnote.svg
export DESKTOP=/usr/share/applications/com.github.flxzt.rnote.desktop
export DEPLOY_OPENGL=1
export STARTUPWMCLASS=com.github.flxzt.rnote # Default to Wayland's wmclass. For X11, GTK_CLASS_FIX will force the wmclass to be the Wayland one.
export GTK_CLASS_FIX=1

# Trace and deploy all files and directories needed for the application (including binaries, libraries and others)
quick-sharun /usr/bin/rnote \
             /usr/bin/rnote-cli \
             /usr/share/fonts/rnote-fonts

# Turn AppDir into AppImage
quick-sharun --make-appimage
