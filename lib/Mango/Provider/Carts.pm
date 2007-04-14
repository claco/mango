# $Id$
package Mango::Provider::Carts;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Provider/;

    __PACKAGE__->mk_group_accessors('simple', qw/storage/);
};
__PACKAGE__->result_class('Mango::Cart');

sub setup {
    my ($self, $args) = @_;
    my $storage = $self->result_class->storage->clone;

    $storage->setup($args);

    $self->storage(
        bless {storage => $storage}, $self->result_class
    );

    return;
};

sub create {
    my $self = shift;
    my $data = shift || {};

    if (my $user = delete $data->{'user'}) {
        $data->{'user_id'} = Scalar::Util::blessed($user) ? $user->id : $user;
    };

    return $self->storage->create($data, @_);
};

sub search {
    my $self = shift;
    my $filter = shift || {};

    if (my $user = delete $filter->{'user'}) {
        $filter->{'user_id'} = Scalar::Util::blessed($user) ? $user->id : $user;
    };

    return $self->storage->search($filter, @_);
};

sub update {
    my ($self, $object) = @_;

    return $object->update;
};

sub delete {
    my $self = shift;
    my $filter = shift;

    if (Scalar::Util::blessed $filter) {
        $filter = {id => $filter->id};
    } elsif (ref $filter eq 'HASH') {
        $filter ||= {};

        if (my $user = delete $filter->{'user'}) {
            $filter->{'user_id'} = Scalar::Util::blessed($user) ? $user->id : $user;
        };
    } elsif (ref $filter ne 'HASH') {
        $filter = {id => $filter};
    };

    return $self->storage->destroy($filter, @_);
};

1;
__END__

=head1 NAME

Mango::Provider::Carts - Provider class for cart information

=head1 SYNOPSIS

    my $provider = Mango::Provider::Carts->new;
    my $cart = $provider->get_by_id(23);

=head1 DESCRIPTION

Mango::Provider::Carts is the provider class responsible for creating,
deleting, updating and searching cart information.

=head1 CONSTRUCTOR

=head2 new

=over

=item Arguments: \%options

=back

Creates a new cart provider object. If options are passed to new, those are
sent to C<setup>.

    my $provider = Mango::Provider::Carts->new;

See L<Mango::Provider/new> for a list of other possible options.

=head1 METHODS

=head2 create

=over

=item Arguments: \%data

=back

Creates a new Mango::Cart object using the supplied data.

    my $cart = $provider->create({
        user => 23
    });
    
    print $cart->count;

In addition to using the column names, the following special keys are available:

=over

=item user

This can be a user id, or a user object for which this cart is assigned to.

    my $cart = $provider->create({
        user => $user
    });

It is recommended that you use this key, rather than setting the foreign key
column manually in case it changes later.

=back

=head2 delete

=over

=item Arguments: \%filter

=back

Deletes carts from the provider matching the supplied filter.

    $provider->delete({
        id => 23
    });

In addition to using the column names, the following special keys are available:

=over

=item user

This can be a user id, or a user object for which this cart is assigned to.

    $provider->delete({
        user => $user
    });

It is recommended that you use this key, rather than setting the foreign key
column manually in case it changes later.

=back

=head2 get_by_id

=over

=item Arguments: $id

=back

Returns a Mango::Cart object matching the specified id.

    my $cart = $provider->get_by_id(23);

Returns undef if no matching cart can be found.

=head2 search

=over

=item Arguments: \%filter, \%options

=back

Returns a list of Mango::Cart objects in list context, or a Mango::Iterator
in scalar context matching the specified filter.

    my @carts = $provider->search({
        name => 'A%'
    });
    
    my $iterator = $provider->search({
        name => 'A%'
    });

In addition to using the column names, the following special keys are available:

=over

=item user

This can be a user id, or a user object for which carts are assigned to.

    my @carts = $provider->search({
        user => $user
    });
    
    my $carts = $provider->search({
        user => $user
    });

=back

See L<Handel::Cart/search> for a list of other possible options.

=head2 update

=over

=item Arguments: $cart

=back

Sets the 'updated' column to DateTime->now and saves any changes made to the
cart back to the underlying store.

    my $cart = $provider->create(\%data);
    $cart->name('Favorites');
    
    $provider->update($cart);

=head1 SEE ALSO

L<Mango::Provider>, L<Mango::Cart>, L<Handel::Cart>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
