public class LockBox.Widgets.SecureItem : Gtk.ListBoxRow {
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
