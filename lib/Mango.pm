# $Id$
package Mango;
use strict;
use warnings;

our $VERSION = '0.01000_06';

BEGIN {
    use base qw/Class::Accessor::Grouped/;
    use File::ShareDir ();
};
__PACKAGE__->share(eval {File::ShareDir::dist_dir('Mango') || $ENV{'MANGO_SHARE'}});

sub share {
    my ($self, $share) = @_;

    if ($share) {
        $self->set_inherited('share', $share);
    };

    return $ENV{'MANGO_SHARE'} || $self->get_inherited('share');
};

1;
__END__

=head1 NAME

Mango - An ecommerce solution using Catalyst, Handel and DBIx::Class

=head1 DESCRIPTION

This is a generic class containing the default configuration used by other
Mango classes.

To learn more about what Mango is and how it works, take a look at the
L<manual|Mango::Manual>.

=head1 METHODS

=head2 share

=over

=item Arguments: $share_path

=back

Gets/sets the location of the Mango share directory where the default
dist templates are stored.

    print $self->share;

If the C<ENV> variable C<MANGO_SHARE> is set, that will be returned instead.

=head1 SEE ALSO

L<Mango::Manual>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
