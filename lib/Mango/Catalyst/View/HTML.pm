# $Id$
package Mango::Catalyst::View::HTML;
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

my $share = File::ShareDir::dist_dir('Mango');
my @path  = qw/templates tt html/;

sub process {
    my ($self, $c) = (shift, shift);
    my $templates = Path::Class::Dir->new($ENV{'MANGO_SHARE'} || $share, @path);

    @{$self->include_path} = (
        $c->path_to('root', @path),
        $templates
    );

    $self->NEXT::process($c, @_);
    $c->response->content_type('text/html; charset=utf-8');

    return 1;
};

1;
__END__

=head1 NAME

Mango::Catalyst::View::HTML - View class for HTML output

=head1 SYNOPSIS

    $c->view('HTML');

=head1 DESCRIPTION

Mango::Catalyst::View::HTML renders content using Catalyst::View::TT and
serves it with the following content type:

    text/html; charset=utf-8

=head1 METHODS

=head2 process

Creates HTML content, writes it to the response body, and changes the content
type. There is usually no reason to call this method directly. Forward to this
view instead:

    $c->forward($c->view('HTML'));

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
