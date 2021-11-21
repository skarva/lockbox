/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 skarva llc <contact@skarva.tech>
 */

public class LockBox : Gtk.Application {
    public LockBox () {
        Object (
            application_id: "com.github.skarva.lockbox",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var main_window = new Gtk.ApplicationWindow (this) {
            default_height =  600,
            default_width = 600,
            title = "Lock Box"
        };

        var label = new Gtk.Label (_("Lock Box Coming Soon"));

        main_window.add (label);
        main_window.show_all ();
    }

    public static int main (string[] args) {
        return new LockBox ().run (args);
    }
}
