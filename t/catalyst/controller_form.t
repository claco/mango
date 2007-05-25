#!perl -wT
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test tests => 15;
    use Mango::Test::Catalyst;
    use File::Spec::Functions qw/catdir catfile/;
    use File::Path qw/mkpath/;
    use File::Copy qw/copy/;

    use_ok('Mango::Catalyst::Controller::Form');
    use_ok('Mango::Exception', ':try');
};

## put a temp root in var and copy some forms
{
    my $var = catdir('t', 'var');
    my $dir = catdir($var, qw/root forms form/);
    mkdir($var) unless -d $var;
    mkpath($dir);
    copy(catfile(qw/share forms admin products create.yml/), $dir);
    copy(catfile(qw/share forms admin products edit.yml/), $dir);
};


## load forms using class2prefix
{
    my $c = Mango::Test::Catalyst->new({
        config => {
            home => catdir(qw/t var/)
        }
    });
    my $controller = $c->controller('Form');
};