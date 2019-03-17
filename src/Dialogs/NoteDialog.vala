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

namespace Lockbox.Dialogs {
    public class NoteDialog : Gtk.Dialog {
        private Gtk.Entry name_entry;
        private Gtk.TextView content_entry;

        private bool is_edit;
        private Secret.Item item;

        public signal void new_note (string name,
                                      HashTable<string, string> attributes,
                                      string password);

        public NoteDialog (Gtk.Window? parent) {
            Object (
                border_width: 12,
                deletable: false,
                resizable: false,
                title: _("Add Note"),
                transient_for: parent
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

            var header = new Granite.HeaderLabel (_("Add Note"));
            grid.attach (header, 0, 0, 2, 1);

            var name_label = new Gtk.Label (_("Name:"));
            name_label.halign = Gtk.Align.END;
            name_label.margin_start = 12;
            name_entry = new Gtk.Entry ();
            name_entry.activates_default = true;
            grid.attach (name_label, 0, 1, 1, 1);
            grid.attach (name_entry, 1, 1, 1, 1);

            var content_label = new Gtk.Label (_("Note:"));
            content_label.halign = Gtk.Align.END;
            content_label.margin_start = 12;
            content_entry = new Gtk.TextView ();
            content_entry.input_purpose = Gtk.InputPurpose.FREE_FORM;
            content_entry.accepts_tab = true;
            grid.attach (content_label, 0, 2, 1, 1);
            grid.attach (content_entry, 1, 2, 1, 1);

            var close = add_button (_("Cancel"), Gtk.ResponseType.CLOSE);
            var save = add_button (_("Save note"), Gtk.ResponseType.OK);
            save.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

            response.connect (on_response);
        }

        public void set_entries (Secret.Item item) {
            name_entry.text = item.label;
            item.load_secret.begin (new Cancellable (), (obj, res) => {
                content_entry.buffer.text = item.get_secret ().get_text ();
            });
            is_edit = true;
            this.item = item;
        }

        private void on_response (Gtk.Dialog source, int response_id) {
            switch (response_id) {
                case Gtk.ResponseType.OK:
                    var invalid_input = name_entry.text_length == 0 ||
                                      content_entry.buffer.text.length == 0;
                    if (invalid_input) {
                        var alert = new Granite.MessageDialog.with_image_from_icon_name (
                            _("Some fields are still empty!"),
                            _("You must fill in all the fields in order to save your note."),
                            "dialog-error",
                            Gtk.ButtonsType.CLOSE
                        );
                        alert.run ();
                        alert.destroy ();
                    } else if (is_edit) {
                        item.label = name_entry.text.strip ();

                        var secret = content_entry.buffer.text.strip ();
                        var secret_value = new Secret.Value (secret,
                                                             secret.length,
                                                             "text/plain");
                        item.set_secret.begin (secret_value, new Cancellable ());
                        destroy ();
                    } else {
                        var id = "{" + Uuid.string_random () + "}";
                        var attributes = new HashTable<string, string> (str_hash, str_equal);
                        attributes.insert ("id", id);

                        new_note (name_entry.text.strip (), attributes,
                                   content_entry.buffer.text.strip ());
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
