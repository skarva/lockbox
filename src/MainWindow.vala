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
    public class MainWindow : Gtk.ApplicationWindow {
        public weak Lockbox.Application app { get; construct; }

        private Widgets.HeaderBar headerbar;
        private Gtk.ListBox collection_list;
        private Gtk.Stack layout_stack;

        private string filter_keyword = "";

        private List<Secret.Item> removal_list;

        private Services.CollectionManager collection_manager;
        private Gtk.Clipboard clipboard;
        private uint clipboard_timer_id = 0;

        public SimpleActionGroup actions { get; construct; }

        public const string ACTION_PREFIX = "lockbox.";
        public const string ACTION_ADD_LOGIN = "action_add_login";
        public const string ACTION_ADD_NOTE = "action_add_note";
        public const string ACTION_SEARCH = "action_search";
        public const string ACTION_PREFERENCES = "action_preferences";
        public const string ACTION_UNDO = "action_undo";
        public const string ACTION_QUIT = "action_quit";

        public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();

        public const ActionEntry[] action_entries = {
            { ACTION_ADD_LOGIN, action_add_login },
            { ACTION_ADD_NOTE, action_add_note },
            { ACTION_SEARCH, action_search },
            { ACTION_PREFERENCES, action_preferences },
            { ACTION_UNDO, action_undo },
            { ACTION_QUIT, action_quit }
        };

        public MainWindow (Lockbox.Application app) {
            Object (
                application: app,
                app: app,
                icon_name: Constants.PROJECT_NAME
            );
        }

        static construct {
            action_accelerators.set (ACTION_ADD_LOGIN, "<Control>a");
            action_accelerators.set (ACTION_ADD_NOTE, "<Control>n");
            action_accelerators.set (ACTION_SEARCH, "<Control>f");
            action_accelerators.set (ACTION_UNDO, "<Control>z");
            action_accelerators.set (ACTION_QUIT, "<Control>q");
        }

        construct {
            /* Load up Secret Service and Collections */
            collection_manager = new Services.CollectionManager ();

            /* Set up actions and hotkeys */
            actions = new SimpleActionGroup ();
            actions.add_action_entries (action_entries, this);
            insert_action_group ("lockbox", actions);

            foreach (var action in action_accelerators.get_keys ()) {
                app.set_accels_for_action (ACTION_PREFIX + action, action_accelerators[action].to_array ());
            }

            /* Load State and Settings */
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

            Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = Services.Settings.get_default ().dark_theme;

            /* Init Clipboard */
            clipboard = Gtk.Clipboard.get_for_display (get_display (), Gdk.SELECTION_CLIPBOARD);

            /* Init Layout */
            headerbar = new Widgets.HeaderBar ();
            set_titlebar (headerbar);

            layout_stack = new Gtk.Stack ();
            add (layout_stack);

            var launch = new Widgets.LaunchScreen ();
            layout_stack.add_named (launch, "launch");

            var welcome = new Widgets.WelcomeScreen ();
            welcome.show_preferences.connect (action_preferences);
            welcome.create_login.connect (action_add_login);
            welcome.create_note.connect (action_add_note);
            layout_stack.add_named (welcome, "welcome");

            var scroll_window = new Gtk.ScrolledWindow (null, null);

            collection_list = new Gtk.ListBox ();
            collection_list.selection_mode = Gtk.SelectionMode.NONE;
            collection_list.set_filter_func (CollectionFilterFunc);
            set_sort_func (Services.Settings.get_default ().sort_by);
            scroll_window.add (collection_list);
            layout_stack.add_named (scroll_window, "collection");

            layout_stack.visible_child_name = "launch";

            /* Connect Signals */
            collection_manager.loaded.connect (() => {
                var items = collection_manager.get_items ();
                populate_list (items);
                if (items.length () > 0) {
                    layout_stack.visible_child_name = "collection";
                } else {
                    layout_stack.visible_child_name = "welcome";
                }
            });

            collection_manager.added.connect (add_item);

            headerbar.filter.connect((keyword) => {
                filter_keyword = keyword;
                collection_list.invalidate_filter ();
            });

            headerbar.sort.connect((sort_by) => {
                var settings = Services.Settings.get_default ();
                if (sort_by != settings.sort_by) {
                    settings.sort_by = sort_by;
                    settings.sort_desc = true;
                } else {
                    settings.sort_desc = !settings.sort_desc;
                }
                set_sort_func (sort_by);
            });

            action_search ();

            show_all ();
        }

        protected override bool delete_event (Gdk.EventAny event) {
            action_quit ();

            return false;
        }

        private void action_add_login () {
            var login_dialog = new Dialogs.LoginDialog (this);
            login_dialog.new_login.connect ((name, attributes, password) => {
                collection_manager.add_item(name, attributes, password,
                                            CollectionType.LOGIN);
                layout_stack.visible_child_name = "collection";
            });
            login_dialog.show_all ();

            login_dialog.present ();
        }

        private void action_add_note () {
            var note_dialog = new Dialogs.NoteDialog (this);
            note_dialog.new_note.connect ((name, attributes, content) => {
                collection_manager.add_item(name, attributes, content,
                                            CollectionType.NOTE);
                layout_stack.visible_child_name = "collection";
            });
            note_dialog.show_all ();

            note_dialog.present ();
        }

        private void action_search () {
            headerbar.search_entry.grab_focus ();
        }

        private void action_preferences () {
            var preferences_dialog = new Dialogs.PreferencesDialog (this);
            preferences_dialog.show_all ();

            preferences_dialog.present ();
        }

        private void action_undo () {
            if (removal_list.length () > 0) {
                var restored_item = removal_list.last ().data;
                removal_list.remove (restored_item);
                add_item (restored_item);
            }
        }

        private void action_quit () {
            collection_manager.remove_items (removal_list);
            collection_manager.close ();
            update_saved_state ();
            if (clipboard_timer_id > 0) {
                GLib.Source.remove (clipboard_timer_id);
                clipboard_timer_id = 0;
                clipboard.clear ();
            }
            destroy ();
        }

        private void update_saved_state () {
            var saved_state = Services.SavedState.get_default ();
            int window_width;
            int window_height;
            int window_x;
            int window_y;
            get_size (out window_width, out window_height);
            get_position (out window_x, out window_y);
            saved_state.window_width = window_width;
            saved_state.window_height = window_height;
            saved_state.window_x = window_x;
            saved_state.window_y = window_y;
            saved_state.maximized = is_maximized;
        }

        private void populate_list (List<Secret.Item> items) {
            foreach (var item in items) {
                if (Schemas.is_login (item) || Schemas.is_note (item)) {
                    add_item (item);
                } else {
                    critical ("Unknown Item type");
                }
            }
        }

        private void add_item (Secret.Item item) {
            var row = new Widgets.CollectionListRow (item);
            if (Schemas.is_login (item)) {
                row.copy_username.connect (copy_username);
                row.copy_password.connect (copy_password);
            }
            row.edit_entry.connect (edit_item);
            row.delete_entry.connect (remove_item);
            collection_list.add (row);
            collection_list.show_all ();
        }

        private void edit_item (Widgets.CollectionListRow row) {
            if (Schemas.is_login (row.item)) {
                var login_dialog = new Dialogs.LoginDialog (this);
                login_dialog.set_entries (row);
                login_dialog.show_all ();

                login_dialog.present ();
            } else if (Schemas.is_note (row.item)) {
                var note_dialog = new Dialogs.NoteDialog (this);
                note_dialog.set_entries (row);
                note_dialog.show_all ();

                note_dialog.present ();
            }
        }

        private void remove_item (Widgets.CollectionListRow row) {
            removal_list.append (row.item);
            collection_list.remove (row);
        }

        private void copy_username (Secret.Item item) {
            var username = item.attributes.get ("username");
            clipboard.set_text (username, -1);
            if (Services.Settings.get_default ().clear_clipboard) {
                reset_clipboard_timer ();
            }
        }

        private void copy_password (Secret.Item item) {
            item.load_secret.begin (new Cancellable (), (obj, res) => {
                var password = item.get_secret ().get_text ();
                clipboard.set_text (password, -1);
                if (Services.Settings.get_default ().clear_clipboard) {
                    reset_clipboard_timer ();
                }
            });
        }

        private bool clear_clipboard_timed_out () {
            if (Services.Settings.get_default ().clear_clipboard) {
                GLib.Source.remove (clipboard_timer_id);
                clipboard_timer_id = 0;
                clipboard.clear ();
            }
            return true;
        }

        private void reset_clipboard_timer () {
            if (clipboard_timer_id > 0) {
                GLib.Source.remove (clipboard_timer_id);
                clipboard_timer_id = 0;
            }
            clipboard_timer_id = GLib.Timeout.add_seconds (Services.Settings.get_default ().clear_clipboard_timeout,
                                                             clear_clipboard_timed_out);
        }

        private void set_sort_func (Services.Sort sort_by) {
            if (sort_by == Services.Sort.NAME) {
                collection_list.set_sort_func (CollectionSortNameFunc);
            } else if (sort_by == Services.Sort.CREATED) {
                collection_list.set_sort_func (CollectionSortDateFunc);
            }
            collection_list.invalidate_sort ();
        }

        private bool CollectionFilterFunc (Gtk.ListBoxRow row) {
            if (filter_keyword.length == 0) {
                return true;
            }

            var collection_row = row as Widgets.CollectionListRow;
            var label = collection_row.item.label;

            // Search using exact match (case-sensitive)
            if (label.contains (filter_keyword)) {
                return true;
            }

            // Search using case insensitivity
            if (label.ascii_down ().contains (filter_keyword.ascii_down ()))
            {
                return true;
            }

            return false;
        }

        private int CollectionSortNameFunc (Gtk.ListBoxRow row1, Gtk.ListBoxRow row2) {
            var collection_row1 = row1 as Widgets.CollectionListRow;
            var collection_row2 = row2 as Widgets.CollectionListRow;
            var desc = Services.Settings.get_default ().sort_desc ? 1 : -1;

            return collection_row1.item.label.ascii_casecmp (collection_row2.item.label) * desc;
        }

        private int CollectionSortDateFunc (Gtk.ListBoxRow row1, Gtk.ListBoxRow row2) {
            var collection_row1 = row1 as Widgets.CollectionListRow;
            var collection_row2 = row2 as Widgets.CollectionListRow;
            var desc = Services.Settings.get_default ().sort_desc ? 1 : -1;

            if (collection_row1.item.created < collection_row2.item.created) {
                return -1 * desc;
            } else if (collection_row1.item.created > collection_row2.item.created) {
                return 1 * desc;
            }

            return 0;
        }
    }
} // Lockbox
