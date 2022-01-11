public class MainWindow : Gtk.Window {
    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            icon_name: "com.github.skarva.lockbox",
            title: _("Lock Box"),
        );
    }

    construct {
        var header = new Gtk.HeaderBar ();
        header.show_close_button = true;

        var label = new Gtk.Label (_("Lock Box Coming Soon"));

        set_titlebar (header);
        add (label);
    }
}
