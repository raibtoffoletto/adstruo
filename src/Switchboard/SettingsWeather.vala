public class Adstruo.SettingsWeather : Granite.SimpleSettingsPage {
    private GLib.Settings settings;
    private Adstruo.Utilities adstruo;

    public SettingsWeather () {
        Object (
            activatable: true,
            description: _("Shows the current weather as an indicator in the wingpanel"),
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

        status_switch.notify["active"].connect (() => {
            this.adstruo.update_status (this.settings, this);
        });
    }

}
