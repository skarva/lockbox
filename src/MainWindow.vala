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
        public const string ACTION_PREFIX = "lockbox.";
        public const string ACTION_ADD_LOGIN = "action_add_login"; // ctrl + n
        public const string ACTION_ADD_NOTE = "action_add_note"; // ctrl + m
        public const string ACTION_EDIT_ITEM = "action_edit_item"; // ctrl + e
        public const string ACTION_REMOVE_ITEM = "action_remove_item"; // ctrl + r
        public const string ACTION_COPY_USERNAME = "action_copy_username"; // ctrl + u
        public const string ACTION_COPY_PASSWORD = "action_copy_password"; // ctrl + p
        public const string ACTION_TOGGLE_DARK_MODE = "action_toggle_dark_mode"; // ctrl + ~
        public const string ACTION_SYNC = "action_sync"; // ctrl + s
        public const string ACTION_SEARCH = "action_search"; // ctrl + f
        public const string ACTION_PREFERENCES = "action_preferences";
        public const string ACTION_QUIT = "action_quit"; // ctrl + q

        public const ActionEntry[] action_entries = {
            { ACTION_ADD_LOGIN, action_add_login },
            { ACTION_ADD_NOTE, action_add_note },
            { ACTION_SEARCH, action_search },
            { ACTION_PREFERENCES, action_preferences },
            { ACTION_QUIT, action_quit }
        };


        public weak Lockbox.Application app { get; construct; }

        public SimpleActionGroup actions { get; construct; }

        public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();


        private Widgets.HeaderBar headerbar;
        private Widgets.CollectionList list;
        private Gtk.Stack layout_stack;

        public string filter_keyword = "";

        private Services.CollectionManager manager;
        private Gtk.Clipboard clipboard;
        private uint clipboard_timer_id = 0;
        private uint auto_reload_timer_id = 0;

        public MainWindow (Lockbox.Application app) {
            Object (
                application: app,
                app: app,
                icon_name: Constants.PROJECT_NAME
            );
        }

        static construct {
            action_accelerators.set (ACTION_ADD_LOGIN, "<Control>n");
            action_accelerators.set (ACTION_ADD_NOTE, "<Control>m");
            action_accelerators.set (ACTION_SEARCH, "<Control>f");
            action_accelerators.set (ACTION_QUIT, "<Control>q");
        }

        construct {
            /* Load up Secret Service and Collections */
            manager = new Services.CollectionManager ();

            /* Set up actions and hotkeys */
            actions = new SimpleActionGroup ();
            actions.add_action_entries (action_entries, this);
            insert_action_group ("lockbox", actions);

            foreach (var action in action_accelerators.get_keys ()) {
                app.set_accels_for_action (ACTION_PREFIX + action, action_accelerators[action].to_array ());
            }

            var rect = Gdk.Rectangle ();
            Application.saved_state.get ("window-size", "(ii)", out rect.width, out rect.height);
            set_default_size (rect.width, rect.height);

            if (Application.saved_state.get_boolean ("maximized")) {
                this.maximize ();
            } else {
                Application.saved_state.get ("window-position", "(ii)", out rect.x, out rect.y);
                if (rect.x != -1 || rect.y != -1) {
                    move (rect.x, rect.y);
                }
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

            list = new Widgets.CollectionList (this);
            list.selection_mode = Gtk.SelectionMode.NONE;
            list.activate_on_single_click = false;
            set_sort_func ((Lockbox.Sort) Application.app_settings.get_enum ("sort-by"));
            scroll_window.add (list);
            layout_stack.add_named (scroll_window, "collection");

            /* Connect Signals */
            manager.search_results.connect (add_item);

            headerbar.filter.connect((keyword) => {
                filter_keyword = keyword;
                list.invalidate_filter ();
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

            list.row_activated.connect (open_url);

            action_search ();

            if (Application.app_settings.get_boolean ("auto-reload")) {
                reset_auto_reload_timer ();
            }

            show_all ();
        }

        public void add_item (List<Secret.Item> items){
            foreach (var item in items) {
                list.add_row (item);
            }
            if (list.size () == 0) {
                layout_stack.visible_child_name = "welcome";
            } else {
                layout_stack.visible_child_name = "collection";
            }
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
                manager.store(Schemas.epiphany (), attributes,
                                            name, password);
                layout_stack.visible_child_name = "collection";
            });
            login_dialog.show_all ();

            login_dialog.present ();
        }

        private void action_add_note () {
            var note_dialog = new Dialogs.NoteDialog (this);
            note_dialog.new_note.connect ((name, attributes, content) => {
                manager.store(Schemas.note (), attributes,
                                            name, content);
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

        private void action_quit () {
            // manager.remove_items (removal_list);
            // manager.close ();
            update_saved_state ();

            if (clipboard_timer_id > 0) {
                GLib.Source.remove (clipboard_timer_id);
                clipboard_timer_id = 0;
                clipboard.clear ();
            }

            if (auto_reload_timer_id > 0) {
                GLib.Source.remove (auto_reload_timer_id);
                auto_reload_timer_id = 0;
            }

            destroy ();
        }

        public void refresh_list () {
            /* Need to load for each type of collection
               item supported (ie Login, Note, etc) */
            manager.search (Schemas.epiphany (), Secret.attributes_build(Schemas.epiphany (), null));
        }

        private void update_saved_state () {
            int width, height, x, y;

            get_size (out width, out height);
            get_position (out x, out y);
            Application.saved_state.set ("window-size", "(ii)", width, height);
            Application.saved_state.set ("window-position", "(ii)", x, y);
            Application.saved_state.set_boolean ("maximized", is_maximized);
        }

        public void copy_username (Secret.Item item) {
            var username = item.attributes.get ("username");
            clipboard.set_text (username, -1);

                if (Application.app_settings.get_boolean ("clear-clipboard")) {
                reset_clipboard_timer ();
            }
        }

        public void copy_password (Secret.Item item) {
            item.load_secret.begin (new Cancellable (), (obj, res) => {
                var password = item.get_secret ().get_text ();
                clipboard.set_text (password, -1);

                if (Application.app_settings.get_boolean ("clear-clipboard")) {
                    reset_clipboard_timer ();
                }
            });
        }

        public void open_url (Gtk.ListBoxRow row) {
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
                clipboard.clear ();
            }

            GLib.Source.remove (clipboard_timer_id);
            clipboard_timer_id = 0;

            return true;
        }

        private void reset_clipboard_timer () {
            if (clipboard_timer_id != 0) {
                GLib.Source.remove (clipboard_timer_id);
                clipboard_timer_id = 0;
            }

            clipboard_timer_id = GLib.Timeout.add_seconds (Application.app_settings.get_int ("clear-clipboard-timeout"),
                                                             clear_clipboard_timed_out);
        }

        private bool auto_reload_timed_out (){
            if (Application.app_settings.get_boolean ("auto-reload")) {
                // Reload list
            }

            GLib.Source.remove (auto_reload_timer_id);
            auto_reload_timer_id = 0;

            return true;
        }

        private void reset_auto_reload_timer () {
            if (auto_reload_timer_id != 0) {
                GLib.Source.remove (auto_reload_timer_id);
                auto_reload_timer_id = 0;
            }

            auto_reload_timer_id = GLib.Timeout.add_seconds (Application.app_settings.get_int ("auto-reload-timeout"),
                                                             auto_reload_timed_out);
        }

        private void set_sort_func (Lockbox.Sort sort_by) {
            if (sort_by == Lockbox.Sort.NAME) {
                list.set_sort_func (list.sort_by_name);
            } else if (sort_by == Lockbox.Sort.CREATED) {
                list.set_sort_func (list.sort_by_date);
            }

            list.invalidate_sort ();
        }
    }
} // Lockbox
