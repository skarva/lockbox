project('com.github.skarva.kipeltip', 'vala', 'c', meson_version: '>= 0.43', version: '0.1')

i18n = import('i18n')

add_project_arguments([
        '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name())
    ],
    language: 'c',
)

dependencies = [
    dependency('granite'),
    meson.get_compiler('vala').find_library('posix'),
    meson.get_compiler('c').find_library('m', required : false)
]

subdir('data')
subdir('src')
subdir('po')
