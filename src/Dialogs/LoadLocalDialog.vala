/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 skarva llc <contact@skarva.tech>
 */

class Hermetic.Dialogs.LoadLocalDialog : Granite.Dialog {
    public LoadLocalDialog(Gtk.Window? parent) {
        Object (
            deletable: false,
            resizable: false,
            title: _("New Container"),
            transient_for: parent
        );
    }
    construct {
        var header = new Granite.HeaderLabel (_("Load Container"));
        var entry = new Gtk.Entry ();
        
        var layout = new Gtk.Grid () {
            column_spacing = 12,
            row_spacing = 6
        };
        layout.attach (header, 0, 1);
        layout.attach (entry, 0, 2);
        
        get_content_area ().append (layout);
        
        add_button ("Cancel", Gtk.ResponseType.CANCEL);
        var button = add_button ("Load Container", Gtk.ResponseType.ACCEPT);
        button.add_css_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);
    }
}
