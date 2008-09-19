## no critic (ProhibitPackageVars)
# $Id$
package Mango::I18N::ru;
use strict;
use warnings;
use utf8;
use vars qw/%Lexicon/;

BEGIN {
    use base qw/Mango::I18N/;
}

%Lexicon = (
    Language => 'русском',

    RESOURCE_NOT_FOUND => 'Resource Not Found Ru',
);

1;
__END__

=head1 NAME

Mango::I18N::ru - Mango Language Pack: Russian

=head1 SYNOPSIS

    use Mango::I18N qw/translate/;

    {
        local $ENV{'LANG'} = 'ru';
        print translate('Hello');
    };

=head1 DESCRIPTION

Mango::I18N::ru contains all of the messages used in Mango in Russian.

=head1 SEE ALSO

L<Mango::I18N>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
