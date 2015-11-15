/**
 * AJAX functions. This provides a beforeAjaxSend event as a global event handler, rather than something
 * more easily snarfable.
 */

App.Ajax = (function()
{
	var oBody = $('body');

	function bindBeforeSend()
	{
		$.ajaxSetup({
			beforeSend: function(oXhr, settings)
			{
				if (!settings.global)
					return;

				var oEv = $.Event('ajaxBeforeSend');

				oBody.trigger(oEv, [oXhr, settings]);

				return (oEv.isDefaultPrevented()) ? false : oEv.result;
			}
		});
	}

	function bindRailsCsrf()
	{
		// 1. get elements
		var elMeta = document.querySelector('meta[name=csrf-token]');
		if ((elMeta === null) || (elMeta.content === undefined) || (elMeta.content === ''))
			return;

		// 2. bind event
		oBody.on('ajaxBeforeSend', function(ev, oXhr, settings)
		{
			oXhr.setRequestHeader('X-CSRF-Token', elMeta.content);
		});
	}


	return {
		init: function()
		{
			// a. if we’re not using zepto, bind a ajaxBeforeSend event
			if (typeof Zepto === "undefined")
				bindBeforeSend();

			// b. handy CSRF binder for rails apps
			bindRailsCsrf();
		}
	}
})();
