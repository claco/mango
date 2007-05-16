# $Id$
package Mango::Catalyst::View::Feed;
use strict;
use warnings;

BEGIN {
    use base qw/Catalyst::View/;

    use Mango::Exception ();
    use Scalar::Util qw/blessed/;
    use XML::Feed ();
};

sub process {
    my ($self, $c, $type) = @_;
    my $entity = $c->stash->{'entity'};
    my @entries;

    Mango::Exception->throw('FEED_TYPE_NOT_SPECIFIED') unless $type;
    Mango::Exception->throw('FEED_NOT_FOUND') unless $entity;

    if (blessed $entity && $entity->can('as_feed')) {
        my $feed = $entity->as_feed($type);

        if (blessed $feed) {
            $c->res->body($feed->as_xml);
            return 1;
        } else {
            $entity = $feed;
        };
    };

    if (my $entries = delete $entity->{'entries'}) {
        if (blessed $entries && $entries->isa('Mango::Iterator')) {
            push @entries, $entries->all;
        } else {
            push @entries, @{$entries};
        };
    };

    my $feed = XML::Feed->new($type);
    foreach my $key (keys %{$entity}) {
        $feed->$key($entity->{$key}) unless
            !$feed->can($key);
    };

    $feed->language($c->language) unless $feed->language;

    for my $entry (@entries) {
        if (blessed $entry && $entry->can('as_feed_entry')) {
            my $data = $entry->as_feed_entry($type);

            if (blessed $data) {
                $feed->add_entry($data);
            } else {
                $entry = $data;
            };
        } else {
            my $new_entry = XML::Feed::Entry->new($type);
            foreach my $key (keys %{$entry}) {
                $new_entry->$key($entry->{$key}) unless
                    !$new_entry->can($key);
            };
            $feed->add_entry($new_entry);
        };
    };

    $c->stash->{'feed'} = $feed;

    $c->response->body($feed->as_xml);

    return 1;
};

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
XML::Feed::Entry object and added to the feed.

If C<entity> is an object and it supports the C<as_feed> method, the output
from that will be used. C<as_feed> B<must> return a XML::Feed object or the
same C<entity> hash described above.

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
