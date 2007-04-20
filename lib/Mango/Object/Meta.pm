# $Id$
package Mango::Object::Meta;
use strict;
use warnings;

BEGIN {
    use base qw/Class::Accessor::Grouped/;

    __PACKAGE__->mk_group_accessors('simple', qw/provider/);
};

sub new {
    my ($class, $args) = @_;

    return bless $args, $class;
};

1;
__END__

=head1 NAME

Mango::Object::Meta - Module representing object meta information

=head1 SYNOPSIS

    my $object = Mango::Object->new;
    $object->meta->provider($provider);

=head1 DESCRIPTION

Mango::Object::Meta module contains all of the non-column, or "meta" information
for a result object.

=head1 CONSTRUCTOR

=head2 new

=over

=item Arguments: \%args

=back

Creates a new meta object that uses the hash supplied to read/write its
information.

=head1 METHODS

=head2 provider

=over

=item Arguments: $provider

=back

Gets/sets the Mango::Provider object that is responsible for creating, or
processing updates for the current object.

=head1 SEE ALSO

L<Mango::Object>, L<Mango::Provider>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
