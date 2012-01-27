#!/usr/bin/perl -w

use strict;
use warnings;

use lib qw(../lib/);

use CGI qw(:standard escapeHTML);

use CGI::Carp qw(fatalsToBrowser);

# use utf8;

# use Unicode::String;

# Unicode::String->stringify_as( 'utf8' ); # utf8 already is the default 

use Framework;

my $cgi = CGI->new();

# binmode(STDOUT, ":utf8");
binmode STDOUT, ':encoding(UTF-8)';
# or confess $OS_ERROR;

# read cgi-params
my $page    = $cgi->param('page') || 'index';
my $subpage = $cgi->param('sub')  || '';

my %mapping = qw(
index index
books  books
impressum impressum
mongers mongers
travel travel
france1998 france1998
greece1997 greece1997
uk1997 uk1997
uk1999 uk1999
);

$page = defined $mapping{$page} ? $mapping{$page} : 'failure';

my $class_param = {
    page    => $page,
    subpage => $page eq 'travel' 
        ? defined $mapping{$subpage} 
            ? $mapping{$subpage} 
            : ''
        : '',
    cgi     => $cgi,
};

my $page_obj = Framework->new($class_param);

$page_obj->get_html();

#use Encode qw(from_to is_utf8 encode decode);
#my $string_utf8 = decode("iso-8859-1", $all);
#Encode::from_to($all, "iso-8859-1", "utf8");
#decode("iso-8859-1", $all);
#Unicode::String::latin1( $all );

$page_obj->set_end_page(end_html());

$page_obj->send_page();

1;

__END__
