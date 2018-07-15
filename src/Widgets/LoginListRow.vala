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
    public class LoginListRow : Gtk.ListBoxRow {
        public int id { get; set; }
        private Gtk.Box container;
        private Gtk.Label title;
        private Gtk.Button copy_username_button;
        private Gtk.Button copy_password_button;
        private Gtk.Button delete_login;
        
        public signal void copy_username (int id);
        public signal void copy_password (int id);
        public signal void delete_entry (LoginListRow row);

        public LoginListRow (Kipeltip.Interfaces.Login login) {
            this.activatable = true;
            this.id = login.id;

            container = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            container.height_request = 50;
            
            title = new Gtk.Label (login.name);
            
            copy_username_button = new Gtk.Button.with_label ("Copy Username");
            copy_password_button = new Gtk.Button.with_label ("Copy Password");
            delete_login = new Gtk.Button.with_label ("Delete Login");

            container.pack_start (title);
            container.pack_start (copy_username_button, false, false, 5);
            container.pack_start (copy_password_button, false, false, 5);
            container.pack_start (delete_login, false, false, 5);   
            
            add (container);
            
            copy_username_button.clicked.connect ( () => {
                copy_username (id);
            });
            
            copy_password_button.clicked.connect ( () => {
                copy_password (id);
            });
            
            delete_login.clicked.connect ( () => {
                delete_entry (this);
            });
        }
    }
}
