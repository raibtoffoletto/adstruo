public class Adstruo.SettingsTemps : Granite.SimpleSettingsPage {
    private GLib.Settings settings;
    private Adstruo.Utilities adstruo;
    private Gtk.ListStore temp_devices;
    private Gtk.ComboBox temp_devices_combo;

    public SettingsTemps () {
        Object (
            activatable: true,
            description: _("Shows a hardware temperature indicator in the wingpanel"),
            header: _("Indicators"),
            icon_name: "sensors-temperature-symbolic",
            title: _("Temperature")
        );
    }

    construct {
        adstruo = new Adstruo.Utilities ();
        settings = new GLib.Settings ("com.github.raibtoffoletto.adstruo.temps");

        status_switch.active = this.settings.get_boolean ("status");
        adstruo.update_status (settings, this);

        content_area.column_spacing = 12;
        content_area.row_spacing = 24;
        content_area.margin_top = 24;
        content_area.halign = Gtk.Align.CENTER;

        var unit_label = new Gtk.Label (_("Use Fahrenheit :"));
            unit_label.xalign = 1;

        var unit_switch = new Gtk.Switch ();
            unit_switch.valign = Gtk.Align.CENTER;
            unit_switch.halign = Gtk.Align.START;
            unit_switch.active = this.settings.get_boolean ("unit-fahrenheit");
            unit_switch.notify["active"].connect (() => {
                this.settings.set_boolean ("unit-fahrenheit", (unit_switch.active ? true : false));
            });

        var temp_label = new Gtk.Label (_("Device to be monitored :"));
            temp_label.xalign = 1;

            temp_devices = new Gtk.ListStore (2, typeof (string), typeof (string));
            update_devices ();

            temp_devices_combo = new Gtk.ComboBox.with_model (temp_devices);
            temp_devices_combo.id_column = 0;
            temp_devices_combo.entry_text_column = 1;
            temp_devices_combo.set_size_request (180, 0);
            temp_devices_combo.active_id = this.settings.get_string ("temperature-source");

        var renderer = new Gtk.CellRendererText ();
            temp_devices_combo.pack_start (renderer, true);
            temp_devices_combo.add_attribute (renderer, "text", 1);

        var advice_label = new Gtk.Label (_("<small>* Usually CPU temps are provided by the kernel (<i>i.e. k10</i>)</small>"));
            advice_label.use_markup = true;

        status_switch.notify["active"].connect (() => {
            this.adstruo.update_status (this.settings, this);
        });
        temp_devices_combo.changed.connect (() => {
            this.settings.set_string ("temperature-source", this.temp_devices_combo.get_active_id ());
        });

        //add to the view
        content_area.attach (unit_label, 0, 0, 1, 1);
        content_area.attach (unit_switch, 1, 0, 1, 1);
        content_area.attach (temp_label, 0, 1, 1, 1);
        content_area.attach (temp_devices_combo, 1, 1, 1, 1);
        content_area.attach (advice_label, 1, 2, 1, 1);

    }

    private void update_devices () {
        try {
            var dir = GLib.Dir.open ("/sys/class/hwmon/", 0);
            string? dirname = null;
            string name;
            Gtk.TreeIter iter;

            while ((dirname = dir.read_name ()) != null) {
                if (FileUtils.test ("/sys/class/hwmon/"+dirname+"/temp1_input", FileTest.EXISTS)) {
                    FileUtils.get_contents("/sys/class/hwmon/"+dirname+"/name", out name);
                    this.temp_devices.append (out iter);
                    this.temp_devices.set (iter, 0, dirname, 1, name.strip ());
                }
            }

        } catch (FileError err) {
            stderr.printf (err.message);
        }
    }

}
