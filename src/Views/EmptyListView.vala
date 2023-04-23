/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 skarva llc <contact@skarva.tech>
 */

public class LockBox.EmptyListView : Gtk.Box {
    public signal void clicked_new_login ();
    public signal void clicked_new_note ();

    construct {
        var welcome = new Granite.Placeholder ("Lock Box") {
            description = "Lock your credentials and secrets up tight."
        };

        var login_button = welcome.append_button (
            new ThemedIcon ("contact-new"),
            "Add new credentials",
            "Store login info for your sites"
        );

        var note_button = welcome.append_button (
            new ThemedIcon ("document-new"),
            "Add a new note",
            "Store sensitive info in a secured note"
        );

        append (welcome);

        login_button.clicked.connect (() => clicked_new_login ());
        note_button.clicked.connect (() => clicked_new_note ());
    }
}
