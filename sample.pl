#!/usr/bin/perl --

use strict;
use warnings;
use lib qw(./lib);
use AWS::Route53::Simple;
use Data::Dumper;

warn $_ foreach (AWS::Route53::Simple->new()->actions());

my %initialize = (
    AccessKey => "YOUR AWS ACCESS KEY",
    SecretAccessKey => "YOUR AWS SECRET ACCESS KEY",
    debug => 1
);

my $data;
my $content = <<EOF;
<?xml version="1.0" encoding="UTF-8" ?>
<ChangeResourceRecordSetsRequest xmlns="https://route53.amazonaws.com/doc/2013-04-01/">
    <ChangeBatch>
        <Changes>
            <Change>
                <Action>CREATE</Action>
                <ResourceRecordSet>
                    <Name>simpletest.domain.org</Name>
                    <Type>A</Type>
                    <TTL>3600</TTL>
                    <ResourceRecords>
                        <ResourceRecord>
                            <Value>192.168.99.128</Value>
                        </ResourceRecord>
                    </ResourceRecords>
                </ResourceRecordSet>
            </Change>
        </Changes>
    </ChangeBatch>
</ChangeResourceRecordSetsRequest>
EOF
$data = AWS::Route53::Simple->new(%initialize)
    ->action("ChangeResourceRecordSets")
#    ->param([
#        {
#            Action => "CREATE",
#            Type => "A",
#            Name => "simpletest.domain.org",
#            Value => "192.168.99.128",
#            TTL => 3600
#        },
#        {
#            Action => "UPSERT",
#            Type => "CNAME",
#            Name => "simpletest.domain.org",
#            Value => "www.simpletest.domain.org",
#            TTL => 3600
#        },
#        {
#            Action => "DELETE",
#            Type => "A",
#            Name => "testtest.domain.org",
#            Value => "192.168.99.200",
#            TTL => 3600
#        }
#    ])
    ->send({ZoneID => "Z2OJFHMITOHA69", Content => $content});
if ($data) {
    warn Dumper($data);
}

## if you want to generate their own request
=head
use HTTP::Request;
use Digest::SHA qw(hmac_sha256);
use MIME::Base64 qw(encode_base64 decode_base64);
my $req = HTTP::Request->new(
    POST => "https://route53.amazonaws.com/2013-04-01/hostedzone/[YOUR HOSTED ZONE ID]/rrset"
);
$req->header(
    "date" => AWS::Route53::Simple->new->_timestamp(),
    "X-Amzn-Authorization" => "AWS3-HTTPS ".join(",",
        "AWSAccessKeyId=".$initialize{"AccessKey"},
        "Algorithm=HmacSHA256",
        "Signature=".encode_base64(hmac_sha256(AWS::Route53::Simple->new->_timestamp(), $initialize{"SecretAccessKey"}))
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
