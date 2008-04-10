# $Id$
package Mango::Exception;
use strict;
use warnings;

BEGIN {
    use base qw/Error/;

    use List::MoreUtils ();
    use Mango::I18N qw/translate/;
}

my $lh = Mango::I18N->get_handle;

sub new {
    my $class = shift;

    ## use the errors style args
    if ( List::MoreUtils::any( sub { $_ =~ /^-/ }, @_ ) ) {
        my %args = @_;
        my $message =
          translate( delete $args{'-text'} || 'UNHANDLED_EXCEPTION' );

        return $class->SUPER::new(
            -text => $message,
            %args
        );
        ## just a message/params
    } else {
        return $class->SUPER::new(
            -text => translate( shift || 'UNHANDLED_EXCEPTION', @_ ) );
    }
}

1;
__END__

=head1 NAME

Mango::Exception - Module representing an exception or error condition

=head1 SYNOPSIS

    use Mango::Exception;
    
    Mango::Exception->throw('Boom!');

=head1 DESCRIPTION

Mango:Exception is a subclass of Error that does some custom message
processing for Mango based exceptions.

=head1 CONSTRUCTOR

=head2 new

=over

=item Arguments: %args or $message

=back

When creating or throwing a new exception, you can pass in Error-style
arguments, or just a plain old message string.

    Mango::Exception->throw('Boom!');
    Mango::Exception->throw(-text => 'Boom!', -line => 27, ...);

Any message passed in will automatically be translated using Mango::I18N.

=head1 SEE ALSO

L<Mango::I18N>, L<Error>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
