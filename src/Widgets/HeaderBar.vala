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

namespace Kipeltip.Widgets {
    private Gtk.Button return_button;
    private Gtk.Button add_button;
    private Gtk.ToggleButton find_button;
    private Gtk.MenuButton app_menu;

    public class HeaderBar : Gtk.HeaderBar {
        public HeaderBar () {
            Object (
                has_subtitle: false,
                show_close_button: true
            );
        }
        
        construct {
            return_button = new Gtk.Button.with_label (_("Close"));
            return_button.no_show_all = true;
            return_button.valign = Gtk.Align.CENTER;
            return_button.action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_CLOSE_COLLECTION;
            return_button.get_style_context ().add_class ("back-button");
        
            add_button = new Gtk.Button.from_icon_name ("list-add", Gtk.IconSize.LARGE_TOOLBAR);
            add_button.no_show_all = true;
            add_button.action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_ADD;
            add_button.tooltip_text = _("New site login");
            
            find_button = new Gtk.ToggleButton ();
            find_button.no_show_all = true;
            find_button.image = new Gtk.Image.from_icon_name ("edit-find", Gtk.IconSize.LARGE_TOOLBAR);
            find_button.tooltip_text = _("Find login");
            
            var preferences_menuitem = new Gtk.ModelButton ();
            preferences_menuitem.text = _("Preferences");
            preferences_menuitem.action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_PREFERENCES;
            
            var reset_menuitem = new Gtk.ModelButton ();
            reset_menuitem.text = _("Remove Collection");
            reset_menuitem.action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_REMOVE_COLLECTION;
            
            var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            
            var menu_grid = new Gtk.Grid ();
            menu_grid.row_spacing = 6;
            menu_grid.margin = 12;
            menu_grid.orientation = Gtk.Orientation.VERTICAL;
            menu_grid.attach (preferences_menuitem, 0, 0, 1, 1);
            menu_grid.attach (separator, 0, 1, 1, 1);
            menu_grid.attach (reset_menuitem, 0, 2, 1, 1);
            menu_grid.show_all ();
            
            var menu = new Gtk.PopoverMenu ();
            menu.add (menu_grid);
            
            app_menu = new Gtk.MenuButton ();
            app_menu.no_show_all = true;
            app_menu.image =  new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
            app_menu.tooltip_text = _("Menu");
            app_menu.popover = menu;
            
            pack_start (return_button);            
            pack_start (add_button);
            pack_end (app_menu);
            //pack_end (find_button);    
        }
        
        public void disable () {
            return_button.hide ();
            add_button.hide ();
            find_button.hide ();
            app_menu.hide ();
        }
        
        public void enable () {
            return_button.show ();
            add_button.show ();
            find_button.show ();
            app_menu.show ();
        }
    }
}
