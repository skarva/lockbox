conf_data = configuration_data()
conf_data.set_quoted('PROJECT_NAME', meson.project_name())
conf_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf_data.set_quoted('VERSION', meson.project_version())
conf_data.set_quoted('PREFIX', get_option('prefix'))
config_header = configure_file(
    input : 'config.vala.in',
    output : 'config.vala',
    configuration : conf_data
)

executable(meson.project_name(),
    'Application.vala',
    'MainWindow.vala',
    'Dialogs/PreferencesDialog.vala',
    'Dialogs/PasswordDialog.vala',
    'Interfaces/Password.vala',
    'Services/Settings.vala',
    'Widgets/PasswordListView.vala',
    'Widgets/PasswordListRow.vala',
    'Widgets/WelcomeScreen.vala',
    config_header,
    dependencies: dependencies,
    install: true
)
