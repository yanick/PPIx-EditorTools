use Module::Build;

my $build = Module::Build->new(
    module_name        => 'PPIx::EditorTools',
    license            => 'perl',
    create_readme      => 1,
    create_makefile_pl => 'passthrough',
    requires           => {
        'perl' => '5.010',
        'PPI'  => 0,
        'Class::XSAccessor' => 0,
    },
    build_requires => { 'Test::Differences' => 0, },
);

$build->create_build_script;

