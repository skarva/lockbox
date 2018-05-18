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
    public class MainWindow : Gtk.ApplicationWindow {
        public weak Kipeltip.Application app { get; construct; }
        private Gtk.Stack layout_stack;
        private Widgets.PasswordListView password_list;
        private Widgets.WelcomeScreen welcome;

        public MainWindow (Kipeltip.Application app) {
            Object (
                application: app,
                app: app,
                icon_name: Constants.PROJECT_NAME,
                title: _("Kipeltip")
            );
        }

        construct {
            var saved_state = SavedState.get_default ();
            set_default_size (saved_state.window_width, saved_state.window_height);
            if (saved_state.window_x == -1 || saved_state.window_y == -1) {
                window_position = Gtk.WindowPosition.CENTER;
            } else {
                move (saved_state.window_x, saved_state.window_y);
            }

            switch (saved_state.window_state) {
                case Kipeltip.WindowState.MAXIMIZED:
                    this.maximize ();
                    break;
                default:
                    break;
            }

            /* Init Layout */
            layout_stack = new Gtk.Stack ();
            layout_stack.transition_type = Gtk.StackTransitionType.UNDER_UP;
            add (layout_stack);

            // If settings aren't saved show welcome dialog
            welcome = new Widgets.WelcomeScreen (this);
            layout_stack.add_named (welcome, "welcome");

            welcome.setup_complete.connect (() => {
                layout_stack.visible_child_name = "passwords";
            });

            password_list = new Widgets.PasswordListView ();
            layout_stack.add_named (password_list, "passwords");
        }

        public override bool delete_event (Gdk.EventAny event) {
            var saved_state = SavedState.get_default ();
            int window_width;
            int window_height;
            get_size (out window_width, out window_height);
            saved_state.window_width = window_width;
            saved_state.window_height = window_height;
            if (is_maximized) {
                saved_state.window_state = Kipeltip.WindowState.MAXIMIZED;
            } else {
                saved_state.window_state = Kipeltip.WindowState.NORMAL;
            }

            return false;
        }
    }
}
