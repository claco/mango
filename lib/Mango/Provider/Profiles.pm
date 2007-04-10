# $Id$
package Mango::Provider::Profiles;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Provider::DBIC/;
};
__PACKAGE__->result_class('Mango::Profile');
__PACKAGE__->source_name('Profiles');


## ditch this in favour of search {user => }
sub get_by_user {
    my $self = shift;
    my $object = shift;
    my $id = Scalar::Util::blessed($object) ? $object->id : $object ;

    return $self->search({user_id => $id}, @_);
};

1;
__END__

=head1 NAME

Mango::Provider::Profiles - Provider class for user profile information

=head1 SYNOPSIS

    my $provider = Mango::Provider::Profiles->new;
    my $profile  = $provider->get_by_user($user->id);

=head1 DESCRIPTION

Mango::Provider::Profiles is the provider class responsible for creating,
deleting, updating and searching user profile information.

=head1 CONSTRUCTOR

=head2 new

=over

=item Arguments: \%options

=back

Creates a new provider object. If options are passed to new, those are
sent to C<setup>.

    my $provider = Mango::Provider::Profiles->new;

See L<Mango::Provider/new> and L<Mango::Provider::DBIC/new> a list of other
possible options.

=head1 METHODS

=head2 create

=over

=item Arguments: \%data

=back

Creates a new Mango::Profile object using the supplied data.

    my $profile = $provider->create({
        user_id => $user->id,
        first_name => 'Christopher',
        last_name => 'Laco'
    });
    
    print $profile->first_name;

=head2 delete

=over

=item Arguments: \%filter

=back

Deletes the specified profile from the store matching the supplied filter.

    $provider->delete({
        user_id => $user->id
    });

=head2 get_by_id

=over

=item Arguments: $id

=back

Returns a Mango::Profile object matching the specified id.

    my $profile = $provider->get_by_id(23);

Returns undef if no matching profile can be found.

=head2 get_by_user

=over

=item Arguments: $id or $user

=back

Returns a Mango::Profile object matching the specified user id. If you pass in
a user object, $object->id will be used.

    my $profile = $provider->get_by_user(23);
    my $profile = $provider->get_by_user($user);

=head2 search

=over

=item Arguments: \%filter, \%options

=back

Returns a list of Mango::Profile objects in list context, or a Mango::Iterator
in scalar context matching the specified filter.

    my @profiles = $provider->search({
        last_name => 'Roberts'
    });
    
    my $iterator = $provider->search({
        last_name => 'Roberts'
    });

See L<DBIx::Class::Resultset/ATTRIBUTES> for a list of other possible options.

=head2 update

=over

=item Arguments: $profile

=back

Saves any changes made to a profile back to the underlying store.

    my $profile = $provider->create(\%data);
    $profile->first_name('Chris');
    
    $provider->update($profile);

=head1 SEE ALSO

L<Mango::Provider>, L<Mango::Provider::Profiles>, L<Mango::Profile>,
L<DBIx::Class>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
