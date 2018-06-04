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
        
        private Widgets.HeaderBar headerbar;
        private Gtk.Stack layout_stack;
        private Widgets.LoginList login_list;
        private Widgets.WelcomeScreen welcome;
        
        public static Gtk.Clipboard clipboard;
        
        public SimpleActionGroup actions { get; construct; }
        
        public const string ACTION_PREFIX = "kipeltip.";
        public const string ACTION_ADD = "action_add";
        public const string ACTION_PREFERENCES = "action_preferences";
        public const string ACTION_RESET = "action_reset";
        
        public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();
        
        public const ActionEntry[] action_entries = {
            { ACTION_ADD, action_add },
            { ACTION_PREFERENCES, action_preferences },
            { ACTION_RESET, action_reset }
        };

        public MainWindow (Kipeltip.Application app) {
            Object (
                application: app,
                app: app,
                icon_name: Constants.PROJECT_NAME,
                title: _("Kipeltip")
            );
        }

        construct {
            actions = new SimpleActionGroup ();
            actions.add_action_entries (action_entries, this);
            insert_action_group ("kipeltip", actions);
        
            foreach (var action in action_accelerators.get_keys ()) {
                app.set_accels_for_action (ACTION_PREFIX + action, action_accelerators[action].to_array ());
            }
        
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
            
            clipboard = Gtk.Clipboard.get_for_display (get_display (), Gdk.SELECTION_CLIPBOARD);
            
            action_accelerators.set (ACTION_ADD, "<Control>n");
            action_accelerators.set (ACTION_PREFERENCES, "<Control>p");

            /* Init Layout */
            headerbar = new Widgets.HeaderBar ();
            headerbar.title = title;
            set_titlebar (headerbar);
            headerbar.disable ();
            
            layout_stack = new Gtk.Stack ();
            layout_stack.transition_type = Gtk.StackTransitionType.UNDER_UP;
            add (layout_stack);

            // If settings aren't saved show welcome dialog, also disable headerbar
            welcome = new Widgets.WelcomeScreen (this);
            layout_stack.add_named (welcome, "welcome");

            welcome.setup_complete.connect (() => {
                layout_stack.visible_child_name = "login";
                headerbar.enable ();
            });

            login_list = new Widgets.LoginList ();
            layout_stack.add_named (login_list, "login");
            
            login_list.row_activated.connect (show_entry_details);
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
        
        private void action_add () {
            // TODO Show dialog for new login either direcly here or call it from LoginList
            var add_login_dialog = new Dialogs.AddLoginDialog (this);
            add_login_dialog.show_all ();
            
            add_login_dialog.present ();
        }
        
        private void action_preferences () {
            var preferences_dialog = new Dialogs.PreferencesDialog (this);
            preferences_dialog.show_all ();
            
            preferences_dialog.present ();
        }
        
        private void action_reset () {
            headerbar.disable ();
            login_list.clear ();
            layout_stack.visible_child_name = "welcome";
        }
        
        private void show_entry_details (Gtk.ListBoxRow row) {
            (row as Widgets.LoginListRow).show_details ();
        }
    }
}
