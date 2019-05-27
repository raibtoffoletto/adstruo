# Adstruo
Additional set indicators for Elementary's Wingpanel

## Install, build and run
### Dependencies:
 - libglib2.0-dev
 - gobject-introspection
 - libgtk-3-0
 - libgranite-dev
 - libsoup2.4-dev
 - libjson-glib-dev
 - libwingpanel-2.0-dev
 - libswitchboard-2.0-dev
 - meson
 - valac

### Install dependencies:
`sudo apt-get install libglib2.0-dev gobject-introspection libgtk-3-0 libgranite-dev libsoup2.4-dev libjson-glib-dev libwingpanel-2.0-dev libswitchboard-2.0-dev meson elementary-sdk`

### Clone and Compile
```bash
$ git clone https://github.com/raibtoffoletto/adstruo.git
$ cd adstruo
$ meson build --prefix=/usr

$ cd build
$ ninja
$ sudo ninja install
```
### Restart Wingpanel
`$ pkill wingpanel -9`


## Generating pot file
```bash
#in ./build directory
$ sudo ninja com.github.raibtoffoletto.adstruo-pot
$ sudo ninja com.github.raibtoffoletto.adstruo-update-po
```
