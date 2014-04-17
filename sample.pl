#!/usr/bin/perl --

use strict;
use warnings;
use AWS::Route53::Simple;
use Data::Dumper;

## gets the action() method parameter values that can be specified
warn $_ foreach (AWS::Route53::Simple->new()->actions());

my %credentials = (
    AccessKey => "YOUR AWS ACCESS KEY",
    SecretAccessKey => "YOUR AWS SECRET ACCESS KEY"
);
my $zoneName = "yourdomain.com";

my $r53 = AWS::Route53::Simple->new(%credentials);

## get the all HostedZones
my $zones = $r53->action("ListHostedZones")->send();
my @targetZone = grep({ $_->{"Name"} eq $zoneName } @{$zones->{"HostedZones"}->{"HostedZone"}});
(my $zoneId = $targetZone[0]->{"Id"}) =~ s/^.*\///msx;

my $data = $r53->action("ChangeResourceRecordSets")
    ->param([
        {
            Action => "UPSERT",
            Type => "A",
            Name => "test.yourdomain.com",
            Value => "10.0.0.1",
            TTL => 3600
        },
    ])
    ->send({ZoneID => $zoneId});
if ($data) {
    warn Dumper($data);
}

## if you want to generate their own request
=head
use HTTP::Request;
use Digest::SHA qw(hmac_sha256);
use MIME::Base64 qw(encode_base64);
my $req = HTTP::Request->new(
    POST => "https://route53.amazonaws.com/2013-04-01/hostedzone/[YOUR HOSTED ZONE ID]/rrset"
);
$req->header(
    "date" => AWS::Route53::Simple->new->_timestamp(),
    "X-Amzn-Authorization" => "AWS3-HTTPS ".join(",",
        "AWSAccessKeyId=".$credentials{"AccessKey"},
        "Algorithm=HmacSHA256",
        "Signature=".encode_base64(hmac_sha256(AWS::Route53::Simple->new->_timestamp(), $credentials{"SecretAccessKey"}))
    )
);
$req->content($content);
$data = AWS::Route53::Simple
        ->new({AccessKey => "YOUR AWS ACCESS KEY", SecretAccessKey => "YOUR AWS SECRET ACCESS KEY"})
        ->action("ChangeResourceRecordSets")
        ->returnType("perl")
        ->send({request => $req});
warn Dumper($data);
=cut
