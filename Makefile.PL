# $Id$
use strict;
use warnings;
use inc::Module::Install 0.65;

name 'Mango';
license 'perl';
perl_version '5.008001';
all_from 'lib/Mango.pm';

requires 'Handel' => '0.99_18';
requires 'DBIx::Class' => '0.07999_02';
requires 'Class::Accessor::Grouped' => '0.03';
requires 'DateTime';
requires 'Error';
requires 'Locale::Maketext';
requires 'Scalar::Util';
requires 'Class::Inspector';
requires 'Catalyst' => '5.7007';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Plugin::Authentication' => '0.09999';
requires 'XML::Feed' => '0.12';
requires 'XML::Atom' => '0.25';
requires 'XML::RSS' => '1.22';
requires 'YAML';
catalyst;

build_requires 'Directory::Scratch';

tests('t/*.t t/*/*.t');
clean_files "t/var";

install_script glob('script/*.pl');
install_share;

eval {
    system 'pod2text lib/Mango.pm > README';
};

auto_install;
WriteAll;
