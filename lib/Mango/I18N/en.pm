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

    RESOURCE_NOT_FOUND =>
        'Resource Not Found',
    RESOURCE_NOT_FOUND_MESSAGE =>
        'The requested resource was not found on this server.',
    UNAUTHORIZED =>
        'Unauthorized',
    UNAUTHORIZED_MESSAGE =>
        'The requested resource requires user authentication.',
    UNHANDLED_EXCEPTION =>
        'An unhandled error has occurred',
    VIRTUAL_METHOD =>
        'This method must be overriden!',
    METHOD_NOT_IMPLEMENTED =>
        'Method not implemented!',
    COMPCLASS_NOT_LOADED =>
        'The component class [_1] [_2] could not be loaded: [_3]',
    SCHEMA_SOURCE_NOT_SPECIFIED =>
        'No schema_source is specified!',
    SCHEMA_SOURCE_NOT_FOUND =>
        'Schema source [_1] not found!',
    SCHEMA_CLASS_NOT_SPECIFIED =>
        'No schema_class is specified!',
    PROVIDER_CLASS_NOT_SPECIFIED =>
        'No provider class is specified!',
    PROVIDER_CLASS_NOT_LOADED =>
        'The provider [_1] could not be loaded: [_2]!',
    NOT_A_ROLE =>
        'The object is not a Mango::Role object',
    NOT_A_USER =>
        'The object is not a Mango::User object',
    NOT_A_TAG =>
        'The object is not a Mango::Tag object',
    NOT_A_ATTRIBUTE =>
        'The object is not a Mango::Attribute object',
    NOT_A_PRODUCT =>
        'The object is not a Mango::Product object',
    NOT_A_ORDER =>
        'The object is not a Mango::Order object',
    NOT_A_CART =>
        'The object is not a Mango::Cart object',
    NOT_A_WISHLIST =>
        'The object is not a Mango::Wishlist object',
    NOT_A_PROFILE =>
        'The object is not a Mango::Profile object',
    NO_USER_SPECIFIED =>
        'No user was specified',
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
