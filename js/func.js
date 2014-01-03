// JavaScript Document
document.observe("dom:loaded", function() {
	print_border();
	social();
 });

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
$('social').style.display = '';
}