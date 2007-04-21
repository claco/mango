package Mango::Iterator;
use strict;
use warnings;

BEGIN {
    use base qw/Class::Accessor::Grouped/;
    use Scalar::Util qw/blessed/;

    __PACKAGE__->mk_group_accessors('simple', qw/provider data pager/);
};

sub new {
    my $class = shift;
    my $args  = shift || {};
    my $data = $args->{'data'};

    if (ref $data eq 'ARRAY') {
        $class = 'Mango::Iterator::List';
    } elsif (blessed $data && $data->isa('Handel::Iterator')) {
        $class = 'Mango::Iterator::HandelResults';
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

package Mango::Iterator::HandelResults;
use strict;
use warnings;

BEGIN {
    use base qw/Handel::Iterator::Results Mango::Iterator/;
};

1;
__END__

=head1 NAME

Mango::Iterator - Module representing a collection of results

=head1 SYNOPSIS

    my $users = $provider->search;
    
    while (my $user = $users->next) {
        print $user->id;
    };

=head1 DESCRIPTION

Mango::Iterator is a collection of results to be iterated or looped through.
This module is a subclass of Handel::Iterator. See
L<Handel::Iterator|Handel::Iterator> for more information about what features
and methods are supported.

=head1 CONSTRUCTOR

=head2 new

=over

=item Arguments: \%args

=back

Creates a new iterator based on the type of data passed into args.

    my $it = Mango::Iterator->new({
        data => \@list
    });

=head1 METHODS

=head2 create_result

Transforms Handel based object into Mango objects.  For non Handel objects, the
original object is just returned.

=head1 SEE ALSO

L<Handel::Iterator>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
