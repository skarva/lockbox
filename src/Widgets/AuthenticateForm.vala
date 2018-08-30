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
    public class AuthenticateForm : Gtk.Box {
        private Gtk.InfoBar infobar;
        private Gtk.Entry name_entry;
        private Gtk.Entry password_entry;
        private Gtk.Button login_button;

        private Services.Collection collection;

        public signal void success ();

        public AuthenticateForm (Services.Collection collection) {
            Object (orientation: Gtk.Orientation.VERTICAL, spacing: 0);
            this.collection = collection;
        }

        construct {
            var info_label = new Gtk.Label (_("Invalid collection credentials!"));
            info_label.show ();

            infobar = new Gtk.InfoBar ();
            infobar.no_show_all = true;
            infobar.message_type = Gtk.MessageType.ERROR;
            infobar.show_close_button = true;
            infobar.get_content_area ().add (info_label);
            infobar.response.connect (() => {
                infobar.visible = false;
            });
            pack_start (infobar);


            var logo = new Gtk.Image.from_file (Constants.DATADIR + "/" + Constants.PROJECT_NAME + "/logo.svg");
            logo.margin_top = 12;
            logo.halign = Gtk.Align.CENTER;
            pack_start (logo);

            var grid = new Gtk.Grid ();
            grid.orientation = Gtk.Orientation.VERTICAL;
            grid.column_spacing = 12;
            grid.row_spacing = 6;
            grid.valign = Gtk.Align.FILL;
            grid.halign = Gtk.Align.CENTER;
            set_center_widget (grid);

            var header = new Granite.HeaderLabel (_("Open a collection"));
            grid.attach (header, 0, 0, 2, 1);

            var name_label = new Gtk.Label (_("Collection:"));
            name_label.halign = Gtk.Align.END;
            name_label.margin_start = 12;
            grid.attach (name_label, 0, 1, 1, 1);

            name_entry = new Gtk.Entry ();
            name_entry.input_purpose = Gtk.InputPurpose.FREE_FORM;
            name_entry.text = Services.Settings.get_default ().last_collection;
            name_entry.activate.connect (check_credentials);
            name_entry.key_release_event.connect (() => {
                is_empty ();
                return false;
            });
            grid.attach (name_entry, 1, 1, 4, 1);

            var password_label = new Gtk.Label (_("Password:"));
            password_label.halign = Gtk.Align.END;
            password_label.margin_start = 12;
            grid.attach (password_label, 0, 2, 1, 1);

            password_entry = new Gtk.Entry ();
            password_entry.input_purpose = Gtk.InputPurpose.PASSWORD;
            password_entry.invisible_char = '*';
            password_entry.visibility = false;
            password_entry.activate.connect (check_credentials);
            password_entry.key_release_event.connect(() => {
                is_empty ();
                return false;
            });
            grid.attach (password_entry, 1, 2, 4, 1);

            login_button = new Gtk.Button.with_label (_("Open Collection"));
            login_button.sensitive = false;
            grid.attach (login_button, 4, 3, 1, 1);

            login_button.clicked.connect (check_credentials);
        }

        private bool is_empty () {
            if (name_entry.text.length > 0 && password_entry.text.length > 0) {
                login_button.sensitive = true;
                return false;
            } else {
                login_button.sensitive = false;
                return true;
            }
        }

        private void check_credentials () {
            if (!is_empty ()) {
                var collection_name = name_entry.text.strip ();
                var collection_password = password_entry.text.strip ();

                if (collection.open (collection_name, collection_password)) {
                    password_entry.text = "";
                    login_button.sensitive = false;
                    success ();
                } else {
                    infobar.visible = true;
                }
            }
        }
    }
}
