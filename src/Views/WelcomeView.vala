/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 skarva llc <contact@skarva.tech>
 */

public class Hermetic.Views.WelcomeView : Gtk.Box {
    public signal void clicked_new_box ();
    public signal void clicked_load_box ();

    construct {
        var welcome = new Granite.Placeholder ("Hermetic") {
            description = "Your secrets. Sealed tight."
        };

        var new_button = welcome.append_button (
            new ThemedIcon ("office-database-new"),
            "Create a new sealed container",
            "Store your important data"
        );

        var load_button = welcome.append_button (
            new ThemedIcon ("document-import"),
            "Load an existing local sealed container",
            "Restore your important data"
        );

        append (welcome);

        new_button.clicked.connect (() => clicked_new_box ());
        load_button.clicked.connect (() => clicked_load_box ());
    }
}
