package Mango::Setup;
use strict;
use warnings;

BEGIN {
    use Catalyst::Runtime '5.7001';
};

use Catalyst qw/
    -Debug
    ConfigLoader
    Session
    Session::Store::File
    Session::State::Cookie
    Static::Simple
    Unicode
    Mango::I18N
/;

our $VERSION = '0.01';

__PACKAGE__->config(name => 'Mango::Setup');
__PACKAGE__->setup;

1;
__END__

=head1 NAME

Mango::Setup - Mango setup application

=head1 SYNOPSIS

    script/mango_setup_server.pl

=head1 DESCRIPTION

Mango::Setup is an application to install Mango for the first time.

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
