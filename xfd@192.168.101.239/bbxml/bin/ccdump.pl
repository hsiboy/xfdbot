#!/usr/bin/perl

#
# load required modules
#
use diagnostics;
use warnings;
use strict;
use XML::Simple;
use LWP::UserAgent;
use Data::Dumper;
use HTTP::Date;

# create object
my $xml = new XML::Simple (KeyAttr=>['Project']);

my $ie="Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)";
my $ua = LWP::UserAgent->new;
$ua->agent($ie);
$ua->timeout(5);
$ua->proxy(['http'], 'http://proxy.tradermedia.co.uk:8080/');
my $url = 'http://stuart-t:fy9nhf@cruise.dev.tradermedia.net/cruise/cctray.xml';
my $response = $ua->get ($url);

if ($response->is_success)
{
	my $xmlfile = $response->content;

my $data = $xml->XMLin($xmlfile);
#print Dumper($data);


# dereference hash ref
# access <employee> array
foreach my $e (@{$data->{Project}})
{
	print "Project Name: ", $e->{name}, "\n";
	print "\tLast Build Status: ", $e->{lastBuildStatus}, "\n"; 
	print "\tActivity: ", $e->{activity}, "\n";
	print "\tlast Build Time: " . scalar(HTTP::Date::parse_date($e->{lastBuildTime})) . "\n";
	print "\n";
}



}
else {
	die($response->status_line);
} # end if success