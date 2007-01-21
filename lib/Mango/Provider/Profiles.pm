# $Id$
package Mango::Provider::Profiles;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Provider::DBIC/;
};
__PACKAGE__->result_class('Mango::Profile');
__PACKAGE__->source_name('Profiles');

sub user_profile {
    my ($self, $user) = @_;

    if (Scalar::Util::blessed $user && $user->isa('Mango::User')) {
        $user = $user->id;
    };

    my $result = $self->resultset->find_or_create({
        'user_id' => $user
    });

    return $self->result_class->new({
        provider => $self,
        data => {$result->get_columns}
    })
};

1;
__END__
