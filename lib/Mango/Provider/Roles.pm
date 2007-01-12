# $Id$
package Mango::Provider::Roles;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Provider::DBIC/;
    use Mango::Role;
};
__PACKAGE__->result_class('Mango::Role');
__PACKAGE__->source_name('Roles');

1;
__END__
