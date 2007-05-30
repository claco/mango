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

=head1 TEMPLATES

When Mango is installed, its stock html templates are stored in:

    %PERLINST%/site/lib/auto/Mango/templates/tt/html

When templates are rendered, the following directories are used:

    root/templates/tt/html
    %PERLINST%/site/lib/auto/Mango/templates/tt/html

You can override any default template by creating a template file of the same
name in your local application template directory.

If you want to use templates from a different shared directory, you can set
$ENV{'MANGO_SHARE'}:

    $ENV{'MANGO_SHARE'} = '/usr/local/share/Mango';

Now, the template search path will be:

    root/templates/tt/html
    /usr/local/share/Mango/templates/tt/html

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
