## no critic
# $Id$
package Mango::I18N::en;
use strict;
use warnings;
use utf8;
use vars qw/%Lexicon/;

BEGIN {
    use base qw/Mango::I18N/;
};

%Lexicon = (
    Language => 'English',

    "RESOURCE_NOT_FOUND" =>
        "Resource Not Found",

    "RESOURCE_NOT_FOUND_MESSAGE" =>
        "The requested resource was not found on this server.",

);

1;
__END__

=head1 NAME

Mango::I18N::en_us - Mango Language Pack: US English

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
