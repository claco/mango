package Mango::Iterator;
use strict;
use warnings;

BEGIN {
    use Scalar::Util qw/blessed/;
};

sub new {
    my $class = shift;
    my $args  = shift || {};
    my $data = $args->{'data'};

    if (blessed $data && $data->isa('DBIx::Class::ResultSet')) {
        $class = 'Mango::Iterator::DBIC';
    } elsif (ref $data eq 'ARRAY') {
        $class = 'Mango::Iterator::List';
    };

    return bless $args, $class;
};

sub create_result {
    my ($self, $result) = @_;

    return bless {result => $result}, $self->result_class;
};

package Mango::Iterator::List;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Iterator Handel::Iterator::List/;
};

package Mango::Iterator::DBIC;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Iterator Handel::Iterator::DBIC/;
};

1;
