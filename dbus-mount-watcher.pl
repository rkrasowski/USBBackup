#!/usr/bin/perl
###########################################
# mount-watcher
# Mike Schilli, 2010 (m@perlmeister.com)
# Modyfied by Robert J. Krasowski
###########################################
use strict;
use Net::DBus;
use Net::DBus::Reactor;
use App::Daemon;
use FindBin qw($Bin);
use Log::Log4perl qw(:easy);

use App::Daemon qw( daemonize );
daemonize();

INFO "Starting up";

my $BACKUP_STICK = 
     "file:///media/BACKUP_1";
my $BACKUP_PROCESS = "/home/robert/Scripts/USBBackup/gtk2-backup.pl";

my $notifications = Net::DBus->session
  ->get_service( 
      "org.gtk.Private.GduVolumeMonitor" )
  ->get_object( 
    "/org/gtk/Private/RemoteVolumeMonitor",
    "org.gtk.Private.RemoteVolumeMonitor",
  );

INFO "Subscribing to signal";

$notifications->connect_to_signal(
    'MountAdded', \&mount_added );

###########################################
sub mount_added  {
###########################################
  my( $service, $addr, $data ) = @_;

  INFO "Found mount point $data->[4] ";

  if( $data->[4] eq $BACKUP_STICK ) {
    my $cmd = "DISPLAY=:0.0 " .
      "$BACKUP_PROCESS $data->[4] &";
    INFO "Launching $cmd";
    system( $cmd );
  }
}

my $reactor = Net::DBus::Reactor->main();
$reactor->run();

