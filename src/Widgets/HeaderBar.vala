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
    public class HeaderBar : Gtk.HeaderBar {
        public Gtk.SearchEntry search_entry { get; private set; }

        public signal void filter(string keyword);
        public signal void sort(Lockbox.Sort sort_by);

        public HeaderBar () {
            Object (
                has_subtitle: false,
                show_close_button: true
            );
        }

        construct {
            /* Add menu and options */
            var add_login_menuitem = new Gtk.ModelButton ();
            add_login_menuitem.text = _("Add New Login");
            add_login_menuitem.action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_ADD_LOGIN;

            var add_note_menuitem = new Gtk.ModelButton ();
            add_note_menuitem.text = _("Add Secure Note");
            add_note_menuitem.action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_ADD_NOTE;

            var add_menu_grid = new Gtk.Grid ();
            add_menu_grid.row_spacing = 6;
            add_menu_grid.margin_top = 3;
            add_menu_grid.margin_bottom = 3;
            add_menu_grid.orientation = Gtk.Orientation.VERTICAL;
            add_menu_grid.attach (add_login_menuitem, 0, 0, 1, 1);
            add_menu_grid.attach (add_note_menuitem, 0, 1, 1, 1);
            add_menu_grid.show_all ();

            var add_menu = new Gtk.PopoverMenu ();
            add_menu.add (add_menu_grid);

            var add_button = new Gtk.MenuButton ();
            add_button.image = new Gtk.Button.from_icon_name ("insert-object", Gtk.IconSize.LARGE_TOOLBAR);
            add_button.tooltip_text = _("Add Login or Note");
            add_button.popover = add_menu;

            /* Search entry */
            search_entry = new Gtk.SearchEntry ();
            search_entry.hexpand = true;
            search_entry.valign = Gtk.Align.CENTER;
            search_entry.placeholder_text = _("Search for sites and notes (Ctrl+F)...");
            search_entry.search_changed.connect (() => {
                filter(search_entry.text.strip ());
            });

            /* App menu and options */
            var preferences_menuitem = new Gtk.ModelButton ();
            preferences_menuitem.text = _("Preferences");
            preferences_menuitem.action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_PREFERENCES;

            var sort_by_name_menuitem = new Gtk.ModelButton ();
            sort_by_name_menuitem.text = _("Sort by Name");
            sort_by_name_menuitem.clicked.connect (() => {
                sort(Lockbox.Sort.NAME);
            });

            var sort_by_created_menuitem = new Gtk.ModelButton ();
            sort_by_created_menuitem.text = _("Sort by Created Date");
            sort_by_created_menuitem.clicked.connect (() => {
                sort(Lockbox.Sort.CREATED);
            });

            var menu_grid = new Gtk.Grid ();
            menu_grid.row_spacing = 6;
            menu_grid.margin_top = 3;
            menu_grid.margin_bottom = 3;
            menu_grid.orientation = Gtk.Orientation.VERTICAL;
            menu_grid.attach (preferences_menuitem, 0, 0, 1, 1);
            menu_grid.attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 0, 1, 1, 1);
            menu_grid.attach (sort_by_name_menuitem, 0, 2, 1, 1);
            menu_grid.attach (sort_by_created_menuitem, 0, 3, 1, 1);
            menu_grid.show_all ();

            var menu = new Gtk.PopoverMenu ();
            menu.add (menu_grid);

            var app_menu = new Gtk.MenuButton ();
            app_menu.image =  new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
            app_menu.tooltip_text = _("Menu");
            app_menu.valign = Gtk.Align.CENTER;
            app_menu.popover = menu;

            set_custom_title (search_entry);

            pack_start (add_button);
            pack_start (new Gtk.Separator (Gtk.Orientation.VERTICAL));
            pack_end (app_menu);
            pack_end (new Gtk.Separator (Gtk.Orientation.VERTICAL));
        }
    }
} // Lockbox.Widgets
