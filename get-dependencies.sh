#!/bin/sh

set -eux

sed -i 's/DownloadUser/#DownloadUser/g' /etc/pacman.conf

ARCH="$(uname -m)"

if [ "$ARCH" = 'x86_64' ]; then
	PKG_TYPE="$ARCH.pkg.tar.zst"
elif [ "$ARCH" = 'aarch64' ]; then
	PKG_TYPE="$ARCH.pkg.tar.xz"
fi

DEBLOATED_PKGS_INSTALLER="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/get-debloated-pkgs.sh"

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
wget --retry-connrefused --tries=30 "$DEBLOATED_PKGS_INSTALLER" -O ./get-debloated-pkgs.sh
chmod +x ./get-debloated-pkgs.sh
./get-debloated-pkgs.sh libxml2-mini mesa-nano gtk4-mini

pacman -U --noconfirm ./*.pkg.*
rm -f ./*.pkg.*

echo "All done!"
echo "---------------------------------------------------------------"
