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

public class Adstruo.Utilities : Object {
    public GLib.Settings temp_settings { get; construct; }
    public GLib.Settings keys_settings { get; construct; }
    public GLib.Settings weather_settings { get; construct; }

    construct {
        temp_settings = new GLib.Settings ("com.github.raibtoffoletto.adstruo.temps");
        keys_settings = new GLib.Settings ("com.github.raibtoffoletto.adstruo.keys");
        weather_settings = new GLib.Settings ("com.github.raibtoffoletto.adstruo.weather");
    }

    public void update_plug_status (string indicator, Granite.SimpleSettingsPage plug) {
        switch (indicator) {
            case "adstruo-temps":
                temp_settings.set_boolean ("status", plug.status_switch.active);
                break;
            case "adstruo-keys":
                keys_settings.set_boolean ("status", plug.status_switch.active);
                break;
            case "adstruo-weather":
                weather_settings.set_boolean ("status", plug.status_switch.active);
                break;
        }

        plug.status = plug.status_switch.active ? _("Enabled") : _("Disabled");
    }

    public string convert_temp (string temp_in, bool fahrenheit = false, bool kelvin = false) {
        var temp_unit = "℃";
        int temp_out = int.parse (temp_in) / 1000;

        if (kelvin) {
            double celsius = double.parse(temp_in) - 273.15;
            temp_out = (int)celsius;
        }

        if (fahrenheit) {
            temp_out = ((temp_out * 9) / 5) + 32;
            temp_unit = "℉";
        }

        var label = "%i %s".printf (temp_out, temp_unit);
        return label;
    }

    public string convert_humidity (string humid_in) {
        int humid_out = int.parse (humid_in);

        var label = _("Humidity: %i").printf (humid_out);
            label += "%";
        return label;
    }

    public string convert_date (int64 date) {
        var unix_time = new DateTime.from_unix_local (date);
        var hour = unix_time.get_hour ();
        var minute = unix_time.get_minute ();

        var label = "%ih%i".printf (hour, minute);
        return label;
    }

    public string convert_wind (double speed, int64 degree, bool imperial = false) {
        string wind_label, degree_label;

        if (imperial) {
            var wind_speed = (speed * 2237) / 1000;
            wind_label = "%i mph". printf ((int)wind_speed);
        } else {
            var wind_speed = (speed * 36) / 10;
            wind_label = "%i km/h". printf ((int)wind_speed);
        }

        if (45 <= degree < 90) {
            degree_label = "↗";
        } else if (90 <= degree < 135) {
            degree_label = "→";
        } else if (135 <= degree < 180) {
            degree_label = "↘";
        } else if (180 <= degree < 225) {
            degree_label = "↓";
        } else if (225 <= degree < 270) {
            degree_label = "↙";
        } else if (270 <= degree < 315) {
            degree_label = "←";
        } else if (315 <= degree < 360) {
            degree_label = "↖";
        } else {
            degree_label = "↑";
        }

        return "%s <small>%s</small>".printf (wind_label, degree_label);
    }

    public string get_weather_icon (string icon_code = "", bool symbolic = false) {
        string condition;

        switch (icon_code) {
            case "01d":
                condition = "weather-clear";
                break;
            case "01n":
                condition = "weather-clear-night";
                break;
            case "02d":
                condition = "weather-few-clouds";
                break;
            case "02n":
                condition = "weather-few-clouds-night";
                break;
            case "50d":
            case "50n":
                condition = "weather-fog";
                break;
            case "03d":
            case "03n":
                condition = "weather-overcast";
                break;
            case "09d":
            case "09n":
                condition = "weather-showers";
                break;
            case "13d":
            case "13n":
                condition = "weather-snow";
                break;
            case "11d":
            case "11n":
                condition = "weather-storm";
                break;
            default :
                condition = "weather-few-clouds";
                break;
        }

        if (symbolic) {
            condition += "-symbolic";
        }

        return condition;
    }
}
