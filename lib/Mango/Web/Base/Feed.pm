package Mango::Web::Base::Feed;
use strict;
use warnings;

BEGIN {
    use base qw/Catalyst::View/;
    use Scalar::Util ();
    use XML::Feed ();
};

sub process {
    my( $self, $c, $type ) = @_;
    my @items;

    if(my $item = $c->stash->{'item'}) {
        push @items, $item;
    } elsif (my $list = $c->stash->{'items'}) {
        if (Scalar::Util::blessed $list && $list->isa('Mango::Iterator')) {
            push @items, $list->all;
        } else {
            push @items, @{$list};
        };
    } else {
       #Catalyst::Exception->throw(
       #    message => 'No item to process.',
       #    status  => 400
       #);
   };

   my $feed = XML::Feed->new( $type );
   $feed->title('My Feed');
   $feed->description('This is my feed.');
   $feed->tagline('Best Feed Ever.');
   $feed->link('bar' );
   $feed->language($c->language);
   $feed->modified($c->stash->{'cart'}->updated);

   for my $item (@items) {
       next unless $item->can('as_entry');
       my $entry  = $item->as_entry($type);
       
       $entry->link($c->uri_for('/cart', $entry->id));
       #$entry->link(
       #    $c->collection_uri_for(
       #        $c->controller( 'Item' )->action_for('item'),
       #        $item->item_id
       #    )
       #);

       $feed->add_entry($entry);
   };

   $c->stash->{'feed'} = $feed;

   $c->res->body($feed->as_xml);
};

1;
