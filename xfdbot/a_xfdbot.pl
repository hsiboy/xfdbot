 #!/usr/bin/perl
$|++;
use warnings;
use strict;

#no warnings qw( syntax deprecated); 



use String::IRC;

our $parser = DateTime::Format::Strptime->new( pattern => '%Y-%m-%dT%H:%M:%S' );
                                                       # 2009-01-16T14:48:38
                                                       
our $msg = "";
our $status = 'on';
our $lastBuildTime = '';
our $lastBuildLabel = '';
our $lastActivity = '';

package XfdBot;
use base 'Bot::BasicBot';
use Acme::Magic8Ball qw(ask);


# Create an instance of the bot and start it running. Connect
# to the main perl IRC server, and join some channels.

   my $bot = XfdBot->new(
                      channels => ['#irchacks'],
                      server   => 'irc.gen.tradermedia.net',
                      port     => '7000',
                      nick     => 'xfdbot',
                      altnicks => ['infobot', 'buildbot'],
                      username => 'BuildBot',
                      name     => 'Yet Another ircBot'
                )->run;

    sub help {
    	my $self = shift;
        return "I'm an XFDbot. I check the build status every 60 seconds, and report it onto the channel if its changed.\nYou can enable or disable the announcements with !statuson or !statusoff ";
    }
    
    sub tick {
  my $self = shift;
  my $stamp = DateTime->now();
  my $dt = $parser->parse_datetime( $stamp );

  my $xml = new XML::Simple;
  
  my $ie="Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)";
  my $ua = LWP::UserAgent->new;
$ua->agent($ie);
$ua->timeout(5);
$ua->credentials(
  'go.gen.tradermedia.net:80',
  'Cruise',
  'cruise' => 'cruise'
);

#$ua->proxy(['http'], 'http://nlwproxy.nlw.autotrader.co.uk:8080/');
$ua->proxy(['http'], 'http://proxy.tradermedia.co.uk:8080/');

my $url = 'http://go.gen.tradermedia.net/go/cctray.xml';
#my $url = "http://127.0.0.1/cctray.xml";
my $response = $ua->get ($url);
my $content;

if ($response->is_success)
{
	my $xmlfile = $response->content;
	#print "i got $xmlfile from the server\n";
	

# read XML file
my $projects = $xml->XMLin($xmlfile);

my $thisActivity      = $projects->{'Project'}->{'autotrader-trunk :: build'}->{'activity'};
my $thisBuildTime     = $projects->{'Project'}->{'autotrader-trunk :: build'}->{'lastBuildTime'};
my $lastBuildStatus   = $projects->{'Project'}->{'autotrader-trunk :: build'}->{'lastBuildStatus'};
my $thisBuildLabel    = $projects->{'Project'}->{'autotrader-trunk :: build'}->{'lastBuildLabel'};
my $webUrl            = $projects->{'Project'}->{'autotrader-trunk :: build'}->{'webUrl'};


if (($lastActivity eq 'Building') && ($lastActivity eq $thisActivity)) {
# check back in 10
	$lastActivity = $thisActivity;
	return 10;
}

	$lastActivity = $thisActivity;
	
if (($thisBuildLabel eq $lastBuildLabel) && ($thisBuildTime eq $lastBuildTime)) {
	# check back in 30
	return 30;
}

$lastBuildTime = $thisBuildTime;
$lastBuildLabel = $thisBuildLabel;


$msg = "I don't know what state the build is in, cruise returned $lastBuildStatus for the last build status?\nCurrently $lastActivity";
# the xml contains the string localhost?? lets take it out...
$webUrl =~ s/http:\/\/go/http:\/\/go.gen.tradermedia.net\/go/g;

my $bt = $parser->parse_datetime( $lastBuildTime );


if ($lastBuildStatus eq "Success" && $lastActivity eq "Building") {
	my $string = "Build $lastBuildLabel started building @ " . $bt->hms(':') . "\nThe Build is Currently $lastActivity\n $webUrl";
	my $si1 = String::IRC->new($string)->orange->bold;
	$msg = $si1;
}
elsif ($lastBuildStatus eq "Success" && $lastActivity eq "Sleeping") {
	my $string = "Build $lastBuildLabel was successfully built @ " . $bt->hms(':') . "\nThe Build is Currently $lastActivity\n $webUrl";
	my $si1 = String::IRC->new($string)->green->bold;
	$msg = $si1;
}
elsif ($lastBuildStatus eq "Failure") {
	my $string = "BORK BORK BORK - Build $lastBuildLabel failed @ " . $bt->hms(':') . "\nThe Build is Currently $lastActivity\n $webUrl";
	my $si2 = String::IRC->new($string)->red->bold;
	$msg = $si2;
}

}
else {
	my $string  = 'erm.. is cruise down? ' . $response->status_line;
	my $si2 = String::IRC->new($string)->grey;
	$msg = $si2;
} # end if success

 
# print msg out to all chanles i'm on
if ($status eq 'on'){
$self->_say_to_all($msg);
}
    
  # this is the amount of time (seconds) we wait until we call tick again
  return 60; 


}#end sub tick


    sub _say_to_all {
 my ($self, $message) = @_;

for (@{$self->{channels}}) {
$self->say(channel =>$_, body =>$message);

}

    }

    # the 'said' callback gets called when someone says something in
    # earshot of the bot.
    sub said {
      my ($self, $message) = @_;
       my $nick = $self->nick;
      # we first check to see if it's a command (if it starts with !)
        if ($message->{body} =~ /^\!(.+)$/) {
               return on_public_command($1, $message->{who});
        }
      
      if ($message->{body} =~ /perl/) {
        return "I hear Ruby is better than perl..";
      }
      elsif ($message->{body} =~ /^laststatus$/i) {
     	return $msg;
      
    }
  if ($message->{body} =~ /^$nick.*$/i) {
    return ask($message->{body});
  }
  
  if ($message->{body} =~ /python/i) {
        return "python? This parrot is dead! that kind of thing?";
      }
      
      if ($message->{body} =~ /ruby/i) {
        return "ruby ruby ruby!";
      }
    }
   
    sub on_public_command {
        
        
        # here, we get the connection object, the text of the command, and
        # the nick of the person who issued the command
        my ($command, $nick) = @_;
        # branch off given the nature of the command
        $_ = $command;
        COM: {
                # this turns builkd status alerts on
                if (/^\!status on$/i) {
                        
                        # don't turn on trivia unless it's off
                        if ($status eq 'on') {
                                return "\@$nick - Build Status Updates are already on.";
                                last COM;
                        }
                        
                        # set status to on
                        $status = 'on';
                        # tell whoever requested
                     
                       return "\@$nick - Build Status Updates are now on!";
                       last COM;
                }
                
                if (/^\!status off$/i) {
                       #dont turn off unless its on
                       if ($status eq 'off') {
                                return "\@$nick - Build Status Updates are already off.";
                                last COM;
                        }
                        # set status to off 
                        $status = 'off';
                        # tell whoever requested
                        return "\@$nick - Build Status updates are now off!";
                        last COM;       
                }
                if (/^fortune$/i){
                	return &fortune;
                	last COM;
                	}
                	
                	if (/^status$/i){
                	return $msg;
                	last COM;
                	}         
      }
    }
    
    sub fortune {
  open FORTUNE, "/usr/games/fortune -s|" or exit;
  my $fortune = <FORTUNE>;
  chop $fortune;
  my $line;
  while ($line = <FORTUNE>)
    {
    $fortune .= ' ' . $line;
    chop($fortune);
    }
  close FORTUNE;
  $fortune =~ s/ +/ /g;
  $fortune =~ s/[\n\t]/ /g;
  return $fortune;
    }
  
    sub emoted {
        my $self = shift;
        my $e = shift;
        dbwrite($e->{channel}, '* ' . $e->{who}, $e->{body});
        return undef;

    }

    sub chanjoin {
        my $self = shift;
        my $e = shift;
        dbwrite($e->{channel}, '',  $e->{who} . ' joined ' . $e->{channel});
        return undef;
    }

    sub get_dbh {
           my $dbh = DBI->connect("dbi:SQLite:xfdbot.dat", "", "", {RaiseError => 1, AutoCommit => 1})or die $DBI::errstr;
           $dbh->do("CREATE TABLE IF NOT EXISTS irclog (id INTEGER PRIMARY KEY, channel, day, nick, timestamp, line)");
    return $dbh;
    }
  
  my $dbh = get_dbh();

    sub prepare {
        my $dbh = shift;
        # (re)create it
        return $dbh->prepare("INSERT INTO irclog (id, channel, day, nick, timestamp, line) VALUES(NULL,?, ?, ?, ?, ?)");
    }
    
    my $q = prepare($dbh);

    sub dbwrite {
        my ($channel, $who, $line) = @_;

        $line =~ s/\A\x{ffef}//;
        my ($day, $month, $year) = (localtime)[3,4,5];
        my $today = sprintf("%04d-%02d-%02d", $year+1900, $month+1, $day);
        my @sql_args = ($channel, $today, $who, time, $line);
        
            $q = prepare(get_dbh());
            $q->execute(@sql_args);
      return;
    }
    
    sub chanquit {
        my $self = shift;
        my $e = shift;
        dbwrite($e->{channel}, '', $e->{who} . ' left ' . $e->{channel});
        return undef;
    }

    sub chanpart {
        my $self = shift;
        my $e = shift;
        dbwrite($e->{channel}, '',  $e->{who} . ' left ' . $e->{channel});
        return undef;
    }

    sub _channels_for_nick {
        my $self = shift;
        my $nick = shift;

        return grep { $self->{channel_data}{$_}{$nick} } keys( %{ $self->{channel_data} } );
    }

    sub userquit {
        my $self = shift;
        my $e = shift;
        my $nick = $e->{who};

        foreach my $channel ($self->_channels_for_nick($nick)) {
            $self->chanpart({ who => $nick, channel => $channel });
        }
    }

    sub topic {
        my $self = shift;
        my $e = shift;
        if ($e->{who}) {
        dbwrite($e->{channel}, "", 'Topic channged to ' . $e->{topic} . ' by ' . $e->{who});
      }
        return undef;
    }

    sub nick_change {
        my $self = shift;
        my($old, $new) = @_;

        foreach my $channel ($self->_channels_for_nick($new)) {
            dbwrite($channel, "", $old . ' is now known as ' . $new);
        }
        
        return undef;
    }

    sub kicked {
        my $self = shift;
        my $e = shift;
        dbwrite($e->{channel}, "", $e->{nick} . ' was kicked by ' . $e->{who} . ': ' . $e->{reason});
        return undef;
    }



package Main;

# use modules
use DBI;
use XML::Simple;
use Data::Dumper;
use LWP::UserAgent;
use HTTP::Status;
use DateTime::Format::Strptime;

# get a database handle.


    
