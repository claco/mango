# $Id: User.pm 1718 2007-02-05 03:00:43Z claco $
package Mango::User;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Object/;

    __PACKAGE__->mk_group_accessors('column', qw/username password/);
};

1;
__END__

=head1 NAME

Mango::User - A user object

=head1 SYNOPSIS

    my $user = $provider->search({ username => 'claco' });
    print $user->created;
    $user->password('newpassword');
    $user->update;

=head1 DESCRIPTION

Mango::User represents a user returned from the user provider.

=head1 METHODS

=head2 id

Returns id of the current user.

    print $user->id;

=head2 created

Returns the date the user was created as a DateTime object.

    print $user->created;

=head2 updated

Returns the date the user was last updated as a DateTime object.

    print $user->updated;

=head2 username

=over

=item Arguments: $username

=back

Gets/sets the username of the user.

    print $user->username;

=head2 password

=over

=item Arguments: $password

=back

Gets/sets the password of the user.

    print $user->password;

=head2 update

Saves any changes to the user back to the provider.

=head1 SEE ALSO

L<Mango::Object>, L<Mango::Provider::Users>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
