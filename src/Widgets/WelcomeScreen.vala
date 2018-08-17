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
    public class WelcomeScreen : Granite.Widgets.Welcome {
        public unowned Kipeltip.MainWindow window { get; construct; }
        private Kipeltip.Dialogs.PreferencesDialog preferences_dialog;

        public signal void setup_complete ();

        public WelcomeScreen (Kipeltip.MainWindow window) {
            Object(
                window: window,
                title: _("Lock it up tight"),
                subtitle: _("Setup your security to start storing your passwords")
            );
        }

        construct {
            valign = Gtk.Align.FILL;
            halign = Gtk.Align.FILL;
            vexpand = true;
            append ("preferences-desktop", _("Pick your preferences"),
                _("Customize features such as clipboard clearing and autolocking."));
            append ("security-high", _("Create a new collection"),
                _("The collection is where you will keep all your passwords safe."));
            set_item_sensitivity (1, false);

            activated.connect ((index) => {
                switch (index) {
                    case 0:
                        preferences_dialog = new Kipeltip.Dialogs.PreferencesDialog (window);
                        preferences_dialog.show_all ();
                        set_item_sensitivity (1, true);
                        break;
                    case 1:
                        setup_complete ();
                        break;
                }
            });
        }
    }
}
