# $Id$
package Mango::Provider::Users;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Provider::DBIC/;
};
__PACKAGE__->result_class('Mango::User');
__PACKAGE__->source_name('Users');

*get_by_user = sub {$_[0]->can('get_by_id')->(@_)};

1;
__END__
