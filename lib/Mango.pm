package Mango;
use Moose;
use MooseX::ClassAttribute;
use MooseX::Types::Path::Class;
use File::ShareDir ();
use Path::Class    ();

our $VERSION = '0.01000_14';

class_has 'share' => (
    is     => 'rw',
    isa    => 'Dir',
    coerce => 1
);

around 'share' => sub {
    my ( $next, $self, $share ) = @_;
    my $dir = Path::Class::dir( $INC{'Mango.pm'} );

    if ($share) {
        $next->( $self, $share );
    }

    return Path::Class::Dir->new(
             $ENV{'MANGO_SHARE'}
          || $self->meta->get_class_attribute_value('share')
          ||

          ## blib?
          (
              $INC{'Mango.pm'} =~ /blib/
            ? $dir->parent->parent->parent->subdir('share')
            : undef
          )
          ||

          ## use share, unless errors on local -I no share
          eval { File::ShareDir::module_dir('Mango') } ||

          ## try for -Ilib/Mango.pm../../share
          $dir->parent->parent->subdir('share')
    );
};

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Mango - An ecommerce solution using Catalyst, Handel and DBIx::Class

=head1 SYNOPSIS

    use Mango;
    print Mango->share;

=head1 DESCRIPTION

This is a generic class containing the default configuration used by other
Mango classes.

To learn more about what Mango is and how it works, take a look at the
L<manual|Mango::Manual>.

=head1 METHODS

=head2 share

=over

=item Arguments: $share_path

=back

Gets/sets the location of the Mango share directory where the default
dist templates are stored.

    print $self->share;

If the C<ENV> variable C<MANGO_SHARE> is set, that will be returned instead.

=head1 SEE ALSO

L<Mango::Manual>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
