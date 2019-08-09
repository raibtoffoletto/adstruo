<!--
* Copyright (c) 2019 Raí B. Toffoletto (https://toffoletto.me)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Raí B. Toffoletto <rai@toffoletto.me>
-->
<p align="center">
  <img align="left" width="64" height="64" src="data/icons/com.github.raibtoffoletto.adstruo.svg" />
  <h1 class="rich-diff-level-zero">Adstruo</h1>
</p>

>Adstruo *(from the latin: to add, to contribute)* aims to provide some additional indicators to
> ElementaryOS's Wingpanel, thus, extending its functionality and providing extra information at a quick glance.
> Indicatos available so far:
> + Hardware temperature
> + Caps and Num Lock
> + Weather *(to be rewritten)*

<img src="https://github.com/raibtoffoletto/adstruo/raw/master/data/com.github.raibtoffoletto.adstruo.screenshot.png"
alt="Adstruo Screenshot" style="display:block; margin-left: auto; margin-right: auto;" />


## Install, build and run
### Dependencies:
 - libglib2.0-dev
 - libgtk-3-0
 - libgranite-dev
 - libsoup2.4-dev
 - libjson-glib-dev
 - libwingpanel-2.0-dev
 - libswitchboard-2.0-dev
 - libgeoclue-2-dev
 - meson
 - valac

### Install dependencies:
`$ sudo apt-get install libglib2.0-dev libgeoclue-2-dev libgtk-3-0 libgranite-dev libsoup2.4-dev libjson-glib-dev libwingpanel-2.0-dev libswitchboard-2.0-dev meson elementary-sdk`

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
