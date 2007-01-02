package Catalyst::Plugin::Mango::I18N;
use strict;
use warnings;

BEGIN {
    use base qw/Catalyst::Plugin::I18N/;
    use NEXT;
    require Locale::Maketext::Simple;
};

sub setup {
    my $self = shift;
    my $calldir = $self;
    $calldir =~ s#::#/#g;
    my $file = "$calldir.pm";
    my $path = $INC{$file};
    $path =~ s#(Setup|Web)\.pm$#/I18N#;

    eval <<"";
      package $self;
      import Locale::Maketext::Simple Path => '$path', Export => '_loc', Decode => 1;


    if ($@) {
        $self->log->error(qq/Couldn't initialize i18n "Mango\::I18N", "$@"/);
    } else {
        $self->log->debug(qq/Initialized i18n "Mango\::I18N"/) if $self->debug;
    };
};

1;
__END__
