i18n.merge_file(
    input: join_paths(meson.project_name() + '.gschema.xml.in'),
    output: meson.project_name() + '.gschema.xml',
    po_dir: join_paths(meson.source_root(), 'po'),
    install: true,
    install_dir: join_paths(get_option ('datadir'), 'glib-2.0', 'schemas')
)

install_data(
    join_paths('icons', 'com.github.raibtoffoletto.adstruo.svg'),
    install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', 'scalable', 'apps')
)

install_data(
    join_paths('icons', 'com.github.raibtoffoletto.adstruo.temps.svg'),
    install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', 'scalable', 'status')
)

install_data(
    join_paths('icons', 'temperature.svg'),
    install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', 'scalable', 'status')
)
