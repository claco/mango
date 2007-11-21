# $Id$
use strict;
use warnings;
use inc::Module::Install 0.65;
use File::Spec;

name 'Mango';
license 'perl';
perl_version '5.008001';
all_from 'lib/Mango.pm';

requires 'Handel' => '1.00001';
requires 'DBIx::Class' => '0.08002';
requires 'Class::Accessor::Grouped' => '0.06000';
requires 'Clone' => '0.27';
requires 'FormValidator::Simple' => '0.17';
requires 'CGI::FormBuilder';
requires 'File::ShareDir';
requires 'DateTime';
requires 'Error';
requires 'Locale::Maketext';
requires 'Scalar::Util';
requires 'Set::Scalar';
requires 'Class::Inspector';
requires 'Path::Class';
requires 'I18N::LangTags';
requires 'I18N::LangTags::Detect';
requires 'MIME::Types';
requires 'Module::Starter' => '1.42';
requires 'Catalyst::Runtime' => '5.7011';
requires 'Catalyst::Devel' => '1.02';
requires 'Catalyst::Plugin::Cache';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Action::REST' => '0.40';
requires 'Catalyst::Plugin::Authentication' => '0.09999';
requires 'Catalyst::Plugin::Authentication::Credential::HTTP';
requires 'Catalyst::Plugin::Authorization::Roles';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Session::Store::File';
requires 'Catalyst::Component::ACCEPT_CONTEXT' => '0.03';
requires 'Catalyst::View::TT';
requires 'XML::Feed' => '0.12';
requires 'XML::Atom' => '0.27';
requires 'XML::RSS' => '1.31';
requires 'YAML';
catalyst;

build_requires 'Directory::Scratch';

tests('t/*.t t/*/*.t');
clean_files('t/var');

install_script glob('script/*.pl');
install_share;

eval {
    my $source = File::Spec->catfile('lib', 'Mango.pm');
    system "pod2text $source > README";
};

auto_install;
WriteAll;
