project(
    'com.github.skarva.hermetic',
    'vala', 'c',
    version: '8.0.0')

gnome = import('gnome')
i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())

dependencies = [
        dependency('gtk4'),
        dependency('granite-7')
]

gnome.post_install(glib_compile_schemas: true)

subdir('data')
subdir('po')
subdir('src')
