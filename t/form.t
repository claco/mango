#!perl -w
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test tests => 17;
    use Mango::Test::Catalyst::Request;
    use Path::Class::File;

    use_ok('Mango::Form');
};


## empty source hash
{
    my $form = Mango::Form->new;
    isa_ok($form, 'Mango::Form');
    isa_ok($form->_form, 'CGI::FormBuilder');
    isa_ok($form->validator, 'FormValidator::Simple');
    is_deeply($form->profile, []);
    is_deeply($form->messages, {});
};


## use a real form
{
    local $ENV{'LANG'} = 'en';

    my $form = Mango::Form->new({
        source => Path::Class::File->new(qw/share forms admin products create.yml/)->stringify
    });
    isa_ok($form, 'Mango::Form');
    isa_ok($form->_form, 'CGI::FormBuilder');
    isa_ok($form->validator, 'FormValidator::Simple');

    ## all blank
    $form->params(Mango::Test::Catalyst::Request->new);
    my $results = $form->validate;
    ok(!$results->success);
    my $errors = $results->errors;
    is_deeply($errors, [
        'CONSTRAINT_SKU_NOT_BLANK',
        'The name field is required.',
        'CONSTRAINT_DESCRIPTION_NOT_BLANK',
        'CONSTRAINT_PRICE_NOT_BLANK'
    ]);

    ## too longs
    $form->params(Mango::Test::Catalyst::Request->new({
        sku => 'ABC-DEFGHJIKLMNOPQRSTUVWXYZ',
        name => 'Over twenty five characters',
        description => 'This description is over one hundred
            characters to anger the profile. If it does not work
            then thas is too bad',
        price => 1.234
    }));
    $results = $form->validate;
    ok(!$results->success);
    $errors = $results->errors;
    is_deeply($errors, [
        'CONSTRAINT_SKU_LENGTH',
        'CONSTRAINT_SKU_UNIQUE',
        'CONSTRAINT_NAME_LENGTH',
        'CONSTRAINT_DESCRIPTION_LENGTH',
        'CONSTRAINT_PRICE_DECIMAL'
    ]);

    ## not unique
    $form->params(Mango::Test::Catalyst::Request->new({
        sku => 'ABC-123',
        name => 'Name',
        description => 'Description',
        price => 1.23
    }));
    $results = $form->validate;
    ok(!$results->success);
    $errors = $results->errors;
    is_deeply($errors, [
        'CONSTRAINT_SKU_UNIQUE'
    ]);


    ## unique w/ custom sub
    $form->params(Mango::Test::Catalyst::Request->new({
        sku => 'ABC-123',
        name => 'Name',
        description => 'Description',
        price => 1.23
    }));
    $form->unique('sku', sub {1});
    $results = $form->validate;
    ok($results->success);
    $errors = $results->errors;
    is_deeply($errors, [

    ]);
};