// JavaScript Document
document.observe("dom:loaded", function() {
	//revise_size();
	//set_height();
	print_border();
	social();
});

function set_height() {
    var pic_height     = $('pic_area').offsetHeight;
    var content_height = $('content_area').offsetHeight;
    
    if (pic_height < content_height)
        $('pic_area').style.height = content_height + 'px';
    else $('content_area').style.height = pic_height + 'px';
}



function revise_size() {
    var cur_width = document.body.offsetWidth;
    $("content_area").style.width = (cur_width - $("pic_area") - 100) + "px";
}

function print_border() {
	if ($('pic_area').offsetHeight >= $('content_area').offsetHeight) {
		$('pic_area').setStyle({
			'borderRight': "5px solid #B28A62"
		});
	}
	else {
		$('content_area').setStyle({
			'borderLeft': "5px solid #B28A62",
			'marginLeft': "380px",
			'paddingLeft': "30px"
		});
	}
}

function social() {
	$('#socialshareprivacy').socialSharePrivacy({
		  services : {
		    facebook : {
		      'perma_option': 'off'
		    }, 
		    twitter : {
		        'status' : 'off'
		    },
		    gplus : {
		      'display_name' : 'Google Plus'
		    }
		  },
		  'cookie_domain' : 'heise.de'
		});
}