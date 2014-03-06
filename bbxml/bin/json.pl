#!/usr/bin/perl

#
# load required modules
#
use diagnostics;
use warnings;
use strict;
use Data::Dumper;
use LWP::UserAgent;
use JSON -support_by_pp;


fetch_json_page('http://cruise:cruise@go.gen.tradermedia.net/go/stageStatus.json?pipelineName=autotrader-trunk&label=latest&counter=1&stageName=build');


sub fetch_json_page
{
  my ($json_url) = @_;
my $ie="Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)";
my $ua = LWP::UserAgent->new;
$ua->agent($ie);
$ua->timeout(5);
$ua->proxy(['http'], 'http://proxy.tradermedia.co.uk:8080/');
my $response = $ua->get ($json_url);

if ($response->is_success)
{
	my $content = $response->content;
	#print "i got $xmlfile from the server\n";

    my $json = new JSON;
 
#  { "stage" : 
#   { "pipelineId" : "4782", "pipelineName" : "Sauron", "uniqueStageId" : "Sauron-build-11600", "buildCause" : "modified by james-o", "materialRevisions" : [  { "revision" : "4800", "revision_href" : "4800", "user" : "james-o", "date" : "2009-05-28 17:38:29 +0100", "modifications" : [  { "user" : "james-o", "revision" : "4800", "date" : "2009-05-28 17:38:29 +0100", "comment" : "[JOB] Correct a lingustic misunderstanding over classnames", "modifiedFiles" : [  { "revision" : "4800", "action" : "modified", "fileName" : "\/trunk\/web\/css\/core.css" } ] } ], 
#   "folder" : "", "scmType" : "Subversion", "location" : "http:\/\/svn.dev.tradermedia.net\/sauron\/trunk\/", "action" : "Modified" } ], "stageName" : "build", "stageCounter" : "1", "current_label" : "4595", "id" : "11600", "builds" : [ 
#   { "agent" : "devapp022.front.tradermedia.net", "agent_ip" : "172.22.5.22", "build_scheduled_date" : "2009-05-28 17:40:25 +0100", "build_assigned_date" : "2009-05-28 17:40:26 +0100", "build_preparing_date" : "2009-05-28 17:40:26 +0100", "build_building_date" : "2009-05-28 17:40:30 +0100", "build_completing_date" : "2009-05-28 17:44:00 +0100", "build_completed_date" : "2009-05-28 17:44:12 +0100", "current_status" : "passed", "current_build_duration" : "221", "last_build_duration" : "0", "id" : "20629", "is_completed" : "true", "name" : "metrics", "result" : "Passed", "buildLocator" : "Sauron\/4595\/build\/1\/metrics" }, 
#   { "agent" : "devapp019.front.tradermedia.net", "agent_ip" : "172.22.5.19", "build_scheduled_date" : "2009-05-28 17:40:25 +0100", "build_assigned_date" : "2009-05-28 17:40:34 +0100", "build_preparing_date" : "2009-05-28 17:40:34 +0100", "build_building_date" : "2009-05-28 17:40:37 +0100", "build_completing_date" : "2009-05-28 17:41:07 +0100", "build_completed_date" : "2009-05-28 17:41:14 +0100", "current_status" : "passed", "current_build_duration" : "37", "last_build_duration" : "0", "id" : "20628", "is_completed" : "true", "name" : "package", "result" : "Passed", "buildLocator" : "Sauron\/4595\/build\/1\/package" }, 
#   { "agent" : "devapp016.front.tradermedia.net", "agent_ip" : "172.22.5.16", "build_scheduled_date" : "2009-05-28 17:40:25 +0100", "build_assigned_date" : "2009-05-28 17:40:26 +0100", "build_preparing_date" : "2009-05-28 17:40:26 +0100", "build_building_date" : "2009-05-28 17:40:31 +0100", "build_completing_date" : "2009-05-28 17:41:07 +0100", "build_completed_date" : "2009-05-28 17:41:08 +0100", "current_status" : "passed", "current_build_duration" : "36", "last_build_duration" : "0", "id" : "20630", "is_completed" : "true", "name" : "validation", "result" : "Passed", "buildLocator" : "Sauron\/4595\/build\/1\/validation" } ], "current_status" : "passed", "last_successful_label" : "4595", "last_successful_stage_id" : "11600", "stage_completed_date" : "5 minutes ago", "canRun" : "false", "stageLocator" : "Sauron\/4595\/build\/1" } }
#    
 
    # these are some nice json options to relax restrictions a bit:
    my $json_text;# = $json->allow_nonref->utf8->relaxed->escape_slash->loose->allow_singlequote->allow_barekey->decode($content);
    
     my $json_obj = $json->allow_nonref->utf8->relaxed->escape_slash->loose->allow_singlequote->allow_barekey->incr_text($content) or die "expected JSON object or array at beginning of string";
     print ref($json_obj);
     exit();

    #print ref($json_text->{stage}->{materialRevisions}[0]) . "\n";
    #print Data::Dumper->new([\%$json_text],[qw(hash)])->Indent(3)->Quotekeys(0)->Dump;
    
# exit;
    foreach my $build(@{$json_text->{stage}->{materialRevisions}->{modifications}}){
      my %build_hash = ();
      $build_hash{user} = $build->{user};
      $build_hash{comment} = $build->{comment};
      $build_hash{id} = $build->{id};
 
      # print episode information:
      while (my($k, $v) = each (%build_hash)){
        print "$k => $v\n";
      }
      print "\n";
    }
  };
  # catch crashes:
  if($@){
    print "[[JSON ERROR]] JSON parser crashed! $@\n";
  }
}
