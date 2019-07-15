/*
* Copyright (c) 2019 skarva LLC. <https://skarva.tech>
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

namespace Lockbox.Dialogs {
    public class LoginDialog : Gtk.Dialog {
        private Gtk.Entry name_entry;
        private Gtk.Entry uri_entry;
        private Gtk.Entry username_entry;
        private Gtk.Entry password_entry;

        private bool is_edit;
        private Widgets.CollectionListRow row;

        public signal void new_login (string name,
                                      HashTable<string, string> attributes,
                                      string password);

        public LoginDialog (Gtk.Window? parent) {
            Object (
                border_width: 12,
                deletable: false,
                resizable: false,
                title: _("Add Login"),
                transient_for: parent,
                modal: true
            );

            is_edit = false;

            set_default_response (Gtk.ResponseType.OK);
        }

        construct {
            var grid = new Gtk.Grid ();
            grid.column_spacing = 12;
            grid.row_spacing = 6;
            grid.margin_bottom = 12;
            get_content_area ().add (grid);

            var header = new Granite.HeaderLabel (_("Add Login"));
            grid.attach (header, 0, 0, 2, 1);

            var name_label = new Gtk.Label (_("Name:"));
            name_label.halign = Gtk.Align.END;
            name_label.margin_start = 12;
            name_entry = new Gtk.Entry ();
            name_entry.activates_default = true;
            grid.attach (name_label, 0, 1, 1, 1);
            grid.attach (name_entry, 1, 1, 1, 1);

            var uri_label = new Gtk.Label (_("URI:"));
            uri_label.halign = Gtk.Align.END;
            uri_label.margin_start = 12;
            uri_entry = new Gtk.Entry ();
            uri_entry.activates_default = true;
            grid.attach (uri_label, 0, 2, 1, 1);
            grid.attach (uri_entry, 1, 2, 1, 1);

            var username_label = new Gtk.Label (_("Username:"));
            username_label.halign = Gtk.Align.END;
            username_label.margin_start = 12;
            username_entry = new Gtk.Entry ();
            username_entry.activates_default = true;
            grid.attach (username_label, 0, 3, 1, 1);
            grid.attach (username_entry, 1, 3, 1, 1);

            var password_label = new Gtk.Label (_("Password:"));
            password_label.halign = Gtk.Align.END;
            password_label.margin_start = 12;
            password_entry = new Gtk.Entry ();
            password_entry.input_purpose = Gtk.InputPurpose.PASSWORD;
            password_entry.invisible_char = '*';
            password_entry.visibility = false;
            password_entry.activates_default = true;
            grid.attach (password_label, 0, 4, 1, 1);
            grid.attach (password_entry, 1, 4, 1, 1);

            var close = add_button (_("Cancel"), Gtk.ResponseType.CLOSE);
            var save = add_button (_("Save Login"), Gtk.ResponseType.OK);
            save.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

            response.connect (on_response);
        }

        public void set_entries (Widgets.CollectionListRow row) {
            var item = row.item;
            name_entry.text = item.label;
            uri_entry.text = item.attributes.get ("uri");
            username_entry.text = item.attributes.get ("username");
            item.load_secret.begin (new Cancellable (), (obj, res) => {
                password_entry.text = item.get_secret ().get_text ();
            });
            is_edit = true;
            this.row = row;
        }

        private void on_response (Gtk.Dialog source, int response_id) {
            switch (response_id) {
                case Gtk.ResponseType.OK:
                    var valid_input = name_entry.text_length == 0 ||
                                      username_entry.text_length == 0 ||
                                      password_entry.text_length == 0;
                    if (valid_input) {
                        var alert = new Granite.MessageDialog.with_image_from_icon_name (
                            _("Some fields are still empty!"),
                            _("You must fill in all the fields in order to save your login info."),
                            "dialog-error",
                            Gtk.ButtonsType.CLOSE
                        );
                        alert.run ();
                        alert.destroy ();
                    } else if (is_edit) {
                        var item = row.item;
                        item.label = name_entry.text.strip ();

                        var attributes = item.get_attributes ();
                        attributes.replace ("uri", uri_entry.text.strip ());
                        attributes.replace ("username", username_entry.text.strip ());
                        item.set_attributes.begin (Schemas.epiphany (), attributes, new Cancellable ());

                        var secret = password_entry.text.strip ();
                        var secret_value = new Secret.Value (secret,
                                                             secret.length,
                                                             "text/plain");
                        item.set_secret.begin (secret_value, new Cancellable ());
                        row.title.set_text(name_entry.text.strip ());
                        destroy ();
                    } else {
                        var id = "{" + Uuid.string_random () + "}";
                        var timestamp = get_real_time () / 1000;
                        var attributes = new HashTable<string, string> (str_hash, str_equal);
                        attributes.insert ("id", id);
                        attributes.insert ("uri", uri_entry.text.strip ());
                        attributes.insert ("target_origin", "");
                        attributes.insert ("form_username", "");
                        attributes.insert ("form_password", "");
                        attributes.insert ("username", username_entry.text.strip ());
                        attributes.insert ("server_time_modified", timestamp.to_string ());

                        new_login (name_entry.text.strip (), attributes,
                                   password_entry.text.strip ());
                        destroy ();
                    }
                    break;
                case Gtk.ResponseType.CLOSE:
                    destroy ();
                    break;
            }
        }
    }
}
