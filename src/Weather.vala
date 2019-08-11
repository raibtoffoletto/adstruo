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

public class Adstruo.Weather : Wingpanel.Indicator {
    public string weather_uri { get; set; }
    private Gtk.Box display_widget;
    private Gtk.Box popover_widget;
    private Adstruo.Utilities adstruo;
    private GLib.Settings settings;
    private GLib.Settings gweather_unit;
    private Soup.Session http_session;
    private Gtk.Image icon;
    private Gtk.Label temperature;
    private bool imperial_units;
    private bool symbolic_icons;
    private string[] locale;

    public Weather () {
        Object (
            code_name : "adstruo-10-weather",
            display_name : _("Weather Conditions Indicator"),
            description: _("Shows a weather indicator in the wingpanel")
        );
    }

    construct {
        visible = false;
        adstruo = new Adstruo.Utilities ();
        http_session = new Soup.Session ();
        locale = Intl.get_language_names ();
        settings = adstruo.weather_settings;
        gweather_unit = new GLib.Settings ("org.gnome.GWeather");

        icon = new Gtk.Image.from_icon_name (adstruo.get_weather_icon (), Gtk.IconSize.SMALL_TOOLBAR);
        temperature = new Gtk.Label ("n/a");

        display_widget = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        display_widget.valign = Gtk.Align.CENTER;
        display_widget.pack_start (icon, false, false);
        display_widget.pack_end (temperature, false, false);

        var loading = new Gtk.Spinner ();
            loading.active = true;
        var grid_loading = new Gtk.Grid ();
            grid_loading.hexpand = true;
            grid_loading.halign = Gtk.Align.CENTER;
            grid_loading.margin = 8;
            grid_loading.attach (loading, 0, 0);
        var update_button = new Gtk.ModelButton ();
            update_button.text = _("Update now");
        var options_button = new Gtk.ModelButton ();
            options_button.text = _("Settings");

        popover_widget = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        popover_widget.expand = true;
        popover_widget.pack_start (grid_loading, false, false);
        popover_widget.pack_end (options_button, false, false);
        popover_widget.pack_end (update_button, false, false);
        popover_widget.pack_end (new Wingpanel.Widgets.Separator (), false, false);

        get_location_data.begin ();
        activate_indicator (settings.get_boolean ("status"));

        notify["weather-uri"].connect (update_weather);

        update_button.clicked.connect (update_weather);

        options_button.clicked.connect (() => {
            try {
                AppInfo.launch_default_for_uri ("settings://adstruo", null);
            } catch (Error e) {
                print ("Err: %s\n", e.message);
            }
        });

        settings.change_event.connect (() => {
            if (settings.get_boolean ("status") != visible) {
                activate_indicator (settings.get_boolean ("status"));
            }
            if (symbolic_icons != settings.get_boolean ("symbolic-icons")) {
                symbolic_icons = settings.get_boolean ("symbolic-icons");
                update_weather ();
            }
        });

        gweather_unit.change_event.connect (() => {
            update_imperial_units (gweather_unit.get_string ("temperature-unit"));
            update_weather ();
        });
    }

    public override Gtk.Widget get_display_widget () {
        return display_widget;
    }

    public override Gtk.Widget? get_widget () {
        return popover_widget;
    }

    public override void opened () {}

    public override void closed () {}

    public void activate_indicator (bool enable = false) {
        visible = enable;
        symbolic_icons = settings.get_boolean ("symbolic-icons");
        update_imperial_units (gweather_unit.get_string ("temperature-unit"));

        if (enable) {
            Timeout.add_seconds_full (Priority.DEFAULT, 300, () => {
                update_weather ();
                return settings.get_boolean ("status");
            });
        }
    }


    public async void get_location_data () {
        try {
            var geoclue = yield new GClue.Simple ("com.github.raibtoffoletto.adstruo", GClue.AccuracyLevel.EXACT, null);
            update_location (geoclue.location.latitude, geoclue.location.longitude);

            geoclue.notify["location"].connect (() => {
                update_location (geoclue.location.latitude, geoclue.location.longitude);
            });
        } catch (Error e) {
            error_message (_("Unable to get your location"));
            print ("Err: %s\n".printf (e.message));
        }
     }

    public void update_location (double latitude = 0, double longitude = 0) {
        var settings_apiid = settings.get_string ("openweatherapi");
        var openweatherapi_default = settings.get_default_value ("openweatherapi").get_string ();
        var openweather_apiid = settings_apiid != openweatherapi_default ? settings_apiid : openweatherapi_default;

        set_property (
            "weather-uri",
            "http://api.openweathermap.org/data/2.5/weather?lat=%.2f&lon=%.2f&lang=%s&APPID=%s".printf
                (latitude, longitude, locale[0], openweather_apiid)
        );
    }

    public void update_weather () {
        get_weather_data.begin ();
    }

    public async void get_weather_data () {
        if (weather_uri != null) {
            var openweather_message = new Soup.Message ("GET", weather_uri);
            http_session.queue_message (openweather_message, (sess, mess) => {
                try {
                    if (openweather_message.status_code == 200) {
                        var openweather_parser = new Json.Parser ();
                            openweather_parser.load_from_data (
                                (string) openweather_message.response_body.flatten ().data,
                                -1
                            );

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
                        var weather_icon_image = new Gtk.Image.from_icon_name (adstruo.get_weather_icon
                                                                                (weather_icon, symbolic_icons),
                                                                                Gtk.IconSize.DIALOG);
                            weather_icon_image.margin = 8;
                            weather_icon_image.margin_end = 20;
                            weather_icon_image.hexpand = true;
                            weather_icon_image.vexpand = true;

                        var main = openweather_root.get_object_member ("main");
                        var main_temp = main.get_double_member ("temp");
                        var main_humidity = main.get_int_member ("humidity");
                        var humidity = new Gtk.Label ("<small>" +
                                                        adstruo.convert_humidity (main_humidity.to_string ())
                                                        + "</small>");
                            humidity.halign = Gtk.Align.END;
                            humidity.use_markup = true;
                            humidity.margin_top = 2;
                            humidity.margin_end = 8;

                        var wind = openweather_root.get_object_member ("wind");
                        var wind_speed = wind.get_double_member ("speed");
                        var wind_deg = wind.get_int_member ("deg");
                        var wind_icon = new Gtk.Image.from_icon_name ("weather-windy-symbolic",
                                                                        Gtk.IconSize.SMALL_TOOLBAR);
                            wind_icon.margin_end = 6;
                            wind_icon.halign = Gtk.Align.END;
                        var wind_label = new Gtk.Label (adstruo.convert_wind (wind_speed, wind_deg, imperial_units));
                            wind_label.halign = Gtk.Align.START;
                            wind_label.use_markup = true;

                        var sys = openweather_root.get_object_member ("sys");
                        var sys_sunrise = sys.get_int_member ("sunrise");
                        var sys_sunset = sys.get_int_member ("sunset");
                        var sunrise_icon = new Gtk.Image.from_icon_name ("daytime-sunrise-symbolic",
                                                                        Gtk.IconSize.SMALL_TOOLBAR);
                            sunrise_icon.margin_end = 6;
                            sunrise_icon.halign = Gtk.Align.END;
                        var sunrise = new Gtk.Label (adstruo.convert_date (sys_sunrise));
                            sunrise.halign = Gtk.Align.START;
                        var sunset_icon = new Gtk.Image.from_icon_name ("daytime-sunset-symbolic",
                                                                        Gtk.IconSize.SMALL_TOOLBAR);
                            sunset_icon.margin_end = 6;
                            sunset_icon.halign = Gtk.Align.END;
                        var sunset = new Gtk.Label (adstruo.convert_date (sys_sunset));
                            sunset.halign = Gtk.Align.START;

                        var extra_info = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
                            extra_info.margin_top = 8;
                            extra_info.pack_start(sunrise_icon);
                            extra_info.pack_start(sunrise);
                            extra_info.pack_start(sunset_icon);
                            extra_info.pack_start(sunset);
                            extra_info.pack_start(wind_icon);
                            extra_info.pack_start(wind_label);

                        icon.set_from_icon_name (adstruo.get_weather_icon (weather_icon), Gtk.IconSize.SMALL_TOOLBAR);
                        temperature.label = adstruo.convert_temp (main_temp.to_string (), imperial_units, true);

                        var weather_info = new Gtk.Grid ();
                            weather_info.margin = 8;
                            weather_info.hexpand = true;
                            weather_info.vexpand = true;
                            weather_info.halign = Gtk.Align.FILL;
                            weather_info.valign = Gtk.Align.CENTER;
                            weather_info.attach (weather_icon_image, 0, 0, 1, 3);
                            weather_info.attach (local, 1, 0, 1, 1);
                            weather_info.attach (weather_description, 1, 1, 1, 1);
                            weather_info.attach (humidity, 1, 2, 1, 1);
                            weather_info.attach (extra_info, 0, 3, 2, 1);
                            weather_info.show_all ();

                        widget_grid_remove ();
                        popover_widget.pack_start (weather_info, false, false);
                    } else {
                        error_message (_("Unable to get the weather." +
                                        "\nCheck your connection or \nyour OpenWeather API id."));
                    }
                } catch (Error e) {
                    error_message (_("Unable to connect to server.\n"));
                    print ("Err: %s\n".printf (e.message));
                }
            });
        } else {
            error_message (_("Unable to set your location"));
        }
    }

    public void update_imperial_units (string gweather_value) {
        imperial_units = gweather_value == "fahrenheit" ? true : false;
    }

    public void error_message (string message = "") {
        icon.set_from_icon_name (adstruo.get_weather_icon (), Gtk.IconSize.SMALL_TOOLBAR);
        temperature.label = "n/a";

        var error_label = new Gtk.Label (message);
            error_label.margin = 8;
            error_label.hexpand = true;
            error_label.halign = Gtk.Align.CENTER;
            error_label.valign = Gtk.Align.CENTER;
            error_label.selectable = true;

        widget_grid_remove ();

        var error_grid = new Gtk.Grid ();
            error_grid.attach (error_label, 0, 0);
            error_grid.show_all ();

        popover_widget.pack_start (error_grid, false, false);
    }

    public void widget_grid_remove () {
        foreach (var child in popover_widget.get_children ()) {
            if (child.name == "GtkGrid") {
                popover_widget.remove (child);
            }
        }
    }
}

public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    debug (_("Activating Weather Indicator"));
    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        return null;
    }

    return new Adstruo.Weather ();
}
