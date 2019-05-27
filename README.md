<p align="center">
    <img align="left" width="64" height="64" src="data/icons/com.github.raibtoffoletto.adstruo.svg">
    <h1 class="rich-diff-level-zero">Adstruo</h1>
</p>

Adstruo aims to provide some additional indicators to ElementaryOS's Wingpanel, thus, extending its functionality and providing extra information at a quick glance.

![Adstruo Screenshot](https://github.com/raibtoffoletto/adstruo/raw/master/data/com.github.raibtoffoletto.adstruo.screenshot.png)

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
`$ sudo apt-get install libglib2.0-dev gobject-introspection libgtk-3-0 libgranite-dev libsoup2.4-dev libjson-glib-dev libwingpanel-2.0-dev libswitchboard-2.0-dev meson elementary-sdk`

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


## Generating i18n files
```bash
#in ./build directory
$ sudo ninja com.github.raibtoffoletto.adstruo-pot
$ sudo ninja com.github.raibtoffoletto.adstruo-update-po
```
