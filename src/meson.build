conf_data = configuration_data()
conf_data.set_quoted('PROJECT_NAME', meson.project_name())
conf_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf_data.set_quoted('VERSION', meson.project_version())
conf_data.set_quoted('PREFIX', get_option('prefix'))
conf_data.set_quoted('DATADIR', join_paths(get_option('prefix'), get_option('datadir')))
config_header = configure_file(
    input : 'config.vala.in',
    output : 'config.vala',
    configuration : conf_data
)

executable(meson.project_name(),
    'Application.vala',
    'MainWindow.vala',
    'Dialogs/LoginDialog.vala',
    'Dialogs/NoteDialog.vala',
    'Dialogs/PreferencesDialog.vala',
    'Schemas/Login.vala',
    'Schemas/Note.vala',
    'Services/Collection.vala',
    'Services/Settings.vala',
    'Widgets/CollectionListRow.vala',
    'Widgets/HeaderBar.vala',
    'Widgets/LaunchScreen.vala',
    'Widgets/WelcomeScreen.vala',
    config_header,
    resources,
    dependencies: dependencies,
    install: true
)
