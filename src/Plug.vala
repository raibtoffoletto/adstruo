public class Adstruo.Plug : Switchboard.Plug {
    private Gtk.Paned main_panel;

    public Plug () {
        Object (category: Category.PERSONAL,
                code_name: "adstruo",
                display_name: _("Aditional Indicators"),
                description: _("Manage aditional indicators for wingpanel."),
                icon: "application-x-addon",
                supported_settings: new Gee.TreeMap<string, string?> (null, null));
        supported_settings.set ("adstruo", null);
    }

    public override Gtk.Widget get_widget () {
        main_panel = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);

        //list of indicators available
        var settings_temps = new Adstruo.SettingsTemps ();
        var settings_weather = new Adstruo.SettingsWeather ();

        //add panels to paned widget
        var stack = new Gtk.Stack ();
            stack.add_named (settings_temps, "settings_temps");
            stack.add_named (settings_weather, "settings_weather");
        var sidebar = new Granite.SettingsSidebar (stack);

        main_panel.add (sidebar);
        main_panel.add (stack);
        main_panel.show_all ();

        return main_panel;
    }

    public override void shown () {
    }

    public override void hidden () {
    }

    public override void search_callback (string location) {
    }

    public override async Gee.TreeMap<string, string> search (string search) {
        return new Gee.TreeMap<string, string> (null, null);
    }
}

public Switchboard.Plug get_plug (Module module) {
    debug (_("Activating Adstruo Options plugin"));
    var plug = new Adstruo.Plug ();
    return plug;
}
