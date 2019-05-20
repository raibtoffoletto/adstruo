public class Adstruo.Utilities {
    // common
    public string convert_temp (string temp_in, bool fahrenheit = false, bool kelvin = false) {
        int temp_out = int.parse(temp_in) / 1000; /* original int from /sys */

        if (kelvin) {
            double celsius = double.parse(temp_in) - 273.15;
            temp_out = (int)celsius;
        }

        if (fahrenheit) {
            temp_out = ((temp_out * 9) / 5) + 32;
        }

        return temp_out.to_string ();
    }

    public void show_settings (Wingpanel.Indicator popover) {
        popover.close ();
        try {
            AppInfo.launch_default_for_uri ("settings://adstruo", null);
        } catch (Error e) {
            warning ("%s\n", e.message);
        }
    }

    // weather indicator
    public Gtk.Image get_weather_icon (string icon_code = "") {
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

        var icon = new Gtk.Image.from_icon_name (condition, Gtk.IconSize.SMALL_TOOLBAR);
        return icon; 
    }

    public void get_location_data (Soup.Session http_session, out string city, out string country) {
        var ipapi_uri = "http://ip-api.com/json/";
        var ipapi_json = new Soup.Message ("GET", ipapi_uri);
        http_session.send_message (ipapi_json);

        city = null;
        country = null;

        try {
            var ipapi_parser = new Json.Parser ();
                ipapi_parser.load_from_data ((string) ipapi_json.response_body.flatten ().data, -1);
            var ipapi_root = ipapi_parser.get_root ().get_object ();

            city = ipapi_root.get_string_member ("city");
            country = ipapi_root.get_string_member ("countryCode");
        } catch (Error e) {
            city = e.message;
        }
    }

    public void get_weather_data (Soup.Session http_session, string weather_uri,
                                    out string weather_description,
                                    out string weather_icon,
                                    out double main_temp,
                                    out double main_temp_min,
                                    out double main_temp_max,
                                    out int64 main_humidity,
                                    out int64 main_pressure,
                                    out double wind_speed,
                                    out int64 wind_deg,
                                    out int64 sys_sunrise,
                                    out int64 sys_sunset) {

        var openweather_get_json = new Soup.Message ("GET", weather_uri);
        http_session.send_message (openweather_get_json);

        weather_description = null;
        weather_icon = null;
        main_temp = 0;
        main_temp_min = 0;
        main_temp_max = 0;
        main_humidity = 0;
        main_pressure = 0;
        wind_speed = 0;
        wind_deg = 0;
        sys_sunrise = 0;
        sys_sunset = 0;


        try {
            var openweather_parser = new Json.Parser ();
                openweather_parser.load_from_data ((string) openweather_get_json.response_body.flatten ().data, -1);
            var openweather_root = openweather_parser.get_root ().get_object ();

            var weather = openweather_root.get_member ("weather");
            var weather_array = weather.get_array ();
        	var weather_elements = weather_array.get_object_element (0);
                weather_description = weather_elements.get_string_member ("description");
                weather_icon = weather_elements.get_string_member ("icon");

            var main = openweather_root.get_object_member ("main");
                main_temp = main.get_double_member ("temp");
                main_temp_min = main.get_double_member ("temp_min");
                main_temp_max = main.get_double_member ("temp_max");
                main_humidity = main.get_int_member ("humidity");
                main_pressure = main.get_int_member ("pressure");

            var wind = openweather_root.get_object_member ("wind");
                wind_speed = wind.get_double_member ("speed");
                wind_deg = wind.get_int_member ("deg");

            var sys = openweather_root.get_object_member ("sys");
                sys_sunrise = sys.get_int_member ("sunrise");
                sys_sunset = sys.get_int_member ("sunset");
        } catch (Error e) {
            weather_description = e.message;
        }
    }

}
