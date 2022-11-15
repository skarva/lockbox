/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 skarva llc <contact@skarva.tech>
 */

public class LockBox.MainWindow : Gtk.ApplicationWindow {
    public Gtk.SearchEntry search_entry { get; private set; }

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

        var scrolled = new Gtk.ScrolledWindow () {
            child = secrets_listbox
        };

        // TODO: Add leaflet to hold welcome placeholder and scroll windows, and hook up signals

        var main_header = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        main_header.add_css_class ("titlebar");
        main_header.add_css_class (Granite.STYLE_CLASS_FLAT);
        main_header.append (start_window_controls);
        main_header.append (search_entry);
        main_header.append (mini_mode_button);
        main_header.append (end_window_controls);

        var main_layout = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_layout.append (main_header);
        main_layout.append (scrolled);

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
}
