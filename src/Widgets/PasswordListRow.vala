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
    public class PasswordListRow : Gtk.Grid {
        public string category { set; get; }
        private Gtk.Label entry_name;
        private Gtk.Button copy_username;
        private Gtk.Button copy_password;
        private Gtk.Revealer detail_revealer;
        private Gtk.Grid detail_view;
        private Gtk.Entry entry_username;
        private Gtk.Entry entry_password;
        private Gtk.Button delete_entry;

        public PasswordListRow (Kipeltip.Interfaces.Password password) {
            entry_name = new Gtk.Label (password.name);
            
            entry_username = new Gtk.Entry ();
            entry_username.text = password.username;
            
            entry_password = new Gtk.Entry ();
            entry_password.text = password.password;
            
            copy_username = new Gtk.Button.with_label ("Copy Username");
            copy_password = new Gtk.Button.with_label ("Copy Password");

            attach (entry_name, 0, 0, 1, 1);
            //attach (copy_username, 1, 0, 1, 1);
            //attach (copy_password, 2, 0, 1, 1);
        }
    }
}
