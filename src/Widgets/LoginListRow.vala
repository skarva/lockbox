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
        public string category { set; get; }
        private Gtk.Box container;
        private Gtk.Label title;
        private Gtk.Button copy_username;
        private Gtk.Button copy_password;
        private Gtk.Revealer detail_revealer;
        private Gtk.Grid detail_view;
        private Gtk.Label username;
        private Gtk.Label password;
        private Gtk.Button delete_login;
        
        public signal void delete_entry (LoginListRow row);

        public LoginListRow (Kipeltip.Interfaces.Login login) {
            this.activatable = true;

            container = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            container.height_request = 50;
            
            title = new Gtk.Label (login.name);
            
            username = new Gtk.Label (login.username);
            
            password = new Gtk.Label (login.password);
            
            copy_username = new Gtk.Button.with_label ("Copy Username");
            copy_password = new Gtk.Button.with_label ("Copy Password");
            delete_login = new Gtk.Button.with_label ("Delete Login");
            
            detail_view = new Gtk.Grid ();
            detail_view.attach (username, 0, 0);
            detail_view.attach (password, 0, 1);
            detail_view.attach (delete_login, 1, 1);
            
            detail_revealer = new Gtk.Revealer ();
            detail_revealer.reveal_child = false;
            detail_revealer.transition_duration = 500;
            detail_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
            detail_revealer.add (detail_view);

            container.pack_start (title);
            container.pack_start (copy_username, false, false, 5);
            container.pack_start (copy_password, false, false, 5);
            container.pack_start (detail_revealer);
            
            add (container);
            
            copy_username.clicked.connect ( () => {
                MainWindow.clipboard.set_text (username.label, username.label.length);
                // TODO Start timer to clear clipboard
            });
            
            copy_password.clicked.connect ( () => {
                MainWindow.clipboard.set_text (password.label, password.label.length);
                // TODO Start timer to clipboard clear
            });
            
            delete_login.clicked.connect ( () => {
                delete_entry (this);
            });
        }
        
        public void show_details () {
            detail_revealer.reveal_child = !detail_revealer.reveal_child;
        }
    }
}
