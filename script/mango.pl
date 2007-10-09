#!perl -w
# $Id$
use strict;
use warnings;

BEGIN {
    use Catalyst::Helper::Mango;
    use Getopt::Long;
    use Pod::Usage;
};

my $help      = 0;
my $version   = 0;
my $adminuser;
my $adminpass;
my $adminrole;

GetOptions(
    'help|?'     => \$help,
    'version'    => \$version,
    'admin-user' => \$adminuser,
    'admin-pass' => \$adminpass,
    'admin-role' => \$adminrole
) || pod2usage(1);

if ($version) {
    require Mango;
    print "Mango ", Mango->VERSION, "\n";
    exit;
};

pod2usage(1) if ($help || !$ARGV[0]);

my $helper = Catalyst::Helper::Mango->new({
    adminuser => $adminuser,
    adminpass => $adminpass,
    adminrole => $adminrole
});

$helper->mk_app($ARGV[0]);

print "created starter directories and files\n";

1;
__END__

=head1 NAME

mango - Bootstrap a Mango application

=head1 SYNOPSIS

mango [options] application-name

Options:

    --help          Show this message
    --version       The installed version
    --admin-user    The username for the admin account (Default: admin)
    --admin-pass    The password for the admin account (Default: admin)
    --admin-role    The name of the admin role (Default: admin)

Example:

    mango MyProject

=head1 DESCRIPTION

The C<mango.pl> script creates a skeleton framework for a new Mango based
application using the recommend style of subclassing for easy customization.

    created "MyApp"
    created "MyApp/script"
    created "MyApp/lib"
    created "MyApp/root"
    created "MyApp/root/static"
    created "MyApp/root/static/images"
    created "MyApp/t"
    created "MyApp/lib/MyApp"
    created "MyApp/lib/MyApp/Model"
    created "MyApp/lib/MyApp/View"
    created "MyApp/lib/MyApp/Controller"
    created "MyApp/myapp.yml"
    created "MyApp/lib/MyApp.pm"
    created "MyApp/lib/MyApp/Controller/Root.pm"
    created "MyApp/README"
    created "MyApp/Changes"
    created "MyApp/t/01app.t"
    created "MyApp/t/02pod.t"
    created "MyApp/t/03podcoverage.t"
    created "MyApp/root/static/images/catalyst_logo.png"
    created "MyApp/root/static/images/btn_120x50_built.png"
    created "MyApp/root/static/images/btn_120x50_built_shadow.png"
    created "MyApp/root/static/images/btn_120x50_powered.png"
    created "MyApp/root/static/images/btn_120x50_powered_shadow.png"
    created "MyApp/root/static/images/btn_88x31_built.png"
    created "MyApp/root/static/images/btn_88x31_built_shadow.png"
    created "MyApp/root/static/images/btn_88x31_powered.png"
    created "MyApp/root/static/images/btn_88x31_powered_shadow.png"
    created "MyApp/root/favicon.ico"
    created "MyApp/Makefile.PL"
    created "MyApp/script/myapp_cgi.pl"
    created "MyApp/script/myapp_fastcgi.pl"
    created "MyApp/script/myapp_server.pl"
    created "MyApp/script/myapp_test.pl"
    created "MyApp/script/myapp_create.pl"
    created "MyApp/data"
    created "MyApp/data/mango.db"
    created admin user/pass (admin:admin)
    created admin role (admin)
    created "MyApp/lib/MyApp/Model/Carts.pm"
    created "MyApp/lib/MyApp/Model/Orders.pm"
    created "MyApp/lib/MyApp/Model/Products.pm"
    created "MyApp/lib/MyApp/Model/Profiles.pm"
    created "MyApp/lib/MyApp/Model/Roles.pm"
    created "MyApp/lib/MyApp/Model/Users.pm"
    created "MyApp/lib/MyApp/Model/Wishlists.pm"
    created "MyApp/lib/MyApp/View/Atom.pm"
    created "MyApp/lib/MyApp/View/HTML.pm"
    created "MyApp/lib/MyApp/View/RSS.pm"
    created "MyApp/lib/MyApp/View/Text.pm"
    created "MyApp/lib/MyApp/View/XHTML.pm"
    created "MyApp/lib/MyApp/Controller/Admin"
    created "MyApp/lib/MyApp/Controller/Admin/Products"
    created "MyApp/lib/MyApp/Controller/Admin.pm"
    created "MyApp/lib/MyApp/Controller/Admin/Roles.pm"
    created "MyApp/lib/MyApp/Controller/Admin/Users.pm"
    created "MyApp/lib/MyApp/Controller/Admin/Products.pm"
    created "MyApp/lib/MyApp/Controller/Admin/Products/Attributes.pm"
    created "MyApp/lib/MyApp/Controller/Cart.pm"
    created "MyApp/lib/MyApp/Controller/Login.pm"
    created "MyApp/lib/MyApp/Controller/Logout.pm"
    created "MyApp/lib/MyApp/Controller/Products.pm"
    created "MyApp/lib/MyApp/Controller/Wishlists.pm"
    created starter directories and files

See L<Mango::Manual::QuickStart> for more information on creating your first
Mango based application.

=head1 SEE ALSO

L<Mango::Manual>, L<Mango::Manual::QuickStart>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
