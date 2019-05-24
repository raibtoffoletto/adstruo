public class Adstruo.Utilities {
    public void update_indicator_status (Wingpanel.Indicator indicator, bool status = true) {
        indicator.visible = status;
    }

    public void show_settings (Wingpanel.Indicator popover) {
        popover.close ();
        try {
            AppInfo.launch_default_for_uri ("settings://adstruo", null);
        } catch (Error e) {
            warning ("%s\n", e.message);
        }
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


        var label = "%s".printf (wind_label);
        return label;
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
            case "02n":
                condition = "few-clouds-night";
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
            case "02d":
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
