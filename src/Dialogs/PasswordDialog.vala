/*
* Copyright (c) 2018 skärva LLC. <https://skarva.tech>
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
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
*/

namespace Kipeltip.Dialogs {
    public class PasswordDialog : Gtk.Dialog {
        private Gtk.Entry password;
        private Gtk.Widget save_button;

        public PasswordDialog (Gtk.Window? parent) {
            Object (
                border_width: 5,
                deletable: false,
                resizable: false,
                title: _("Master Password"),
                transient_for: parent
            );

            set_default_response (Gtk.ResponseType.NONE);
        }

        construct {
            var grid = new Gtk.Grid ();
            grid.column_spacing = 12;
            grid.row_spacing = 6;
            get_content_area ().add (grid);

            var password_label = new Gtk.Label (_("Master Password"));
            password_label.halign = Gtk.Align.END;
            password_label.margin_start = 12;
            grid.attach (password_label, 0, 0, 1, 1);

            password = new Gtk.Entry ();
            password.input_purpose = Gtk.InputPurpose.PASSWORD;
            password.invisible_char = '*';
            password.visibility = false;
            password.activates_default = true;
            grid.attach (password, 1, 0, 1, 1);

            save_button = add_button (_("Set Password"), Gtk.ResponseType.NONE);

            response.connect (()=> {
               // TODO Create user DB using master password as passphrase
               destroy ();
            });
        }
    }
}
