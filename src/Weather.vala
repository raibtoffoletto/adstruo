public class Adstruo.Weather : Wingpanel.Indicator {
    private Gtk.Box display_widget;
    private Gtk.Box popover_widget;
    private Gtk.Image icon;
    private Gtk.Label temperature;
    private GLib.Settings settings;
    private Wingpanel.Widgets.Switch fahrenheit_switch;
    private Adstruo.Utilities adstruo;

    public Weather () {
        Object (
            code_name : "adstruo-weather",
            display_name : "Weather Conditions Indicator",
            description: "Adds the current weather information to the wingpanel."
        );
    }

    construct {
        this.visible = true;
        this.adstruo = new Adstruo.Utilities ();
        this.settings = new GLib.Settings ("com.github.raibtoffoletto.adstruo.weather");

        //indicator's structure
        icon = this.adstruo.get_weather_icon ();
        temperature = new Gtk.Label ("n/a");
        temperature.margin = 2;

        display_widget = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        display_widget.valign = Gtk.Align.CENTER;
        display_widget.pack_start (icon);
        display_widget.pack_start (temperature);

        var options_button = new Gtk.ModelButton ();
            options_button.text = "Options";
            options_button.clicked.connect (() => {
                this.adstruo.show_settings (this);
            });

        fahrenheit_switch = new Wingpanel.Widgets.Switch ("Fahrenheit");
        fahrenheit_switch.notify["active"].connect (() => {
        });

        popover_widget = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        popover_widget.add (fahrenheit_switch);
        popover_widget.add (new Wingpanel.Widgets.Separator ());
        popover_widget.add (options_button);

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

}

// wingpanel 
public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    debug ("Activating Weather Indicator");

    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        return null;
    }

    var indicator = new Adstruo.Weather ();

    return indicator;
}
