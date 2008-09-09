#!perl -w
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Test::More tests => 42;

    use_ok('Mango::Object');
    use_ok('Mango::Object::Meta');
    use_ok('Mango::Exception', ':try');
    use_ok('Mango::Provider');
};


## non-attached object
{
    my $object = Mango::Object->new;
    isa_ok($object, 'Mango::Object');

    isa_ok($object->meta, 'Mango::Object::Meta');
};


## make sure update/destroy pass through
{
    my $object = Mango::Object->new;
    isa_ok($object, 'Mango::Object');
    isa_ok($object->meta, 'Mango::Object::Meta');

    $object->meta->provider(
        Mango::Provider->new
    );

    try {
        local $ENV{'LANG'} = 'en';
        $object->destroy;

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Not implemented from base provider');
        like(shift, qr/overriden/i, 'not implemented');
    } otherwise {
        fail('Other exception thrown');
    };

    try {
        local $ENV{'LANG'} = 'en';
        $object->update;

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Not implemented from base provider');
        like(shift, qr/overriden/i, 'not implemented');
    } otherwise {
        fail('Other exception thrown');
    };
};


## create a new object
{
    my $provider = Mango::Provider->new;
    my $object = Mango::Object->new({
        col1 => 'Foo',
        col2 => 'Bar',
        meta => {
            provider => $provider
        }
    });

    isa_ok($object, 'Mango::Object');
    is($object->get_column('col1'), 'Foo');
    is($object->get_column('col2'), 'Bar');

    isa_ok($object->meta, 'Mango::Object::Meta');
    is($object->meta->provider, $provider);

    my %columns = $object->get_columns;
    is(scalar keys %columns, 2);
    is($columns{'col1'}, $object->get_column('col1'));
    is($columns{'col2'}, $object->get_column('col2'));

    $object->set_column('col3', 'Quix');
    is($object->get_column('col3'), 'Quix');

    my %columns2 = $object->get_columns;
    is(scalar keys %columns2, 3);
};


## check id/created/updates
{
    my $provider = Mango::Provider->new;
    my $object = Mango::Object->new({
        id => 'Foo',
        created => 'Bar',
        updated => 'Baz',
        meta => {
            provider => $provider
        }
    });

    isa_ok($object, 'Mango::Object');
    is($object->id, 'Foo');
    is($object->created, 'Bar');
    is($object->updated, 'Baz');

    isa_ok($object->meta, 'Mango::Object::Meta');
    is($object->meta->provider, $provider);

    my %columns = $object->get_columns;
    is(scalar keys %columns, 3);
    is($columns{'id'}, $object->id);
    is($columns{'created'}, $object->created);
    is($columns{'updated'}, $object->updated);

    $object->id('Quix');
    is($object->id, 'Quix');

    my %columns2 = $object->get_columns;
    is(scalar keys %columns2, 3);
};


## use another meta class
{
    my $provider = Mango::Provider->new;
    my $object = Mango::Object->new({
        meta_class => 'Mango::Test::Meta',
        meta => {
            provider => $provider
        }
    });

    isa_ok($object, 'Mango::Object');
    #is(Mango::Object->meta_class, 'Mango::Object::Meta');
    is($object->meta_class, 'Mango::Test::Meta');
    isa_ok($object->meta, 'Mango::Test::Meta');
    is($object->meta->provider, $provider);
};


## set_component_class goes boom if class can't be loaded
{
    try {
        local $ENV{'LANG'} = 'en';
        Mango::Object->meta_class('JunkPoopGarbage');

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/loaded/i, 'class cant be loaded');
    } otherwise {
        fail('Other exception thrown');
    };
};


## set_component_class goes boom if no class is specified
{
    try {
        local $ENV{'LANG'} = 'en';
        Mango::Object->meta_class('');

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/no.*specified/i, 'class not specified');
    } otherwise {
        fail('Other exception thrown');
    };
};