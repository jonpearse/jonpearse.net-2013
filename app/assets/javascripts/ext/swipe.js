(function($)
{
    /**
     * Plug-in to watch for swipe events on objects. This has to be manually triggered on elements, it doesn’t globally
     * listen to everything.
     *
     * Options
     * -------
     *  iMinSuppressDelta   the minimum of horizontal movement on the element before we start inhibiting scrolling
     *                      (default: 10px)
     *  iMaxSwipeTime       the maximum amount of time a ‘swipe’ can take (after that, it’s just interaction)
     *                      (default: 1000ms)
     *  iMinHorizDelta      minimum horizontal distance before we consider interaction a swipe (30px)
     *  iMaxVertDelta       maximum vertical distance that we consider a swipe, otherwise it’s just interaction (75px)
     *
     * @param   opt configuration options (optional)
     */
    $.fn.enableSwipe = function()
    {
        var _opt = $.extend({
            iMinSuppressDelta: 10,          // minimum amount of (horiz) swipe before we stop scrolling
            iMaxSwipeTime:     1000,        // maximum amount of time we’ll watch for swiping, before we give up
            iMinHorizDelta:    30,          // minimum horizontal distance before we trigger a swipe
            iMaxVertDelta:     75           // maximum vertical distance at which we trigger a swipe
        }, (arguments.length == 1) ? arguments[0] : {});
    
        return this.on('touchstart.swipe', function(event)
        {            
            var oThis = $(this),
                oTouchEvent = event.originalEvent.touches[0],
                oStart = {
                    time: new Date().getTime(),
                    pos: {x: oTouchEvent.pageX, y: oTouchEvent.pageY},
                    target: $(event.target)
                },
                oEnd = null;

            // 1. bind move event
            oThis.on('touchmove.swipe', function(event)
            {
                oTouchEvent = event.originalEvent.touches[0];
            
                // a. store current info into oEnd object
                oEnd = {
                    time: new Date().getTime(),
                    pos: {x: oTouchEvent.pageX, y: oTouchEvent.pageY}
                };
            
                // b. if we’ve scrolled sufficiently far, cancel scrolling
                if (Math.abs(oStart.pos.x - oEnd.pos.x) > _opt.iMinSuppressDelta)
                {
                    event.preventDefault();
                }
            });
        
            // 2. bind end event
            oThis.on('touchend.swipe', function()
            {
                // a. unbind events
                oThis.off('touchmove.swipe touchend.swipe');
            
                // b. if it’s quick enough, and triggers threshholds
                if (((oEnd.time - oStart.time) < _opt.iMaxSwipeTime) &&
                    (Math.abs(oStart.pos.x - oEnd.pos.x) > _opt.iMinHorizDelta) &&
                    (Math.abs(oStart.pos.y - oEnd.pos.y) < _opt.iMaxVertDelta)
                )
                {
                    oStart.target.trigger('swipe').trigger((oEnd.pos.x > oStart.pos.x) ? 'swiperight' : 'swipeleft');
                }
            
                // c. teardown
                oStart = null;
                oEnd   = null;
            });
        });
    };
})(jQuery);