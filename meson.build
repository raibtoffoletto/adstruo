project('com.github.raibtoffoletto.adstruo','c', 'vala')

shared_module('adstruo-temps',
    'src/Temps.vala',
    dependencies: [
        dependency('gtk+-3.0'),
        dependency('wingpanel-2.0')
    ],
    install: false
)
#usr/lib/x86_64-linux-gnu/wingpanel/ 

shared_module('adstruo-plug',
    'src/Plug.vala',
    'src/Switchboard/SettingsPage.vala',
    'src/Switchboard/SimpleSettingsPage.vala',
    'src/Switchboard/SettingsTemps.vala',
    dependencies:[
        dependency('gtk+-3.0'),
        dependency('switchboard-2.0'),
        dependency('granite')
    ],
    install: false,
)
#/usr/lib/x86_64-linux-gnu/switchboard/personalssss
subdir ('data')

meson.add_install_script('meson/post_install.py')
