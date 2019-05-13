public class Adstruo.SettingsTemps : Granite.SimpleSettingsPage {
    private GLib.Settings settings;
<<<<<<< HEAD
    private Gtk.ListStore temp_devices;
    private Gtk.ComboBox temp_devices_combo;
=======
>>>>>>> 1046c421a351e3d9148b658ed431579fc00f8150

    public SettingsTemps () {
        Object (
            activatable: true,
            description: "Shows a temperature indicator in the wingpanel",
            header: "Indicators",
            icon_name: "sensors-temperature-symbolic",
            title: "Temperatures"
        );
    }

    construct {
        //get gsettings
        this.settings = new GLib.Settings ("com.github.raibtoffoletto.adstruo.temps");
        status_switch.active = this.settings.get_boolean ("status");
<<<<<<< HEAD
        update_status ();

        //config content area
        content_area.column_spacing = 12;
        content_area.row_spacing = 24;
        content_area.margin_top = 24;
        content_area.halign = Gtk.Align.CENTER;

        //list options available
        var unit_label = new Gtk.Label ("Use Fahrenheit : ");
            unit_label.xalign = 1;

        var unit_switch = new Gtk.Switch ();
            unit_switch.valign = Gtk.Align.CENTER;
            unit_switch.halign = Gtk.Align.START;
            unit_switch.active = this.settings.get_boolean ("unit-fahrenheit");
            unit_switch.notify["active"].connect (() => {
                this.settings.set_boolean ("unit-fahrenheit", (unit_switch.active ? true : false));
            });

        var temp_label = new Gtk.Label ("Source device to be monitored : ");
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

        var advice_label = new Gtk.Label ("<small>* Usually CPU temps are provided by the kernel (<i>i.e. k10</i>)</small>");
            advice_label.use_markup = true;

        //connect methods
        status_switch.notify["active"].connect (update_status);
        temp_devices_combo.changed.connect (() => {
            this.settings.set_string ("temperature-source", this.temp_devices_combo.get_active_id ());
        });

        //add to the view
        content_area.attach (unit_label, 0, 0, 1, 1);
        content_area.attach (unit_switch, 1, 0, 1, 1);
        content_area.attach (temp_label, 0, 1, 1, 1);
        content_area.attach (temp_devices_combo, 1, 1, 1, 1);
        content_area.attach (advice_label, 1, 2, 1, 1);

=======

        update_status ();
        status_switch.notify["active"].connect (update_status);
>>>>>>> 1046c421a351e3d9148b658ed431579fc00f8150
    }

    private void update_status () {
        this.settings.set_boolean ("status", status_switch.active);
        status = (status_switch.active ? "Enabled" : "Disabled");
    }

<<<<<<< HEAD
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

=======
>>>>>>> 1046c421a351e3d9148b658ed431579fc00f8150
}
