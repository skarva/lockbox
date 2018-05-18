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
    public class PasswordListView : Gtk.Grid {
        private Gtk.Grid password_list;

        construct {
            password_list = new Gtk.Grid ();
            password_list.expand = true;
            password_list.orientation = Gtk.Orientation.VERTICAL;
            add (password_list);

            // TODO Load sites from DB

            /* Test Passwords */
            var pwd = new Kipeltip.Interfaces.Password ("Test 1", "test", "pass");
            var entry1 = new PasswordListRow (pwd);
            password_list.add (entry1);
        }

        public void add_password () {
            // TODO Add password dialog
        }
    }
}
