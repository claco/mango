# $Id$
package Catalyst::Helper::Mango;
use strict;
use warnings;

BEGIN {
    use base qw/Catalyst::Helper/;
    use Catalyst::Utils;
    use DateTime;
    use Path::Class qw/file dir/;
    use YAML;
    use Mango::Schema;
};

sub mk_app {
    my ($self, $name) = @_;

    ## set defaults
    $self->{'adminuser'} ||= 'admin';
    $self->{'adminpass'} ||= 'admin';
    $self->{'adminrole'} ||= 'admin';

    ## make the Catalyst app
    $self->SUPER::mk_app($name);

    ## add database
    $self->add_database;

    ## inject plugins
    $self->add_plugins;

    # add config
    $self->add_config;

    ## add contollers/models/views
    $self->mk_stuff;

    return;
};

sub add_database {
    my $self = shift;
    my $dir = dir($self->{'dir'}, 'data');
    my $file = file($dir, 'mango.db');

    if (! -e $file) {
        $self->mk_dir($dir);
        my $adminuser = $self->{'adminuser'};
        my $adminpass = $self->{'adminpass'};
        my $adminrole = $self->{'adminrole'};

        my $schema = Mango::Schema->connect("dbi:SQLite:$file");
        $schema->deploy;
        print "created \"$file\"\n";

        $schema->resultset('Users')->create({
            id => 1,
            username => $adminuser,
            password => $adminpass,
            created => DateTime->now,
            updated => DateTime->now
        });
        print "created admin user/pass ($adminuser:$adminpass)\n";

        $schema->resultset('Roles')->create({
            id => 1,
            name => $adminrole,
            description => 'Administrators',
            created => DateTime->now,
            updated => DateTime->now
        });
        print "created admin role ($adminrole)\n";

        $schema->resultset('UsersRoles')->create({
            user_id => 1,
            role_id => 1
        });
    };

    return;
};

sub add_plugins {
    my $self = shift;
    my $file = file($self->{'mod'} . '.pm');
    my $contents = $file->slurp;

    if ($contents !~ /\+Mango::Catalyst::Plugin/i) {
        $contents =~ s/-Debug ConfigLoader/-Debug ConfigLoader Session Session::Store::File Session::State::Cookie +Mango::Catalyst::Plugin::Application Authorization::Roles/;

        my $io = $file->open('>');
        $io->print($contents);
        $io->close;
        undef $io;
    };

    return;
};

sub add_config {
    my $self = shift;
    my $file = file($self->{'dir'}, $self->{'appprefix'} . '.yml');
    my $config = YAML::LoadFile($file);

    $config->{'authentication'} = {
        default_realm => 'mango',
        realms => {
            mango => {
                credential => {
                    class => 'Password',
                    password_field => 'password',
                    password_type => 'clear'
                },
                store => {
                    class => '+Mango::Catalyst::Plugin::Authentication::Store'
                },
            }
        }
    };
    $config->{'connection_info'} = ['dbi:SQLite:data/mango.db'];
    $config->{'default_view'} = 'XHTML';
    $config->{'authorization'}->{'mango'}->{'admin_role'} = $self->{'adminrole'};

$config->{cache}->{backend} = {
        store => "Memory",
};

    YAML::DumpFile($file, $config);

    return;
};

sub mk_stuff {
    my $self = shift;
    my $c = $self->{'c'};
    my $m = $self->{'m'};
    my $v = $self->{'v'};

    $self->render_file('model_carts',     file($m, 'Carts.pm'));
    $self->render_file('model_orders',    file($m, 'Orders.pm'));
    $self->render_file('model_products',  file($m, 'Products.pm'));
    $self->render_file('model_profiles',  file($m, 'Profiles.pm'));
    $self->render_file('model_roles',     file($m, 'Roles.pm'));
    $self->render_file('model_users',     file($m, 'Users.pm'));
    $self->render_file('model_wishlists', file($m, 'Wishlists.pm'));

    $self->render_file('view_atom',  file($v, 'Atom.pm'));
    $self->render_file('view_html',  file($v, 'HTML.pm'));
    $self->render_file('view_rss',   file($v, 'RSS.pm'));
    $self->render_file('view_text',  file($v, 'Text.pm'));
    $self->render_file('view_xhtml', file($v, 'XHTML.pm'));

    $self->mk_dir(dir($c, 'Admin'));
    $self->mk_dir(dir($c, 'Admin', 'Products'));

    ## admin speciic controllers
    $self->render_file('controller_admin',
        file($c, 'Admin.pm'));
    $self->render_file('controller_admin_roles',
        file($c, 'Admin', 'Roles.pm'));
    $self->render_file('controller_admin_users',
        file($c, 'Admin', 'Users.pm'));
    $self->render_file('controller_admin_products',
        file($c, 'Admin', 'Products.pm'));
    $self->render_file('controller_admin_products_attributes',
        file($c, 'Admin', 'Products', 'Attributes.pm'));

    ## sitewide controllers
    $self->render_file('controller_cart',
        file($c, 'Cart.pm'));
    $self->render_file('controller_login',
        file($c, 'Login.pm'));
    $self->render_file('controller_logout',
        file($c, 'Logout.pm'));
    $self->render_file('controller_products',
        file($c, 'Products.pm'));
    $self->render_file('controller_users',
        file($c, 'Users.pm'));
};

1;
__DATA__
__model_carts__
package [% name %]::Model::Carts;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Model::Carts/;
};

1;
__model_orders__
package [% name %]::Model::Orders;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Model::Orders/;
};

1;
__model_products__
package [% name %]::Model::Products;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Model::Products/;
};

1;
__model_profiles__
package [% name %]::Model::Profiles;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Model::Profiles/;
};

1;
__model_roles__
package [% name %]::Model::Roles;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Model::Roles/;
};

1;
__model_users__
package [% name %]::Model::Users;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Model::Users/;
};

1;
__model_wishlists__
package [% name %]::Model::Wishlists;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Model::Wishlists/;
};

1;
__view_atom__
package [% name %]::View::Atom;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::View::Atom/;
};

1;
__view_html__
package [% name %]::View::HTML;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::View::HTML/;
};

1;
__view_rss__
package [% name %]::View::RSS;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::View::RSS/;
};

1;
__view_text__
package [% name %]::View::Text;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::View::Text/;
};

1;
__view_xhtml__
package [% name %]::View::XHTML;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::View::XHTML/;
};

1;
__controller_cart__
package [% name %]::Controller::Cart;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller::Cart/;
};

1;
__controller_user_wishlists__
package [% name %]::Controller::User::Wishlists;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller::User::Wishlists/;
};

1;
__controller_login__
package [% name %]::Controller::Login;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller::Login/;
};

1;
__controller_logout__
package [% name %]::Controller::Logout;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller::Logout/;
};

1;
__controller_products__
package [% name %]::Controller::Products;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller::Products/;
};

1;
__controller_users__
package [% name %]::Controller::Users;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller::Users/;
};

1;
__controller_admin__
package [% name %]::Controller::Admin;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller::Admin/;
};

1;
__controller_admin_roles__
package [% name %]::Controller::Admin::Roles;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller::Admin::Roles/;
};

1;
__controller_admin_users__
package [% name %]::Controller::Admin::Users;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller::Admin::Users/;
};

1;
__controller_admin_products__
package [% name %]::Controller::Admin::Products;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller::Admin::Products/;
};

1;
__controller_admin_products_attributes__
package [% name %]::Controller::Admin::Products::Attributes;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller::Admin::Products::Attributes/;
};

1;