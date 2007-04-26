# $Id$
package Mango::Catalyst::Plugin::Authentication::AnonymousUser;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Plugin::Authentication::User/;

    use Mango::Exception ();
};
__PACKAGE__->mk_accessors(qw/password/);

sub new {
    my ($class, $c) = @_;
    my $name = $c->config->{authentication}{mango}{model};
    my $model = $c->model($name);

    Mango::Exception->throw('MODEL_NOT_FOUND', $name) unless $model;

    my $user = $model->result_class->new({
        username => 'anonymous'
    });

    return bless {_context => $c, _user => $user}, $class;
};

sub roles {

};

sub profile {
    my $self = shift;
    my $name = $self->_context->config->{profiles}{mango}{model};
    my $model = $self->_context->model($name);

    Mango::Exception->throw('MODEL_NOT_FOUND', $name) unless $model;

    if (!$self->_profile) {
        $self->_profile(
            $model->result_class->new({
                first_name => 'Anonymous',
                last_name => 'User'
            })
        );
    };

    return $self->_profile;
};

sub supported_features {
    my $self = shift;

    return {
        roles => 1,
        profiles => 1,
        carts => 1
    };
};

1;
__END__
