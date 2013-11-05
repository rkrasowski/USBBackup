#!/usr/bin/perl
use strict;
use warnings;

my $FH;

open($FH,">>","log.txt") or die "Couldn't open file file.txt, $!";
print $FH "testing";

close $FH;


#just add the line 
