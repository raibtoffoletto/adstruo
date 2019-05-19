public class Adstruo.Utilities {

    public string convert_temp (string temp_in, bool fahrenheit = false, bool kelvin = false) {

        
        int temp_out = int.parse(temp_in) / 1000; /* origin from /sys */

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
}
