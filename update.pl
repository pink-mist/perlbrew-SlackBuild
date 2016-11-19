#!/usr/bin/env perl

use strict;
use warnings;

use File::Open qw/ fopen /;
use Mojo::UserAgent;
use Digest::MD5 qw/ md5_hex /;

update($_) for @ARGV;

sub update {
  my $name = shift; $name =~ s!src/([^/]+)/.*!$1!;
  my $info = "src/$name/$name.info";
  my $slackbuild = "src/$name/$name.SlackBuild";
  my ($url) = map { /^\Q$name: \E(.*)/ ? $1 : () } readline fopen 'urls';
  my @lines = readline fopen $info;

  return if grep { /^\QDOWNLOAD="$url"\E/ } @lines;

  my ($dist, $ver) = $url =~ m{.*/([^/]+)-([^/-]+)[.]tar[.]gz};
  my $tarball = "$dist-$ver.tar.gz";
  print "Downloading $url...\n";
  my $md5 = md5_hex(Mojo::UserAgent->new->get($url)->res->body);

  foreach my $line (@lines) {
    $line = qq{DOWNLOAD="$url"\n} if $line =~ /^DOWNLOAD=/;
    $line = qq{MD5SUM="$md5"\n}   if $line =~ /^MD5SUM=/;
    $line = qq{VERSION="$ver"\n}  if $line =~ /^VERSION=/;
  }

  my $fh = fopen $info, 'w';
  print $fh @lines;

  my @slackbuild = readline fopen $slackbuild;

  foreach my $line (@slackbuild) {
    $line = qq[VERSION=\${VERSION:-$ver}\n] if $line =~ /^VERSION=/;
  }

  my $sb = fopen $slackbuild, 'w';
  print $sb @slackbuild;
}
