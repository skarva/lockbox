project(
    'com.github.skarva.lockbox',
    'vala', 'c',
    version: '7.0.0')

gnome = import('gnome')
i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())

i18n.merge_file(
    input: 'data' / 'lockbox.desktop.in',
    output: meson.project_name() + '.desktop',
    po_dir: meson.source_root() / 'po',
    type: 'desktop',
    install: true,
    install_dir: get_option('datadir') / 'applications'
)

i18n.merge_file(
    input: 'data' / 'lockbox.metainfo.xml.in',
    output: meson.project_name() + '.metainfo.xml',
    po_dir: meson.source_root() / 'po',
    install: true,
    install_dir: get_option('datadir') / 'metainfo'
)

gresource_lockbox = gnome.compile_resources(
    'gresource_lockbox',
    join_paths('data' / 'lockbox.gresource.xml'),
    source_dir: 'data'
)

executable(
    meson.project_name(),
    'src' / 'Application.vala',
    'src' / 'MainWindow.vala',
    'src' / 'SecretObject.vala',
    'src' / 'CredentialObject.vala',
    'src/Dialogs' / 'NewLocalDialog.vala',
    'src/Dialogs' / 'LoadLocalDialog.vala',
    'src/Views' / 'EmptyListView.vala',
    'src/Views' / 'WelcomeView.vala',
    'src/Widgets' / 'SecureItem.vala',
    gresource_lockbox,
    dependencies: [
        dependency('gtk4'),
        dependency('granite-7')
    ],
    install: true
)

subdir('po')

icon_sizes = ['16', '24', '32', '48', '64', '128']

foreach i: icon_sizes
    install_data(
        'data' / i + '.svg',
        install_dir: get_option('datadir') / 'icons' / 'hicolor' / i + 'x' + i / 'apps',
        rename: meson.project_name() + '.svg'
    )
    install_data(
        'data' / i + '.svg',
        install_dir: get_option('datadir') / 'icons' / 'hicolor' / i + 'x' + i / 'apps',
        rename: meson.project_name() + '.svg'
    )
endforeach

install_data (
    'data' / 'lockbox.gschema.xml',
    install_dir: get_option('datadir') / 'glib-2.0' / 'schemas',
    rename: meson.project_name() + '.gschema.xml'
)

meson.add_install_script('meson/post_install.py')
