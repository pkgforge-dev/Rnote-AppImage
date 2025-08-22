#!/bin/sh

set -eux

sed -i 's/DownloadUser/#DownloadUser/g' /etc/pacman.conf

ARCH="$(uname -m)"

if [ "$ARCH" = 'x86_64' ]; then
	PKG_TYPE="$ARCH.pkg.tar.zst"
elif [ "$ARCH" = 'aarch64' ]; then
	PKG_TYPE="$ARCH.pkg.tar.xz"
fi

LIBXML2_URL="https://github.com/pkgforge-dev/archlinux-pkgs-debloated/releases/download/continuous/libxml2-mini-$PKG_TYPE"
OPUS_URL="https://github.com/pkgforge-dev/archlinux-pkgs-debloated/releases/download/continuous/opus-mini-$PKG_TYPE"
MESA_URL="https://github.com/pkgforge-dev/archlinux-pkgs-debloated/releases/download/continuous/mesa-nano-$PKG_TYPE"
INTEL_MEDIA_DRIVER_URL="https://github.com/pkgforge-dev/archlinux-pkgs-debloated/releases/download/continuous/intel-media-driver-mini-$PKG_TYPE" 
GTK4_URL="https://github.com/pkgforge-dev/archlinux-pkgs-debloated/releases/download/continuous/gtk4-mini-$PKG_TYPE"

echo "Installing build dependencies for sharun & AppImage integration..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	base-devel \
	curl \
	desktop-file-utils \
	git \
	libxtst \
	wget \
	xorg-server-xvfb \
	zsync
echo "Building the app & it's dependencies..."
echo "---------------------------------------------------------------"

sed -i 's|EUID == 0|EUID == 69|g' /usr/bin/makepkg
git clone https://gitlab.archlinux.org/archlinux/packaging/packages/rnote.git ./rnote && (
	cd ./rnote
	sed -i -e "s|x86_64|$ARCH|" ./PKGBUILD
    makepkg -fs --noconfirm
	ls -la .
	pacman --noconfirm -U *.pkg.tar.*
)

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
wget --retry-connrefused --tries=30 "$LIBXML2_URL"  -O  ./"libxml2-mini-$PKG_TYPE"
wget --retry-connrefused --tries=30 "$OPUS_URL"    -O  ./"opus-mini-$PKG_TYPE"
wget --retry-connrefused --tries=30 "$MESA_URL"        -O  ./"mesa-nano-$PKG_TYPE"
wget --retry-connrefused --tries=30 "$GTK4_URL"        -O  ./"gtk4-mini-$PKG_TYPE"
if [ "$ARCH" = 'x86_64' ]; then
  wget --retry-connrefused --tries=30 "$INTEL_MEDIA_DRIVER_URL"  -O ./"intel-media-driver-mini-$PKG_TYPE"
fi

pacman -U --noconfirm ./*.pkg.*
rm -f ./*.pkg.*

echo "All done!"
echo "---------------------------------------------------------------"
