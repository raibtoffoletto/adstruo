public class Adstruo.Weather : Wingpanel.Indicator {
    private Gtk.Box display_widget;
    private Gtk.Box popover_widget;

    private MainLoop loop;
    private Adstruo.Utilities adstruo;
    private GLib.Settings settings;
    private Soup.Session http_session;

    private Gtk.Image icon;
    private Gtk.Label temperature;
    private Gtk.Grid weather_info;
    private bool imperial_units;
    private string weather_uri;
    private string[] locale;

    public Weather () {
        Object (
            code_name : "adstruo-weather",
            display_name : "Weather Conditions Indicator",
            description: "Adds the current weather information to the wingpanel."
        );
    }

    construct {
        loop = new MainLoop ();
        adstruo = new Adstruo.Utilities ();
        settings = new GLib.Settings ("com.github.raibtoffoletto.adstruo.weather");
        http_session = new Soup.Session ();
        get_location_data.begin ();
        locale = Intl.get_language_names ();

        adstruo.update_indicator_status (this, settings.get_boolean ("status"));
        settings.change_event.connect (() => {
            adstruo.update_indicator_status (this, settings.get_boolean ("status"));
        });

        var gweather_unit = new GLib.Settings ("org.gnome.GWeather");
        update_imperial_units (gweather_unit.get_string ("temperature-unit"));
        gweather_unit.change_event.connect (() => {
            update_imperial_units (gweather_unit.get_string ("temperature-unit"));
            get_location_data.begin ();
        });

        //indicator's structure
        icon = this.adstruo.get_weather_icon ();
        temperature = new Gtk.Label ("n/a");

        display_widget = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        display_widget.valign = Gtk.Align.CENTER;
        display_widget.pack_start (icon);
        display_widget.pack_start (temperature);

        weather_info = new Gtk.Grid ();

        var update_button = new Gtk.ModelButton ();
            update_button.text = "Update now";
            update_button.clicked.connect (() => {
                get_location_data.begin ();
            });

        var options_button = new Gtk.ModelButton ();
            options_button.text = "Settings";
            options_button.clicked.connect (() => {
                this.adstruo.show_settings (this);
            });

        popover_widget = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        popover_widget.pack_start (weather_info);
        popover_widget.pack_end (options_button);
        popover_widget.pack_end (update_button);
        popover_widget.pack_end (new Wingpanel.Widgets.Separator ());

        Timeout.add_seconds_full (Priority.DEFAULT, 300, () => {
            get_location_data.begin ();
            return true;
        });

        loop.run ();
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

    public async void get_location_data () {
        // I have contacted Mozzila for a valid API
        // or FUTURE to do: implement GeoClue, it won't compile at this moment
        var ipapi_message = new Soup.Message ("GET", "https://location.services.mozilla.com/v1/geolocate?key=test");
        this.http_session.queue_message (ipapi_message, (sess, mess) => {
            try {
                if (ipapi_message.status_code == 200) {
                    var ipapi_json = new Json.Parser ();
                        ipapi_json.load_from_data ((string) mess.response_body.flatten ().data, -1);
                    var ipapi_root = ipapi_json.get_root ().get_object ().get_object_member ("location");

                    update_location (true, ipapi_root.get_double_member ("lat"), ipapi_root.get_double_member ("lng"));
                } else {
                    update_location ();
                }

                this.loop.quit ();
            } catch (Error e) {
                stderr.printf ("Could not get your location.\n");
            }

        });
    }

    public void update_location (bool connexion = false, double latitude = 0, double longitude = 0) {
        if (connexion) {
            var openweather_apiid = settings.get_string ("openweatherapi");
            this.weather_uri = "http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&lang=%s&APPID=%s".printf
                                (latitude, longitude, locale[0], openweather_apiid);
            get_weather_data.begin ();
        } else {
            //need to clean up before updating images
            this.display_widget.remove (this.icon);
            this.display_widget.remove (this.temperature);
            this.icon = this.adstruo.get_weather_icon ();
            this.temperature.label = "n/a";
            this.display_widget.add (this.icon);
            this.display_widget.add (this.temperature);
            this.display_widget.show_all ();

            var no_connection = new Gtk.Label ("waiting for connection");
                no_connection.margin = 8;
                no_connection.hexpand = true;
                no_connection.halign = Gtk.Align.CENTER;
                no_connection.valign = Gtk.Align.CENTER;
            this.popover_widget.remove (this.weather_info);
            this.weather_info = new Gtk.Grid ();
            this.weather_info.attach (no_connection, 0, 0);
            this.popover_widget.pack_start (this.weather_info);
            this.weather_info.show_all ();
        }

    }

    public async void get_weather_data () {
        var openweather_message = new Soup.Message ("GET", this.weather_uri);
        this.http_session.queue_message (openweather_message, (sess, mess) => {
            try {
                if (openweather_message.status_code == 200) {
                    var openweather_parser = new Json.Parser ();
                        openweather_parser.load_from_data ((string) openweather_message.response_body.flatten ().data, -1);
                    var openweather_root = openweather_parser.get_root ().get_object ();

                    var local = new Gtk.Label ("<b>%s</b>".printf (openweather_root.get_string_member ("name")));
                        local.use_markup = true;
                        local.halign = Gtk.Align.END;
                        local.valign = Gtk.Align.CENTER;
                        local.hexpand = true;
                        local.margin_end = 8;

                    var weather = openweather_root.get_member ("weather");
                    var weather_array = weather.get_array ();
                	var weather_elements = weather_array.get_object_element (0);
                    var weather_description = new Gtk.Label (weather_elements.get_string_member ("description"));
                        weather_description.halign = Gtk.Align.END;
                        weather_description.valign = Gtk.Align.CENTER;
                        weather_description.margin_end = 8;
                    var weather_icon = weather_elements.get_string_member ("icon");
                    var weather_icon_image = this.adstruo.get_weather_icon (weather_icon, true, Gtk.IconSize.DIALOG);
                        weather_icon_image.margin = 8;
                        weather_icon_image.margin_end = 20;
                        weather_icon_image.hexpand = true;
                        weather_icon_image.vexpand = true;

                    var main = openweather_root.get_object_member ("main");
                    var main_temp = main.get_double_member ("temp");
                    var main_humidity = main.get_int_member ("humidity");
                    var humidity = new Gtk.Label ("<small>" +
                                                    this.adstruo.convert_humidity (main_humidity.to_string ())
                                                    + "</small>");
                        humidity.halign = Gtk.Align.END;
                        humidity.use_markup = true;
                        humidity.margin_top = 2;
                        humidity.margin_end = 8;

                    var wind = openweather_root.get_object_member ("wind");
                    var wind_speed = wind.get_double_member ("speed");
                    var wind_deg = wind.get_int_member ("deg");
                    var wind_icon = new Gtk.Image.from_icon_name ("weather-windy-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
                        wind_icon.margin_end = 6;
                        wind_icon.halign = Gtk.Align.END;
                    var wind_label = new Gtk.Label (this.adstruo.convert_wind (wind_speed, wind_deg, this.imperial_units));
                        wind_label.halign = Gtk.Align.START;

                    var sys = openweather_root.get_object_member ("sys");
                    var sys_sunrise = sys.get_int_member ("sunrise");
                    var sys_sunset = sys.get_int_member ("sunset");
                    var sunrise_icon = new Gtk.Image.from_icon_name ("daytime-sunrise-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
                        sunrise_icon.margin_end = 6;
                        sunrise_icon.halign = Gtk.Align.END;
                    var sunrise = new Gtk.Label (this.adstruo.convert_date (sys_sunrise));
                        sunrise.halign = Gtk.Align.START;
                    var sunset_icon = new Gtk.Image.from_icon_name ("daytime-sunset-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
                        sunset_icon.margin_end = 6;
                        sunset_icon.halign = Gtk.Align.END;
                    var sunset = new Gtk.Label (this.adstruo.convert_date (sys_sunset));
                        sunset.halign = Gtk.Align.START;

                    var extra_info = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
                        extra_info.margin_top = 8;
                        extra_info.pack_start(sunrise_icon);
                        extra_info.pack_start(sunrise);
                        extra_info.pack_start(sunset_icon);
                        extra_info.pack_start(sunset);
                        extra_info.pack_start(wind_icon);
                        extra_info.pack_start(wind_label);

                    this.display_widget.remove (this.icon);
                    this.display_widget.remove (this.temperature);
                    this.icon = this.adstruo.get_weather_icon (weather_icon);
                    this.temperature.label = this.adstruo.convert_temp (main_temp.to_string (), this.imperial_units, true);
                    this.display_widget.add (this.icon);
                    this.display_widget.add (this.temperature);
                    this.display_widget.show_all ();

                    this.popover_widget.remove (this.weather_info);
                    this.weather_info = new Gtk.Grid ();
                    this.weather_info.margin = 8;
                    this.weather_info.hexpand = true;
                    this.weather_info.vexpand = true;
                    this.weather_info.halign = Gtk.Align.FILL;
                    this.weather_info.valign = Gtk.Align.CENTER;
                    this.weather_info.attach (weather_icon_image, 0, 0, 1, 3);
                    this.weather_info.attach (local, 1, 0, 1, 1);
                    this.weather_info.attach (weather_description, 1, 1, 1, 1);
                    this.weather_info.attach (humidity, 1, 2, 1, 1);
                    this.weather_info.attach (extra_info, 0, 3, 2, 1);
                    this.popover_widget.pack_start (this.weather_info);
                    this.weather_info.show_all ();

                }
            } catch (Error e) {
                stderr.printf ("Could not get the weather information.\n");
            }
        });
    }

    public void update_imperial_units (string gweather_value) {
        if (gweather_value == "fahrenheit") {
            this.imperial_units = true;
        } else {
            this.imperial_units = false;
        }
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
