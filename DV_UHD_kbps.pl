#!/usr/bin/perl
use strict;
use warnings;
use LWP::Simple;

# URL of the BDInfo report
my $url = "https://forum.blu-ray.com/showthread.php?p=14764370&highlight=kbps#post14764370";

# Download the BDInfo report content
my $content = get $url;

# Regular expression pattern for matching kbps values
my $kbps_pattern = qr/Bit rate\s*:\s*([\d,]+)\s*kbps/;

# Scrape kbps values from each track in the BDInfo report
my @kbps_values;
while ($content =~ /$kbps_pattern/g) {
    my $kbps = $1;
    $kbps =~ s/,//g;  # Remove commas from the number
    push @kbps_values, $kbps;
}

# Output the kbps values in CSV format
open my $csv_file, '>', 'output.csv' or die $!;
print $csv_file join(",", @kbps_values);
close $csv_file;
