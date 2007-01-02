package Mango::Setup::Controller::Setup;
use strict;
use warnings;

BEGIN {
    use base qw/Catalyst::Controller/;
    eval 'use DBI';
    eval 'use Mango::Schema';
};

sub index : Private {
    my ($self, $c) = @_;
    $c->stash->{'template'} = 'setup/index';
};

sub requirements : Local {
    my ($self, $c) = @_;
    $c->stash->{'template'} = 'setup/requirements';

    my $requirements = $c->config->{'requirements'};
    my (@requirements, $has_requirements);

    foreach my $module (sort keys %{$requirements}) {
        eval "use $module";
        my $installed = ($@ ? 0 : 1);
        my $version   = $installed ? $module->VERSION : 0;
        my $requires  = $requirements->{$module};
        my $upgrade   = $version lt $requires ? 1 : 0;

        push @requirements, {
            'name'      => $module,
            'installed' => $installed,
            'version'   => $version,
            'upgrade'   => $upgrade,
            'requires'  => $requires
        };

        if ($installed && !$upgrade) {
            $has_requirements = 1;
        } else {
            $has_requirements = 0;
        };
    };

    $c->stash->{'requirements'} = \@requirements;

    if ($has_requirements) {
        $c->session->{'has_requirements'} = 1;
    };
};

sub database : Local {
    my ($self, $c) = @_;
    $c->stash->{'template'} = 'setup/database';

    if ($c->req->method eq 'GET') {
        my @drivers;
        my %supported = map {$_ => 1} @{$c->config->{'drivers'}};

        foreach my $driver (DBI->available_drivers) {
            if (exists $supported{$driver}) {
                push @drivers, $driver;
            };
        };

        $c->stash->{'drivers'} = \@drivers;
    } else {
        my $driver   = $c->req->param('driver');
        my $host     = $c->req->param('host');
        my $port     = $c->req->param('port');
        my $database = $c->req->param('database');
        my $dsn      = "dbi:$driver:$database";
        if ($host) {
            $dsn .= ":host=$host";
        };
        if ($port) {
            $dsn .= ":port=$port";
        };

        my $schema = Mango::Schema->connect(
            $dsn, $c->req->param('user'), $c->req->param('pass')
        );

        #eval {
            $schema->deploy;
        #};

        if ($@) {
            print $@;
        } else {
            
        };
    };
};

1;
__END__

=head1 NAME

Mango::Setup::Controller::Setup - Setup Controller for Mango::Setup

=head1 SYNOPSIS

    script/mango_setup_server.pl
    
    http://localhost:3000/setup/

=head1 DESCRIPTION

Mango::Setup::Controller::Setup is loaded by Mango::Setup.

=head1 METHODS

=head2 index



=head2 requirements

Checks that the local machine has the required modules loaded.

=head2 database

Installs the schema into a support database.

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
