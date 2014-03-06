 #!/usr/bin/perl
$|++;
use warnings;
use strict;
use base 'Bot::BasicBot::Pluggable';

# with all defaults.

  my $bot = Bot::BasicBot::Pluggable->new(
  
                      channels => ['#at2_dove'],
                      server   => 'irc.gen.tradermedia.net',
                      port     => '7000',
                      nick     => 'plugbot',
                      altnicks => ['pbot', 'plugger'],
                      username => 'pbot',
                      name     => 'Yet Another Pluggable Bot'
                );
                
                  # Load the Loader module.
  $bot->load('Loader');

  # run the bot.
  $bot->run();