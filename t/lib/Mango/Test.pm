# $Id$
package Mango::Test;
use strict;
use warnings;

BEGIN {
    # little trick by Ovid to pretend to subclass+exporter Test::More
    use base qw/Test::Builder::Module Class::Accessor::Grouped/;
    use Test::More;
    use File::Spec::Functions qw/catfile catdir/;
    use DateTime ();

    @Mango::Test::EXPORT = @Test::More::EXPORT;

    __PACKAGE__->mk_group_accessors('inherited', qw/db_dir db_file/);
};

__PACKAGE__->db_dir(catdir('t', 'var'));
__PACKAGE__->db_file('mango.db');

## cribbed and modified from DBICTest in DBIx::Class tests
sub init_schema {
    my ($self, %args) = @_;
    my $db_dir  = $args{'db_dir'}  || $self->db_dir;
    my $db_file = $args{'db_file'} || $self->db_file;
    my $namespace = $args{'namespace'} || 'Mango::TestSchema';
    my $db = catfile($db_dir, $db_file);

    eval 'use DBD::SQLite';
    if ($@) {
       BAIL_OUT('DBD::SQLite not installed');

        return;
    };

    eval 'use Mango::Test::Schema';
    if ($@) {
        BAIL_OUT("Could not load Mango::Test::Schema: $@");

        return;
    };

    unlink($db) if -e $db;
    unlink($db . '-journal') if -e $db . '-journal';
    mkdir($db_dir) unless -d $db_dir;

    my $dsn = 'dbi:SQLite:' . $db;
    my $schema = Mango::Test::Schema->compose_namespace($namespace)->connect($dsn);
    $schema->storage->on_connect_do([
        'PRAGMA synchronous = OFF',
        'PRAGMA temp_store = MEMORY'
    ]);

    __PACKAGE__->deploy_schema($schema, %args);
    __PACKAGE__->populate_schema($schema, %args) unless $args{'no_populate'};

    return $schema;
};

sub deploy_schema {
    my ($self, $schema, %options) = @_;
    my $eval = $options{'eval_deploy'};

    eval 'use SQL::Translator';
    if (!$@ && !$options{'no_deploy'}) {
        eval {
            $schema->deploy();
        };
        if ($@ && !$eval) {
            die $@;
        };
    } else {
        open IN, catfile('t', 'sql', 'test.sqlite.sql');
        my $sql;
        { local $/ = undef; $sql = <IN>; }
        close IN;
        eval {
            ($schema->storage->dbh->do($_) || print "Error on SQL: $_\n") for split(/;\n/, $sql);
        };
        if ($@ && !$eval) {
            die $@;
        };
    };
};

sub clear_schema {
    my ($self, $schema, %options) = @_;

    foreach my $source ($schema->sources) {
        $schema->resultset($source)->delete_all;
    };
};

sub populate_schema {
    my ($self, $schema, %options) = @_;
    my $date = '2004-07-04 12:00:00';
    
    if ($options{'clear'}) {
        $self->clear_schema($schema, %options);
    };

    $schema->populate('Users', [
        [ qw/id username password created/ ],
        [1,'test1','password1', $date],
        [2,'test2','password2', $date],
        [3,'test3','password3', $date],
    ]);

    $schema->populate('Roles', [
        [ qw/id name description created/ ],
        [1,'role1','Role1', $date],
        [2,'role2','Role2', $date],
    ]);

    $schema->populate('UsersRoles', [
        [ qw/user_id role_id/ ],
        [1,1],
        [1,2],
        [2,1],
    ]);

    $schema->populate('Profiles', [
        [ qw/id user_id first_name last_name created/ ],
        [1,1,'Christopher', 'Laco', $date]
    ]);

    $schema->populate('Carts', [
        [ qw/id user_id created/ ],
        [1,1,$date],
        [2,0,$date],
    ]);

    $schema->populate('CartItems', [
        [ qw/id cart_id sku quantity price description created/ ],
        [1,1,'ABC-123',1,1.11,'SKU1',$date],
        [2,1,'DEF-345',2,2.22,'SKU2',$date],
        [3,2,'GHI-678',3,3.33,'SKU3',$date],
    ]);

    $schema->populate('Wishlists', [
        [ qw/id user_id name description created/ ],
        [1,1,'Wishlist1','First Wishlist',$date],
        [2,1,'Wishlist2','Second Wishlist',$date],
        [3,2,'Wishlist3','Third Wishlist',$date],
    ]);

    $schema->populate('WishlistItems', [
        [ qw/id wishlist_id sku quantity description created/ ],
        [1,1,'WABC-123',1,'WSKU1',$date],
        [2,1,'WDEF-345',2,'WSKU2',$date],
        [3,2,'WGHI-678',3,'WSKU3',$date],
    ]);

};

1;
