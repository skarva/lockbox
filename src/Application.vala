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

namespace Kipeltip {
    public class Application : Granite.Application {
        public static string app_cmd_name;

        construct {
            flags |= ApplicationFlags.HANDLES_OPEN;
            build_version = Constants.VERSION;

            program_name = app_cmd_name;
            exec_name = Constants.PROJECT_NAME;
            app_launcher = Constants.PROJECT_NAME + ".desktop";
            application_id = Constants.PROJECT_NAME;
        }

        public Application () {
            Intl.setlocale (LocaleCategory.ALL, "");
            string langpack_dir = Path.build_filename (Constants.INSTALL_PREFIX, "share", "locale");
            Intl.bindtextdomain (Constants.GETTEXT_PACKAGE, langpack_dir);
            Intl.bind_textdomain_codeset (Constants.GETTEXT_PACKAGE, "UTF-8");
            Intl.textdomain (Constants.GETTEXT_PACKAGE);

            Granite.Services.Logger.initialize ("Kipeltip");
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
            app_cmd_name = "Kipeltip";
            Application app = Application.instance;
            return app.run (args);
        }
    }
}
