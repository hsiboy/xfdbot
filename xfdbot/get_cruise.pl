 #!/usr/bin/perl
$|++;
use warnings;
use strict;
use LWP::UserAgent;
use HTTP::Status;

my $ie  = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)";
my $url = 'http://cruise:cruise@cruise.dev.tradermedia.net:80/cruise/cctray.xml';

my $ua = LWP::UserAgent->new;
$ua->proxy(['http'], 'http://proxy.tradermedia.co.uk:8080/');
$ua->agent($ie);
$ua->timeout(5);


my $request = HTTP::Request->new(GET => $url);
my $response = $ua->request($request);
 
 if ($response->is_success) {
     print $response->content;  # or whatever
 }
 else {
     die $response->status_line;
 }
