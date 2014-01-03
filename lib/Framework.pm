package Framework;

use strict;
use XML::Simple qw(XMLin XMLout);
use Carp;

use Data::Dumper;

my $LANG;

sub new {
	my $class   = shift;
	my $params  = shift;
	
	my $social_share = <<'SHARE';

SHARE
		
	my $self = {
	    page           => $params->{page} || 'index',
	    subpage        => $params->{subpage} || '',
	    pagename       => $params->{subpage} || $params->{page} || '',
	    wrap_start     => "\n".'<div id="wrap">',
	    wrap_end       => "\n".'</div>',
	    pic_start      => "\n".'<div id="pic_area">',
	    pic_end        => "\n".'</div>',
	    content_start  => "\n".'<div id="content_area">',
	    content_end    => "\n".'</div>',
	    info_start     => "\n".'<div id="info_area">',
	    info_end       => "\n".'</div>', 
	    clear          => "\n".'<div class="clear"/>',
	    cgi            => $params->{cgi},
	    javascript             => [ 
            {
                -language   => 'javascript',
                -src        => '../js/prototype-1.7.js'
               # -src        => '../lightbox/js/prototype.js',
            },
#            {   -language   => 'javascript',
#                #-src        => '../js/jquery-1.7.js',
#                -src        => '../socialshareprivacy/jquery-1.7.js',
#            },
#            {   -language   => 'javascript',
#                -src        => '../socialshareprivacy/jquery.socialshareprivacy.js',
#            },
            {
                -language   => 'javascript',
                -src        => '../js/func.js',
            },
        ],
        css            => [
            { src => '../css/global_design.css' },
          #  { src => '../socialshareprivacy/socialshareprivacy/socialshareprivacy.css' },
          ],
    };
	
	bless($self, $class);
	
	$LANG = $params->{lang};
	
	my $file = '../data/config2014.xml';
    
    
    $self->{config} = XMLin $file;
    #die Dumper ( $self->{config});
	
	return $self;
}

sub get_html {
    my $self = shift;
    
    my $html = $self->{wrap_start};
    
    my $info = $self->_get_content(1);
    
    if ($info) {
        $html .= $self->{pic_start};
        $html .= $info;
        $html .= $self->{pic_end};
    }
    
    $html .= $self->{content_start};
    $html .= $self->_get_content();
    $html .= $self->add_ad('astore_widget') if ($self->{page} eq 'travel');
    $html .= $self->{content_end};
    
    
    $html .= $self->{clear};
    
    $html .= $self->{wrap_end};
    $self->{content} = $html;
    
    return $self;
}

sub set_end_page {
    my $self = shift;
    $self->{end_page} = shift;    
}

sub set_link_attr {
    my $self = shift;
    $self->{link_attr} = shift;
}


sub footer {
    return shift->_get_footer_html();
}

sub navigation  {
    my $self = shift;
    
    #die Dumper $self->{config};
    my @first_order  = split /\s/, $self->{config}->{pages}->{order}; # //:;#
    
    my $first_pages  = $self->{config}->{pages}->{page};
    my $second_pages = $first_pages->{$self->{page}}->{subpage};
    
    
    my $first_page = $first_pages->{$self->{page}};
    my $second_page = $second_pages->{$self->{subpage}};
    
    my @second_order = split /\s/, $first_page->{order}; # //:;#
    
    # die Dumper \@second_order;
    
    my $first_id     = $first_page->{pid};
    my $first_href   = $first_page->{href} . add_lang_to_url($first_page->{href});
    my $first_label  = $first_page->{$LANG};
    
    my ($second_id, $second_href, $second_label);
    
    # <div id="title_bar">
    #     <div id="title">
    #         <div id="nav">Navi Links
    #              <div id="lang">flags
    #              </div>
    #         </div>
    #         <div id="nav2">
    #     </div>
    # </div>
    
    # ************* TITLEBAR PART1 *************
    my $div_title_bar = qq(<div id="title_bar">);
    
    my $div_title = qq(<div id="title">) . $self->_get_description() . qq(</div>\n);
    
    $div_title_bar .= $div_title;
    
    my $div_nav = qq(<div id="nav">);	
    
    
    # fill with links
    $div_nav .= $self->_get_ul_list( {
        order => \@first_order,
        pages => $first_pages,
        id    => $first_id,
    });

    # ************* TITLEBAR PART2 *************
    my $url = defined $second_page->{href}
        ? $second_page->{href}
        : $first_page->{href};
    
    my $div_nav_lang .= qq(<div id="lang">);
    $div_nav_lang .= qq(<span><a href="$url&lang=de"><img class="lang_flag" src="../png/de.png" border="0"/></a>);
    $div_nav_lang .= qq(<a href="$url&lang=en"><img class="lang_flag" src="../png/en.png" border="0"/></a>);
    $div_nav_lang .= qq(</span></div>);
   
    $div_nav .= $div_nav_lang;
    $div_nav .=  qq(</div>\n);
    $div_title_bar .= $div_nav;
    
    # ************* BREADCRUMB DATA *************
    
    my @breadcrumb_data;
    
    push @breadcrumb_data, {href => 'index.pl' . add_lang_to_url(), label => 'Home'};
        
    if ($first_id ne 'index') {
        push @breadcrumb_data, {href => $first_href, label => $first_label};
    }
    
    # ************* 2ND NAVIGATION *************
    
    my $div_nav2;
    
    # subpage navi bar
    if (keys %{$first_page->{subpage}}) {
        $div_nav2 = qq(<div id="nav2">);
        
        $second_id = $self->{subpage};
        $second_href = $second_page->{href} . add_lang_to_url($second_page->{href});
        $second_label = $second_page->{$LANG};
        
        # fill with links
        $div_nav2 .= $self->_get_ul_list( {
            order => \@second_order,
            pages => $second_pages,
            id    => $second_id,
        });
        
        $div_nav2 .= qq(</div>\n);
        if ($self->{subpage}) {
            push @breadcrumb_data, {href => $second_href, label => $second_label};
        }
    } 
       
    $div_title_bar .= qq(</div>\n);	
    
    # ************* HEADERBAR *************
    
    # <div id="header_bar">
    #     <div id="breadcrumb"
    #     </div>
    # </div>
    
    my $div_header_bar = qq(<div id="header_bar">\n);
    
    my $div_breadcrumb = qq(<div id="breadcrumb" style="float:right">\n)
          . qq(<ul>\n);
    for my $bread (@breadcrumb_data) {
        my $href  = $bread->{href};
        my $label = $bread->{label};
            
        $div_breadcrumb .= qq(<li><a href="$href">$label</a></li>\n);            
    }
    
    
    $div_breadcrumb .= qq(</ul></div>\n);
    
    my $iframe = '';
    
    $div_header_bar .= $iframe;

    $div_header_bar .= $div_breadcrumb;
    $div_header_bar .= $div_nav2;
    
    $div_header_bar .= qq(</div>\n);
    
    # set html
    
    my $html .= $div_title_bar; 
    $html    .= $div_header_bar;
    
	return $html;
}

sub add_ad {
    my $self = shift;
    my $ad   = shift;

    my %ad_html;
    
    $ad_html{astore_widget} = <<'HTML';
<OBJECT classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
    codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab" 
    id="Player_6837104c-1160-409d-90e0-427df343bcdd"  
    WIDTH="468px" HEIGHT="60px"> 
    <PARAM NAME="movie" 
        VALUE="http://ws.amazon.de/widgets/q?ServiceVersion=20070822&MarketPlace=DE&ID=V20070822%2FDE%2Fhomepagevonco-21%2F8009%2F6837104c-1160-409d-90e0-427df343bcdd&Operation=GetDisplayTemplate">
        <PARAM NAME="quality" VALUE="high">
        <PARAM NAME="bgcolor" VALUE="#FFFFFF">
        <PARAM NAME="allowscriptaccess" VALUE="always">
        <embed src="http://ws.amazon.de/widgets/q?ServiceVersion=20070822&MarketPlace=DE&ID=V20070822%2FDE%2Fhomepagevonco-21%2F8009%2F6837104c-1160-409d-90e0-427df343bcdd&Operation=GetDisplayTemplate" 
            id="Player_6837104c-1160-409d-90e0-427df343bcdd" 
            quality="high" 
            bgcolor="#ffffff" 
            name="Player_6837104c-1160-409d-90e0-427df343bcdd" 
            allowscriptaccess="always"  
            type="application/x-shockwave-flash" 
            align="middle" 
            height="60px" 
            width="468px">
        </embed>
</OBJECT> 
<NOSCRIPT>
    <A HREF="http://ws.amazon.de/widgets/q?ServiceVersion=20070822&MarketPlace=DE&ID=V20070822%2FDE%2Fhomepagevonco-21%2F8009%2F6837104c-1160-409d-90e0-427df343bcdd&Operation=NoScript">
        Amazon.de Widgets
    </A>
</NOSCRIPT>
HTML
    
    $ad_html{mp3_widget} = <<'HTML';
<OBJECT classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab" id="Player_4f678024-a501-470e-a9df-8a538156f31c"  WIDTH="250px" HEIGHT="250px"> <PARAM NAME="movie" VALUE="http://ws.amazon.de/widgets/q?rt=tf_w_mpw&ServiceVersion=20070822&MarketPlace=DE&ID=V20070822%2FDE%2Fhomepagevonco-21%2F8014%2F4f678024-a501-470e-a9df-8a538156f31c&Operation=GetDisplayTemplate"><PARAM NAME="quality" VALUE="high"><PARAM NAME="bgcolor" VALUE="#FFFFFF"><PARAM NAME="allowscriptaccess" VALUE="always"><embed src="http://ws.amazon.de/widgets/q?rt=tf_w_mpw&ServiceVersion=20070822&MarketPlace=DE&ID=V20070822%2FDE%2Fhomepagevonco-21%2F8014%2F4f678024-a501-470e-a9df-8a538156f31c&Operation=GetDisplayTemplate" id="Player_4f678024-a501-470e-a9df-8a538156f31c" quality="high" bgcolor="#ffffff" name="Player_4f678024-a501-470e-a9df-8a538156f31c" allowscriptaccess="always"  type="application/x-shockwave-flash" align="middle" height="250px" width="250px"></embed></OBJECT> <NOSCRIPT><A HREF="http://ws.amazon.de/widgets/q?rt=tf_w_mpw&ServiceVersion=20070822&MarketPlace=DE&ID=V20070822%2FDE%2Fhomepagevonco-21%2F8014%2F4f678024-a501-470e-a9df-8a538156f31c&Operation=NoScript">Amazon.de Widgets</A></NOSCRIPT>
HTML
    
    return $ad_html{$ad};
}

sub add_javascript {
    my $self       = shift;
    my $javascript = shift;
    my $islib      = shift;
    
    if (!$islib) {
        push (@{$self->{javascript}}, $javascript);
    }
    else {
        my %libs = qw(
        scriptaculous ../lightbox/js/scriptaculous.js?load=effects,builder
        lightbox      ../lightbox/js/lightbox.js
        );
        push (@{$self->{javascript}}, {
            -language   => 'javascript',
            -src        => $libs{$javascript},
        });
    }
    
    return $self;    
}

sub add_keywords {
    my $self = shift;
    $self->{keywords} .= shift;
    return $self;
}

sub add_css {
    my $self  = shift;
    my $css   = shift;
    my $islib = shift;
    
    if (!$islib) {
        push (@{$self->{css}}, $css);
    }
    else {
        my %libs = qw(
        lightbox ../lightbox/css/lightbox.css
        );
        push (@{$self->{css}}, {
            src        => $libs{$css},
        });
    }
    
    return $self;
}

# ------------------------------- HELPER ---------------------


sub _get_footer_html {
    my $self = shift;
    
    return <<'HTML';
<div id="fusszeile">
    <p>Copyright &copy; Colin Hotzky, alle Rechte vorbehalten.</p>
</div>
HTML

}

sub _replace_entities {
    my $self = shift;
    my $html = shift;
    
    $html =~ s/Š/&auml;/gm;
    $html =~ s/€/&Auml;/gm;
    $html =~ s/Ÿ/&uuml;/gm;
    $html =~ s{\\x\{fc\}}{&uuml;}gm;
    $html =~ s/†/&Uuml;/gm;
    $html =~ s/š/&ouml;/gm;
    $html =~ s/…/&Ouml;/gm;
    $html =~ s/§/&#223;/gm; 
    $html =~s/™/&ocirc;/gm;
    $html =~s/¤/&sect;/gm;
    
    return $html;  
}

sub _get_content {
    my $self = shift;
    my $info = shift || '';
    
    my $file = "../data/". $self->{pagename} . ($info ? '_info' : '') . '.xml';
    
    unless (-e $file) { return ''; }
    
    open my $DATA, "<$file"
       or return $! . ' ' . $file;
    my @dat = <$DATA>;
    
    close $DATA;
    
    return join('',@dat);
}

sub sub_addressdata() {
	my $self = shift;
	
	my $address = 'Colin Hotzky<br/>Memelstrasse 41<br/>91052 Erlangen';
	my $contact = 'E-Mail: webmaster (at) hotzky (punkt) de';
	
	$self->{content} =~ s/xxxCONTACTxxx/$contact/g;
	$self->{content} =~ s/xxxADDRESSxxx/$address/g;
	
	
	
}

# ------------------------------------- SEND PAGE ----------------------------------------

sub send_page() {
    my $self = shift;
    
    my $cgi = $self->{cgi};
    my $content = $self->{content};
    
   # $self-> add_javascript($social_share);


    $cgi->charset('UTF-8');
    
    # ------------- HEADER ---------------
    my $html = $cgi->header(-dtd => '-//W3C//DTD XHTML 1.0 Transitional//DE', -type => 'text/html'); 
    $html .= $cgi->start_html(
        -title  =>'Homepage von Colin Hotzky',
        -author =>'Colin Hotzky',
        #-base   =>'true',
        #-target =>'_blank',
        -meta   =>  { 
            keywords            => $self->_get_keywords(),
            description         => $self->_get_description(),
            copyright           => $self->_get_copyright(),
            'content-language'  => $self->_get_language(),
            robots              => 'INDEX,FOLLOW',
            'revisit-after'     => '60 days',
        },
        -style  => $self->{css},
        -script => $self->{javascript},
        -head   => $self->{link_attr},
        
        
      #  -BGCOLOR=>'#FFFFCC',
      #  -TEXT   =>'#000000',
      #  -LINK   =>'red',
      #  -VLINK  =>'blue',
      #  -ALINK  =>'black'
    );
    
    # ----------------- NAVI -----------------
    $html .= $self->navigation();
    
    # ----------------- CONTENT --------------
    $html .= $self->{content};
    
    # ---------------- FOOTER ----------------
    $html .= $self->footer();
    
    # --------------- END PAGE --------------
    
    $html .= $self->{end_page};
    
    print $self->_replace_entities($html);
    
    return $self;
}

sub _get_keywords {
    my $self = shift;
    
    my $config = $self->{config};
    my $page   = $self->{page};
    
    my %seen;
        
    # common keywords
    my %keywords = map {$_ => 1} grep $_ && !$seen{$_}, map {$_->{$LANG}} @{$config->{keywords}->{item}};
    
    
    # page key words
    for (@{$config->{pages}->{page}->{$page}->{keywords}->{item}}) { # /
        $keywords{$_->{$LANG}} = 1 if $_->{$LANG} && !$seen{$_->{$LANG}};
    }
  
    return join(',', keys %keywords);
}

sub _get_description {
    my $self = shift;
    
    return $self->{config}->{description}->{$LANG};
}

sub _get_copyright {
    my $self = shift;
    return $self->{config}->{copyright};
}

sub _get_language {
    my $self = shift;
    return $self->{config}->{language};
}

sub _get_ul_list {
    my $self   = shift;
    my $params = shift;
    
    my @navi_order = @{$params->{order}};
    my $navi_pages = $params->{pages};
    my $navi_id    = $params->{id};
        
    my $html = '<ul>';

    for my $ord (@navi_order) {
        $html .= q(<li id=")
            . $navi_pages->{$ord}->{pid}
            . q(");
        $html .= q( class="aktiv") if ($ord eq $navi_id); 
       
        $html .= q(>);
        
        if ($ord ne $navi_id) {
            $html .= q(<a href=") . $navi_pages->{$ord}->{href} . q(">);
        }
        else {$html .= q(<span>);}
        
        $html .= $navi_pages->{$ord}->{$LANG};
        
        if ($ord ne $navi_id) {
            $html .= q(</a>);
        }
        else {$html .= q(</span>);}
        
        $html .= q(</li>);
    }
    
    $html .= q(</ul>);
    
    #die $html;
}

sub add_lang_to_url {
    return (shift =~ /\?/) 
       ? ('&lang=' . $LANG) 
       : ('?lang=' . $LANG);
}



1;
