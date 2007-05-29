# $Id$
package Mango::Catalyst::View::Text;
use strict;
use warnings;

BEGIN {
    use base qw/Catalyst::View::TT/;
    use File::ShareDir ();
    use Path::Class ()
};

__PACKAGE__->config(
    WRAPPER => 'wrapper'
);

my $templates = Path::Class::Dir->new(File::ShareDir::dist_dir('Mango'), 'templates', 'tt', 'text');

sub process {
    my ($self, $c) = (shift, shift);

    @{$self->include_path} = (
        $c->path_to('root', 'templates', 'tt', 'text'),
        $templates
    );

    $self->NEXT::process($c, @_);
    $c->res->content_type('text/plain; charset=utf-8');

    return 1;
};

1;
__END__

=head1 NAME

Mango::Catalyst::View::Text - View class for Text output

=head1 SYNOPSIS

    $c->view('Text');

=head1 DESCRIPTION

Mango::Catalyst::View::Text renders content using Catalyst::View::TT and
serves it with the following content type:

    text/plain; charset=utf-8

=head1 METHODS

=head2 process

Creates plain text content, writes it to the response body, and changes the
content type. There is usually no reason to call this method directly. Forward
to this view instead:

    $c->forward($c->view('Text'));

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
