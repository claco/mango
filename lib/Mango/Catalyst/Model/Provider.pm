# $Id$
package Mango::Catalyst::Model::Provider;
use strict;
use warnings;

BEGIN {
    use base qw/Catalyst::Model Class::Accessor::Grouped/;
    use Class::Inspector ();
    use Mango::Exception ();

    __PACKAGE__->mk_group_accessors('inherited', qw/provider/);
};

sub COMPONENT {
    my $self = shift->new(@_);
    my $provider_class = delete $self->{'provider'};

    if (!$provider_class) {
        throw Mango::Exception('PROVIDER_CLASS_NOT_SPECIFIED');
    };

    if (!Class::Inspector->loaded($provider_class)) {
        eval "use $provider_class"; ## no critic;
        if ($@) {
            Mango::Exception->throw('PROVIDERCLASS_NOT_LOADED', $provider_class, $@);
        };
    };

    $self->provider(
        $provider_class->new({
            connection_info => $_[0]->config->{'connection_info'},
            %{$self}
        })
    );
warn %{$self->provider};
    return $self;
};

sub AUTOLOAD {
    my ($method) = (our $AUTOLOAD =~ /([^:]+)$/);
    return if $method =~ /(DESTROY|ACCEPT_CONTEXT)/;

    return shift->provider->$method(@_);
};

1;
__END__
