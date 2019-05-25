public class Adstruo.SettingsWeather : Granite.SimpleSettingsPage {
    private GLib.Settings settings;
    private Adstruo.Utilities adstruo;

    public SettingsWeather () {
        Object (
            activatable: true,
            description: _("Shows a weather indicator in the wingpanel"),
            icon_name: "weather-few-clouds-symbolic",
            title: _("Weather")
        );
    }

    construct {
        adstruo = new Adstruo.Utilities ();
        settings = new GLib.Settings ("com.github.raibtoffoletto.adstruo.weather");

        status_switch.active = this.settings.get_boolean ("status");
        adstruo.update_status (settings, this);

        content_area.column_spacing = 12;
        content_area.row_spacing = 24;
        content_area.margin_top = 24;
        content_area.halign = Gtk.Align.CENTER;


        var weather_description_label = new Gtk.Label (_("Oi"));
            weather_description_label.use_markup = true;

        var openweather_label = new Gtk.Label (_("OpenWeather API :"));
            openweather_label.xalign = 1;

        var openweather_entry = new Gtk.Entry ();
            openweather_entry.hexpand = true;
            openweather_entry.placeholder_text = "Enter your own API ID";

        content_area.attach (weather_description_label, 0, 0, 2, 1);
        content_area.attach (openweather_label, 0, 1);
        content_area.attach (openweather_entry, 1, 1);

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
            this.adstruo.update_status (this.settings, this);
        });
    }

}
