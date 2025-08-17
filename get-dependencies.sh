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
LLVM_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/llvm-libs-nano-$PKG_TYPE"
# opus is not used by the app, it's just to debloat the base install
OPUS_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/opus-nano-$PKG_TYPE"
MESA_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/mesa-mini-$PKG_TYPE"
INTEL_MEDIA_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/intel-media-mini-$PKG_TYPE" 
VK_RADEON_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/vulkan-radeon-mini-$PKG_TYPE"
VK_INTEL_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/vulkan-intel-mini-$PKG_TYPE"
VK_NOUVEAU_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/vulkan-nouveau-mini-$PKG_TYPE"
VK_PANFROST_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/vulkan-panfrost-mini-$PKG_TYPE"
VK_FREEDRENO_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/vulkan-freedreno-mini-$PKG_TYPE"
VK_BROADCOM_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/vulkan-broadcom-mini-$PKG_TYPE"

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
        pacman -Syu --noconfirm gtk4 glib2 libadwaita poppler-glib gstreamer alsa-lib \
	                        meson cargo cmake clang git
	makepkg -f
	ls -la .
	pacman --noconfirm -U *.pkg.tar.*
)
pacman -Syu --noconfirm mesa

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
