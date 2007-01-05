package Mango::User;
use strict;
use warnings;

BEGIN {
    use base qw/Class::Accessor::Grouped/;
};
__PACKAGE__->mk_group_accessors('simple', qw/result/);

sub id {
    return shift->result->id(@_);
};

sub username {
    return shift->result->username(@_);
};

sub password {
    return shift->result->password(@_);
};

1;
