/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 skarva llc <contact@skarva.tech>
 */

public class Hermetic.SecureItem : Gtk.ListBoxRow {
    construct {
        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);

        var icon = new Gtk.Image () {
            gicon = new ThemedIcon ("network-workgroup"),
            pixel_size = 24
        };

        var site_name = new Gtk.Label ("Test Site");

        box.append (icon);
        box.append (site_name);

        child = box;
    }
}
