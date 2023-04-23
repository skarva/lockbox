/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 skarva llc <contact@skarva.tech>
 */

class Hermetic.Dialogs.NewLocalDialog : Granite.Dialog {
    public NewLocalDialog(Gtk.Window? parent) {
        Object (
            deletable: false,
            resizable: false,
            title: _("New Container"),
            transient_for: parent
        );
    }
    construct {
        var header = new Granite.HeaderLabel (_("New Container"));
        var use_password = new Gtk.Switch () {
            halign = Gtk.Align.START
        };
        var entry = new Gtk.Entry ();
        
        var layout = new Gtk.Grid () {
            column_spacing = 12,
            row_spacing = 6
        };
        layout.attach (header, 0, 1);
        layout.attach (use_password, 0, 2);
        layout.attach (entry, 0, 3);
        
        get_content_area ().append (layout);
        
        add_button ("Cancel", Gtk.ResponseType.CANCEL);
        add_button ("Create Container", Gtk.ResponseType.ACCEPT);
    }
}
