/*
* Copyright (c) 2020 skarva LLC. <https://skarva.tech>
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
    class CollectionList : Gtk.ListBox {
        private weak MainWindow? main_window;
        private ListStore model;

        public CollectionList(MainWindow? window) {
            main_window = window;
            model = new ListStore (Type.OBJECT);
            
            bind_model (model, add_row);

            set_filter_func (filter);
        }

        /// Adds relevant secret item data to a new row
        /// Returns size of the list after adding
        public void add_row (Secret.Item item) {
            var row = new Widgets.CollectionListRow (item);

            if (Schemas.is_login (item)) {
                row.copy_username.connect (main_window.copy_username);
                row.copy_password.connect (main_window.copy_password);
            }

            row.edit_entry.connect (edit_row);
            row.delete_entry.connect (remove_row);
            add (row);

            show_all ();
        }

        public void edit_row (Widgets.CollectionListRow row) {
            if (Schemas.is_login (row.item)) {
                var login_dialog = new Dialogs.LoginDialog (main_window);
                login_dialog.set_entries (row);
                login_dialog.show_all ();

                login_dialog.present ();
            } else if (Schemas.is_note (row.item)) {
                var note_dialog = new Dialogs.NoteDialog (main_window);
                note_dialog.set_entries (row);
                note_dialog.show_all ();

                note_dialog.present ();
            }
        }

        public void remove_row (Widgets.CollectionListRow row) {
            remove (row);
        }

        public bool filter (Gtk.ListBoxRow row) {
            if (main_window.filter_keyword.length == 0) {
                return true;
            }

            var collection_row = row as Widgets.CollectionListRow;
            var label = collection_row.item.label;

            // Search using exact match (case-sensitive)
            if (label.contains (main_window.filter_keyword)) {
                return true;
            }

            // Search using case insensitivity
            if (label.ascii_down ().contains (main_window.filter_keyword.ascii_down ())) {
                return true;
            }

            return false;
        }

        public int sort_by_name (Gtk.ListBoxRow row1, Gtk.ListBoxRow row2) {
            var collection_row1 = row1 as Widgets.CollectionListRow;
            var collection_row2 = row2 as Widgets.CollectionListRow;
            var desc = Application.app_settings.get_boolean ("sort-desc") ? 1 : -1;

            return collection_row1.item.label.ascii_casecmp (collection_row2.item.label) * desc;
        }

        public int sort_by_date (Gtk.ListBoxRow row1, Gtk.ListBoxRow row2) {
            var collection_row1 = row1 as Widgets.CollectionListRow;
            var collection_row2 = row2 as Widgets.CollectionListRow;
            var desc = Application.app_settings.get_boolean ("sort-desc") ? 1 : -1;

            if (collection_row1.item.created < collection_row2.item.created) {
                return -1 * desc;
            } else if (collection_row1.item.created > collection_row2.item.created) {
                return 1 * desc;
            }

            return 0;
        }

        public uint size () {
            return model.get_n_items ();
        }
    }
} // Lockbox.Widgets
