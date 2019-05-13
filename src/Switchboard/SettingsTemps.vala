public class Adstruo.SettingsTemps : Granite.SimpleSettingsPage {
    private GLib.Settings settings;

    public SettingsTemps () {
        Object (
            activatable: true,
            description: "Shows a temperature indicator in the wingpanel",
            header: "Indicators",
            icon_name: "sensors-temperature-symbolic",
            title: "Temperatures"
        );
    }

    construct {
        //get gsettings
        this.settings = new GLib.Settings ("com.github.raibtoffoletto.adstruo.temps");
        status_switch.active = this.settings.get_boolean ("status");

        update_status ();
        status_switch.notify["active"].connect (update_status);
    }

    private void update_status () {
        this.settings.set_boolean ("status", status_switch.active);
        status = (status_switch.active ? "Enabled" : "Disabled");
    }

}
