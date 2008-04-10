# $Id$
package Mango::Catalyst::Model::Provider;
use strict;
use warnings;

BEGIN {
    use base qw/Catalyst::Model Class::Accessor::Grouped/;
    use English '-no_match_vars';
    use Scalar::Util qw/blessed/;
    use Class::Inspector ();
    use Mango::Exception ();

    __PACKAGE__->mk_group_accessors( 'inherited',
        qw/_provider_class _provider/ );
}

sub COMPONENT {
    my $self = shift->new(@_);

    if ( my $provider_class = delete $self->{'provider_class'} ) {
        $self->provider_class($provider_class);
    }

    if ( !$self->provider_class ) {
        Mango::Exception->throw('PROVIDER_CLASS_NOT_SPECIFIED');
    }

    ## hack for Handel Storage setup
    ## should fix this
    my %config = %{$self};
    delete $config{'_provider_class'};
    delete $config{'_provider'};

    $self->provider(
        $self->provider_class->new(
            {
                connection_info => $_[0]->config->{'connection_info'},
                %config
            }
        )
    );

    return $self;
}

sub provider_class {
    my ( $self, $provider_class ) = @_;

    if ($provider_class) {
        if ( !Class::Inspector->loaded($provider_class) ) {
            eval "use $provider_class";    ## no critic;
            if ($EVAL_ERROR) {
                Mango::Exception->throw( 'PROVIDER_CLASS_NOT_LOADED',
                    $provider_class, $EVAL_ERROR );
            }
        }

        $self->_provider_class($provider_class);
    }

    return $self->_provider_class;
}

sub provider {
    my ( $self, $provider ) = @_;

    if ($provider) {
        $self->_provider($provider);
    } elsif ( !$self->_provider ) {

        ## hack for Handel Storage setup
        ## should fix this
        my %config = %{$self};
        delete $config{'_provider_class'};
        delete $config{'_provider'};

        $self->_provider( $self->provider_class->new( \%config ) );
        $self->_provider_class( blessed $provider);
    }

    return $self->_provider;
}

sub AUTOLOAD {
    my ($method) = ( our $AUTOLOAD =~ /([^:]+)$/ );
    return if $method =~ /(DESTROY|ACCEPT_CONTEXT)/;

    return shift->provider->$method(@_);
}

1;
__END__

=head1 NAME

Mango::Catalyst::Model::Provider - Catalyst model for Mango::Provider classes

=head1 SYNOPSIS

    package MyApp::Model::Provider;
    use base 'Mango::Catalyst::Model::Provider';

=head1 DESCRIPTION

Mango::Catalyst::Model::Provider provides glue between Mango::Providers and
Catalyst models

=head1 CONFIGURATION

The following configuration options are used directly by this model:

=over

=item provider_class

See L</provider_class> for more information.

=back

All other configuration options are passed directly into
L<Mango::Provider/setup> for use by the providers themselves.

=head1 METHODS

=head2 COMPONENT

Creates an instance of the specified provider class, configures it and returns
the new model.

=head2 AUTOLOAD

Forwards all method calls to the underlying provider instance.

    my $it = $model->search;
    
    ## same as this, but don't do that
    my $it = $model->provider->search;

=head2 provider_class

=over

=item Arguments: $provider_class

=back

Gets/sets the provider class to be used by the current model.

    $model->provider_class('Mango::Provider::Carts');
    print ref $model->provider;  # Mango::Provider::Carts    

=head2 provider

Gets/sets the provider instance to used by the current model.

    my $provider = $model->provider;

If the provider class is specified and no provider instance exists, one will
be created automatically using the available configuration.

=head1 SEE ALSO

L<Mango::Provider>, L<Mango::Provider::DBIC>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
