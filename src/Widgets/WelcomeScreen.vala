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

namespace Lockbox.Widgets {
    public class WelcomeScreen : Granite.Widgets.Welcome {
        public signal void show_preferences ();
        public signal void create_login ();
        public signal void create_note ();

        public WelcomeScreen () {
            Object(
                title: _("Nothing to see here"),
                subtitle: _("Start storing your important info securely")
            );
        }

        construct {
            append ("preferences-desktop", _("Configure"), _("Customize your lock box"));
            append ("contact-new", _("Store Login"), _("Add website login details to your lock box"));
            append ("document-new", _("Store Note"), _("Add a new note to yourself to your lock box"));

            valign = Gtk.Align.FILL;
            halign = Gtk.Align.FILL;
            vexpand = true;

            activated.connect ((index) => {
                switch (index) {
                    case 0:
                        show_preferences ();
                        break;
                    case 1:
                        create_login ();
                        break;
                    case 2:
                        create_note ();
                        break;
                }
            });
        }
    }
} // Lockbox.Widgets
