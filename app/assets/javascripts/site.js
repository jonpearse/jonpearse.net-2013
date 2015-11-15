/* External modules */
//= require contrib/jquery-2.1.4
//= require contrib/jquery-debounce
//= require contrib/jquery-changed
//= require contrib/jquery-scrollTo
//= require contrib/elementquery

// core components
//= require core/app
//= require_tree ./core

// behaviours
//= require behaviours/responsiveMedia
//= require behaviours/comments

// handlers

/**
 * Loader: kicks everything off
 */
$(function()
{
	// 1. init core app functionality
	App.init();

	// 2. pay attention to window dimension change so we can ping manually
	$('body').on('viewportChange', function(ev, sNewSize)
	{
		$.get('/media/ping/'+sNewSize, null, function() {});
	});
});
