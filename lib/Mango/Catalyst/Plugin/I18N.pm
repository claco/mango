# $Id$
package Mango::Catalyst::Plugin::I18N;
use strict;
use warnings;
our $VERSION = $Mango::VERSION;

BEGIN {
    use Mango ();
    use Mango::I18N ();
    use I18N::LangTags ();
    use I18N::LangTags::Detect ();
    use NEXT;
    use Scalar::Util qw/blessed/;
};

sub setup {
    my $self = shift;
    $self->NEXT::setup(@_);

    my $class = blessed $self || $self;
    my $custom = $self->config->{'i18n_class'} || "$class\:\:I18N";

    if (eval "require $custom") {
        $self->config->{'i18n_class'} = $custom;
    } elsif (eval "require $class\:\:L10N") {
        $self->config->{'i18n_class'} = "$class\:\:L10N";
    } else {
        delete $self->config->{'i18n_class'};
    };
};

*lang = \&language;

sub language {
    my ($c, $language) = @_;

    if ($language) {
        $c->languages($language);
    };

    my $class = $c->config->{'i18n_class'} || 'Mango::I18N';
    my $lang = ref $class->get_handle(@{$c->languages});
    $lang =~ s/.*:://;

    return $lang;
};

*langs = \&languages;

sub languages {
    my ($c, $languages) = @_;

    if ($languages) {
        $c->{'languages'} = ref($languages) eq 'ARRAY' ? $languages : [ split(/,\s*/, $languages) ];
        delete $c->{'__mango_i18n_handle'};
    } else {
        $c->{languages} ||= [
            I18N::LangTags::implicate_supers(
                I18N::LangTags::Detect->http_accept_langs(
                    $c->request->header('Accept-Language')
                )
            ),
            'i-default'
        ];
    };

    return $c->{languages};
};

*loc = \&localize;

sub localize {
    my ($c, $text) = (shift, shift);
    my $changed;

    if ($c->config->{'i18n_class'}) {
        if (!$c->{'__mango_app_i18_handle'}) {
            $c->{'__mango_app_i18_handle'} = $c->config->{'i18n_class'}->get_handle(@{$c->languages});
        };

        my $loc = $c->{'__mango_app_i18_handle'}->maketext($text, @_);

        ## bail if text was localized
        return $loc unless $loc eq $text;
    };

    if (!$c->{'__mango_i18n_handle'}) {
        $c->{'__mango_i18n_handle'} = Mango::I18N->get_handle(@{$c->languages});
    };

    return $c->{'__mango_i18n_handle'}->maketext($text, @_);
};

1;
__END__

=head1 NAME

Mango::Catalyst::Plugin::I18N - Custom Catalyst I18N Plugin

=head1 SYNOPSIS

    use Catalyst qw/
        -Debug
        ConfigLoader
        +Mango::Catalyst::Plugin::I18N
        Static::Simple
    /;
    
    $c->localize('Hello [_1]', 'world');

=head1 DESCRIPTION

Mango::Catalyst::Plugin::I18N is a custom Catalyst plugin for localizing text
messages within a Mango application.

=head1 CONFIGURATION

The following configuration variables are available:

=over

=item i18n_class

If specific, this is the name of the class to be used to localize text. The
class can be any class that supports the Locale::MAketext interface.

IF no class is specified, $appname::I18N will be loaded. IF that does not
exist, $appname::L10N will be loaded.

=back

=head1 METHODS

=head2 lang

Same as L</language>.

=head2 language

Returns the first supported language from the first available localization
class.

=head2 langs

Same as L</languages>.

=head2 languages

Returns an array reference containing the list of requested languages from
%ENV/Accept-Language.

=head2 loc

Same as L</localize>.

=head2 localize

=over

=item Arguments: $text, @args

=back

Localizes the given text using the first available localization class
(i18n_class, $appname::I18N, $appname::L10N). If the text appears unchanged,
Mango::I18N will be called to localize the text as a last resort.

=head2 setup

Called by Catalyst when loading the plugin.

=head1 SEE ALSO

L<Mango::I18N>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
