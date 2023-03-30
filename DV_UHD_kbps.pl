#!/usr/bin/perl

use strict;
use warnings;
use LWP::Simple;
use Text::CSV;

my $url = "https://forum.blu-ray.com/showthread.php?p=18667865";
my $start_pattern = 'DISC INFO:';
my $end_pattern = 'SUBTITLES:';
my $csv_file = 'output.csv';

my $csv = Text::CSV->new({ binary => 1, auto_diag => 1, eol => "\n" });
open(my $fh, '>', $csv_file) or die "Cannot open $csv_file: $!";

# Add header row to CSV
$csv->print($fh, ["Disc Title", "MPEG-H HEVC Video", "* MPEG-H HEVC Video", "Dolby TrueHD/Atmos Audio"]);


my $content = get($url) or die "Error getting $url: $!";

my @reports = split(/($start_pattern.*?$end_pattern)/s, $content);
shift @reports; # remove first element (not a full report)

foreach my $report (@reports) {
    if ( $report =~ /DISC INFO/ )
    {
        print "report is [$report]\n------------------------------------------\n\n\n";
        my ($title) = $report =~ /Disc Title:\s*(.*?)\n/i;
        $title =~ s/\r//g;
        $title =~ s/<br \/>//g;
        my ($vc1_bitrate) = $report =~ /MPEG-H HEVC Video.*?([\d.]+)\s*kbps/ism;
        my ($vc2_bitrate) = $report =~ /\* MPEG-H HEVC Video.*?([\d.]+)\s*kbps/ism;
        my ($ac1_bitrate) = $report =~ /Dolby TrueHD\/Atmos Audio.*?([\d.]+)\s*kbps/ism;
        print "title is [$title][$vc1_bitrate][$vc2_bitrate][$ac1_bitrate]\n";

        $csv->print($fh, [$title, $vc1_bitrate, $vc2_bitrate, $ac1_bitrate]);
    }
}

close $fh;
