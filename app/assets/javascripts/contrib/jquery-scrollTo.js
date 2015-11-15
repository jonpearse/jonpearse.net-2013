(function($)
{
	$.fn.scrollTo = function(options)
	{
		$('html,body').stop().animate({
			scrollTop: $(this).first().offset().top - 10
		}, options)
	}
})( jQuery );
