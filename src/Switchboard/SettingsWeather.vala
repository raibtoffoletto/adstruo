public class Adstruo.SettingsWeather : Granite.SimpleSettingsPage {
    private GLib.Settings settings;
    private Adstruo.Utilities adstruo;

    public SettingsWeather () {
        Object (
            activatable: true,
            description: _("Shows the current weather in the wingpanel"),
            icon_name: "weather-few-clouds-symbolic",
            title: _("Current Weather")
        );
    }

    construct {
        adstruo = new Adstruo.Utilities ();
        settings = new GLib.Settings ("com.github.raibtoffoletto.adstruo.weather");

        status_switch.active = this.settings.get_boolean ("status");
        adstruo.update_status (settings, this);

        var weather_description = _("TO DO");
        var weather_description_label = new Gtk.Label (weather_description);
            weather_description_label.justify = Gtk.Justification.FILL;
            weather_description_label.halign = Gtk.Align.START;
            weather_description_label.hexpand = true;
            weather_description_label.wrap = true;
            weather_description_label.margin_start = 60;
            weather_description_label.margin_end = 60;
            weather_description_label.use_markup = true;

        var openweather_label = new Gtk.Label (_("OpenWeather API :"));
            openweather_label.xalign = 1;

        var openweather_entry = new Gtk.Entry ();
            openweather_entry.hexpand = true;
            openweather_entry.width_chars = 32;
            openweather_entry.placeholder_text = "Enter your own API ID";

        var options_grid = new Gtk.Grid ();
            options_grid.halign = Gtk.Align.CENTER;
            options_grid.hexpand = true;
            options_grid.column_spacing = 16;
            options_grid.row_spacing = 16;
            options_grid.margin_top = 24;
            options_grid.attach (openweather_label, 0, 0);
            options_grid.attach (openweather_entry, 1, 0);

        content_area.halign = Gtk.Align.FILL;
        content_area.hexpand = true;
        content_area.attach (weather_description_label, 0, 0);
        content_area.attach (options_grid, 0, 1);

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
