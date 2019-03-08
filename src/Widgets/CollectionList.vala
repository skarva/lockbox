/*
* Copyright (c) 2019 skärva LLC. <https://skarva.tech>
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

namespace Lockbox.Widgets {
    public class CollectionList : Gtk.ListBox {
        public List<Interfaces.Item> removal_list;

        public signal void copy_username (Interfaces.Item item);
        public signal void copy_password (Interfaces.Item item);
        public signal void edit_entry (Interfaces.Item item);

        construct {
            this.selection_mode = Gtk.SelectionMode.NONE;
            // Add check for sort setting and set sort method accordingly

            removal_list = new List<Interfaces.Item> ();
        }

        public void clear_list () {
            foreach (var widget in this.get_children ()) {
                remove (widget);
            }
            foreach (var item in removal_list) {
                removal_list.remove (item);
            }
        }

        public void clean () {
            foreach (var item in removal_list) {
                item.delete.begin (new Cancellable ());
            }
        }

        public void add_login (Interfaces.Login item) {
            var new_entry = new CollectionListLoginRow (item);
            new_entry.copy_username.connect (copy_login_username);
            new_entry.copy_password.connect (copy_login_password);
            new_entry.edit_entry.connect (edit_item);
            new_entry.delete_entry.connect (remove_item);
            add (new_entry);

            show_all ();
        }

         public void add_note (Interfaces.Note item) {
            var new_entry = new CollectionListNoteRow (item);
            new_entry.edit_entry.connect (edit_item);
            new_entry.delete_entry.connect (remove_item);
            add (new_entry);

            show_all ();
        }

        public void populate (List<Secret.Item> items) {
            foreach (var item in items) {
                if (Interfaces.Login.is_login (item)) {
                    var login = new Interfaces.Login (
                        item.attributes.get("id"),
                        item.label,
                        item.attributes.get("uri"),
                        item.attributes.get("username"), 
                        ""); // No password here since it is a secret value
                    add_login (login);
                } else if (Interfaces.Note.is_note (item)) {
                    var note = new Interfaces.Note (
                        item.attributes.get("id"),
                        item.label,
                        item.attributes.get("content"));
                    add_note (note);
                } else {
                    critical ("Unknown CollectionType");
                }
            }
        }

        private void copy_login_username (Interfaces.Item item) {
            copy_username (item);
        }

        private void copy_login_password (Interfaces.Item item) {
            copy_password (item);
        }

        private void edit_item (Interfaces.Item item) {
            edit_entry(item);
        }

        private void remove_item (CollectionListRow row) {
            removal_list.append (row.item);
            remove (row);
        }
    }
}
