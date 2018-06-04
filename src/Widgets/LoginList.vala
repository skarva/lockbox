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
        construct {
            this.selection_mode = Gtk.SelectionMode.NONE;

            /* Test Passwords */
            var pwd = new Kipeltip.Interfaces.Login ("Test 1", "test", "pass");
            var entry1 = new LoginListRow (pwd);
            entry1.delete_entry.connect (remove_login);
            add (entry1);

            var pwd2 = new Kipeltip.Interfaces.Login ("Test 2", "test", "pass2");
            var entry2 = new LoginListRow (pwd2);
            entry2.delete_entry.connect (remove_login);
            add (entry2);
            
            populate_from_db ();
        }
        
        public void update () {
            clear ();
            populate_from_db ();
        }
        
        public void clear () {
            foreach (Gtk.Widget widget in this.get_children ()) {
                remove (widget);
            }
        }
        
        private void populate_from_db () {
            // TODO Access DB and load entries
        }

        private void add_login () {
            // TODO Add password dialog
        }

        private void remove_login (LoginListRow row) {
            remove (row);
        }
    }
}
