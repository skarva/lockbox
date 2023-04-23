[![Build Status](https://travis-ci.com/skarva/hermetic.svg?branch=master)](https://travis-ci.com/skarva/hermetic)

<p align="center">
    <img src="data/icons/icon.svg" alt="Icon" />
</p>
<h1 align="center">Hermetic</h1>
<p align="center">
    <a href="https://appcenter.elementary.io/com.github.skarva.hermetic"><img src="https://appcenter.elementary.io/badge.svg" alt="Get it on AppCenter" /></a>
</p>

![Hermetic Screenshot](data/screenshot1.png?raw=true)

## Your secrets. Sealed tight.

Keep your notes and website logins secure in an easy to manage collection.

### Features
* Store passwords or important notes
* Fast search
* Sort by name or date added

## Developing and Building

You'll need the following dependencies:
* meson
* libgranite-dev
* valac

Run `meson build` to configure the build environment. Change to the build directory and run `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`, then execute with `com.github.skarva.hermetic`

    sudo ninja install
    com.github.skarva.hermetic
