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
MESA_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/mesa-nano-$PKG_TYPE"
VK_RADEON_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/vulkan-radeon-nano-$PKG_TYPE"
VK_INTEL_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/vulkan-intel-nano-$PKG_TYPE"
VK_NOUVEAU_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/vulkan-nouveau-nano-$PKG_TYPE"
VK_PANFROST_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/vulkan-panfrost-nano-$PKG_TYPE"
VK_FREEDRENO_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/vulkan-freedreno-nano-$PKG_TYPE"
VK_BROADCOM_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/vulkan-broadcom-nano-$PKG_TYPE"
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
wget --retry-connrefused --tries=30 "$LLVM_URL"    -O  ./llvm-libs.pkg.tar.zst
wget --retry-connrefused --tries=30 "$LIBXML_URL"  -O  ./libxml2-iculess.pkg.tar.zst
wget --retry-connrefused --tries=30 "$OPUS_URL"    -O  ./opus-nano.pkg.tar.zst
wget --retry-connrefused --tries=30 "$MESA_URL"        -O  ./mesa.pkg.tar.zst
wget --retry-connrefused --tries=30 "$VK_RADEON_URL"   -O  ./vulkan-radeon.pkg.tar.zst
wget --retry-connrefused --tries=30 "$VK_NOUVEAU_URL"  -O  ./vulkan-nouveau.pkg.tar.zst

if [ "$ARCH" = 'x86_64' ]; then
	wget --retry-connrefused --tries=30 "$VK_INTEL_URL"     -O ./vulkan-intel.pkg.tar.zst
	wget --retry-connrefused --tries=30 "$INTEL_MEDIA_URL"  -O ./intel-media.pkg.tar.zst
else
	wget --retry-connrefused --tries=30 "$VK_PANFROST_URL"  -O ./vulkan-panfrost.pkg.tar.zst
	wget --retry-connrefused --tries=30 "$VK_FREEDRENO_URL" -O ./vulkan-freedreno.pkg.tar.zst
	wget --retry-connrefused --tries=30 "$VK_BROADCOM_URL"  -O ./vulkan-broadcom.pkg.tar.zst
fi

pacman -U --noconfirm ./*.pkg.tar.zst
rm -f ./*.pkg.tar.zst

echo "All done!"
echo "---------------------------------------------------------------"
