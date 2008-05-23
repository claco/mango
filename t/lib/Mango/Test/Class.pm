# $Id$
package Mango::Test::Class;
use strict;
use warnings;

BEGIN {
    use base 'Test::Class';

    use Test::More;
    use Mango::Test ();
    use Path::Class ();
}

sub startup : Test(startup) {
    my $self = shift;
    my $app = Mango::Test->mk_app( undef, $self->config || {} );
    my $lib = Path::Class::dir( $app, 'lib' );
    eval "use lib '$lib';";

    $self->application($app);
    $ENV{'CATALYST_DEBUG'} = 0;

    $self->config_application;
    {
        local $SIG{__WARN__} = sub { };
        require Test::WWW::Mechanize::Catalyst;
        Test::WWW::Mechanize::Catalyst->import('TestApp');
    };
}

sub application {
    my ( $self, $application ) = @_;

    if ($application) {
        $self->{'application'} = $application;
    }

    return $self->{'application'};
}

sub config {};

sub config_application {};

sub client {
    return Mango::Test::Class::Mechanize->new;
}

sub path {};

sub validate_markup {
    my ($self, $content) = @_;

    ## stop fighting Test::HTML::W3C plan issues for now
    SKIP: {
        eval 'require WebService::Validator::HTML::W3C';
        skip 'WebService::Validator::HTML::W3C not installed', 1 if $@;

        my $v = WebService::Validator::HTML::W3C->new(
            detailed => 1
        );

        if ( $v->validate_markup($content) ) {
            if ( $v->is_valid ) {
                pass('content is valid');
            } else {
                my ($package, $filename, $line) = caller;
                my $message;
                foreach my $error ( @{$v->errors} ) {
                    $message .= sprintf("line: %s, column: %s error: %s\n", 
                            $error->line, $error->col, $error->msg);

                    my @lines = split(/\n/, $content);
                    $message .= '  ' . $lines[$error->line - 1] . "\n";
                }

                fail "content is not valid at $package line $line" or diag $message;;
            }
        } else {
            fail('Failed to validate the content: ' . $v->validator_error);
        }
    };
}

package Mango::Test::Class::Mechanize;
use strict;
use warnings;

BEGIN {
    use base 'Test::WWW::Mechanize::Catalyst';
}

sub form_id {
    my ( $self, $formid ) = @_;

    my $temp;
    my @matches =
      grep { defined( $temp = $_->attr('id') ) and ( $temp eq $formid ) }
      $self->forms;
    if (@matches) {
        $self->warn(
            "There are ",
            scalar @matches,
            " forms with id $formid. The first one was used."
        ) if @matches > 1;
        return $self->{form} = $matches[0];
    } else {
        $self->warn(qq{ There is no form with id "$formid"});
        return undef;
    }
}

sub submit_form_ok {
    my $self = shift;
    my $args = shift;

    if (my $id = delete $args->{'form_id'}) {
        $self->form_id($id);
    }

    return $self->SUPER::submit_form_ok($args, @_);
}

1;
