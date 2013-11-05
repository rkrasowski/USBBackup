#!/usr/bin/perl
use strict;
use warnings;

my $cmd = "DISPLAY=:0.0 \/home\/robert\/Script\/USBBackup\/gtk2-backup.pl file:///media/USB_BACKUP1";
system( $cmd );

