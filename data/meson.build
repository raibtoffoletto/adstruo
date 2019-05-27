i18n.merge_file(
    input: join_paths(meson.project_name() + '.gschema.xml.in'),
    output: meson.project_name() + '.gschema.xml',
    po_dir: join_paths(meson.source_root(), 'po'),
    install: true,
    install_dir: join_paths(get_option ('datadir'), 'glib-2.0', 'schemas')
)

i18n.merge_file(
    input: join_paths(meson.project_name() + '.appdata.xml.in'),
    output: meson.project_name() + '.appdata.xml',
    po_dir: join_paths(meson.source_root(), 'po'),
    install: true,
    install_dir: join_paths(get_option('datadir'), 'metainfo')
)

install_data(
    'adstruo.svg',
    install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', 'scalable', 'apps')
)


extra_icons = ['termometer',
            'weather-temperature-max',
            'weather-temperature-min']

foreach i : extra_icons
    install_data(
        join_paths('icons', i + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', 'scalable', 'status')
    )

    install_data(
        join_paths('icons', i + '-symbolic.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', 'scalable', 'status')
    )
endforeach
