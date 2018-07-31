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
        private Widgets.AuthenticateForm auth_form;
        
        private Services.Collection current_collection;
        
        private Gtk.Clipboard clipboard;
        
        public SimpleActionGroup actions { get; construct; }
        
        public const string ACTION_PREFIX = "kipeltip.";
        public const string ACTION_ADD = "action_add";
        public const string ACTION_PREFERENCES = "action_preferences";
        public const string ACTION_CLOSE_COLLECTION = "action_close_collection";
        public const string ACTION_REMOVE_COLLECTION = "action_remove_collection";
        
        public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();
        
        public const ActionEntry[] action_entries = {
            { ACTION_ADD, action_add },
            { ACTION_PREFERENCES, action_preferences },
            { ACTION_CLOSE_COLLECTION, action_close_collection },
            { ACTION_REMOVE_COLLECTION, action_remove_collection }
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
            current_collection = new Services.Collection ();
        
            actions = new SimpleActionGroup ();
            actions.add_action_entries (action_entries, this);
            insert_action_group ("kipeltip", actions);
        
            foreach (var action in action_accelerators.get_keys ()) {
                app.set_accels_for_action (ACTION_PREFIX + action, action_accelerators[action].to_array ());
            }
        
            var saved_state = Services.SavedState.get_default ();
            set_default_size (saved_state.window_width, saved_state.window_height);
            if (saved_state.window_x == -1 || saved_state.window_y == -1) {
                window_position = Gtk.WindowPosition.CENTER;
            } else {
                move (saved_state.window_x, saved_state.window_y);
            }

            if (saved_state.maximized) {
                this.maximize ();
            }
            
            clipboard = Gtk.Clipboard.get_for_display (get_display (), Gdk.SELECTION_CLIPBOARD);

            /* Init Layout */
            headerbar = new Widgets.HeaderBar ();
            headerbar.title = title;
            set_titlebar (headerbar);
            
            layout_stack = new Gtk.Stack ();
            layout_stack.transition_type = Gtk.StackTransitionType.UNDER_UP;
            add (layout_stack);

            welcome = new Widgets.WelcomeScreen (this);
            layout_stack.add_named (welcome, "welcome");

            welcome.setup_complete.connect (show_auth_form);
            
            login_list = new Widgets.LoginList ();
            login_list.copy_username.connect (copy_username);
            login_list.copy_password.connect (copy_password);
            login_list.edit_entry.connect (edit_entry);
            layout_stack.add_named (login_list, "login");
            
            auth_form = new Widgets.AuthenticateForm (current_collection);
            layout_stack.add_named (auth_form, "auth");
            
            auth_form.success.connect (() => {
                headerbar.subtitle = current_collection.name;
                login_list.populate (current_collection.retrieve_list ());
                if (Services.Settings.get_default ().autolock) {
                    GLib.Timeout.add_seconds (Services.Settings.get_default ().autolock_timeout, autolock_timed_out);
                }
                show_login_list ();
            });
            
            show_all ();
        }
        
        public void init_window () {
            if (get_num_collections () == 0) {
                show_welcome_screen ();
            } else {
                show_auth_form ();
            }
        }
        
        protected override bool delete_event (Gdk.EventAny event) {
            remove_entries ();
            update_saved_state ();

            return false;
        }
        
        private void action_add () {
            var add_login_dialog = new Dialogs.AddLoginDialog (this);
            add_login_dialog.new_login.connect (update_login_list);
            add_login_dialog.show_all ();
            
            add_login_dialog.present ();
        }
        
        private void action_preferences () {
            var preferences_dialog = new Dialogs.PreferencesDialog (this);
            preferences_dialog.show_all ();
            
            preferences_dialog.present ();
        }
        
        private void action_close_collection () {
            show_auth_form ();
            remove_entries ();
        }
        
        private void action_remove_collection () {
            try {
                var file = Granite.Services.Paths.user_data_folder.get_child (current_collection.name + ".db");
                current_collection = new Services.Collection ();
                file.delete ();
            } catch (Error e) {
                critical (e.message);
            }
            
            if (get_num_collections () == 0) {
                show_welcome_screen ();
            } else {
                show_auth_form ();
            }
        }
                
        private void show_welcome_screen () {
            layout_stack.visible_child = welcome;
            headerbar.subtitle = "";
            headerbar.disable ();
        }
        
        private void show_auth_form () {
            layout_stack.visible_child = auth_form;
            headerbar.subtitle = "";
            headerbar.disable ();
        }
        
        private void show_login_list () {
            layout_stack.visible_child = login_list;
            headerbar.enable ();
        }
        
        private void update_login (Interfaces.Login login) {
            current_collection.update_login (login);
        }

        private void update_login_list (Interfaces.Login new_entry) {
            int id = current_collection.add_login_entry (new_entry);
            if (id == -1) {
                var alert = new Granite.MessageDialog.with_image_from_icon_name (
                    _("Failed to add login to collection!"),
                    _("An error occured while trying to add a new entry to the collection.\n
                    If this issue persists, contact the developers"),
                    "dialog-error",
                    Gtk.ButtonsType.CLOSE
                );
                alert.run ();
                alert.destroy ();
            } else {
                new_entry.id = id;
                login_list.add_login (new_entry);
            }
        }
        
        private int get_num_collections () {
            int results = 0;
            try {
                var data_dir = Granite.Services.Paths.user_data_folder;
                FileEnumerator enumerator = data_dir.enumerate_children ("standard::*", FileQueryInfoFlags.NOFOLLOW_SYMLINKS, null);
                
                FileInfo info = null;
                while ((info = enumerator.next_file ()) != null) {
                    if (info.get_file_type () == FileType.REGULAR && info.get_name ().contains (".db")) {
                        results++;
                    }
                }
            } catch (Error e) {
                critical (e.message);
            }
            return results; 
        }
        
        private void update_saved_state () {
            var saved_state = Services.SavedState.get_default ();
            int window_width;
            int window_height;
            get_size (out window_width, out window_height);
            saved_state.window_width = window_width;
            saved_state.window_height = window_height;
            saved_state.maximized = is_maximized;
        }
        
        private void remove_entries () {
            foreach (var login_id in login_list.removal_list) {
                current_collection.remove_login_entry (login_id);
            }
        }
        
        private void copy_username (int id) {
            var username = current_collection.retrieve_username (id);
            clipboard.set_text (username, -1);
            if (Services.Settings.get_default ().clear_clipboard) {
                GLib.Timeout.add_seconds (Services.Settings.get_default ().clear_clipboard_timeout, clear_clipboard_timed_out);
            }
        }
        
        private void copy_password (int id) {
            var password = current_collection.retrieve_password (id);
            clipboard.set_text (password, -1);
            if (Services.Settings.get_default ().clear_clipboard) {
                GLib.Timeout.add_seconds (Services.Settings.get_default ().clear_clipboard_timeout, clear_clipboard_timed_out);
            }
        }
        
        private void edit_entry (int id) {
            var login = current_collection.retrieve_login (id);
            var edit_login_dialog = new Dialogs.EditLoginDialog (this, login);
            edit_login_dialog.update_login.connect (update_login);
            edit_login_dialog.show_all ();
            
            edit_login_dialog.present ();
        }
        
        private bool autolock_timed_out () {
            if (Services.Settings.get_default ().autolock) {
                action_close_collection ();
            }
            return true;
        }
        
        private bool clear_clipboard_timed_out () {
            if (Services.Settings.get_default ().clear_clipboard) {
                clipboard.clear ();
            }
            return true;
        }
    }
}
