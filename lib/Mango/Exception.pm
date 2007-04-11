# $Id: Exception.pm 1708 2007-02-04 02:33:21Z claco $
package Mango::Exception;
use strict;
use warnings;

BEGIN {
    use base qw/Error/;
    use Mango::I18N qw/translate/;
};

my $lh = Mango::I18N->get_handle;

sub new {
    my $class = shift;

    ## use the errors style args
    if (grep /^-/, @_) {
        my %args = @_;
        my $message = translate(delete $args{'-text'} || 'UNHANDLED_EXCEPTION');

        return $class->SUPER::new(
            -text => $message, %args
        );
    ## just a message/params
    } else {
        return $class->SUPER::new(
            -text => translate(shift || 'UNHANDLED_EXCEPTION', @_)
        );
    };
};

1;
__END__
