# $Id$
package Catalyst::Plugin::Mango::I18N;
use strict;
use warnings;
our $VERSION = $Mango::VERSION;

BEGIN {
    use Mango::I18N ();
    use I18N::LangTags ();
    use I18N::LangTags::Detect ();
    use Mango ();
};

sub language {
    my ($c, $language) = @_;

    if ($language) {
        $c->languages($language);
    };

    my $lang = ref Mango::I18N->get_handle(@{$c->languages});
    $lang =~ s/.*:://;

    return $lang;
};

sub languages {
    my ($c, $languages) = @_;

    if ($languages) {
        $c->{'languages'} = ref($languages) eq 'ARRAY' ? $languages : [ split(/,/, $languages) ];
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
}

*loc = \&localize;

sub localize {
    my $c = shift;

    if (!$c->{'__mango_i18n_handle'}) {
        $c->{'__mango_i18n_handle'} = Mango::I18N->get_handle(@{$c->languages});
    };

    return $c->{'__mango_i18n_handle'}->maketext(@_);
}

1;
__END__
