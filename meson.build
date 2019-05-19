project('com.github.raibtoffoletto.adstruo', 'vala','c')

i18n = import('i18n')
gnome = import('gnome')
gettext_name = meson.project_name()
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format(gettext_name), language:'c')

wingpanel_dep = dependency('wingpanel-2.0')
switchboard_dep = dependency('switchboard-2.0')

dependencies = [
    dependency('glib-2.0'),
    dependency('gio-2.0'),
    dependency('gobject-2.0'),
    dependency('gtk+-3.0'),
    dependency('granite'),
    dependency('libsoup-2.4'),
    dependency('json-glib-1.0'),
    switchboard_dep,
    wingpanel_dep
]

shared_module('adstruo-temps',
    'src/Temps.vala',
    dependencies: dependencies,
    install: true,
    install_dir : wingpanel_dep.get_pkgconfig_variable('indicatorsdir')
)

# shared_module(
#     meson.project_name(),
#     files,
#     dependencies: dependencies,
#     install: true,
#     install_dir : wingpanel_dep.get_pkgconfig_variable('indicatorsdir')
#)


shared_module('adstruo-plug',
    'src/Plug.vala',
    'src/Switchboard/SettingsTemps.vala',
    dependencies: dependencies,
    install: true,
    install_dir : join_paths(switchboard_dep.get_pkgconfig_variable('plugsdir'), 'personal')
)

subdir ('data')
subdir ('po')

meson.add_install_script('meson/post_install.py')
