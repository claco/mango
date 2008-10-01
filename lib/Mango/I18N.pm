## no critic (ProhibitPackageVars)
package Mango::I18N;
use Moose;
use utf8;
use vars qw/@EXPORT_OK %Lexicon $handle/;

extends qw/Locale::Maketext Exporter/;

@EXPORT_OK = qw(translate);

%Lexicon = ( _AUTO => 1 );

sub translate {
    my $handle = __PACKAGE__->get_handle;
    my $text;

    eval { $text = $handle->maketext(@_); };

    return defined $text ? $text : shift;
}

1;
__END__

=head1 NAME

Mango::I18N - Message localization support for Mango

=head1 SYNOPSIS

    use Mango::I18N qw/translate/;
    
    warn translate('This is my message');

=head1 DESCRIPTION

Mango::I18N is the module responsible for message localization support in
Mango. It is a subclass of C<Locale::Maketext>. By default it doesn't
export anything. You can either use it directly:

    use Mango::I18N;
    
    warn Mango::I18N::translate('My message');

or export L</translate> into the callers namespace:

    use Mango::I18N qw/translate/;
    
    warn translate('My message');

If you have the time and can do a language, the help would be much
appreciated. If you're going to email a translation module, please Gzip it
first. It's not uncommon for an email server or client along the way to trash
UTF-8 characters in the .pm attachment text.

=head1 FUNCTIONS

=head2 translate

=over

=item Arguments: $message

=back

Translates the supplied text into the appropriate language if available. If no
match is available, the original text is returned.

    print translate('foo was here');

=head1 SEE ALSO

L<Locale::Maketext>, L<Mango::I18N::en>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
