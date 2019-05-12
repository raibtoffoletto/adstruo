public class Adstruo.SettingsTemps : Granite.SimpleSettingsPage {
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
        
    }
}
