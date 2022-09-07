/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 skarva llc <contact@skarva.tech>
 */

public class LockBox.MainWindow : Gtk.Window {
    private Gtk.ListBox secret_item_list;

    construct {
        var header = new Gtk.HeaderBar ();
        set_titlebar (header);

        secret_item_list = new Gtk.ListBox () {
            hexpand = true,
            vexpand = true
        };

        var test_item = new LockBox.SecureItem ();
        var test_item2 = new LockBox.SecureItem ();
        secret_item_list.append (test_item);
        secret_item_list.append (test_item2);

        var stack = new Gtk.Stack () {
            vexpand = true
        };

        var welcome_page = new LockBox.WelcomeView ();
        stack.add_titled (welcome_page, "Welcome", "Welcome");

        child = stack;
    }
}
