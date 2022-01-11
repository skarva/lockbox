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

namespace Lockbox {
    public class Application : Gtk.Application {
        public static string app_cmd_name;
        public static GLib.Settings saved_state;
        public static GLib.Settings app_settings;

        construct {
            flags |= ApplicationFlags.HANDLES_OPEN;

            application_id = Constants.PROJECT_NAME;
        }

        static construct {
            saved_state = new GLib.Settings (Constants.PROJECT_NAME + ".saved-state");
            app_settings = new GLib.Settings (Constants.PROJECT_NAME + ".settings");
        }

        public Application () {
            Intl.setlocale (LocaleCategory.ALL, "");
            string langpack_dir = Path.build_filename (Constants.INSTALL_PREFIX, "share", "locale");
            Intl.bindtextdomain (Constants.GETTEXT_PACKAGE, langpack_dir);
            Intl.bind_textdomain_codeset (Constants.GETTEXT_PACKAGE, "UTF-8");
            Intl.textdomain (Constants.GETTEXT_PACKAGE);

            Granite.Services.Logger.initialize ("Lock Box");
            Granite.Services.Logger.DisplayLevel = Granite.Services.LogLevel.NOTIFY;
        }

        public static Application _instance = null;

        public static Application instance {
            get {
                if (_instance == null) {
                    _instance = new Application ();
                }
                return _instance;
            }
        }

        protected override void activate () {
            var window = new MainWindow (this);
            window.show_all ();
        }

        public static int main (string[] args) {
            Gtk.init (ref args);

            var css_provider = new Gtk.CssProvider ();
            css_provider.load_from_resource ("com/github/skarva/lockbox/Note.css");

            Gtk.StyleContext.add_provider_for_screen (
                Gdk.Screen.get_default (),
                css_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

            app_cmd_name = "Lockbox";
            Application app = Application.instance;
            return app.run (args);
        }
    }
} // Lockbox
