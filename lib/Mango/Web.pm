# $Id$
package Mango::Web;
use strict;
use warnings;

BEGIN {
    use Catalyst::Runtime '5.7001';
};

$ENV{DBIC_TRACE} = 1;

use Catalyst qw/
    -Debug
    ConfigLoader
    Session
    Session::Store::File
    Session::State::Cookie
    Authentication
    Authentication::Store::Mango
    Authentication::Credential::Password
    Authorization::Roles
    Static::Simple
    Unicode
    Mango::I18N
/;

our $VERSION = '0.01';

__PACKAGE__->config(name => 'Mango::Web');
__PACKAGE__->setup;

1;
__END__

=head1 NAME

Mango::Web - Mango web application

=head1 SYNOPSIS

    script/mango_web_server.pl

=head1 DESCRIPTION

Mango::Web is the main Mango application.

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
