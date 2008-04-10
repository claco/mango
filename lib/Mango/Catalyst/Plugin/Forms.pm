# $Id$
package Mango::Catalyst::Plugin::Forms;
use strict;
use warnings;
our $VERSION = $Mango::VERSION;

BEGIN {
    use base qw/Class::Accessor::Grouped/;
    use Mango ();
    use Scalar::Util qw/blessed/;

    __PACKAGE__->mk_group_accessors( 'inherited', qw/_forms/ );
}
__PACKAGE__->_forms( {} );    ## no critic;

sub add_form {
    my ( $self, $form, $name ) = @_;

    if ( blessed $form && $form->isa('Mango::Form') ) {
        $name ||= $form->id || $form->name;
        $self->_forms->{$name} = $form;
    } else {
        Mango::Exception->throw('NOT_A_FORM');
    }

    return;
}

sub forms {
    my ( $self, $name ) = @_;

    if ( my $form = $self->_forms->{$name} ) {
        $form = $form->clone;

        ## hack around form action // under Cat::Test/Mech
        if ( $form->{'action'} || $form->action =~ /^\/\// ) {
            $form->action( $self->request->uri->as_string );
        }
        $form->params( $self->request );
        $form->localizer( sub { $self->localize(@_) } );

        return $form;
    }

    return;
}

1;
__END__

=head1 NAME

Mango::Catalyst::Plugin::Forms - Catalyst plugin for application wide forms

=head1 SYNOPSIS

    use Catalyst qw/
        -Debug
        ConfigLoader
        Mango::Catalyst::Plugin::Forms
        Static::Simple
    /;

=head1 DESCRIPTION

Mango::Catalyst::Plugin::Forms exposes all of the Mango forms loaded into the
current Mango application.

=head1 METHODS

=head2 add_form

=over

=item Arguments: $form, $name

=back

Adds a form by name to the collection of application forms. If not specified,
the name will be taken from the forms name attribute.

=head2 forms

Gets the collection of Mango::Form objects loaded into the current
application.

=head1 SEE ALSO

L<Mango::Catalyst::Controller::Form>, L<Mango::Form>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
