# $Id$
package Mango::Form::Results;
use strict;
use warnings;

BEGIN {
    use base qw/Class::Accessor::Grouped/;

    __PACKAGE__->mk_group_accessors( 'simple', qw/_results errors/ );
}

sub new {
    my ( $class, $args ) = @_;

    return bless $args || {}, $class;
}

sub success {
    my $self = shift;

    return $self->_results->success;
}

1;
__END__

=head1 NAME

Mango::Form::Results - Module representing form validation results

=head1 SYNOPSIS

    my $form = Mango::Form->new({
        source => 'path/to/some/config.yml'
    });
    my $results = $form->validate;
    if (!$results->success) {
        print @{$results->errors};
    };

=head1 DESCRIPTION

Mango::Form::Results contains for validation results.

=head1 CONSTRUCTOR

=head2 new

Creates a new Mango::Form::Results object.

=head1 METHODS

=head2 errors

Returns an array reference containing the localized errors while
validating the form data.

=head2 success

Returns true if form validation succeeded; false otherwise.

=head1 SEE ALSO

L<Mango::Form::Results>, L<CGI::FormBuilder>, L<FormValidator::Simple>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
