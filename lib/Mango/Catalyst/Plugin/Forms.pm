# $Id$
package Mango::Catalyst::Plugin::Forms;
use strict;
use warnings;
our $VERSION = $Mango::VERSION;

BEGIN {
    use base qw/Class::Accessor::Grouped/;
    use Mango ();
    use Scalar::Util qw/blessed/;
    use Clone();

    __PACKAGE__->mk_group_accessors('inherited', qw/_forms/);
};
__PACKAGE__->_forms({});

sub add_form {
    my ($self, $form, $name) = @_;

    if (blessed $form && $form->isa('Mango::Form')) {
        $name ||= $form->id || $form->name;
        $self->_forms->{$name} = $form;
    } else {
        Mango::Exception->throw('NOT_A_FORM');
    };

    return;
};

sub forms {
    my ($self, $name) = @_;

    if (my $form = $self->_forms->{$name}) {
        $form = Clone::clone($form);
        $form->action($self->request->uri->as_string) unless $form->action;
        $form->params($self->request);
        $form->localizer(
            sub {$self->localize(@_)}
        );    

        return $form;
    };

    return;
};

1;
__END__
