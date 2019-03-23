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

namespace Lockbox.Services {
    public enum Sort {
        NAME,
        CREATED
    }

    public class SavedState : Granite.Services.Settings {
        public int window_width { get; set; }
        public int window_height { get; set; }
        public int window_x { get; set; }
        public int window_y { get; set; }
        public bool maximized { get; set; }

        public SavedState () {
            base (Constants.PROJECT_NAME + ".saved-state");
        }

        private static SavedState saved_state;
        public static unowned SavedState get_default () {
            if (saved_state == null) {
                saved_state = new SavedState ();
            }
            return saved_state;
        }
    }

    public class Settings : Granite.Services.Settings {
        public bool clear_clipboard { get; set; }
        public int clear_clipboard_timeout { get; set; }
        public bool dark_theme { get; set; }
        public Sort sort_by { get; set; }
        public bool sort_desc { get; set; }

        public Settings () {
            base (Constants.PROJECT_NAME + ".settings");
        }

        public override void verify (string key) {
            switch (key) {
                case "clear-clipboard":
                    Granite.Services.Logger.notification ("Changed clear clipboard setting");
                    break;
                case "dark-mode":
                    Granite.Services.Logger.notification ("Changed dark mode setting");
                    break;
            }
        }

        public static Settings settings;
        public static unowned Settings get_default () {
            if (settings == null) {
                settings = new Settings ();
            }
            return settings;
        }
    }
}
