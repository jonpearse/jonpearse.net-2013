/**
 * Window monitor. This mostly does window resize event delegation;
 */
App.Window = (function()
{
	"use strict";
    
	var oBody    = null;
	var oTo      = null;
	var sSize    = null;

	/**
	 * Binds a handler to the window resize
	 */
	function init()
	{
		// 1. start stuff up
		oBody = $('body');

		// 2. bind to window resize
		$(window).off('.appWindow').on('resize.appWindow', $.debounce(100, assessWidth));

		// 3. finally, trigger the handler
		setTimeout(assessWidth, 100); // delay, for IE…
	}

	/**
	 * Callback from resize handler in init, above.
     */
	function assessWidth()
	{
		// 1. trigger a resize event
		oBody.trigger('windowResize');

		// 2. work out the breakpoint, if it exists
		var sNewSize = window.getComputedStyle(document.body, ':before').content.replace(/[^a-z]/g, '')
		if ((sNewSize !== "") && (sNewSize !== sSize))
		{
			oBody.trigger('viewportChange', sNewSize);
			sSize = sNewSize;
		}
	}

	return {
		init:      init,
		getSize:   function()
		{
			return sSize;
		}
	}

})();
