public class Adstruo.Temps : Wingpanel.Indicator {
    private Gtk.Box display_widget;
    private Gtk.Grid popover_widget;

    public Temps () {
        Object (
            code_name : "adstruo-temps",
            display_name : "Temperature Indicator",
            description: "Adds temperature information (CPU or GPU) to the wingpanel."
        );
    }

    construct {
        var icon = new Gtk.Image.from_icon_name ("sensors-temperature-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        var temperature = new Gtk.Label ("0℃");
        temperature.margin = 2;

        display_widget = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        display_widget.valign = Gtk.Align.CENTER;
        display_widget.pack_start (icon);
        display_widget.pack_start (temperature);

        //var popover_separator = new Wingpanel.Widgets.Separator ();
        var options_button = new Gtk.ModelButton ();
            options_button.text = "Options";

        popover_widget = new Gtk.Grid ();
        //popover_widget.add (popover_separator);
        popover_widget.attach (options_button, 0, 0);

        this.visible = true;

        options_button.clicked.connect (() => {
            this.visible = false;

            Timeout.add (2000, () => {
                this.visible = true;
                return false;
            });
        });

    }

    public override Gtk.Widget get_display_widget () {
        return display_widget;
    }

    public override Gtk.Widget? get_widget () {
        return popover_widget;
    }

    public override void opened () {
    }

    public override void closed () {
    }
}

public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    debug ("Activating Sample Indicator");

    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        return null;
    }

    var indicator = new Adstruo.Temps ();

    return indicator;
}
