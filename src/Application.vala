/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 skarva llc <contact@skarva.tech>
 */

public class LockBox.Application : Gtk.Application {
    public Application () {
        Object (
            application_id: "com.github.skarva.lockbox",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var main_window = new MainWindow () {
            title = _("Lock Box")
        };
        main_window.present ();
        
        add_window(main_window);
        
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();
        
        gtk_settings.gtk_application_prefer_dark_theme = (
            granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK
        );
        
        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = (
                granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK
            );
        });
    }

    public static int main (string[] args) {
        return new Application ().run (args);
    }
}
