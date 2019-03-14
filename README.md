# Lock Box

![Screenshot](data/screenshot.png?raw=true)

## Building, Testing, and Installation

You'll need the following dependencies:
* meson
* libgranite-dev
* libsecret-1-dev
* libvala-0.34-dev (or higher)
* valac

Run `meson build` to configure the build environment. Change to the build directory and run `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`, then execute with `com.github.skarva.lockbox`

    sudo ninja install
    com.github.skarva.lockbox
