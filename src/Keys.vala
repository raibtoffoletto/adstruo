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

public class Adstruo.Keys : Wingpanel.Indicator {
    public bool capslock_status { get; set; }
    public bool numlock_status { get; set; }
    private Gtk.Box display_widget;
    private Gtk.Box popover_widget;
    private Adstruo.Utilities adstruo;
    private GLib.Settings settings;
    private Gtk.Label capslock;
    private Gtk.Label numlock;
    private Gdk.Keymap keymap;

    public Keys () {
        Object (
            code_name : "adstruo-30-keys",
            display_name : _("Keyboard Status Keys"),
            description: _("Shows the Capslock or Numlock status in the wingpanel")
        );
    }

    construct {
        visible = false;
        adstruo = new Adstruo.Utilities ();
        settings = adstruo.keys_settings;
        keymap = Gdk.Keymap.get_for_display (Gdk.Display.get_default ());

        numlock = new Gtk.Label ("<span foreground=\"gray\">1</span>");
        numlock.use_markup = true;
        numlock.margin = 2;
        numlock.set_size_request (16, 16);
        numlock.halign = Gtk.Align.CENTER;
        numlock.valign = Gtk.Align.CENTER;

        capslock = new Gtk.Label ("<span foreground=\"gray\">A</span>");
        capslock.use_markup = true;
        capslock.margin = 2;
        capslock.set_size_request (16, 16);
        capslock.halign = Gtk.Align.CENTER;
        capslock.valign = Gtk.Align.CENTER;

        display_widget = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        display_widget.valign = Gtk.Align.CENTER;
        display_widget.pack_start (numlock, false, false);
        display_widget.pack_end (capslock, false, false);

        var options_button = new Gtk.ModelButton ();
            options_button.text = _("Settings");

        popover_widget = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        popover_widget.expand = true;
        popover_widget.pack_end (options_button, false, false);

        Timeout.add_full (Priority.DEFAULT, 5, () => {
            activate_indicator ();
            return false;
        });


        options_button.clicked.connect (() => {
            try {
                AppInfo.launch_default_for_uri ("settings://adstruo", null);
            } catch (Error e) {
                print ("Erro: %s\n", e.message);
            }
        });

        settings.change_event.connect (() => {
            activate_indicator ();
        });

        keymap.state_changed.connect (update_keys);

        notify["numlock-status"].connect (() => {
            if (numlock_status) {
                numlock.get_style_context ().add_class ("keyboard");
                numlock.label = "1";
            } else {
                numlock.get_style_context ().remove_class ("keyboard");
                numlock.label = "<span foreground=\"gray\">1</span>";
            }
        });

        notify["capslock-status"].connect (() => {
            if (capslock_status) {
                capslock.get_style_context ().add_class ("keyboard");
                capslock.label = "A";
            } else {
                capslock.get_style_context ().remove_class ("keyboard");
                capslock.label = "<span foreground=\"gray\">A</span>";
            }
        });
    }

    public override Gtk.Widget get_display_widget () {
        return display_widget;
    }

    public override Gtk.Widget? get_widget () {
        return popover_widget;
    }

    public override void opened () {}

    public override void closed () {}

    private void activate_indicator () {
        visible = settings.get_boolean ("status");
        if (visible) {
            numlock.visible = settings.get_boolean ("numlock") ? true : false;
            capslock.visible = settings.get_boolean ("capslock") ? true : false;
        }
    }

    private void update_keys () {
        set_property ("capslock-status", keymap.get_caps_lock_state ());
        set_property ("numlock-status", keymap.get_num_lock_state ());
    }
}

public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    debug (_("Activating Keys Indicator"));
    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        return null;
    }

    return new Adstruo.Keys ();
}
