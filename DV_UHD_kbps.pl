#!/usr/bin/perl
use strict;
use warnings;
use LWP::Simple;
use HTTP::Status;
use Text::CSV_XS;

# URL of the BDInfo report
my $url = "https://forum.blu-ray.com/showthread.php?p=18667865";
my $csv_file = 'output.csv'; # Replace with the name of the output CSV file
my @fields = ('Disc Title', 'Video codec 1 bitrate', 'Video codec 2 bitrate', 'Audio codec 1 bitrate');

my $csv = Text::CSV_XS->new({ binary => 1, eol => "\n" }) or die "Cannot use CSV: " . Text::CSV_XS->error_diag();
$csv->print(\*STDOUT, \@fields);

my $content = get($url) or die "Error retrieving URL: $!";

while ($content =~ m/Disc Title:\s*(.*?)<br \/>(.*?)SUBTITLES:<br \/>/smg) {
    my $title = $1;
    my $playlist_info = $2;

print "playlist_info is [$playlist_info]\n";

    my %bitrates = ();
    while ($playlist_info =~ m/^(.*?)\s+(\d+)\skbps\s+(.*?)<br \/>/gm) {
        my $codec = $1;
        my $bitrate = $2;
        my $description = $3;
        $bitrates{$codec} = $bitrate;
    }

    my @values = ($title, $bitrates{'Video'}, $bitrates{'Video 2'}, $bitrates{'Audio'});
    $csv->print(\*STDOUT, \@values);
    $csv->print(\*STDERR, \@values);

    open(my $fh, '>>', $csv_file) or die "Cannot open file '$csv_file' for writing: $!";
    $csv->print($fh, \@values);
    close $fh;
}