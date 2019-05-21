public class Adstruo.Weather : Wingpanel.Indicator {
    private Gtk.Box display_widget;
    private Gtk.Box popover_widget;
    private GLib.Settings settings;
    private Adstruo.Utilities adstruo;
    private Gtk.Image icon;
    private Gtk.Label temperature;
    private Wingpanel.Widgets.Switch imperial_switch;
    private bool imperial_units;
private Soup.Session http_session;
private Gtk.Label dbug;
private int lng;
    public Weather () {
        Object (
            code_name : "adstruo-weather",
            display_name : "Weather Conditions Indicator",
            description: "Adds the current weather information to the wingpanel."
        );
    }

    construct {
        this.visible = true;
        adstruo = new Adstruo.Utilities ();
        settings = new GLib.Settings ("com.github.raibtoffoletto.adstruo.weather");
        imperial_units = this.settings.get_boolean ("imperial-units");
http_session = new Soup.Session ();
lng = 0;
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
                // this.adstruo.show_settings (this);
                get_weather_info ();
            });

        imperial_switch = new Wingpanel.Widgets.Switch ("Imperial Units");
        imperial_switch.active = imperial_units; 
        imperial_switch.notify["active"].connect (() => {
            var imperial_units_changed = imperial_switch.active ? true : false;
            this.settings.set_boolean ("imperial-units", imperial_units_changed);
            imperial_units = imperial_units_changed;
            get_weather_info ();
        });

        popover_widget = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
dbug = new Gtk.Label ("");
popover_widget.add (dbug);
        popover_widget.add (new Wingpanel.Widgets.Separator ());
        popover_widget.add (imperial_switch);
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

    public void get_weather_info () {
        string city, country, name, weather_description, weather_icon;
        double main_temp, main_temp_min, main_temp_max, wind_speed;
        int64 main_humidity, main_pressure, wind_deg, sys_sunrise, sys_sunset;

        this.adstruo.get_location_data (this.http_session, out city, out country);

        var api_id = settings.get_string("openweatherapi");
        // var weather_uri = "http://api.openweathermap.org/data/2.5/weather?q=%s,%s&APPID=%s".printf(city,country,api_id);
        var weather_uri = "http://api.openweathermap.org/data/2.5/weather?lat=50&lon=%i&APPID=%s".printf(this.lng, api_id);

        this.adstruo.get_weather_data (this.http_session, weather_uri, out name, out weather_description, out weather_icon, out main_temp,
                                    out main_temp_min, out main_temp_max, out main_humidity, out main_pressure, out wind_speed,
                                    out wind_deg, out sys_sunrise, out sys_sunset);

        this.icon = this.adstruo.get_weather_icon (weather_icon);
        this.temperature.label = this.adstruo.convert_temp(main_temp.to_string (), this.imperial_units, true);

dbug.label = "%s\nlong is %i".printf(name, this.lng);
this.lng += 1;
    }

}

public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    debug ("Activating Weather Indicator");

    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        return null;
    }

    var indicator = new Adstruo.Weather ();
    return indicator;
}
