#!perl -w
# $Id$
use strict;
use warnings;

BEGIN {
    use Catalyst::Helper::Mango;
    use Getopt::Long;
    use Pod::Usage;
};

my $help    = 0;
my $version = 0;

GetOptions(
    'help|?'          => \$help,
    'version'         => \$version
) || pod2usage(1);

if ($version) {
    require Mango;
    print "Mango ", Mango->VERSION, "\n";
    exit;
};

pod2usage(1) if ($help || !$ARGV[0]);

Catalyst::Helper::Mango->mk_app($ARGV[0]);

print "Created starter directories and files\n";

1;
__END__

=head1 NAME

mango - Bootstrap a Mango application

=head1 SYNOPSIS

mango [options] application-name

Options:

    --help       Show this message
    --version    The installed version

Example:

    mango MyProject

=head1 DESCRIPTION

The C<mango.pl> script creates a skeleton framework for a new Mango based
application using the recommend style of subclassing for easy customization.

    Created MyProject
    Created MyProject\lib\MyProject
    Created MyProject\lib\MyProject\Cart.pm
    Created MyProject\lib\MyProject\Cart
    Created MyProject\lib\MyProject\Cart\Item.pm
    Created MyProject\lib\MyProject\Storage
    Created MyProject\lib\MyProject\Storage\Cart.pm
    Created MyProject\lib\MyProject\Storage\Cart
    Created MyProject\lib\MyProject\Storage\Cart\Item.pm
    Created MyProject\lib\MyProject\Order.pm
    Created MyProject\lib\MyProject\Order
    Created MyProject\lib\MyProject\Order\Item.pm
    Created MyProject\lib\MyProject\Storage\Order.pm
    Created MyProject\lib\MyProject\Storage\Order
    Created MyProject\lib\MyProject\Storage\Order\Item.pm
    Created MyProject\lib\MyProject\Checkout.pm
    Created MyProject\t
    Created MyProject\t\pod_syntax.t
    Created MyProject\t\pod_spelling.t
    Created MyProject\t\basic.t
    Created MyProject\t\pod_coverage.t
    Created MyProject\.cvsignore
    Created MyProject\Makefile.PL
    Created MyProject\MANIFEST
    Created MyProject\script\myapp_handel.pl

See L<Mango::Manual::QuickStart> for more information on creating your first
Mango based application.

=head1 SEE ALSO

L<Mango::Manual>, L<Mango::Manual::QuickStart>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
