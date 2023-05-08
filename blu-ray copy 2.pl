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

# print out the links
foreach my $link (@links) {
    my $href = $link->attr('href');
    my $title = $link->as_trimmed_text;

    my $full_link = "http://www.dvdcompare.net/comparisons/$href";
    print "$title\n$full_link\n";

    # fetch the content of the full link
    my $full_content = get($full_link);
    die "Couldn't get $full_link" unless defined $full_content;

    # extract Amazon link
    if ($full_content =~ /href="(https:\/\/www\.amazon\.com\/.*?\/dp\/([A-Z0-9]+)\/\?tag=rewinddvdcomp-20)"/) {
        my $amazon_link = $1;
        print "ASIN: $amazon_link\n";
    }

    # extract Caps-a-holic link
    if ($full_content =~ /href="(https:\/\/caps-a-holic\.com\/c_list\.php\?c=\d+)" rel="external"/) {
        my $caps_link = $1;
        print "Caps-a-holic: $caps_link\n";

        # Codec                   Bitrate             Description     
        # -----                   -------             -----------     
        # MPEG-H HEVC Video       41864 kbps          2160p / 23.976 fps / 16:9 / Main 10 @ Level 5.1 @ High / 4:2:0 / 10 bits / 1000nits / HDR10 / BT.2020
        # * MPEG-H HEVC Video     65 kbps (0.15%)     1080p / 23.976 fps / 16:9 / Main 10 @ Level 5.1 @ High / 4:2:0 / 10 bits / 1000nits / Dolby Vision MEL / BT.2020

        # AUDIO:

        # Codec                           Language        Bitrate         Description     
        # -----                           --------        -------         -----------     
        # DTS-HD Master Audio             English         3887 kbps       5.1 / 48 kHz / 3887 kbps / 24-bit (DTS Core: 5.1 / 48 kHz / 768 kbps / 24-bit)

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
            if ($caps_content =~ /MPEG-H HEVC Video\s+(\d+)\s+kbps.*?\n.*?\n.*?MPEG-H HEVC Video\s+(\d+)\s+kbps/m) {
                $video_bitrate1 = $1;
                $video_bitrate2 = $2;
                print "Video bitrates: $video_bitrate1 kbps, $video_bitrate2 kbps\n";
            }
            if ($caps_content =~ /DTS-HD Master Audio\s+\w+\s+\d+\s+kbps/) {
                ($audio_bitrate) = $caps_content =~ /DTS-HD Master Audio\s+\w+\s+(\d+)\s+kbps/;
                print "Audio bitrate: $audio_bitrate kbps\n";
            }
    }

 

    print "\n";
    last;
}
