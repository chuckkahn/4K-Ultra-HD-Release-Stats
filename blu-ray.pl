#!/usr/bin/perl
use strict;
use warnings;
use LWP::Simple;
use HTML::TreeBuilder;

# fetch the URL content
my $url = 'http://www.dvdcompare.net/comparisons/search.php?searchtype=text&param=(Blu-ray%204K)';
my $content = get($url);
die "Couldn't get $url" unless defined $content;

# parse the content
my $tree = HTML::TreeBuilder->new;
$tree->parse($content);

# find all the links
my @links = $tree->look_down(
    _tag => 'a',
    href => qr{^film\.php\?fid=\d+$},
);

# process the first 10 links
my $count = 0;
foreach my $link (@links) {
    last if $count >= 10;
    $count++;

    my $href = $link->attr('href');
    my $title = $link->as_trimmed_text;

    my $full_link = "http://www.dvdcompare.net/comparisons/$href";
    print "$title\n$full_link\n";

    # fetch the content of the full link
    my $full_content = get($full_link);
    die "Couldn't get $full_link" unless defined $full_content;

    # extract Amazon link
    if ($full_content =~ /\/dp\/([A-Z0-9]+)/ || $full_content =~ /asins=([A-Z0-9]+)/) {
        my $asin = $1;
        print "ASIN: $asin\n";
    }



    # extract Caps-a-holic link
    if ($full_content =~ /href="(https?:\/\/caps-a-holic\.com\/c_list\.php\?c=\d+)"[^>]*rel="external"/) {
        my $caps_link = $1;
        print "Caps-a-holic: $caps_link\n";


        # scrape Caps-a-holic page for bdinfo report data
        my $caps_content = get($caps_link);
        die "Couldn't get $caps_link" unless defined $caps_content;

        # extract disc size
        my $disc_size;
        if ($caps_content =~ /Size:\s+(.*?)\s+bytes/) {
            $disc_size = $1;
            $disc_size =~ s/,//g;
            print "Disc size: $disc_size bytes\n";
        }

        # extract video and audio bitrates

my ($video_bitrate1, $video_bitrate2, $audio_bitrate);

# Check for video bitrates in the 8th report
if ($caps_content =~ /MPEG-H HEVC Video\s+(\d+)\s+kbps.*?(?:MPEG-H HEVC Video\s+\d+\s+kbps.*?)?.*?\n.*?AUDIO/m) {
    $video_bitrate1 = $1;
    if ($caps_content =~ /MPEG-H HEVC Video\s+\d+\s+kbps.*?(MPEG-H HEVC Video\s+\d+\s+kbps).*?\n.*?AUDIO/m) {
        $video_bitrate2 = $1;
    }
    print "Video bitrates: $video_bitrate1 kbps, $video_bitrate2 kbps\n" if ($video_bitrate1 && $video_bitrate2);
    print "Video bitrate: $video_bitrate1 kbps\n" if ($video_bitrate1 && !$video_bitrate2);
}

# Check for audio bitrates in both reports
if ($caps_content =~ /DTS-HD Master Audio\s+\w+\s+(\d+)\s+kbps/) {
    $audio_bitrate = $1;
    print "Audio bitrate: $audio_bitrate kbps\n";
} elsif ($caps_content =~ /DTS-HD Master Audio\s+\w+\s+(\d+) kbps/) {
    $audio_bitrate = $1;
    print "Audio bitrate: $audio_bitrate kbps\n";
} elsif ($caps_content =~ /DTS Audio\s+\w+\s+(\d+)\s+kbps/) {
    $audio_bitrate = $1;
    print "Audio bitrate: $audio_bitrate kbps\n";
} elsif ($caps_content =~ /DTS Audio\s+\w+\s+(\d+) kbps/) {
    $audio_bitrate = $1;
    print "Audio bitrate: $audio_bitrate kbps\n";
} elsif ($caps_content =~ /Dolby Digital Audio\s+\w+\s+(\d+)\s+kbps/) {
    $audio_bitrate = $1;
    print "Audio bitrate: $audio_bitrate kbps\n";
} elsif ($caps_content =~ /Dolby Digital Audio\s+\w+\s+(\d+) kbps/) {
    $audio_bitrate = $1;
    print "Audio bitrate: $audio_bitrate kbps\n";
}

    }

    print "\n";
}
