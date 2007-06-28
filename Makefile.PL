# $Id$
use strict;
use warnings;
use inc::Module::Install 0.65;

name 'Mango';
license 'perl';
perl_version '5.008001';
all_from 'lib/Mango.pm';

requires 'Handel' => '1.00001';
requires 'DBIx::Class' => '0.08002';
requires 'Class::Accessor::Grouped' => '0.06000';
requires 'Clone';
requires 'FormValidator::Simple' => '0.17';
requires 'CGI::FormBuilder';
requires 'File::ShareDir';
requires 'DateTime';
requires 'Error';
requires 'Locale::Maketext';
requires 'Scalar::Util';
requires 'Class::Inspector';
requires 'Path::Class';
requires 'I18N::LangTags';
requires 'I18N::LangTags::Detect';
requires 'MIME::Types';
requires 'Catalyst' => '5.7007';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Action::REST' => '0.40';
requires 'Catalyst::Plugin::Authentication' => '0.09999';
requires 'Catalyst::Component::ACCEPT_CONTEXT' => '0.03';
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
