/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 skarva llc <contact@skarva.tech>
 */

public class LockBox.WelcomeView : Gtk.Box {
    construct {
        var welcome = new Granite.Placeholder ("Lock Box") {
            description = "Lock your credentials and secrets up tight."
        };

        var login_button = welcome.append_button (
            new ThemedIcon ("contact-new"),
            "Add new credentials",
            "Store a login and password"
        );

        var note_button = welcome.append_button (
            new ThemedIcon ("document-new"),
            "Add new secret note",
            "Store an important piece of information"
        );

        append (welcome);
    }
}
