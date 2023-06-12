/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 skarva llc <contact@skarva.tech>
 */

class Hermetic.Dialogs.NewLocalDialog : Granite.Dialog {
    private Gtk.Label location_label;
    private Gtk.Entry location_entry;

    public NewLocalDialog(Gtk.Window? parent) {
        Object (
            deletable: false,
            resizable: false,
            title: _("New Seal"),
            transient_for: parent
        );
    }
    construct {
        var header = new Granite.HeaderLabel (_("New Hermetic Seal"));
        var label_label = new Gtk.Label (_("Seal Label")) {
            halign = Gtk.Align.END,
            margin_start = 12
        };
        var label_entry = new Gtk.Entry ();

        var integrate_tooltip = _("Integrate directly into your system so it locks and unlocks when you log in or out. You can still export to make a backup.");
        var integrate_label = new Gtk.Label (_("Integrate with Login")) {
            halign = Gtk.Align.END,
            margin_start = 12,
            tooltip_text = integrate_tooltip
        };

        var integrate_switch = new Gtk.Switch () {
            halign = Gtk.Align.START,
            tooltip_text = integrate_tooltip,
            active = true
        };
        integrate_switch.state_set.connect (toggle_save_location);

        location_label = new Gtk.Label (_("Seal Location")) {
            halign = Gtk.Align.END,
            margin_start = 12
        };

        location_entry = new Gtk.Entry () {
            sensitive = false
        };

        var layout = new Gtk.Grid () {
            column_spacing = 12,
            row_spacing = 6
        };
        layout.attach (header, 0, 1);
        layout.attach (label_label, 0, 2);
        layout.attach (label_entry, 1, 2);
        layout.attach (integrate_label, 0, 3);
        layout.attach (integrate_switch, 1, 3);
        layout.attach (location_label, 0, 4);
        layout.attach (location_entry, 1, 4);

        get_content_area ().append (layout);

        add_button ("Cancel", Gtk.ResponseType.CANCEL);
        var button = add_button ("Create Container", Gtk.ResponseType.ACCEPT);
        button.add_css_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);
    }

    bool toggle_save_location (bool state) {
        location_entry.sensitive = !state;

        return false;
    }
}
