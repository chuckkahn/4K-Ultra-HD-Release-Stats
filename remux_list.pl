#!/usr/bin/perl

use strict;
use warnings;
use Text::CSV;

my $csv = Text::CSV->new({ binary => 1, auto_diag => 1, eol => "\n" });

# Open output file for writing
open(my $fh, ">:encoding(utf8)", "remux_list.csv") or die "Cannot open remux_list.csv: $!";

# Write headers to CSV file
$csv->print($fh, ["Page", "Title", "Link"]);

my $html;

# Loop over all pages
for (my $page = 1; $page <= 35; $page++) {

    # Construct URL for current page

    if ($page == 1) {
        $html = `curl -s https://hduse.net/forum-4k-remux`;
    } else {
        $html = `curl -s "https://hduse.net/forum-4k-remux?page=$page"`;
    }


    # Extract title and link of each thread
    while ($html =~ m/<span\s+class=".*?subject_(?:new|old).*?"\s+id="tid_\d+"><a\s+href="(.*?)">(.*?)<\/a><\/span>/sg) {
        my $link = "https://hduse.net/$1";
        my $title = $2;
        $csv->print($fh, [$page, $title, $link]);
    }
}

close($fh);
print "Done!\n";
