public class Adstruo.Plug : Switchboard.Plug {
    private Gtk.Grid main_grid;
    private Gtk.Label hello_label;

    public Plug () {
        Object (category: Category.PERSONAL,
                code_name: "adstruo-options",
                display_name: "Aditional Indicators",
                description: "Manage aditional indicators for wingpanel",
                icon: "application-x-addon",
                supported_settings: new Gee.TreeMap<string, string?> (null, null));
        supported_settings.set ("indicators", null);
    }

    public override Gtk.Widget get_widget () {
        if (main_grid == null) {
            main_grid = new Gtk.Grid ();
            hello_label = new Gtk.Label ("Hello World!");
            main_grid.attach (hello_label, 0, 0, 1, 1);
        }

        main_grid.show_all ();
        return main_grid;
    }

    public override void shown () {

    }

    public override void hidden () {

    }

    public override void search_callback (string location) {
        hello_label.label = "Callback : %s".printf (location);
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
