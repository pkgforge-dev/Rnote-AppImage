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
export STARTUPWMCLASS=rnote # For Wayland, this is 'com.github.flxzt.rnote', so this needs to be changed in desktop file manually by the user in that case until some potential automatic fix exists for this

# Trace and deploy all files and directories needed for the application (including binaries, libraries and others)
quick-sharun /usr/bin/rnote \
             /usr/bin/rnote-cli \
             /usr/share/fonts/rnote-fonts

# Turn AppDir into AppImage
quick-sharun --make-appimage
