# $Id$
package Mango::Profile;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Object/;

    __PACKAGE__->mk_group_accessors('column', qw/user_id first_name last_name/);
};

1;
__END__

=head1 NAME

Mango::Profile - A user profile

=head1 SYNOPSIS

    my $profile = $provider->search({ user => 23 });
    print $user->created;
    $user->first_name('Christopher');
    $user->update;

=head1 DESCRIPTION

Mango::Profile represents a profile returned from the profile provider.

=head1 METHODS

=head2 id

Returns id of the current profile.

    print $profile->id;

=head2 created

Returns the date the profile was created as a DateTime object.

    print $profile->created;

=head2 updated

Returns the date the profile was last updated as a DateTime object.

    print $profile->updated;

=head2 first_name

=over

=item Arguments: $first_name

=back

Gets/sets the first name of the user.

    print $profile->first_name;

=head2 last_name

=over

=item Arguments: $last_name

=back

Gets/sets the last name of the user.

    print $profile->last_name;

=head2 update

Saves any changes to the profile back to the provider.

=head1 SEE ALSO

L<Mango::Object>, L<Mango::Provider::Profiles>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
