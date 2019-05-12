public class SettingsPage : Granite.SettingsPage {
    public SettingsPage () {
        var user_name = Environment.get_user_name ();
        Object (
            display_widget: new Granite.Widgets.Avatar.from_file ("/var/lib/AccountsService/icons/%s".printf (user_name), 32),
            header: "Manual Pages",
            status: user_name,
            title: "Avatar Test Page"
        );
    }

    construct {
        var title_label = new Gtk.Label ("Title:");
        title_label.xalign = 1;

        var title_entry = new Gtk.Entry ();
        title_entry.hexpand = true;
        title_entry.placeholder_text = "This page's title";

        var content_area = new Gtk.Grid ();
        content_area.column_spacing = 12;
        content_area.row_spacing = 12;
        content_area.margin = 12;
        content_area.attach (title_label, 0, 1, 1, 1);
        content_area.attach (title_entry, 1, 1, 1, 1);

        add (content_area);

        title_entry.changed.connect (() => {
            title = title_entry.text;
        });
    }
}
