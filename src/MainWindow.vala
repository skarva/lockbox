/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 skarva llc <contact@skarva.tech>
 */

public class LockBox.MainWindow : Gtk.ApplicationWindow {
    private Gtk.SearchEntry search_entry { get; private set; }
    private Gtk.Stack stack { get; private set; }
    private ListStore secrets_liststore { get; private set; }

    public MainWindow (Gtk.Application application) {
        Object(application: application);
    }

    construct {
        icon_name = "com.github.skarva.lockbox";
        title = _("Lock Box");

        var start_window_controls = new Gtk.WindowControls (Gtk.PackType.START);

        search_entry = new Gtk.SearchEntry () {
                hexpand = true,
                placeholder_text = _("Search your Secrets"),
                valign = Gtk.Align.CENTER,
                margin_end = 12,
        };

        var mini_mode_button = new Gtk.Button.from_icon_name("media-playlist-shuffle-symbolic") {
            action_name = Application.ACTION_PREFIX + Application.ACTION_MINI,
            tooltip_text = _("Toggle Mini Mode")
        };

        var end_window_controls = new Gtk.WindowControls (Gtk.PackType.END) {
            halign = Gtk.Align.END
        };

        var welcome_placeholder = new LockBox.WelcomeView ();

        var empty_placeholder = new LockBox.EmptyListView ();

        var secrets_listbox = new Gtk.ListBox () {
            hexpand = true,
            vexpand = true
        };
        secrets_listbox.set_placeholder (empty_placeholder);

        secrets_liststore = new ListStore (typeof (SecretObject));
        secrets_listbox.bind_model (secrets_liststore, create_secret_row);

        var scrolled = new Gtk.ScrolledWindow () {
            child = secrets_listbox
        };

        stack = new Gtk.Stack ();
        stack.add_named (welcome_placeholder, "welcome");
        stack.add_named (scrolled, "secrets");

        welcome_placeholder.clicked_new_box.connect (create_secrets_list);
        welcome_placeholder.clicked_load_box.connect (load_secrets_list);

        var main_header = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        main_header.add_css_class ("titlebar");
        main_header.add_css_class (Granite.STYLE_CLASS_FLAT);
        main_header.append (start_window_controls);
        main_header.append (search_entry);
        main_header.append (mini_mode_button);
        main_header.append (end_window_controls);

        var main_layout = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_layout.append (main_header);
        main_layout.append (stack);

        var error_toast = new Granite.Toast ("");

        var main_overlay = new Gtk.Overlay () {
            child = main_layout
        };
        main_overlay.add_overlay (error_toast);

        var main_handle = new Gtk.WindowHandle () {
            child = main_overlay
        };

        child = main_handle;

        // We need to hide the title area for the split headerbar
        var null_title = new Gtk.Grid () {
            visible = false
        };
        set_titlebar (null_title);

        var gtk_settings = Gtk.Settings.get_default ();

        gtk_settings.gtk_icon_theme_name = "elementary";
        if (!(gtk_settings.gtk_theme_name.has_prefix ("io.elementary.stylesheet"))) {
            gtk_settings.gtk_theme_name = "io.elementary.stylesheet.strawberry";
        }

        var granite_settings = Granite.Settings.get_default ();
        gtk_settings.gtk_application_prefer_dark_theme = (
            granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK
        );

        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = (
                granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK
            );
        });
    }

    // TODO: This may need to either figure out type or have functions to create different secret types (note vs cred)
    private Gtk.Widget create_secret_row (GLib.Object object) {
        unowned var secret_object = (SecretObject) object;

        return new LockBox.SecureItem ();
    }

    private void create_secrets_list () {
        stack.set_visible_child_name ("secrets");
    }
    
    private void load_secrets_list () {
        stack.set_visible_child_name ("secrets");
    }
}
