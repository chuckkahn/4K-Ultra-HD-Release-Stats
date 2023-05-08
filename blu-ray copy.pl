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
    print "$title\n$full_link\n\n";

# add code to extract Amazon URL from $full_link 
# Amazon url will be embedded in HTML like this
# <a href="https://www.amazon.com/Daniel-Craig-Collection-Ultra-Blu-ray/dp/B07XN4DTYD/?tag=rewinddvdcomp-20">

# add code to extract Caps-o-holic url from $full_link
# Caps-o-holic url will be embedded in HTML like this
# 	<a href="https://caps-a-holic.com/c_list.php?c=5284" rel="external" title="Link opens in a new window">


    last;
}
