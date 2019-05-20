public class Adstruo.Weather : Wingpanel.Indicator {
    private Gtk.Box display_widget;
    private Gtk.Box popover_widget;
    private Gtk.Image icon;
    private Gtk.Label temperature;
    private GLib.Settings settings;
    private Wingpanel.Widgets.Switch imperial_switch;
    private Adstruo.Utilities adstruo;
    private Soup.Session http_session;
    private string weather_description;
    private string weather_icon;
    private double main_temp;
    private double main_temp_min;
    private double main_temp_max;
    private int64 main_humidity;
    private int64 main_pressure;
    private double wind_speed;
    private int64 wind_deg;
    private int64 sys_sunrise;
    private int64 sys_sunset;

    public Weather () {
        Object (
            code_name : "adstruo-weather",
            display_name : "Weather Conditions Indicator",
            description: "Adds the current weather information to the wingpanel."
        );
    }

    construct {
        this.visible = true;
        this.http_session = new Soup.Session ();
        adstruo = new Adstruo.Utilities ();
        settings = new GLib.Settings ("com.github.raibtoffoletto.adstruo.weather");

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
        imperial_switch.notify["active"].connect (() => {
            this.settings.set_boolean ("imperial-units", (imperial_switch.active ? true : false));
        });

        popover_widget = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
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
        string city, country;
        adstruo.get_location_data (this.http_session, out city, out country);

        var api_id = settings.get_string("openweatherapi");
        var weather_uri = "http://api.openweathermap.org/data/2.5/weather?q=%s,%s&APPID=%s".printf(city,country,api_id);

        adstruo.get_weather_data (this.http_session, weather_uri, out this.weather_description, out this.weather_icon, out this.main_temp,
                                    out this.main_temp_min, out this.main_temp_max, out this.main_humidity, out this.main_pressure, out this.wind_speed,
                                    out this.wind_deg, out this.sys_sunrise, out this.sys_sunset);
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
