project('com.github.raibtoffoletto.adstruo','c', 'vala')

#add_project_arguments(['--vapidir=' + join_paths(meson.source_root(), 'vapi')], language: 'vala')

#add_project_arguments(['-DGETTEXT_PACKAGE="wingpanel"', '-DG_LOG_DOMAIN="wingpanel"'], language: 'c')

#indicators_dir = join_paths(get_option('prefix'), get_libdir('option'), 'wingpanel')

shared_module('adstruo-temps',
    'src/Temps.vala',
    dependencies: [
        dependency('gtk+-3.0'),
        dependency('wingpanel-2.0')
    ],
    install: false
)
#usr/lib/x86_64-linux-gnu/wingpanel/libadnutus.so 


shared_module('adstruo-switchboard',
    'src/Switchboard.vala',
    dependencies:[
        dependency('gtk+-3.0'),
        dependency('switchboard-2.0')
    ],
    install: false,
)
#/usr/lib/x86_64-linux-gnu/switchboard/personal
