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

namespace Kipeltip.Widgets {
    public class LoginList : Gtk.ListBox {
        public List<int> removal_list;
        
        construct {
            this.selection_mode = Gtk.SelectionMode.NONE;
            
            removal_list = new List<int> ();
        }
        
        public void clear () {
            foreach (var widget in this.get_children ()) {
                remove (widget);
            }
        }
        
        public void add_login (Interfaces.Login new_login) {
            var new_entry = new LoginListRow (new_login);
            new_entry.delete_entry.connect (remove_login);
            add (new_entry);

            show_all ();
        }
                
        public void populate (List<Interfaces.Login> entries) {
            foreach (var entry in entries) {
                add_login (entry);
            }
        }

        private void remove_login (LoginListRow row) {
            // TODO Hide row until the application is closed
            removal_list.append (row.id);
            remove (row);
        }
    }
}
