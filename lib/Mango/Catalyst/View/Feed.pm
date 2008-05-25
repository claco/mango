# $Id$
package Mango::Catalyst::View::Feed;
use strict;
use warnings;

BEGIN {
    use base qw/Catalyst::View/;

    use Mango::Exception ();
    use Scalar::Util     ();
    use XML::Feed        ();
}

sub process {
    my ( $self, $c, $type ) = @_;

    if ( !$type ) {
        Mango::Exception->throw('FEED_TYPE_NOT_SPECIFIED');
    }

    my $feed = $self->feed( $c, $type );
    if ( !$feed ) {
        Mango::Exception->throw('FEED_NOT_FOUND');
    } elsif ( !Scalar::Util::blessed $feed || !$feed->isa('XML::Feed') ) {
        Mango::Exception->throw('NOT_A_FEED');
    }

    ## fixup until XML::Feed is fixed
    if ( $feed->format eq 'RSS 2.0' ) {
        if (
            delete $feed->{'rss'}->{'modules'}
            ->{'http://purl.org/rss/1.0/modules/dcterms/'} )
        {
            $feed->{'rss'}->add_module(
                prefix => 'dcterms',
                uri    => 'http://purl.org/dc/terms/'
            );
        }
        $feed->{'rss'}->add_module(
            prefix => 'atom',
            uri    => 'http://www.w3.org/2005/Atom'
        );
        $feed->{'rss'}->channel(
            atom => {
                link => {
                    href => $feed->link,
                    rel  => 'self',
                    type => 'application/rss+xml'
                }
            }
        );
    } elsif ( $feed->format eq 'Atom' ) {
        $feed->{'atom'}->add_link(
            {
                href => $feed->link,
                rel  => 'self',
                type => 'application/atom+xml'
            }
        );
    }

    foreach my $entry ( $self->feed_entries( $c, $type ) ) {
        $feed->add_entry($entry);
    }

    if ( !$feed->language ) {
        $feed->language( $c->language );
    }

    $c->stash->{'feed'} = $feed;
    $c->response->body( $feed->as_xml );

    return 1;
}

sub feed {
    my ( $self, $c, $type ) = @_;
    my $entity = $c->stash->{'entity'};
    my $data;

    if ( !$entity ) {
        return;
    }

    if ( Scalar::Util::blessed $entity && $entity->isa('XML::Feed') ) {
        return $entity;
    } elsif ( Scalar::Util::blessed $entity && $entity->can('as_feed') ) {
        $data = $entity->as_feed($type);

        if ( Scalar::Util::blessed $data) {
            return $data;
        }
    } else {
        $data = $entity;
    }

    my $feed = XML::Feed->new($type);
    foreach my $key ( keys %{$data} ) {
        if ( $feed->can($key) ) {
            $feed->$key( $data->{$key} );
        } else {
            ## another hack until XML::Feed is fixed
            if ( $feed->format eq 'Atom' ) {
                if ( $feed->{'atom'}->can($key) ) {
                    $feed->{'atom'}->$key( $data->{$key} );
                }
            }
        }
    }

    return $feed;
}

sub feed_entries {
    my ( $self, $c, $type ) = @_;
    my $entity = $c->stash->{'entity'};
    my @entities;
    my @entries;
    my $data;

    if ( Scalar::Util::blessed $entity) {
        return;
    }

    if ( my $entries = delete $entity->{'entries'} ) {
        if ( Scalar::Util::blessed $entries
            && $entries->isa('Mango::Iterator') )
        {
            push @entities, $entries->all;
        } else {
            push @entities, @{$entries};
        }
    }

    for my $entity (@entities) {
        if ( Scalar::Util::blessed $entity
            && $entity->isa('XML::Feed::Entry') )
        {
            push @entries, $entity;
        } elsif ( Scalar::Util::blessed $entity
            && $entity->can('as_feed_entry') )
        {
            $data = $entity->as_feed_entry($type);

            if ( Scalar::Util::blessed $data) {
                push @entries, $data;
            }
        } else {
            $data = $entity;
        }
        my $new_entry = XML::Feed::Entry->new($type);
        foreach my $key ( keys %{$data} ) {
            if ( $new_entry->can($key) ) {
                $new_entry->$key( $data->{$key} );
            }
        }
        push @entries, $new_entry;
    }

    return @entries;
}

1;
__END__

=head1 NAME

Mango::Catalyst::View::Feed - View class for XML::Feed based feeds

=head1 SYNOPSIS

    $c->view('Atom');
    $c->view('RSS');

=head1 DESCRIPTION

Mango::Catalyst::View::Feed renders a feed using XML::Feed and
serves it with the appropriate content type.

There is no real reason to use this view directly. Please use
Mango::Catalyst::View::RSS or Mango::Catalyst::View::Atom instead.

=head1 FEED DATA

When this view is called, it will create a feed using the data in:

    $c->stash->{'entity'};

If C<entity> is a hash, each key will be assigned to the XML::Feed object:

    $c->stash->{'entity'} = {
        title => 'My Feed',
        description => 'This is my feed'
        entries => [
            {title => 'Entry1', id => 1, ...},
            {title => 'Entry2', id => 2, ...}
        ]
    };

    my $feed = XML::Feed->new;
    my $entity = $c->stash->{'entity'};
    $feed->$_($entity->{$_}) for keys %{$entity}

If an C<entries> key is supplied, each item in it will also be converted to an
XML::Feed::Entry object and added to the feed. C<entries> may also contain a
list of XML::Feed::Entry objects, or objects that support a C<as_feed_entry>
method which returns XML::Feed::Entry objects or the appropriate hash.

If C<entity> is an XML::Feed object, that is used directly. If C<entity> is an
object and it supports the C<as_feed> method, the output from that method will
be used. C<as_feed> B<must> return a XML::Feed object or the
same C<entity> hash described above.

=head1 METHODS

=head2 feed

=over

=item Arguments: $c, $type

C<type> can be either 'RSS' or 'Atom'.

=back

Returns an XML::Feed object from the configuration described above.

=head2 feed_entries

=over

=item Arguments: $c, $type

C<type> can be either 'RSS' or 'Atom'.

=back

Returns a list of XML::Feed::Entry objects from the configuration described
above.

=head2 process

=over

=item Arguments: $c, $type

C<type> can be either 'RSS' or 'Atom'.

=back

Creates an XML::Feed of the specific type, writes it to the response body,
changing the content type.

=head1 SEE ALSO

L<Mango::Catalyst::View::RSS>, L<Mango::Catalyst::View::Atom>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
