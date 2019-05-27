/*
* Copyright (c) 2019 Raí B. Toffoletto (https://toffoletto.me)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Raí B. Toffoletto <rai@toffoletto.me>
*/
public class Adstruo.Temps : Wingpanel.Indicator {
    private Gtk.Box display_widget;
    private Gtk.Box popover_widget;
    private Adstruo.Utilities adstruo;
    private GLib.Settings settings;
    private Gtk.Label temperature;
    private Wingpanel.Widgets.Switch fahrenheit_switch;

    public Temps () {
        Object (
            code_name : "adstruo-temps",
            display_name : _("Temperature Indicator"),
            description: _("Shows a hardware temperature indicator in the wingpanel")
        );
    }

    construct {
        adstruo = new Adstruo.Utilities ();
        settings = new GLib.Settings ("com.github.raibtoffoletto.adstruo.temps");

        adstruo.update_indicator_status (this, settings.get_boolean ("status"));
        settings.change_event.connect (() => {
            adstruo.update_indicator_status (this, settings.get_boolean ("status"));
            update_temp ();
        });

        var icon = new Gtk.Image.from_icon_name ("temperature", Gtk.IconSize.SMALL_TOOLBAR);
        temperature = new Gtk.Label ("0 ℃");

        display_widget = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        display_widget.valign = Gtk.Align.CENTER;
        display_widget.pack_start (icon);
        display_widget.pack_start (temperature);

        var options_button = new Gtk.ModelButton ();
            options_button.text = _("Settings");
            options_button.clicked.connect (() => {
                this.adstruo.show_settings (this);
            });

        fahrenheit_switch = new Wingpanel.Widgets.Switch (_("Use Fahrenheit"));
        fahrenheit_switch.notify["active"].connect (() => {
            this.settings.set_boolean ("unit-fahrenheit", (fahrenheit_switch.active ? true : false));
            update_temp ();
        });

        popover_widget = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        popover_widget.add (fahrenheit_switch);
        popover_widget.add (new Wingpanel.Widgets.Separator ());
        popover_widget.add (options_button);

        update_temp ();
        Timeout.add_full (Priority.DEFAULT, 5000, update_temp);

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

    //get temperatures directly from /sys and update indicator
    private bool update_temp () {
        var temperature_source = this.settings.get_string ("temperature-source");
        var unit_fahrenheit = this.settings.get_boolean ("unit-fahrenheit");
        fahrenheit_switch.active = unit_fahrenheit;

    	try {
            string temp_raw;
            FileUtils.get_contents("/sys/class/hwmon/" + temperature_source + "/temp1_input", out temp_raw);

            this.temperature.label = this.adstruo.convert_temp (temp_raw, unit_fahrenheit);

        } catch (FileError err) {
    		stderr.printf (err.message);
	        return false;
	    }

	    return true;
    }

}

public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    debug (_("Activating Temperature Indicator"));

    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        return null;
    }

    var indicator = new Adstruo.Temps ();

    return indicator;
}
