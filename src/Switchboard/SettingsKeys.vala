/*
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
*/

public class Adstruo.SettingsKeys : Granite.SimpleSettingsPage {
    public weak Adstruo.Plug plug { get; construct; }
    private GLib.Settings settings;

    public SettingsKeys (Adstruo.Plug plug) {
        Object (
            title: _("Keyboard Status Keys"),
            description: _("Shows the Capslock or Numlock status in the wingpanel"),
            icon_name: "preferences-desktop-keyboard",
            activatable: true,
            plug: plug
        );
    }

    construct {
        settings = plug.adstruo.keys_settings;

        status_switch.active = settings.get_boolean ("status");
        plug.adstruo.update_plug_status ("adstruo-keys", this);

        var numlock_label = new Gtk.Label (_("Num Lock indicator :"));
            numlock_label.xalign = 1;

        var numlock_switch = new Gtk.Switch ();
            numlock_switch.valign = Gtk.Align.CENTER;
            numlock_switch.halign = Gtk.Align.START;
            numlock_switch.active = settings.get_boolean ("numlock");

        var capslock_label = new Gtk.Label (_("Caps Lock indicator :"));
            capslock_label.xalign = 1;

        var capslock_switch = new Gtk.Switch ();
            capslock_switch.valign = Gtk.Align.CENTER;
            capslock_switch.halign = Gtk.Align.START;
            capslock_switch.active = settings.get_boolean ("capslock");

        content_area.halign = Gtk.Align.CENTER;
        content_area.hexpand = true;
        content_area.column_spacing = 16;
        content_area.row_spacing = 16;
        content_area.margin_top = 24;
        content_area.attach (numlock_label, 0, 0);
        content_area.attach (numlock_switch, 1, 0);
        content_area.attach (capslock_label, 0, 1);
        content_area.attach (capslock_switch, 1, 1);

        status_switch.notify["active"].connect (() => {
            plug.adstruo.update_plug_status ("adstruo-keys", this);
        });

        numlock_switch.notify["active"].connect (() => {
            settings.set_boolean ("numlock", numlock_switch.active);
        });

        capslock_switch.notify["active"].connect (() => {
            settings.set_boolean ("capslock", capslock_switch.active);
        });
    }
}
