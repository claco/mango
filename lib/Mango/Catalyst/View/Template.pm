# $Id$
package Mango::Catalyst::View::Template;
use strict;
use warnings;

BEGIN {
    use base qw/Catalyst::View Class::Accessor::Grouped/;
    use Mango::Exception ();
    use File::ShareDir ();

    __PACKAGE__->mk_group_accessors('inherited', qw/wrapper content_type share_paths root_paths template_paths/);
    __PACKAGE__->mk_group_accessors('simple', qw/view_instance/);
};
__PACKAGE__->view_class('Catalyst::View::TT');
__PACKAGE__->share(File::ShareDir::dist_dir('Mango'));
__PACKAGE__->wrapper('wrapper');

sub new {
    my $self = shift->NEXT::new(@_);
    my $c = $_[0];
    my $view = 'tt';

    $self->view_instance(
        $self->view_class->new(@_)
    );

    if ($self->view_class =~ /^Catalyst::View::(.*)$/) {
        $view = lc $1;
        $view =~ s/\:\:/-/;
    };

    $self->template_paths([]);
    foreach my $path (@{$self->root_paths}) {
        $path = $c->path_to('root', $path);
        $path =~ s/\%view/$view/g;

        push @{$self->template_paths}, $path;
    };
    foreach my $path (@{$self->share_paths}) {
        $path = Path::Class::Dir->new($self->share, $path);
        $path =~ s/\%view/$view/g;

        push @{$self->template_paths}, $path;
    };

    @{$self->view_instance->include_path} = (@{$self->template_paths});

    return $self;
};

sub share {
    my ($self, $share) = @_;

    if ($share) {
        $self->set_inherited('share', $share);
    };

    return $ENV{'MANGO_SHARE'} || $self->get_inherited('share');
};

sub view_class {
    my ($self, $view) = @_;
    my $class = ref $self || $self;

    if ($view) {
        no strict 'refs';

        eval "require $view";
        Mango::Exception->throw('VIEW_CLASS_NOT_LOADED', $view, $@) if $@;

        $self->set_inherited('view_class', $view);
    };

    $self->get_inherited('view_class');
};

sub process {
    my $self = shift;
    my $c = $_[0];

    my $result = $self->view_instance->process(@_);

    if ($self->content_type) {
        $_[0]->response->content_type($self->content_type);
    };

    return $result;
};

1;
__END__
