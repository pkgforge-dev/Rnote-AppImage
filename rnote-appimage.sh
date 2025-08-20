#!/bin/sh

set -eux

ARCH="$(uname -m)"
PACKAGE=rnote
URUNTIME="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh"
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"

VERSION=$(pacman -Q "$PACKAGE" | awk 'NR==1 {print $2; exit}')
[ -n "$VERSION" ] && echo "$VERSION" > ~/version

# Variables used by quick-sharun
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export OUTNAME="$PACKAGE"-"$VERSION"-anylinux-"$ARCH".AppImage
export DESKTOP=/usr/share/applications/com.github.flxzt.rnote.desktop
export ICON=/usr/share/icons/hicolor/scalable/apps/com.github.flxzt.rnote.svg
export DEPLOY_OPENGL=1
export DEPLOY_VULKAN=1
export STARTUPWMCLASS=rnote # For Wayland, this is 'com.github.flxzt.rnote', so this needs to be changed in desktop file manually by the user in that case until some potential automatic fix exists for this

# DEPLOY ALL LIBS
wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun
./quick-sharun /usr/bin/rnote /usr/bin/rnote-cli

## Copy fonts used for rnote
cp -vr /usr/share/fonts/rnote-fonts ./AppDir/share/fonts/

## Further debloat locale
find ./AppDir/share/locale -type f ! -name '*glib*' ! -name '*rnote*' -delete

## Set gsettings to save to keyfile, instead to dconf
echo "GSETTINGS_BACKEND=keyfile" >> ./AppDir/.env

# MAKE APPIMAGE WITH URUNTIME
wget --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime2appimage
chmod +x ./uruntime2appimage
./uruntime2appimage
