#!/usr/bin/perl

use strict;
use warnings;
use Text::CSV;

my $csv = Text::CSV->new({ binary => 1, eol => $/ })
    or die "Cannot use CSV: " . Text::CSV->error_diag();

# Open CSV file for writing
open(my $fh, ">:encoding(utf8)", "remux_list.csv")
    or die "Cannot open CSV file: $!";

# Write header row to CSV file
$csv->print($fh, ["Title", "Link"]);

# Loop through pages
for my $page (1..3) {

    my $url = "https://hduse.net/forum-4k-remux-page-$page";

    # Get page HTML using curl
    my $html = `curl -s "$url"`;

    # Loop through threads on page and extract titles and links
    while ($html =~ m/<span\s+class=".*?subject_old.*?"\s+id="tid_\d+"><a\s+href="(.*?)">(.*?)<\/a><\/span><\/span>/sg) {
        my $link = "https://hduse.net/$1";
        my $title = $2;

        # Write title and link to CSV file
        $csv->print($fh, [$title, $link]);
    }
}

close $fh;
print "Done\n";
