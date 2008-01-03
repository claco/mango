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
    COMCLASS_NOT_SPECIFIED =>
        'The component class [_1] was not specified',
    SCHEMA_SOURCE_NOT_SPECIFIED =>
        'No schema_source is specified!',
    SCHEMA_SOURCE_NOT_FOUND =>
        'Schema source [_1] not found!',
    SCHEMA_CLASS_NOT_SPECIFIED =>
        'No schema_class is specified!',
    PROVIDER_CLASS_NOT_SPECIFIED =>
        'No provider class is specified!',
    PROVIDER_CLASS_NOT_LOADED =>
        "The provider '[_1]' could not be loaded: [_2]!",
    VIEW_CLASS_NOT_LOADED =>
        "The view '[_1]' could not be loaded: [_2]!",
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
    NOT_A_FORM =>
        'The object is not a Mango::Form object',
    NO_USER_SPECIFIED =>
        'No user was specified',
    MODEL_NOT_FOUND =>
        "The model requested '[_1]' could not be found",
    FEED_NOT_FOUND =>
        'No feed data was specified',
    FEED_TYPE_NOT_SPECIFIED =>
        'No feed type was apsecified',
    REALM_NOT_FOUND =>
        'The realm \'mango\' could not be found',
    REALM_NOT_MANGO =>
        'The default realm is not \'mango\'',
    LOGIN_FAILED =>
        'The username or password are incorrect.',
    LOGIN_SUCCEEDED =>
        'Login successful!',
    LOGOUT_SUCCEEDED =>
        'Logout successful!',
    ALREADY_LOGGED_IN =>
        'You are already logged in!',
    USERNAME_NOT_BLANK =>
        'The username field is required.',
    PASSWORD_NOT_BLANK =>
        'The password field is required.',
    CART_IS_EMPTY =>
        'Your shopping cart is empty.',



    ## page titles
    PAGE_TITLE_HOME =>
        'Welcome!',
    PAGE_TITLE_CART =>
        'Cart',
    PAGE_TITLE_LOGIN =>
        'Login',
    PAGE_TITLE_LOGOUT =>
        'Logout',
    PAGE_TITLE_PRODUCTS =>
        'Products',


    ## link text
    LINK_TEXT_HOME =>
        'Home',
    LINK_TEXT_ADMIN =>
        'Admin',
    LINK_TEXT_CART =>
        'Cart',
    LINK_TEXT_LOGIN =>
        'Login',
    LINK_TEXT_LOGOUT =>
        'Logout',
    LINK_TEXT_PRODUCTS =>
        'Products',
    LINK_TEXT_WISHLISTS =>
        'Wishlists',


    ## field label text
    FIELD_LABEL_USERNAME =>
        'Username',
    FIELD_LABEL_PASSWORD =>
        'Password',
    FIELD_LABEL_QUANTITY =>
        'Quantity',


    ## form button text
    BUTTON_LABEL_LOGIN =>
        'Login',
    BUTTON_LABEL_ADD_TO_CART =>
        'Add to Cart',


    ## form constraint messages
    CONSTRAINT_USERNAME_NOT_BLANK =>
        'The username field is required.',
    CONSTRAINT_PASSWORD_NOT_BLANK =>
        'The password field is required.',
    CONSTRAINT_SKU_EXISTS =>
        'The sku or part requested could not be found.',
);

1;
__END__

=head1 NAME

Mango::I18N::en - Mango Language Pack: English

=head1 SYNOPSIS

    use Mango::I18N qw/translate/;

    {
        local $ENV{'LANG'} = 'en';
        print translate('Hello');
    };

=head1 DESCRIPTION

Mango::I18N::en contains all of the messages used in Mango in English.

=head1 SEE ALSO

L<Mango::I18N>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
