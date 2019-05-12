public class Adstruo.Plug : Switchboard.Plug {
    private Gtk.Paned main_panel;

    public Plug () {
        Object (category: Category.PERSONAL,
                code_name: "adstruo",
                display_name: "Aditional Indicators",
                description: "Manage aditional indicators for wingpanel.",
                icon: "application-x-addon",
                supported_settings: new Gee.TreeMap<string, string?> (null, null));
        supported_settings.set ("adstruo", null);
    }

    public override Gtk.Widget get_widget () {
        main_panel = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);

        //list of indicators available 
        var settings_page = new SettingsPage ();
        var settings_page_two = new SimpleSettingsPage ();
        var settings_temps = new Adstruo.SettingsTemps ();

        //list stacked in order
        var stack = new Gtk.Stack ();
        stack.add_named (settings_temps, "settings_temps");
        stack.add_named (settings_page, "settings_page");
        stack.add_named (settings_page_two, "settings_page_two");
        var sidebar = new Granite.SettingsSidebar (stack);

        //add panels to paned widget
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
        // hello_label.label = "Callback : %s".printf (location);
    }

    public override async Gee.TreeMap<string, string> search (string search) {
        return new Gee.TreeMap<string, string> (null, null);
    }
}

public Switchboard.Plug get_plug (Module module) {
    debug ("Activating Adstruo Options plugin");
    var plug = new Adstruo.Plug ();
    return plug;
}
