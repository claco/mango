package Catalyst::Helper::Mango;
use strict;
use warnings;

BEGIN {
    use Catalyst::Helper;
    use Catalyst::Utils;
    use Path::Class qw/file/;
};

sub mk_app {
    my ($class, $name) = @_;
    my $helper = Catalyst::Helper->new;

    $helper->mk_app($name);
    $class->mk_stuff($helper);

    return;
};

sub mk_stuff {
    my ($self, $helper) = @_;
    my $c = $helper->{'c'};
    my $m = $helper->{'m'};
    my $v = $helper->{'v'};

    #use Data::Dump;
    #warn Data::Dump::dump($helper);

    $helper->render_file('model_carts',     file($m, 'Carts.pm'));
    $helper->render_file('model_orders',    file($m, 'Orders.pm'));
    $helper->render_file('model_products',  file($m, 'Products.pm'));
    $helper->render_file('model_profiles',  file($m, 'Profiles.pm'));
    $helper->render_file('model_roles',     file($m, 'Roles.pm'));
    $helper->render_file('model_users',     file($m, 'Users.pm'));
    $helper->render_file('model_wishlists', file($m, 'Wishlists.pm'));
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
