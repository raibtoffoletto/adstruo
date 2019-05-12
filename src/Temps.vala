public class Adstruo.Temps : Wingpanel.Indicator {
    private Gtk.Box display_widget;
    private Gtk.Box popover_widget;
    private Gtk.Label temperature;
    private GLib.Settings settings;
    private Wingpanel.Widgets.Switch fahrenheit_switch;

    public Temps () {
        Object (
            code_name : "adstruo-temps",
            display_name : "Temperature Indicator",
            description: "Adds temperature information (CPU or GPU) to the wingpanel."
        );
    }

    construct {
        // visible by default
        this.visible = true;

        //get gsettings
        this.settings = new GLib.Settings ("com.github.raibtoffoletto.adstruo.temps");

        //indicator's structure
        var icon = new Gtk.Image.from_icon_name ("sensors-temperature-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        temperature = new Gtk.Label ("0℃");
        temperature.margin = 2;

        display_widget = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        display_widget.valign = Gtk.Align.CENTER;
        display_widget.pack_start (icon);
        display_widget.pack_start (temperature);

        var options_button = new Gtk.ModelButton ();
        options_button.text = "Options";
        options_button.clicked.connect (() => {
            show_settings ();
        });

        fahrenheit_switch = new Wingpanel.Widgets.Switch ("Fahrenheit");
        fahrenheit_switch.notify["active"].connect (() => {
            this.settings.set_boolean ("unit-fahrenheit", (fahrenheit_switch.active ? true : false));
        });

        popover_widget = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        popover_widget.add (fahrenheit_switch);
        popover_widget.add (new Wingpanel.Widgets.Separator ());
        popover_widget.add (options_button);

        //update indicator info
        Timeout.add_full (Priority.DEFAULT, 1000, update_temp);

    }

    public override Gtk.Widget get_display_widget () {
        return display_widget;
    }

    public override Gtk.Widget? get_widget () {
        return popover_widget;
    }

    public override void opened () {
    }

    public override void closed () {
    }

    //get temperatures directly from /sys and update indicator
    private bool update_temp () {
        this.visible = this.settings.get_boolean ("status");
        var temperature_source = this.settings.get_string ("temperature-source");
        var unit_fahrenheit = this.settings.get_boolean ("unit-fahrenheit");
        fahrenheit_switch.active = unit_fahrenheit;

    	try {
            string temp_raw, temp_unit;
            FileUtils.get_contents("/sys/class/hwmon/" + temperature_source + "/temp1_input", out temp_raw);

            var temp_value = convert_temp(temp_raw, unit_fahrenheit);

            if (unit_fahrenheit) {
                temp_unit = "℉";
            } else {
                temp_unit = "℃";
            }

            this.temperature.label = temp_value + temp_unit;

        } catch (FileError err) {
    		stderr.printf (err.message);
	    }

	    return true;
    }

    // converts raw temperature info
    private string convert_temp (string temp_in, bool fahrenheit = false) {
        int temp_out = int.parse(temp_in) / 1000;

        if (fahrenheit) {
            temp_out = ((temp_out * 9) / 5) + 32;
        }

        return temp_out.to_string ();
    }

    // opens system settings
    private void show_settings () {
        close ();

        try {
            AppInfo.launch_default_for_uri ("settings://adstruo", null);
        } catch (Error e) {
            warning ("%s\n", e.message);
        }
    }
}

// wingpanel 
public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    debug ("Activating Temperature Indicator");

    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        return null;
    }

    var indicator = new Adstruo.Temps ();

    return indicator;
}
