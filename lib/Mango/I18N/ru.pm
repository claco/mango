## no critic
# $Id$
package Mango::I18N::ru;
use strict;
use warnings;
use utf8;
use vars qw/%Lexicon/;

BEGIN {
    use base qw/Mango::I18N/;
};

%Lexicon = (
    Language => 'русском',

    "RESOURCE_NOT_FOUND" =>
        "Ресурсов не найдено",

    "RESOURCE_NOT_FOUND_MESSAGE" =>
        "Запрашиваемый ресурс не найден на этом сервере.",

);

1;
__END__

=head1 NAME

Mango::I18N::ru - Mango Language Pack: Russian

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
