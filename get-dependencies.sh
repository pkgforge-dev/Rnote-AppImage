#!/bin/sh

set -eux

sed -i 's/DownloadUser/#DownloadUser/g' /etc/pacman.conf

ARCH="$(uname -m)"

if [ "$ARCH" = 'x86_64' ]; then
	PKG_TYPE='x86_64.pkg.tar.zst'
else
	PKG_TYPE='aarch64.pkg.tar.xz'
fi

LIBXML_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/libxml2-iculess-$PKG_TYPE"
OPUS_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/opus-nano-$PKG_TYPE"
MESA_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/mesa-mini-$PKG_TYPE"
INTEL_MEDIA_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/intel-media-mini-$PKG_TYPE" 

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

case "$ARCH" in
	'x86_64')  
		PKG_TYPE='x86_64.pkg.tar.zst'
		pacman -Syu --noconfirm intel-media-driver libva-intel-driver vulkan-intel haskell-gnutls svt-av1
		;;
	'aarch64') 
		PKG_TYPE='aarch64.pkg.tar.xz'
		pacman -Syu --noconfirm vulkan-freedreno vulkan-panfrost
		;;
	''|*)      
		echo "Unknown cpu arch: $ARCH" 
		exit 1
		;;
esac

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
wget --retry-connrefused --tries=30 "$LIBXML_URL"  -O  ./libxml2-iculess.pkg.tar.zst
wget --retry-connrefused --tries=30 "$OPUS_URL"    -O  ./opus-nano.pkg.tar.zst
wget --retry-connrefused --tries=30 "$MESA_URL"        -O  ./mesa.pkg.tar.zst

if [ "$ARCH" = 'x86_64' ]; then
	wget --retry-connrefused --tries=30 "$INTEL_MEDIA_URL"  -O ./intel-media.pkg.tar.zst
fi

pacman -U --noconfirm ./*.pkg.tar.zst
rm -f ./*.pkg.tar.zst

echo "All done!"
echo "---------------------------------------------------------------"
