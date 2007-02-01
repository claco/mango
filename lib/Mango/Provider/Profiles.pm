# $Id$
package Mango::Provider::Profiles;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Provider::DBIC/;
};
__PACKAGE__->result_class('Mango::Profile');
__PACKAGE__->source_name('Profiles');

1;
__END__
