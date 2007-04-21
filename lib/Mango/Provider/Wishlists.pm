# $Id$
package Mango::Provider::Wishlists;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Provider/;

    __PACKAGE__->mk_group_accessors('simple', qw/storage/);
};
__PACKAGE__->result_class('Mango::Wishlist');

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
        if (Scalar::Util::blessed($user)) {
            if ($user->isa('Mango::User')) {
                $data->{'user_id'} = $user->id;
            } else {
                Mango::Exception->throw('NOT_A_USER');
            };
        } else {
            $data->{'user_id'} = $user;
        };
    };

    if (!$data->{'user_id'}) {
        Mango::Exception->throw('NO_USER_SPECIFIED');
    };

    return $self->storage->create($data, @_);
};

sub search {
    my $self = shift;
    my $filter = shift || {};

    if (my $user = delete $filter->{'user'}) {
        if (Scalar::Util::blessed $user) {
            if ($user->isa('Mango::User')) {
                $filter->{'user_id'} = $user->id;
            } else {
                Mango::Exception->throw('NOT_A_USER');
            };
        } else {
            $filter->{'user_id'} = $user;
        };
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
        if ($filter->isa('Mango::Wishlist')) {
            $filter = {id => $filter->id};
        } else {
            Mango::Exception->throw('NOT_A_WISHLIST');
        };
    } elsif (ref $filter eq 'HASH') {
        if (my $user = delete $filter->{'user'}) {
            if (Scalar::Util::blessed $user) {
                if ($user->isa('Mango::User')) {
                    $filter->{'user_id'} = $user->id;
                } else {
                    Mango::Exception->throw('NOT_A_USER');
                };
            } else {
                $filter->{'user_id'} = $user;
            };
        };
    } else {
        $filter = {id => $filter};
    };

    return $self->storage->destroy($filter, @_);
};

1;
__END__

=head1 NAME

Mango::Provider::Wishlists - Provider class for wishlist information

=head1 SYNOPSIS

    my $provider = Mango::Provider::Wishlists->new;
    my $wishlist = $provider->get_by_id(23);

=head1 DESCRIPTION

Mango::Provider::Wishlists is the provider class responsible for creating,
deleting, updating and searching wishlist information.

=head1 CONSTRUCTOR

=head2 new

=over

=item Arguments: \%options

=back

Creates a new wishlist provider object. If options are passed to new, those are
sent to C<setup>.

    my $provider = Mango::Provider::Wishlists->new;

See L<Mango::Provider/new> for a list of other possible options.

=head1 METHODS

=head2 create

=over

=item Arguments: \%data

=back

Creates a new Mango::Wishlist object using the supplied data.

    my $wishlist = $provider->create({
        user => 23
    });
    
    print $wishlist->name;

In addition to using the column names, the following special keys are available:

=over

=item user

This can be a user id, or a user object for which this cart is assigned to.

    my $wishlist = $provider->create({
        user => $user
    });

It is recommended that you use this key, rather than setting the foreign key
column manually in case it changes later.

=back

=head2 delete

=over

=item Arguments: \%filter

=back

Deletes wishlists from the provider matching the supplied filter.

    $provider->delete({
        id => 23
    });

In addition to using the column names, the following special keys are available:

=over

=item user

This can be a user id, or a user object for which this profile is assigned to.

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

Returns a Mango::Wishlist object matching the specified id.

    my $wishlist = $provider->get_by_id(23);

Returns undef if no matching wishlist can be found.

=head2 search

=over

=item Arguments: \%filter, \%options

=back

Returns a list of Mango::Wishlist objects in list context, or a Mango::Iterator
in scalar context matching the specified filter.

    my @wishlists = $provider->search({
        name => 'A%'
    });
    
    my $iterator = $provider->search({
        name => 'A%'
    });

In addition to using the column names, the following special keys are available:

=over

=item user

This can be a user id, or a user object for which roles are assigned to.

    my @wishlists = $provider->search({
        user => $user
    });
    
    my $wishlists = $provider->search({
        user => $user
    });

=back

See L<Handel::Cart/search> for a list of other possible options.

=head2 update

=over

=item Arguments: $cart

=back

Sets the 'updated' column to DateTime->now and saves any changes made to the
wishlist back to the underlying store.

    my $wishlist = $provider->create(\%data);
    $wishlist->name('Favorites');
    
    $provider->update($wishlist);

=head1 SEE ALSO

L<Mango::Provider>, L<Mango::Wishlist>, L<Handel::Cart>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
