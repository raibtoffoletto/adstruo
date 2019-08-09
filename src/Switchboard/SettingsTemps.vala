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
public class Adstruo.SettingsTemps : Granite.SimpleSettingsPage {
    public weak Adstruo.Plug plug { get; construct; }
    private GLib.Settings settings;
    private Gtk.ListStore temp_devices;
    private Gtk.ComboBox temp_devices_combo;

    public SettingsTemps (Adstruo.Plug plug) {
        Object (
            header: _("Indicators"),
            title: _("Hardware Temperature"),
            description: _("Shows a hardware temperature in the wingpanel"),
            icon_name: "com.github.raibtoffoletto.adstruo.temps",
            activatable: true,
            plug: plug
        );
    }

    construct {
        settings = plug.adstruo.temp_settings;

        status_switch.active = settings.get_boolean ("status");
        plug.adstruo.update_plug_status ("adstruo-temps", this);

        var temps_description = _("Here you can choose a device to monitor its temperature. \n" +
                                "Devices available may vary according to your system, " +
                                "the information is obtained directly from sensors in <b>/sys</b>.");

        var temps_description_label = new Gtk.Label (temps_description);
            temps_description_label.justify = Gtk.Justification.FILL;
            temps_description_label.halign = Gtk.Align.START;
            temps_description_label.hexpand = true;
            temps_description_label.wrap = true;
            temps_description_label.margin_start = 60;
            temps_description_label.margin_end = 60;
            temps_description_label.use_markup = true;

        var temp_label = new Gtk.Label (_("Device to be monitored :"));
            temp_label.xalign = 1;

            temp_devices = new Gtk.ListStore (2, typeof (string), typeof (string));
            get_devices_list ();

            temp_devices_combo = new Gtk.ComboBox.with_model (temp_devices);
            temp_devices_combo.id_column = 0;
            temp_devices_combo.entry_text_column = 1;
            temp_devices_combo.set_size_request (180, 0);

        var renderer = new Gtk.CellRendererText ();
            temp_devices_combo.pack_start (renderer, true);
            temp_devices_combo.add_attribute (renderer, "text", 1);
            temp_devices_combo.active_id = settings.get_string ("temperature-source");

        var advice_label = new Gtk.Label (_("* CPU temps are ysually provided by the kernel (<i>i.e. k10*</i>)"));
            advice_label.use_markup = true;

        var unit_label = new Gtk.Label (_("Use Fahrenheit :"));
            unit_label.xalign = 1;

        var unit_switch = new Gtk.Switch ();
            unit_switch.valign = Gtk.Align.CENTER;
            unit_switch.halign = Gtk.Align.START;
            unit_switch.active = settings.get_boolean ("unit-fahrenheit");

        var options_grid = new Gtk.Grid ();
            options_grid.halign = Gtk.Align.CENTER;
            options_grid.hexpand = true;
            options_grid.column_spacing = 16;
            options_grid.row_spacing = 16;
            options_grid.margin_top = 24;
            options_grid.attach (temp_label, 0, 0);
            options_grid.attach (temp_devices_combo, 1, 0);
            options_grid.attach (advice_label, 1, 1);
            options_grid.attach (unit_label, 0, 2);
            options_grid.attach (unit_switch, 1, 2);

        content_area.halign = Gtk.Align.FILL;
        content_area.hexpand = true;
        content_area.attach (temps_description_label, 0, 0);
        content_area.attach (options_grid, 0, 1);

        status_switch.notify["active"].connect (() => {
            plug.adstruo.update_plug_status ("adstruo-temps", this);
        });

        temp_devices_combo.changed.connect (() => {
            settings.set_string ("temperature-source", temp_devices_combo.get_active_id ());
        });

        unit_switch.notify["active"].connect (() => {
            settings.set_boolean ("unit-fahrenheit", (unit_switch.active ? true : false));
        });

    }

    private void get_devices_list () {
        try {
            var dir = GLib.Dir.open ("/sys/class/hwmon/", 0);
            string? dirname = null;
            string name;

            while ((dirname = dir.read_name ()) != null) {
                if (FileUtils.test ("/sys/class/hwmon/"+dirname+"/temp1_input", FileTest.EXISTS)) {
                    FileUtils.get_contents("/sys/class/hwmon/"+dirname+"/name", out name);
                    Gtk.TreeIter iter;
                    temp_devices.append (out iter);
                    temp_devices.set (iter, 0, dirname, 1, name.strip ());
                }
            }

        } catch (FileError err) {
            stderr.printf (err.message);
        }
    }

}
