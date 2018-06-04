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
    public class AddLoginDialog : Gtk.Dialog {
        private Gtk.Entry entry_name;
        private Gtk.Entry username;
        private Gtk.Entry password;
        
        public signal void update_list ();
        
        public AddLoginDialog (Gtk.Window? parent) {
            Object (
                border_width: 6,
                deletable: false,
                resizable: false,
                title: _("Add Login"),
                transient_for: parent
            );
            
            set_default_response (Gtk.ResponseType.NONE);
        }
        
        construct {
            var grid = new Gtk.Grid ();
            grid.column_spacing = 12;
            grid.row_spacing = 6;
            get_content_area ().add (grid);

            var header = new Granite.HeaderLabel (_("Add Login"));
            grid.attach (header, 0, 0, 2, 1);

            var name_label = new Gtk.Label (_("Name"));
            entry_name = new Gtk.Entry ();
            grid.attach (name_label, 0, 1, 1, 1);
            grid.attach (entry_name, 1, 1, 1, 1);
            
            var username_label = new Gtk.Label (_("Username"));
            username = new Gtk.Entry ();
            grid.attach (username_label, 0, 2, 1, 1);
            grid.attach (username, 1, 2, 1, 1);
            
            var password_label = new Gtk.Label (_("Password"));
            password = new Gtk.Entry ();
            grid.attach (password_label, 0, 3, 1, 1);
            grid.attach (password, 1, 3, 1, 1);
            
            var close_button = add_button (_("Close"), Gtk.ResponseType.NONE);

            response.connect (()=> {
                destroy ();
            });
        }
    }
}
