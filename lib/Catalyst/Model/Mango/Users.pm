# $Id$
package Catalyst::Model::Mango::Users;
use strict;
use warnings;

BEGIN {
    use base qw/Catalyst::Model Class::Accessor::Grouped/;
    use Class::Inspector;
    use Catalyst::Exception;
};
__PACKAGE__->mk_group_accessors('inherited', qw/provider/);

sub COMPONENT {
    my $self = shift->new(@_);
    my $provider_class = delete $self->{'provider'} || 'Mango::Provider::Users';

    if (!Class::Inspector->loaded($provider_class)) {
        eval "use $provider_class"; ## no critic;
        if ($@) {
            Catalyst::Exception->throw(
                message => translate('Could not load cart class [_1]: [_2]', $provider_class, $@)
            );
        };
    };

    $self->provider(
        $provider_class->new({%{$self}})
    );

    return $self;
};

sub AUTOLOAD {
    my ($method) = (our $AUTOLOAD =~ /([^:]+)$/);
    return if $method =~ /(DESTROY|ACCEPT_CONTEXT)/;

    return shift->provider->$method(@_);
};

1;
__END__
