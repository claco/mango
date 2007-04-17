use inc::Module::Install;

name 'Mango';
license 'perl';
all_from 'lib\Mango.pm';

perl_version '5.008001';
requires 'Handel' => '1.00';
requires 'DBIx::Class' => '0.08';
requires 'Class::Accessor::Grouped' => '0.03';
requires 'DateTime';
requires 'Error';
requires 'Locale::Maketext';
requires 'Scalar::Util';
requires 'Class::Inspector';
#requires 'Catalyst' => '5.7007';
#requires 'Catalyst::Plugin::ConfigLoader';
#requires 'Catalyst::Plugin::Static::Simple';
#requires 'Catalyst::Action::RenderView';
#requires 'YAML';
#catalyst;

tests('t/*.t t/*/*.t');
clean_files "t/var";

install_script glob('script/*.pl');

auto_install;
WriteAll;
