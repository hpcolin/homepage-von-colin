package Framework;

use strict;
use XML::Simple qw(XMLin XMLout);

sub new {
	my $class   = shift;
	my $params  = shift;
		
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
            },
            {
                -language   => 'javascript',
                -src        => '../js/func.js',
            },
            {   -language   => 'javascript',
                -src        => '../js/jquery.js',
            },
            {   -language   => 'javascript',
                -src        => 'jquery.socialshareprivacy.js',
            },
        ],
        keywords       => q( 
            Colin 
            Hotzky 
            Kochen 
            Reisen 
            Buch 
            Leipzig 
            Wandern 
            Urlaubsberichte 
            Erlangen
            NŸrnberg
            FŸrth
            Franken
            Perl
            Artikel)
	};
	
	bless($self, $class);
	
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
    $html .= $self->add_ad('astore_widget') if ($self->get_page() eq 'travel');
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


sub footer {
    return shift->_get_footer_html();
}

sub navigation  {
    my $self = shift;
    
    my $c_page = $self->_get_page();
    my $s_page = $self->_get_subpage();
    
    my $html ='<div id="title_bar"><div id="title">Homepage von Colin Hotzky</div><div id="nav">';		
    
    my %pages;
    
    $pages{index} = { 
        id    => 'index',
        href  => 'index.pl',
        label => 'Home',
    };
    $pages{travel} = { 
        id    => 'travel',
        href  => 'index.pl?page=travel',
        label => 'Ausfl&uuml;ge &amp; Reisen',
        subs  => {
            greece1997 => {
                id    => 'greece1997',
                href  => 'index.pl?page=travel&sub=greece1997',
                label => 'Griechenland 1997',
            },
            uk1997 => {
                id    => 'uk1997',
                href  => 'index.pl?page=travel&sub=uk1997',
                label => 'England, Schottland und Wales 1997',
            },
            france1998 => {
                id    => 'france1998',
                href  => 'index.pl?page=travel&sub=france1998',
                label => 'Frankreich 1998',
            },
            uk1999 => {
                id    => 'uk1999',
                href  => 'index.pl?page=travel&sub=uk1999',
                label => 'England und Schottland 1999',
            },
        },
    };
    $pages{books} = { 
        id    => 'books',
        #href  => 'http://astore.amazon.de/homepagevonco-21/detail/3836412756',
        href  => 'index.pl?page=books',
        label => 'Buchtip',
    };
    $pages{rueda} = { 
        id    => 'rueda',
        href  => 'index.pl?page=rueda',
        label => 'Rueda',
    };
    $pages{gb} = { 
        id    => 'gb',
        href  => 'http://www.grafikgaestebuch.de/ggbook.php?userid=65960',
        label => 'G&auml;stebuch',
    };
    $pages{mongers} = { 
        id    => 'mongers',
        href  => 'index.pl?page=mongers',
        label => 'Perl Mongers',
    };
    $pages{impressum} = { 
        id    => 'impressum',
        href  => 'index.pl?page=impressum',
        label => 'Impressum',
    };
    
    my @page_display = ('index','travel','books','mongers','impressum',);
    
    	         

    $html .= '<ul>';

    for my $key (@page_display) {
        $html .= '<li id="'
            . $pages{$key}->{id}
            . '"';
        $html .= ' class="aktiv"' if ($key eq $c_page);    
        $html .= '><a href="'
            . $pages{$key}->{href}
            . '">'
            . $pages{$key}->{label}
            . '</a></li>';
    }
    
    $html .= '</ul>';


    $html .= '</div></div></div>';	
    
    $html .= '<div id="header_bar">'    
          . '<div id="breadcrumb" style="float:right">'
          . '<ul>'
          . '<li><a href="index.pl">Home</a></li>';
          
    if ($c_page ne 'index') {
        $html .= '<li><a href="'.$pages{$c_page}->{href}.'">'.$pages{$c_page}->{label}.'</a></li>';
    }
    
    if ($s_page) {
        $html .= '<li><a href="'.$pages{$c_page}->{subs}->{$s_page}->{href}.'">'.$pages{$c_page}->{subs}->{$s_page}->{label}.'</a></li>';
    }
    
    $html .= '</ul></div></div></div><div id="socialshareprivacy"></div>';
    
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
    my $self  = shift;
    my $javascript    = shift;
    my $islib = shift;
    
    if ($islib) {
        push (@{$self->{javascript}}, $javascript);
    }
    else {
        push (@{$self->{javascript}}, {
            -language   => 'javascript',
            -src        => $javascript,
        });
    }
    
}

sub add_keywords {
    my $self = shift;
    $self->{keywords} .= shift;
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

sub _get_page() { return shift->{page};}
sub get_page() { return shift->{page};}

sub _get_subpage() { return shift->{subpage};}

sub _replace_entities {
    my $self = shift;
    my $html = shift;
    
    $html =~ s/Š/&auml;/gm;
    $html =~ s/€/&Auml;/gm;
    $html =~ s/Ÿ/&uuml;/gm;
    $html =~ s/†/&Uuml;/gm;
    $html =~ s/š/&ouml;/gm;
    $html =~ s/…/&Ouml;/gm;
    $html =~ s/§/&#223;/gm; 
    $html =~s/™/&ocirc;/gm;
    
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

# ------------------------------------- SEND PAGE ----------------------------------------

sub send_page() {
    my $self = shift;
    
    my $cgi = $self->{cgi};
    my $content = $self->{content};
    
    my $social_share = <<'SHARE';
jQuery(document).ready(function($){
      if($('#socialshareprivacy').length > 0){
        $('#socialshareprivacy').socialSharePrivacy(); 
      }
    });
SHARE


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
            keywords => $self->{keywords},
            description         => 'Homepage von Colin Hotzky',
            copyright           => '1997 - 2012 by Colin Hotzky',
            'content-language'  => 'de',
            robots              => 'INDEX,FOLLOW',
            'revisit-after'     => '60 days',
        },
        -style  => { src => '../css/global_design.css' },
        -script => $self->{javascript},
        
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

1;
