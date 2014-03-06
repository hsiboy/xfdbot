#!/usr/bin/perl -w
# Petr Baudis (c) 2004, public domain
# Slightly inspired by Stefan "tommie" Tomanek's newsline.pl.
# RSS->IRC gateway256 | Chapter 10, Announcement Bots
#66 Feed Syndicated RSS News into IRC Channels

use strict;

### Configuration section.
# In our example setup, we are going to deliver Slashdot headlines.

use vars qw ($nick $server $port $channel $rss_url $refresh);

$nick = 'slashrss';
$server = 'irc.gen.tradermedia.net';
$port = 7000;
$channel = '#irchacks';
$rss_url = 'http://cruise:cruise@go.gen.tradermedia.net/go/cctray.xml';
$refresh = 60; # seconds before refresh; 

### Preamble.
use POSIX;
use Net::IRC;
use LWP::UserAgent;
use XML::RSS;
use XML::Simple;
use Data::Dumper;

### Connection initialization.

use vars qw ($irc $conn);

$irc = new Net::IRC;

print "Connecting to server ".$server.":".$port." with nick ".$nick."...\n";

$conn = $irc->newconn (Nick => $nick, Server => $server, Port => $port, Ircname => 'RSS->IRC gateway IRC hack');

# Connect event handler - we immediately try to join our channel.

sub on_connect {

  my ($self, $event) = @_;
  print "Joining channel ".$channel."...\n";
  $self->join ($channel);
}

$conn->add_handler ('welcome', \&on_connect);

# Joined the channel, so log that.

sub on_joined {

  my ($self, $event) = @_;
  print "Joined channel ".$channel."...\n";
}

$conn->add_handler ('endofnames', \&on_joined);

# It is a good custom to reply to the CTCP VERSION request.

sub on_cversion {

  my ($self, $event) = @_;
  $self->ctcp_reply ($event->nick, 'VERSION RSS->IRS gateway IRC hack');
}

$conn->add_handler ('cversion', \&on_cversion);

### The RSS feed

use vars qw (@items);

# Fetches the RSS from server and returns a list of RSS items.

sub fetch_rss {

  my $ua = LWP::UserAgent->new (env_proxy => 1, keep_alive => 1, timeout => 30);
  my $request = HTTP::Request->new('GET', $rss_url);
  my $response = $ua->request ($request);

  return unless ($response->is_success);

  my $data = $response->content;
 # my $rss = new XML::RSS ( );


my $simple = XML::Simple->new();
my $data   = $simple->XMLin($data);

print Dumper($data);

#  $rss->parse($data);

#  foreach my $item (@{$rss->{items}}) {

    # Make sure to strip any possible newlines and similiar stuff.
#    $item->{Project} =~ s/\s/ /g;
#}  
#  return @{$rss->{items}};
}

# Attempts to find some newly appeared RSS items.

sub delta_rss {

  my ($old, $new) = @_;

  # If @$old is empty, it means this is the first run and we will therefore not do anything.
  return ()unless ($old and @$old);
  
  # We take the first item of @$old and find it in @$new.
  # Then anything before its position in @$new are the newly appeared items which we return.
  my $sync = $old->[0];
  
  # If it is at the start of @$new, nothing has changed.
  return ( ) if ($sync->{title} eq $new->[0]->{title});
  my $item;
  for ($item = 1; $item < @$new; $item++) {

    # We are comparing the titles which might not be 100% reliable but RSS
    # streams really should not contain multiple items with same title.
    last if ($sync->{title} eq $new->[$item]->{title});
}

  return @$new[0 .. $item - 1];
}

# Check RSS feed periodically.

sub check_rss {
  my (@new_items);

  print "Checking RSS feed [".$rss_url."]...\n";

  @new_items = fetch_rss();

  if (@new_items) {
    my @delta = delta_rss (\@items, \@new_items);
    foreach my $item (reverse @delta) {
      $conn->privmsg ($channel, '"'.$item->{title}.'" :: '.$item->{link});
}  
    @items = @new_items;
} 
  alarm $refresh;
}

$SIG{ALRM}=\&check_rss;

check_rss();

# Fire up the IRC loop.
$irc->start;