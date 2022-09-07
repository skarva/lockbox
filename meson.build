project(
    'com.github.skarva.lockbox',
    'vala', 'c',
    version: '7.0.0')

gnome = import('gnome')
i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

i18n.merge_file(
    input: 'data' / 'lockbox.desktop.in',
    output: meson.project_name() + '.desktop',
    po_dir: meson.source_root() / 'po',
    type: 'desktop',
    install: true,
    install_dir: get_option('datadir') / 'applications'
)

i18n.merge_file(
    input: 'data' / 'lockbox.appdata.xml.in',
    output: meson.project_name() + '.appdata.xml',
    po_dir: meson.source_root() / 'po',
    install: true,
    install_dir: get_option('datadir') / 'metainfo'
)

gresource_lockbox = gnome.compile_resources(
    'gresource_lockbox',
    join_paths('data', meson.project_name() + '.gresource.xml'),
    source_dir: 'data'
)

executable(
    meson.project_name(),
    'src' / 'Application.vala',
    'src' / 'MainWindow.vala',
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
