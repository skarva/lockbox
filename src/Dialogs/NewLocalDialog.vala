/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 skarva llc <contact@skarva.tech>
 */

// class Dialogs.NewLocalDialog : Gtk.Window {

//     public NewLocalDialog(Gtk.Window? parent) {
//         Object (
//             deletable: false,
//             resizable: false,
//             title: _("New Local Lock Box"),
//             transient_for: parent
//          );
//     }

//     construct {
//         width_request = 400;
//         var start_window_controls = new Gtk.WindowControls (Gtk.PackType.START);
//         var end_window_controls = new Gtk.WindowControls (Gtk.PackType.END) {
//             halign = Gtk.Align.END
//         };

//         var main_header = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
//         main_header.add_css_class ("titlebar");
//         main_header.add_css_class (Granite.STYLE_CLASS_FLAT);
//         main_header.append (start_window_controls);
//         main_header.append (end_window_controls);

//         var main_layout = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
//         main_layout.append (main_header);

//         // We need to hide the title area for the split headerbar
//         var null_title = new Gtk.Grid () {
//             visible = false
//         };
//         set_titlebar (null_title);

//         child = main_layout;
//     }
// }

class Dialogs.NewLocalDialog : Granite.Dialog {
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
