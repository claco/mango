#!perl -wT
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test tests => 9;
    use Path::Class::File;

    use_ok('Mango::Form');
};


## empty source hash
{
    my $form = Mango::Form->new;
    isa_ok($form, 'Mango::Form');
    isa_ok($form->form, 'CGI::FormBuilder');
    isa_ok($form->validator, 'FormValidator::Simple');
    is_deeply($form->profile, []);
    is_deeply($form->messages, {});
};


## use a real form
{
    my $form = Mango::Form->new({
        source => Path::Class::File->new(qw/share forms admin products create.yml/)->stringify
    });
    isa_ok($form, 'Mango::Form');
    isa_ok($form->form, 'CGI::FormBuilder');
    isa_ok($form->validator, 'FormValidator::Simple');
};