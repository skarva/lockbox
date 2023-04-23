/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 skarva llc <contact@skarva.tech>
 */

public class LockBox.Application : Gtk.Application {
    public const string ACTION_PREFIX = "app.";
    public const string ACTION_MINI = "action-mini";

    private const ActionEntry[] ACTION_ENTRIES = {
        { ACTION_MINI, action_mini_toggle }
    };

    public Application () {
        Object (
            application_id: "com.github.skarva.lockbox",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        add_action_entries (ACTION_ENTRIES, this);

        ((SimpleAction) lookup_action (ACTION_MINI)).set_enabled (false);

        // TODO Initialize mini window

        var main_window = new MainWindow (this);
        main_window.present ();

        add_window(main_window);

        var settings = new Settings ("com.github.skarva.lockbox");
        settings.bind ("window-height", main_window, "default-height", SettingsBindFlags.DEFAULT);
        settings.bind ("window-width", main_window, "default-width", SettingsBindFlags.DEFAULT);

        if (settings.get_boolean ("window-maximized")) {
            main_window.maximize ();
        }

        settings.bind ("window-maximized", main_window, "maximized", SettingsBindFlags.SET);
    }

    protected override void startup () {
        base.startup ();

        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("/com/github/skarva/lockbox/Application.css");
        Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
    }

    private void action_mini_toggle () {
        // TODO Swap window modes and save settings
    }

    public static int main (string[] args) {
        return new Application ().run (args);
    }
}
