# $Id$
use strict;
use warnings;
use inc::Module::Install 0.65;
use File::Spec;

name 'Mango';
license 'perl';
perl_version '5.008001';
all_from 'lib/Mango.pm';

requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Action::REST' => '0.60';
requires 'Catalyst::Component::ACCEPT_CONTEXT' => '0.05';
requires 'Catalyst::Devel' => '1.02';
requires 'Catalyst::Plugin::Authentication' => '0.09999';
requires 'Catalyst::Plugin::Authentication::Credential::HTTP';
requires 'Catalyst::Plugin::Authorization::Roles';
requires 'Catalyst::Plugin::Cache';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Session::Store::File';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Runtime' => '5.7012';
requires 'Catalyst::View::TT';
requires 'CGI::FormBuilder';
requires 'Class::Accessor::Grouped' => '0.06000';
requires 'Class::Inspector';
requires 'Clone' => '0.27';
requires 'DateTime';
requires 'DBIx::Class' => '0.08008';
requires 'Error';
requires 'File::ShareDir';
requires 'FormValidator::Simple' => '0.17';
requires 'Handel' => '1.00009';
requires 'HTML::TagCloud::Sortable';
requires 'I18N::LangTags';
requires 'I18N::LangTags::Detect';
requires 'List::MoreUtils';
requires 'Locale::Maketext';
requires 'MIME::Types';
requires 'Module::Starter' => '1.42';
requires 'Path::Class';
requires 'Scalar::Util';
requires 'Set::Scalar';
requires 'Test::WWW::Mechanize::Catalyst';
requires 'XML::Atom' => '0.27';
requires 'XML::Feed' => '0.12';
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

    use lib 'lib';
    use Mango::Schema;
    Mango::Schema->connect->create_ddl_dir([qw/MySQL SQLite PostreSQL/], undef, 't/sql', '0.01000_10');
};

auto_install;
WriteAll;
