package Catalyst::Helper::Mango;
use strict;
use warnings;

BEGIN {
    use Catalyst::Helper;
    use Catalyst::Utils;
    use Path::Class qw/file dir/;
    use YAML;
    use Mango::Schema;
};

sub mk_app {
    my ($self, $name) = @_;
    my $helper = Catalyst::Helper->new;

    ## make the Catalyst app
    $helper->mk_app($name);

    ## add database
    $self->add_database($helper);

    ## inject plugins
    $self->add_plugins($helper);

    # add config
    $self->add_config($helper);

    ## add contollers/models/views
    $self->mk_stuff($helper);

    return;
};

sub add_database {
    my ($self, $helper) = @_;
    my $dir = dir($helper->{'dir'}, 'data');
    my $file = file($dir, 'mango.db');

    $helper->mk_dir($dir);

    my $schema = Mango::Schema->connect("dbi:SQLite:$file");
    $schema->deploy;

    return;
};

sub add_plugins {
    my ($self, $helper) = @_;
    my $file = file($helper->{'mod'} . '.pm');
    my $contents = $file->slurp;

    if ($contents !~ /\+Mango::Catalyst::Plugin/i) {
        $contents =~ s/-Debug ConfigLoader/-Debug ConfigLoader Session Session::Store::File Session::State::Cookie +Mango::Catalyst::Plugin::I18N +Mango::Catalyst::Plugin::Authentication +Mango::Catalyst::Plugin::Forms/;

        my $io = $file->open('>');
        $io->print($contents);
        $io->close;
        undef $io;
    };

    return;
};

sub add_config {
    my ($self, $helper) = @_;
    my $file = file($helper->{'dir'}, $helper->{'appprefix'} . '.yml');
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
                }
            }
        }
    };
    $config->{'connection_info'} = ['dbi:SQLite:data/mango.db'];
    $config->{'default_view'} = 'XHTML';

    YAML::DumpFile($file, $config);

    return;
};

sub mk_stuff {
    my ($self, $helper) = @_;
    my $c = $helper->{'c'};
    my $m = $helper->{'m'};
    my $v = $helper->{'v'};

    $helper->render_file('model_carts',     file($m, 'Carts.pm'));
    $helper->render_file('model_orders',    file($m, 'Orders.pm'));
    $helper->render_file('model_products',  file($m, 'Products.pm'));
    $helper->render_file('model_profiles',  file($m, 'Profiles.pm'));
    $helper->render_file('model_roles',     file($m, 'Roles.pm'));
    $helper->render_file('model_users',     file($m, 'Users.pm'));
    $helper->render_file('model_wishlists', file($m, 'Wishlists.pm'));

    $helper->render_file('view_atom',  file($v, 'Atom.pm'));
    $helper->render_file('view_html',  file($v, 'HTML.pm'));
    $helper->render_file('view_rss',   file($v, 'RSS.pm'));
    $helper->render_file('view_text',  file($v, 'Text.pm'));
    $helper->render_file('view_xhtml', file($v, 'XHTML.pm'));

    $helper->render_file('controller_cart',      file($c, 'Cart.pm'));
    $helper->render_file('controller_wishlists', file($c, 'Wishlists.pm'));
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
__controller_wishlists__
package [% name %]::Controller::Wishlists;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller::Wishlists/;
};

1;