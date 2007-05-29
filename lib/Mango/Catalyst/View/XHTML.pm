# $Id$
package Mango::Catalyst::View::XHTML;
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

my $htemplates = Path::Class::Dir->new(File::ShareDir::dist_dir('Mango'), 'templates', 'tt', 'html');
my $xtemplates = Path::Class::Dir->new(File::ShareDir::dist_dir('Mango'), 'templates', 'tt', 'xhtml');

sub process {
    my ($self, $c) = (shift, shift);

    @{$self->include_path} = (
        $c->path_to('root', 'templates', 'tt', 'xhtml'),
        $c->path_to('root', 'templates', 'tt', 'html'),
        $htemplates,
        $xtemplates
    );

    $self->NEXT::process($c, @_);
    $c->response->content_type('application/xhtml+xml; charset=utf-8');

    return 1;
};

1;
__END__

=head1 NAME

Mango::Catalyst::View::XHTML - View class for XHTML output

=head1 SYNOPSIS

    $c->view('XHTML');

=head1 DESCRIPTION

Mango::Catalyst::View::XHTML renders content using Catalyst::View::TT and
serves it with the following content type:

    application/xhtml+xml; charset=utf-8

=head1 METHODS

=head2 process

Creates XHTML content, writes it to the response body, and changes the content
type. There is usually no reason to call this method directly. Forward to this
view instead:

    $c->forward($c->view('XHTML'));

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
