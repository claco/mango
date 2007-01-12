# $Id$
package Mango::Provider::Users;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Provider::DBIC/;
    use Mango::User;
};
__PACKAGE__->result_class('Mango::User');
__PACKAGE__->source_name('Users');

1;
__END__
