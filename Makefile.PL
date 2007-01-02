use inc::Module::Install;

name 'Mango';
license 'perl';
all_from 'lib\Mango\Web.pm';

perl_version '5.008001';
requires 'Catalyst' => '5.7001';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'YAML';

catalyst;
tests('t/*/*.t');

install_script glob('script/*.pl');
auto_install;
WriteAll;
