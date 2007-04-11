# $Id: Profiles.pm 1791 2007-04-10 00:46:54Z claco $
package Mango::Provider::Profiles;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Provider::DBIC/;
};
__PACKAGE__->result_class('Mango::Profile');
__PACKAGE__->source_name('Profiles');

sub create {
    my ($self, $data) = @_;

    if (my $user = delete $data->{'user'}) {
        $data->{'user_id'} = Scalar::Util::blessed($user) ? $user->id : $user;
    };

    return $self->SUPER::create($data);
};

sub delete {
    my ($self, $filter) = @_;

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

    return $self->SUPER::delete($filter);
};

sub search {
    my ($self, $filter, $options) = @_;

    $filter ||= {};
    $options ||= {};

    if (my $user = delete $filter->{'user'}) {
        $filter->{'user_id'} = Scalar::Util::blessed($user) ? $user->id : $user;
    };

    return $self->SUPER::search($filter, $options);
};

1;
__END__

=head1 NAME

Mango::Provider::Profiles - Provider class for user profile information

=head1 SYNOPSIS

    my $provider = Mango::Provider::Profiles->new;
    my $profile = $provider->get_by_id(23);

=head1 DESCRIPTION

Mango::Provider::Profiles is the provider class responsible for creating,
deleting, updating and searching user profile information.

=head1 CONSTRUCTOR

=head2 new

=over

=item Arguments: \%options

=back

Creates a new profile provider object. If options are passed to new, those are
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
        user => 23
        first_name => 'Christopher',
        last_name  => 'Laco'
    });
    
    print $role->name;

In addition to using the column names, the following special keys are available:

=over

=item user

This can be a user id, or a user object for which this profile is assigned to.

    my $profile = $provider->create({
        user => $user,
        first_name => 'Christopher'
    });

It is recommended that you use this key, rather than setting the foreign key
column manually in case it changes later.

=back

=head2 delete

=over

=item Arguments: \%filter

=back

Deletes profile from the provider matching the supplied filter.

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

Returns a Mango::Profile object matching the specified id.

    my $profile = $provider->get_by_id(23);

Returns undef if no matching profile can be found.

=head2 search

=over

=item Arguments: \%filter, \%options

=back

Returns a list of Mango::Profile objects in list context, or a Mango::Iterator
in scalar context matching the specified filter.

    my @profiles = $provider->search({
        last_name => 'A%'
    });
    
    my $iterator = $provider->search({
        last_name => 'A%'
    });

In addition to using the column names, the following special keys are available:

=over

=item user

This can be a user id, or a user object for which roles are assigned to.

    my @profiles = $provider->search({
        user => $user
    });
    
    my $profiles = $provider->search({
        user => $user
    });

=back

See L<DBIx::Class::Resultset/ATTRIBUTES> for a list of other possible options.

=head2 update

=over

=item Arguments: $profile

=back

Sets the 'updated' column to DateTime->now and saves any changes made to the
profile back to the underlying store.

    my $profile = $provider->create(\%data);
    $profile->first_name('Christopher');
    
    $provider->update($profile);

=head1 SEE ALSO

L<Mango::Provider>, L<Mango::Provider::DBIC>, L<Mango::Profile>,
L<DBIx::Class>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
