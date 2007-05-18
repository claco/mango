# $Id$
package Mango::Schema;
use strict;
use warnings;

BEGIN {
    use base qw/DBIx::Class::Schema/;

    use Mango::Exception ();
};
__PACKAGE__->load_classes;

sub connect {
    my ($class, $dsn, $user, $password, $attr) = @_;

    $attr ||= {
        AutoCommit => 1
    };

    my $schema = $class->next::method($dsn, $user, $password, $attr);

    $schema->exception_action(
        sub {
            Mango::Exception->throw(shift);
        }
    );

    return $schema;
};

1;
__END__

=head1 NAME

Mango::Schema - Schema class for Mango

=head1 SYNOPSIS

    use Mango::Schema;
    my $schema = Mango::Schema->connect;
    my $roles = $schema->resultset('Roles')->search;

=head1 DESCRIPTION

Mango::Schema is the schema classes used to interact with the database.

=head1 METHODS

=head2 connect

=over

=item Arguments: $dsn, $user, $password, \%attr

=back

Creates a new schema instance and uses Mango::Exception to catch all
db related errors.

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
