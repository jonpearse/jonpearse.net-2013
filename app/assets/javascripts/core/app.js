/**
 * Main JS file, contains most of the core logic
 */
// root namespace
var App = (function()
{
    "use strict";

    var aBehaviours = {};
    var aHandlers   = {};
    var oDoc        = $(document);

    /**
     * Triggers all behaviours
     */
    function initBehaviours(oCtx)
    {
    	// 1. default the context to the document
    	if (oCtx === undefined)
    		oCtx = oDoc;

    	// 2. iterate through elements and bind behaviours
    	oCtx.find('[data-behaviour]').each(function()
    	{
    	    var aBh = $(this).data('behaviour').trim().split(/\s+/);
    	    var sBh = '';
    	    var i   = 0;

    	    for (; i < aBh.length; i++)
    	    {
                // dashes to camel for consistency
    	        sBh = aBh[i].replace(/\-([a-z])/i, function(sM, sFirst) { return sFirst.toUpperCase(); });

                // attempt to bind
    	        if (typeof aBehaviours[sBh] === 'function')
    	        {
    	            try
    	            {
    	                // load behaviour
                        aBehaviours[sBh].call(this);
    	            }
    	            catch (e)
    	            {
    	                console.error("Error when binding behaviour "+sBh);
    	            }
    	            finally
    	            {
    	                $(this).trigger('behaviours/'+sBh+'/bound');
    	            }
    	        }
    	        else
    	        {
                    console.warn("Undefined behaviour "+sBh);
                }
    	    }

            // fire events
            $(this).trigger('behaviours/@all/bound');
    	});
    }

    /**
     * Binds handlers—these are simpler functions that listen for events and do stuff with them.
     */
    function initHandlers()
    {
        $('body').on('click', '[data-handler]', function(ev)
        {
            // a. if we're clicking on a link with a modifier key, don’t bother interfering with the user
            if ((this.nodeName.toUpperCase === 'A') && (ev.metaKey || ev.shiftKey || ev.ctrlKey))
                return;

            // b. break out handlers
            var aHl = $(this).data('handler').trim().split(/\s+/),
                sHl = '',
                bR  = false;
                i   = 0;
            for (; i < aHl.length; i++)
            {
                sHl = aHl[i];
                bR  = true;

                if (typeof aHandlers[sHl] === 'function')
                {
                    bR = aHandlers[sHl].call(this, ev);
                }
                else
                {
                    console.warn("Undefined handler "+sHl);
                }

                // returning false from a handler should stop all further handlers from executing
                if (!bR)
                    return false;
            }
        });
    }

    /**
     * Binds a behaviour to the app.
     */
    function registerBehaviour(sBehaviour, fCallback)
    {
        if (aBehaviours[sBehaviour] !== undefined)
        {
            console.error("Attempting to redefine behaviour "+sBehaviour);
            return false;
        }

        aBehaviours[sBehaviour] = fCallback;
        return true;
    }
    // expose to global namespace
    window.registerBehaviour = registerBehaviour;

    /**
     * Registers a Handler
     */
    function registerHandler(sHandler, fCallback)
    {
        if (aHandlers[sHandler] !== undefined)
        {
            console.error("Attempting to redefine handler "+sHandler);
            return false;
        }

        aHandlers[sHandler] = fCallback;
        return true;
    }
    // expose to global namespace
    window.registerHandler = registerHandler;

    return {
		init: function()
		{
            // 1. local inits
			initBehaviours();
			initHandlers();

            // 2. modules
            for (var k in App)
            {
                // a. if it’s not one of our properties, not a module, or doesn’t have an init() method
                if (!App.hasOwnProperty(k) ||
                    (typeof App[k] === "function") ||
                    (App[k].init === undefined) ||
                    (typeof App[k].init !== "function"))
                    continue;

                // b. assume it’s a module, so call it
                App[k].init();
                oDoc.trigger('modules/'+k+'/inited');
            }

            // 3. call back
            oDoc.trigger('app/inited');
		},
    	initBehaviours: initBehaviours
    }
})();
