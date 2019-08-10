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
public class Adstruo.SettingsWeather : Granite.SimpleSettingsPage {
    public weak Adstruo.Plug plug { get; construct; }
    private GLib.Settings settings;

    public SettingsWeather (Adstruo.Plug plug) {
        Object (
            title: _("Current Weather"),
            description: _("Shows the current weather in the wingpanel"),
            activatable: true,
            plug: plug
        );
    }

    construct {
        settings = plug.adstruo.weather_settings;

        this.icon_name = settings.get_boolean ("symbolic-icons") ?
                            "weather-few-clouds-symbolic" : "weather-few-clouds";

        status_switch.active = settings.get_boolean ("status");
        plug.adstruo.update_plug_status ("adstruo-weather", this);

        var weather_description = _("This indicator gets the weather information from the " +
                                    "OpenWeatherMap organization.\nThe language and units used " +
                                    "can be changed in the \"Language & Region\" settings.\n" +
                                    "The free API used by default provides a limited amount of " +
                                    "calls per minute, therefore, please consider registering for " +
                                    "your own API ID.");
        var weather_description_label = new Gtk.Label (weather_description);
            weather_description_label.justify = Gtk.Justification.FILL;
            weather_description_label.halign = Gtk.Align.START;
            weather_description_label.hexpand = true;
            weather_description_label.wrap = true;
            weather_description_label.margin_start = 60;
            weather_description_label.margin_end = 60;

        var openweather_label = new Gtk.Label (_("OpenWeather API :"));
            openweather_label.xalign = 1;

        var openweather_entry = new Gtk.Entry ();
            openweather_entry.hexpand = true;
            openweather_entry.width_chars = 32;
            openweather_entry.placeholder_text = "Enter your own API ID";

        var symbolics_label = new Gtk.Label (_("Use Symbolic Icons :"));
            symbolics_label.xalign = 1;

        var symbolics_switch = new Gtk.Switch ();
            symbolics_switch.valign = Gtk.Align.CENTER;
            symbolics_switch.halign = Gtk.Align.START;
            symbolics_switch.active = this.settings.get_boolean ("symbolic-icons");
            symbolics_switch.notify["active"].connect (() => {
                this.settings.set_boolean ("symbolic-icons", (symbolics_switch.active ? true : false));
                this.icon_name = settings.get_boolean ("symbolic-icons") ?
                                    "weather-few-clouds-symbolic" : "weather-few-clouds";
            });

        var options_grid = new Gtk.Grid ();
            options_grid.halign = Gtk.Align.CENTER;
            options_grid.hexpand = true;
            options_grid.column_spacing = 16;
            options_grid.row_spacing = 16;
            options_grid.margin_top = 24;
            options_grid.attach (openweather_label, 0, 0);
            options_grid.attach (openweather_entry, 1, 0);
            options_grid.attach (symbolics_label, 0, 1);
            options_grid.attach (symbolics_switch, 1, 1);

        content_area.halign = Gtk.Align.FILL;
        content_area.hexpand = true;
        content_area.attach (weather_description_label, 0, 0);
        content_area.attach (options_grid, 0, 1);

        var openweather_button = new Gtk.Button.with_label ("Go to openweathermap.org");
        action_area.add (openweather_button);
        openweather_button.clicked.connect (() => {
            try {
                AppInfo.launch_default_for_uri ("https://openweathermap.org/appid", null);
            } catch (Error e) {
                warning ("%s\n", e.message);
            }
        });

        openweather_entry.changed.connect (() => {
            var openweather_entry_lenght = openweather_entry.text.char_count ();
            var openweatherapi_default = this.settings.get_default_value ("openweatherapi").get_string ();

            if (openweather_entry_lenght > 0) {
                this.settings.set_string ("openweatherapi", openweather_entry.text);
            } else {
                this.settings.set_string ("openweatherapi", openweatherapi_default);
            }
        });

        status_switch.notify["active"].connect (() => {
            plug.adstruo.update_plug_status ("adstruo-weather", this);
        });
    }

}
