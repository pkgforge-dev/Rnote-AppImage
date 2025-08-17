# Rnote-AppImage 🐧

[![GitHub Downloads](https://img.shields.io/github/downloads/pkgforge-dev/Rnote-AppImage/total?logo=github&label=GitHub%20Downloads)](https://github.com/pkgforge-dev/Rnote-AppImage/releases/latest)
[![CI Build Status](https://github.com//pkgforge-dev/Rnote-AppImage/actions/workflows/blank.yml/badge.svg)](https://github.com/pkgforge-dev/Rnote-AppImage/releases/latest)

* [Latest Stable Release](https://github.com/pkgforge-dev/Rnote-AppImage/releases/latest)

---

AppImage made using [sharun](https://github.com/VHSgunzo/sharun), which makes it extremely easy to turn any binary into a portable package without using containers or similar tricks. 

**This AppImage bundles everything and should work on any linux distro, even on musl based ones.**

It is possible that this appimage may fail to work with appimagelauncher, I recommend these alternatives instead: 

* [AM](https://github.com/ivan-hc/AM) `am -i citron` or `appman -i citron`

* [dbin](https://github.com/xplshn/dbin) `dbin install citron.appimage`

* [soar](https://github.com/pkgforge/soar) `soar install citron`

This appimage works without fuse2 as it can use fuse3 instead, it can also work without fuse at all thanks to the [uruntime](https://github.com/VHSgunzo/uruntime)

<details>
  <summary><b><i>raison d'être</i></b></summary>
    <img src="https://github.com/user-attachments/assets/d40067a6-37d2-4784-927c-2c7f7cc6104b" alt="Inspiration Image">
  </a>
</details>

More at: [AnyLinux-AppImages](https://pkgforge-dev.github.io/Anylinux-AppImages/)

---

## Known variance

- Working directory in Workspace is the temporary AppImage one, instead of `$HOME`.  
That is because we are patching the main binary to look into AppImage's `share` folder instead of the host's `/usr/share/`, which is required for locale/languages to work.  
To workaround this issue, you can just create a new workspace with correct directory and delete the old one.

<details>
  <summary><b><i>This is how it looks like</i></b></summary>
    <img width="1051" height="1008" alt="Screenshot From 2025-08-17 18-50-14" src="https://github.com/user-attachments/assets/97c76553-8c00-4649-a8a2-b50bc100506c" />
  </a>
</details>
