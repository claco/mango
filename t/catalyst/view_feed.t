#!perl -w
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test tests => 76;
    use Mango::Test::Catalyst;
    use DateTime;

    use_ok('Mango::Catalyst::View::Feed');
    use_ok('Mango::Exception', ':try');
};

my $c = Mango::Test::Catalyst->new;
my $view = $c->view('Feed');
isa_ok($view, 'Mango::Catalyst::View::Feed');


my $ATOM = <<EOF;
 <?xml version="1.0" encoding="utf-8"?>
 <feed xmlns="http://www.w3.org/2005/Atom" xml:lang="en-US">
   <link rel="alternate" href="http://localhost/" type="text/html"/>
   <rights>Copyright 2007</rights>
   <author>
     <name>Christopher H. Laco</name>
   </author>
   <subtitle>My Description</subtitle>
   <updated>2003-07-19T12:13:14Z</updated>
   <generator>Mango Feed View</generator>
   <title>My Feed Title</title>
   <entry>
     <link rel="alternate" href="http://localhost/entries/12345" type="text/html"/>
     <summary>Entry1 Summary</summary>
     <published>2002-07-19T12:13:14Z</published>
     <content type="xhtml">
       <div xmlns="http://www.w3.org/1999/xhtml">Entry1 Content</div>
     </content>
     <id>12345</id>
     <author>
       <name>Entry1 Author</name>
     </author>
     <category term="computers"/>
     <title>Entry1</title>
     <updated>2003-07-19T12:13:14Z</updated>
   </entry>
   <entry>
     <link rel="alternate" href="http://localhost/entries/6789" type="text/html"/>
     <summary>Entry2 Summary</summary>
     <published>2002-07-19T12:13:14Z</published>
     <content type="xhtml">
       <div xmlns="http://www.w3.org/1999/xhtml">Entry2 Content</div>
     </content>
     <id>6789</id>
     <author>
       <name>Entry2 Author</name>
     </author>
     <category term="tv"/>
     <title>Entry2</title>
     <updated>2003-07-19T12:13:14Z</updated>
   </entry>
 </feed>
EOF


my $RSS = <<EOF;
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
 xmlns:dcterms="http://purl.org/rss/1.0/modules/dcterms/"
 xmlns:blogChannel="http://backend.userland.com/blogChannelModule"
 xmlns:content="http://purl.org/rss/1.0/modules/content/"
>
  <channel>
    <title>My Feed Title</title>
    <link>http://localhost/</link>
    <description>My Description</description>
    <language>en-US</language>
    <copyright>Copyright 2007</copyright>
    <pubDate>Sat, 19 Jul 2003 12:13:14 -0000</pubDate>
    <webMaster>Christopher H. Laco</webMaster>
    <generator>Mango Feed View</generator>
    <item>
      <title>Entry1</title>
      <link>http://localhost/entries/12345</link>
      <description>Entry1 Summary</description>
      <author>Entry1 Author</author>
      <category>computers</category>
      <guid isPermaLink="true">http://localhost/entries/12345</guid>
      <pubDate>Fri, 19 Jul 2002 12:13:14 -0000</pubDate>
      <dcterms:modified>2003-07-19T12:13:14Z</dcterms:modified>
      <content:encoded>Entry1 Content</content:encoded>
    </item>
    <item>
      <title>Entry2</title>
      <link>http://localhost/entries/6789</link>
      <description>Entry2 Summary</description>
      <author>Entry2 Author</author>
      <category>tv</category>
      <guid isPermaLink="true">http://localhost/entries/6789</guid>
      <pubDate>Fri, 19 Jul 2002 12:13:14 -0000</pubDate>
      <dcterms:modified>2003-07-19T12:13:14Z</dcterms:modified>
      <content:encoded>Entry2 Content</content:encoded>
    </item>
  </channel>
</rss>
EOF


## throw exception when no feed type is specified
{
    try {
        local $ENV{'LANG'} = 'en';

        $view->process($c);

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/no feed type/i, 'no feed type');
    } otherwise {
        fail('Other exception thrown');
    };
};


## throw exception when no feed data is available
{
    try {
        local $ENV{'LANG'} = 'en';

        $view->process($c, 'RSS');

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/no feed data/i, 'no feed data');
    } otherwise {
        fail('Other exception thrown');
    };
};


## make an Atom feed using only hash data
{
    my $created = DateTime->new(
        year   => 2002,
        month  => 7,
        day    => 19,
        hour   => 12,
        minute => 13,
        second => 14,
        nanosecond => 0,
        time_zone => 'UTC'
    );

    my $modified = DateTime->new(
        year   => 2003,
        month  => 7,
        day    => 19,
        hour   => 12,
        minute => 13,
        second => 14,
        nanosecond => 0,
        time_zone => 'UTC'
    );

    local $c->stash->{'entity'} = {
        title => 'My Feed Title',
        description => 'My Description',
        author => 'Christopher H. Laco',
        language => 'en-US',
        copyright => 'Copyright 2007',
        generator => 'Mango Feed View',
        link => 'http://localhost/',
        modified => $modified,
        entries => [
            {
                title => 'Entry1',
                link => 'http://localhost/entries/12345',
                content => 'Entry1 Content',
                summary => 'Entry1 Summary',
                category => 'computers',
                author => 'Entry1 Author',
                id => '12345',
                issued => $created,
                modified => $modified
            },
            {
                title => 'Entry2',
                link => 'http://localhost/entries/6789',
                content => 'Entry2 Content',
                summary => 'Entry2 Summary',
                category => 'tv',
                author => 'Entry2 Author',
                id => '6789',
                issued => $created,
                modified => $modified
            }
        ]
    };

    ok($view->process($c, 'Atom'));

    my $feed = $c->stash->{'feed'};
    isa_ok($feed, 'XML::Feed');

    is($feed->title, 'My Feed Title');
    is($feed->format, 'Atom');
    is($feed->description, 'My Description');
    is($feed->author, 'Christopher H. Laco');
    is($feed->language, 'en-US');
    is($feed->copyright, 'Copyright 2007');
    is($feed->generator, 'Mango Feed View');
    is($feed->link, 'http://localhost/');
    is($feed->modified, $modified);

    my @entries = $feed->entries;
    is(scalar @entries, 2);

    my $entry1 = shift @entries;
    isa_ok($entry1, 'XML::Feed::Entry');
    is($entry1->title, 'Entry1');
    is($entry1->link, 'http://localhost/entries/12345');
    is($entry1->content->body, 'Entry1 Content');
    is($entry1->summary->body, 'Entry1 Summary');
    is($entry1->category, 'computers');
    is($entry1->author, 'Entry1 Author');
    is($entry1->id, 12345);
    is($entry1->issued, $created);
    is($entry1->modified, $modified);

    my $entry2 = shift @entries;
    isa_ok($entry2, 'XML::Feed::Entry');
    is($entry2->title, 'Entry2');
    is($entry2->link, 'http://localhost/entries/6789');
    is($entry2->content->body, 'Entry2 Content');
    is($entry2->summary->body, 'Entry2 Summary');
    is($entry2->category, 'tv');
    is($entry2->author, 'Entry2 Author');
    is($entry2->id, 6789);
    is($entry2->issued, $created);
    is($entry2->modified, $modified);

    SKIP: {
        skip 'Test::LongString not installed', 1 unless eval 'require Test::LongString';
        Test::LongString::is_string_nows($c->response->body, $ATOM);
    };
};


## make an RSS feed using only hash data
{
    my $created = DateTime->new(
        year   => 2002,
        month  => 7,
        day    => 19,
        hour   => 12,
        minute => 13,
        second => 14,
        nanosecond => 0,
        time_zone => 'UTC'
    );

    my $modified = DateTime->new(
        year   => 2003,
        month  => 7,
        day    => 19,
        hour   => 12,
        minute => 13,
        second => 14,
        nanosecond => 0,
        time_zone => 'UTC'
    );

    local $c->stash->{'entity'} = {
        title => 'My Feed Title',
        description => 'My Description',
        author => 'Christopher H. Laco',
        language => 'en-US',
        copyright => 'Copyright 2007',
        generator => 'Mango Feed View',
        link => 'http://localhost/',
        modified => $modified,
        entries => [
            {
                title => 'Entry1',
                link => 'http://localhost/entries/12345',
                content => 'Entry1 Content',
                summary => 'Entry1 Summary',
                category => 'computers',
                author => 'Entry1 Author',
                id => '12345',
                issued => $created,
                modified => $modified
            },
            {
                title => 'Entry2',
                link => 'http://localhost/entries/6789',
                content => 'Entry2 Content',
                summary => 'Entry2 Summary',
                category => 'tv',
                author => 'Entry2 Author',
                id => '6789',
                issued => $created,
                modified => $modified
            }
        ]
    };

    ok($view->process($c, 'RSS'));

    my $feed = $c->stash->{'feed'};
    isa_ok($feed, 'XML::Feed');

    is($feed->title, 'My Feed Title');
    is($feed->format, 'RSS 2.0');
    is($feed->description, 'My Description');
    is($feed->author, 'Christopher H. Laco');
    is($feed->language, 'en-US');
    is($feed->copyright, 'Copyright 2007');
    is($feed->generator, 'Mango Feed View');
    is($feed->link, 'http://localhost/');
    is($feed->modified, $modified);

    my @entries = $feed->entries;
    is(scalar @entries, 2);

    my $entry1 = shift @entries;
    isa_ok($entry1, 'XML::Feed::Entry');
    is($entry1->title, 'Entry1');
    is($entry1->link, 'http://localhost/entries/12345');
    is($entry1->content->body, 'Entry1 Content');
    is($entry1->summary->body, 'Entry1 Summary');
    is($entry1->category, 'computers');
    is($entry1->author, 'Entry1 Author');
    is($entry1->id, 12345);
    is($entry1->issued, $created);
    is($entry1->modified, $modified);

    my $entry2 = shift @entries;
    isa_ok($entry2, 'XML::Feed::Entry');
    is($entry2->title, 'Entry2');
    is($entry2->link, 'http://localhost/entries/6789');
    is($entry2->content->body, 'Entry2 Content');
    is($entry2->summary->body, 'Entry2 Summary');
    is($entry2->category, 'tv');
    is($entry2->author, 'Entry2 Author');
    is($entry2->id, 6789);
    is($entry2->issued, $created);
    is($entry2->modified, $modified);

    SKIP: {
        skip 'Test::LongString not installed', 1 unless eval 'require Test::LongString';

        Test::LongString::is_string_nows($c->response->body, $RSS);
    };
};


## set language if no language is given
{
    local $c->stash->{'entity'} = {

    };

    no warnings 'once';
    *Mango::Test::Catalyst::language = sub{'ru'};

    ok($view->process($c, 'Atom'));

    my $feed = $c->stash->{'feed'};
    isa_ok($feed, 'XML::Feed');

    is($feed->language, 'ru');
};
