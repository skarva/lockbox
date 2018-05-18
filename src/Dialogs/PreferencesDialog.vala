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

namespace Kipeltip.Dialogs {
    public class PreferencesDialog : Gtk.Dialog {
        private Gtk.Switch clear_clipboard;
        private Gtk.Entry clear_clipboard_timeout;
        private Gtk.Switch autolock;
        private Gtk.Entry autolock_timeout;

        public PreferencesDialog (Gtk.Window? parent) {
            Object (
                border_width: 5,
                deletable: false,
                resizable: false,
                title: _("Preferences"),
                transient_for: parent
            );

            set_default_response (Gtk.ResponseType.NONE);
        }

        construct {
            var settings = Settings.get_default ();

            var grid = new Gtk.Grid ();
            grid.column_spacing = 12;
            grid.row_spacing = 6;
            get_content_area ().add (grid);

            var header = new Granite.HeaderLabel (_("Security"));
            grid.attach (header, 0, 0, 2, 1);

            /* Clipboard clearing settings */
            var clear_clipboard_label = new SettingsLabel (_("Clear clipboard after timeout"));
            clear_clipboard = new SettingsSwitch ("clear-clipboard");
            grid.attach (clear_clipboard_label, 0, 1, 1, 1);
            grid.attach (clear_clipboard, 1, 1, 1, 1);

            var clear_clipboard_timeout_label = new SettingsLabel (_("Timeout (secs)"));
            clear_clipboard_timeout = new Gtk.Entry ();
            clear_clipboard_timeout.input_purpose = Gtk.InputPurpose.DIGITS;
            clear_clipboard_timeout.text = settings.clear_clipboard_timeout.to_string ();
            clear_clipboard_timeout.activates_default = true;
            grid.attach (clear_clipboard_timeout_label, 0, 2, 1, 1);
            grid.attach (clear_clipboard_timeout, 1, 2, 1, 1);

            /* Autolock settings */
            var autolock_label = new SettingsLabel (_("Autolock after timeout"));
            autolock = new SettingsSwitch (_("autolock"));
            grid.attach (autolock_label, 0, 3, 1, 1);
            grid.attach (autolock, 1, 3, 1, 1);

            var autolock_timeout_label = new SettingsLabel (_("Timeout (secs)"));
            autolock_timeout = new Gtk.Entry ();
            autolock_timeout.input_purpose = Gtk.InputPurpose.DIGITS;
            autolock_timeout.text = settings.autolock_timeout.to_string ();
            autolock_timeout.activates_default = true;
            grid.attach (autolock_timeout_label, 0, 4, 1, 1);
            grid.attach (autolock_timeout, 1, 4, 1, 1);

            var close_button = add_button (_("Close"), Gtk.ResponseType.NONE);

            response.connect (()=> {
                destroy ();
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
                Settings.get_default ().schema.bind (setting, this, "active", SettingsBindFlags.DEFAULT);
            }
        }
    }
}
