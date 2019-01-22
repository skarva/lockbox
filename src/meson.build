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
    'Dialogs/PreferencesDialog.vala',
    'Interfaces/Item.vala',
    'Interfaces/Login.vala',
    'Services/Collection.vala',
    'Services/Settings.vala',
    'Widgets/CollectionList.vala',
    'Widgets/CollectionListRow.vala',
    'Widgets/HeaderBar.vala',
    'Widgets/WelcomeScreen.vala',
    config_header,
    dependencies: dependencies,
    install: true
)
