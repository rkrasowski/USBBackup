#!/usr/bin/perl
###########################################
# gtk2-backup
# Mike Schilli, 2010 (m@perlmeister.com)
###########################################
use strict;
use File::Finder;
use Glib qw/TRUE FALSE/;
use Gtk2 '-init';
use DateTime;

my $PID;
my $tar     = "tar";
my $src_dir = "/home/robert/";
my $ymd     = DateTime->now->ymd('');
my $hms	    = DateTime->now->hms('');
my $label   = "$ymd"."-"."$hms";



my($stick_dir) = @ARGV;

if(! defined $stick_dir ) {
    die "usage: $0 stick_dir";
}
$stick_dir =~ s#^file://##;

my $dst_tarball = "$stick_dir/$label.tgz";

my $NOF_FILES = scalar File::Finder
    -> type( "f" )
    -> in( $src_dir );

my $CMD = 
  "$tar zcfv $dst_tarball $src_dir";

my $window = Gtk2::Window->new('toplevel');
$window->set_border_width(10);
$window->set_size_request( 500, 100 );

my $vbox = Gtk2::VBox->new( TRUE, 10 );
$window->add( $vbox );

my $pbar = Gtk2::ProgressBar->new();
$pbar->set_fraction(0);
$pbar->set_text("Progress");
$vbox->pack_start( $pbar, TRUE, TRUE, 0 );

my $cancel = Gtk2::Button->new('Cancel');
$vbox->pack_end( $cancel, 
                 FALSE, FALSE, 0 );
$cancel->signal_connect( clicked => 
    sub { kill 2, $PID if defined $PID;
          Gtk2->main_quit; } );

$window->show_all();

my $timer = Glib::Timeout->add ( 
  10, \&start, $pbar, 
  Glib::G_PRIORITY_LOW );

Gtk2->main;

###########################################
sub start {
###########################################
  my( $pbar ) = @_;

  $PID = open my $fh, "$CMD |";

  my $count = 1;
  while( <$fh> ) {
    chomp;
    next if m#/$#; # skip dirs

    $pbar->set_text( "Home Backup Progress " .
      "($count/$NOF_FILES)" );
    $pbar->set_fraction($count/$NOF_FILES);

    Gtk2->main_iteration while 
      Gtk2->events_pending;

    $count++;
  }

  close $fh or die "$CMD failed ($!)";

  $cancel->set_label( "Done, you can disconnect the drive" );
  undef $PID;

  return Glib::SOURCE_REMOVE;
}

