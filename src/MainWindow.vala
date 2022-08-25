public class LockBox.MainWindow : Gtk.Window {
    private Gtk.ListBox secret_item_list;

    construct {
        var header = new Gtk.HeaderBar ();
        set_titlebar (header);

        secret_item_list = new Gtk.ListBox () {
            hexpand = true,
            vexpand = true
        };
        
        var test_item = new LockBox.Widgets.SecureItem ();
        var test_item2 = new LockBox.Widgets.SecureItem ();
        secret_item_list.append (test_item);
        secret_item_list.append (test_item2);
        
        child = secret_item_list;
    }
}
