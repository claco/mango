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

    if (ref $data eq 'ARRAY') {
        $class = 'Mango::Iterator::List';
    };

    return bless $args, $class;
};

sub create_result {
    my ($self, $result) = @_;

    return $result;
};

package Mango::Iterator::List;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Iterator Handel::Iterator::List/;
};

1;
