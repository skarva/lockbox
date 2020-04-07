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

            set_default_size (Application.saved_state.get_int ("window-width"), Application.saved_state.get_int ("window-height"));

            var window_x = Application.saved_state.get_int ("window-x");
            var window_y = Application.saved_state.get_int ("window-y");
            if (window_x == -1 || window_y == -1) {
                window_position = Gtk.WindowPosition.CENTER;
            } else {
                move (window_x, window_y);
            }

            if (Application.saved_state.get_boolean ("maximized")) {
                this.maximize ();
            }

            Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = Application.app_settings.get_boolean ("dark-theme");

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
            collection_list.activate_on_single_click = false;
            set_sort_func ((Services.Sort) Application.app_settings.get_enum ("sort-by"));
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
                if (sort_by != Application.app_settings.get_enum ("sort-by")) {
                    Application.app_settings.set_enum ("sort-by", sort_by);
                    Application.app_settings.set_boolean ("sort-desc", true);
                } else {
                    Application.app_settings.set_boolean ("sort-desc", !Application.app_settings.get_boolean ("sort-desc"));
                }
                set_sort_func (sort_by);
            });

            collection_list.row_activated.connect (open_url);

            action_search ();

            show_all ();
        }

        public override bool key_press_event (Gdk.EventKey event) {
            var focus_widget = get_focus ();
            if (focus_widget != null && focus_widget is Gtk.Editable) {
                return base.key_press_event(event);
            }

            var modifiers = Gtk.accelerator_get_default_mod_mask ();
            bool modifiers_active = (event.state & modifiers) != 0;

            if (!modifiers_active) {
                var typed_unichar = event.str.get_char ();

                if (typed_unichar.isalnum ()) {
                    action_search ();
                }
            }

            return base.key_press_event (event);
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
            int window_width;
            int window_height;
            int window_x;
            int window_y;
            get_size (out window_width, out window_height);
            get_position (out window_x, out window_y);
            Application.saved_state.set_int ("window-width", window_width);
            Application.saved_state.set_int ("window-height", window_height);
            Application.saved_state.set_int ("window-x", window_x);
            Application.saved_state.set_int ("window-y", window_y);
            Application.saved_state.set_boolean ("maximized", is_maximized);
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
            if (Application.app_settings.get_boolean ("clear-clipboard")) {
                reset_clipboard_timer ();
            }
        }

        private void copy_password (Secret.Item item) {
            item.load_secret.begin (new Cancellable (), (obj, res) => {
                var password = item.get_secret ().get_text ();
                clipboard.set_text (password, -1);
                if (Application.app_settings.get_boolean ("clear-clipboard")) {
                    reset_clipboard_timer ();
                }
            });
        }

        private void open_url (Gtk.ListBoxRow row) {
            var crow = row as Widgets.CollectionListRow;

            if (Schemas.is_login (crow.item)) {
                var item = crow.item;
                var uri = item.attributes.get ("uri");
                if (uri != null && uri.length > 0) {
                    try {
                        AppInfo.launch_default_for_uri (uri, null);
                    } catch (Error e) {
                        warning (e.message);
                    }
                }
            }
        }

        private bool clear_clipboard_timed_out () {
            if (Application.app_settings.get_boolean ("clear-clipboard")) {
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
            clipboard_timer_id = GLib.Timeout.add_seconds (Application.app_settings.get_int ("clear-clipboard-timeout"),
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
            var desc = Application.app_settings.get_boolean ("sort-desc") ? 1 : -1;

            return collection_row1.item.label.ascii_casecmp (collection_row2.item.label) * desc;
        }

        private int CollectionSortDateFunc (Gtk.ListBoxRow row1, Gtk.ListBoxRow row2) {
            var collection_row1 = row1 as Widgets.CollectionListRow;
            var collection_row2 = row2 as Widgets.CollectionListRow;
            var desc = Application.app_settings.get_boolean ("sort-desc") ? 1 : -1;

            if (collection_row1.item.created < collection_row2.item.created) {
                return -1 * desc;
            } else if (collection_row1.item.created > collection_row2.item.created) {
                return 1 * desc;
            }

            return 0;
        }
    }
} // Lockbox
