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
    public class PreferencesDialog : Gtk.Dialog {
        private Gtk.Switch clear_clipboard;
        private Gtk.Entry clear_clipboard_timeout;
        private Gtk.Switch dark_theme;

        public PreferencesDialog (Gtk.Window? parent) {
            Object (
                border_width: 12,
                deletable: false,
                resizable: false,
                title: _("Preferences"),
                transient_for: parent,
                modal: false
            );

            set_default_response (Gtk.ResponseType.CLOSE);
        }

        construct {
            var grid = new Gtk.Grid ();
            grid.column_spacing = 12;
            grid.row_spacing = 6;
            grid.margin_bottom = 12;
            get_content_area ().add (grid);

            var security_header = new Granite.HeaderLabel (_("Security"));
            grid.attach (security_header, 0, 0, 2, 1);

            /* Clipboard clearing settings */
            var clear_clipboard_label = new SettingsLabel (_("Clear clipboard after timeout:"));
            clear_clipboard = new SettingsSwitch ("clear-clipboard");
            grid.attach (clear_clipboard_label, 0, 1, 1, 1);
            grid.attach (clear_clipboard, 1, 1, 1, 1);

            var clear_clipboard_timeout_label = new SettingsLabel (_("Timeout (secs):"));
            clear_clipboard_timeout = new Gtk.Entry ();
            clear_clipboard_timeout.input_purpose = Gtk.InputPurpose.DIGITS;
            clear_clipboard_timeout.text = Application.app_settings.get_int ("clear-clipboard-timeout").to_string ();
            clear_clipboard_timeout.activates_default = true;
            grid.attach (clear_clipboard_timeout_label, 0, 2, 1, 1);
            grid.attach (clear_clipboard_timeout, 1, 2, 1, 1);

            var interface_header = new Granite.HeaderLabel(_("Interface"));
            grid.attach (interface_header, 0, 3, 2, 1);

            /* Dark Mode setting */
            var dark_theme_label = new SettingsLabel (_("Dark Mode:"));
            dark_theme = new SettingsSwitch ("dark-theme");
            grid.attach (dark_theme_label, 0, 4, 1, 1);
            grid.attach (dark_theme, 1, 4, 1, 1);

            var close_button = add_button (_("Close"), Gtk.ResponseType.CLOSE);

            response.connect (()=> {
                destroy ();
            });

            dark_theme.state_set.connect ((state) => {
                Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = state;
            });
        }

        private class SettingsLabel : Gtk.Label {
            public SettingsLabel (string text) {
                label = text;
                halign = Gtk.Align.END;
                margin_start = 12;
            }
        }

        private class SettingsSwitch : Gtk.Switch {
            public SettingsSwitch (string setting) {
                halign = Gtk.Align.START;
                valign = Gtk.Align.CENTER;
                Application.app_settings.bind (setting, this, "active", SettingsBindFlags.DEFAULT);
            }
        }
    }
}
