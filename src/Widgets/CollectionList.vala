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

        public void add_item (Interfaces.Item new_item) {
            var new_entry = new CollectionListRow (new_item);
            new_entry.copy_username.connect (copy_login_username);
            new_entry.copy_password.connect (copy_login_password);
            new_entry.edit_entry.connect (edit_item);
            new_entry.delete_entry.connect (remove_item);
            add (new_entry);

            show_all ();
        }

        public void populate (List<Interfaces.Item> entries) {
            clear_list ();
            foreach (var entry in entries) {
                add_item (entry);
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
