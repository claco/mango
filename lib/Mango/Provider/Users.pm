# $Id$
package Mango::Provider::Users;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Provider::DBIC/;
    use Scalar::Util ();
};
__PACKAGE__->result_class('Mango::User');
__PACKAGE__->source_name('Users');

1;
__END__

=head1 NAME

Mango::Provider::Users - Provider class for user information

=head1 SYNOPSIS

    my $provider = Mango::Provider::Users->new;
    my $user = $provider->get_by_id(23);

=head1 DESCRIPTION

Mango::Provider::Users is the provider class responsible for creating,
deleting, updating and searching users.

=head1 CONSTRUCTOR

=head2 new

=over

=item Arguments: \%options

=back

Creates a new user provider object. If options are passed to new, those are
sent to C<setup>.

    my $provider = Mango::Provider::Users->new;

See L<Mango::Provider/new> and L<Mango::Provider::DBIC/new> for a list of other
possible options.

=head1 METHODS

=head2 create

=over

=item Arguments: \%data

=back

Creates a new Mango::User object using the supplied data.

    my $user = $provider->create({
        username => 'admin',
        password => 'r2d2c3po'
    });
    
    print $user->username;

=head2 delete

=over

=item Arguments: \%filter

=back

Deletes users from the provider matching the supplied filter.

    $provider->delete({
        username => 'claco'
    });

=head2 get_by_id

=over

=item Arguments: $id

=back

Returns a Mango::User object matching the specified id.

    my $user = $provider->get_by_id(23);

Returns undef if no matching user can be found.

=head2 search

=over

=item Arguments: \%filter, \%options

=back

Returns a list of Mango::User objects in list context, or a Mango::Iterator
in scalar context matching the specified filter.

    my @users = $provider->search({
        username => 'C%'
    });
    
    my $iterator = $provider->search({
        username => 'C%'
    });

See L<DBIx::Class::Resultset/ATTRIBUTES> for a list of other possible options.

=head2 update

=over

=item Arguments: $user

=back

Sets the 'updated' column to DateTime->now and saves any changes made to the
user back to the underlying store.

    my $user = $provider->create(\%data);
    $user->password('newpwd');
    
    $provider->update($user);

=head1 SEE ALSO

L<Mango::Provider>, L<Mango::Provider::DBIC>, L<Mango::Role>,
L<DBIx::Class>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
