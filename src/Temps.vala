public class Adstruo.Temps : Wingpanel.Indicator {
    private Gtk.Box display_widget;
    private Gtk.Box popover_widget;
    private Adstruo.Utilities adstruo;
    private GLib.Settings settings;
    private Gtk.Label temperature;
    private Wingpanel.Widgets.Switch fahrenheit_switch;

    public Temps () {
        Object (
            code_name : "adstruo-temps",
            display_name : _("Temperature Indicator"),
            description: _("Shows a hardware temperature indicator in the wingpanel")
        );
    }

    construct {
        adstruo = new Adstruo.Utilities ();
        settings = new GLib.Settings ("com.github.raibtoffoletto.adstruo.temps");

        adstruo.update_indicator_status (this, settings.get_boolean ("status"));
        settings.change_event.connect (() => {
            adstruo.update_indicator_status (this, settings.get_boolean ("status"));
            update_temp ();
        });

        var icon = new Gtk.Image.from_icon_name ("sensors-temperature-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        temperature = new Gtk.Label ("0 ℃");

        display_widget = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        display_widget.valign = Gtk.Align.CENTER;
        display_widget.pack_start (icon);
        display_widget.pack_start (temperature);

        var options_button = new Gtk.ModelButton ();
            options_button.text = _("Settings");
            options_button.clicked.connect (() => {
                this.adstruo.show_settings (this);
            });

        fahrenheit_switch = new Wingpanel.Widgets.Switch (_("Use Fahrenheit"));
        fahrenheit_switch.notify["active"].connect (() => {
            this.settings.set_boolean ("unit-fahrenheit", (fahrenheit_switch.active ? true : false));
            update_temp ();
        });

        popover_widget = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        popover_widget.add (fahrenheit_switch);
        popover_widget.add (new Wingpanel.Widgets.Separator ());
        popover_widget.add (options_button);

        update_temp ();
        Timeout.add_full (Priority.DEFAULT, 5000, update_temp);

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
        var temperature_source = this.settings.get_string ("temperature-source");
        var unit_fahrenheit = this.settings.get_boolean ("unit-fahrenheit");
        fahrenheit_switch.active = unit_fahrenheit;

    	try {
            string temp_raw;
            FileUtils.get_contents("/sys/class/hwmon/" + temperature_source + "/temp1_input", out temp_raw);

            this.temperature.label = this.adstruo.convert_temp (temp_raw, unit_fahrenheit);

        } catch (FileError err) {
    		stderr.printf (err.message);
	        return false;
	    }

	    return true;
    }

}

public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    debug (_("Activating Temperature Indicator"));

    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        return null;
    }

    var indicator = new Adstruo.Temps ();

    return indicator;
}
