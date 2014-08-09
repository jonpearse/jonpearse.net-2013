jjp.galleries = (function()
{
    function Gallery()
    {        
        // 1. set everything up
        var oEl   = $(this).addClass('-processed'),
            oList = oEl.find('ul.images'),
            iNum  = oList.children().length,
            iCurr = 0;
        if (iNum > 1)
            _createPagination();
        
        // 2. bind on resolution
        $(window).on('sizechanged', _assessHeight);
        
        // 3. move stuff out of the way
        oList.children('li:not(:first)').addClass('-right');
        oList.children('li:first').addClass('-current');    // for older browsers
        
        // 4. bind swipe
        oEl.enableSwipe().on('swipeleft', function()
        {
            _go(1);
        }).on('swiperight', function()
        {
            _go(-1);
        })
        
        /**
         * Creates pagination DOM, binds event listeners
         */
        function _createPagination()
        {
            // 0. DOM
            var oPage = $('<nav class="pagination">').insertAfter(oList);
            
            // 1. back button
            $('<button class="-prev"/>').appendTo(oPage).append('<i class="fa fa-angle-left" title="view previous image"/>').on('click',function()
            {
                _go(-1);
                return false;
            });
            
            // 2. next button
            $('<button class="-next">').appendTo(oPage).append('<i class="fa fa-angle-right" title="ciew next image"/>').on('click',function()
            {
                _go(1);
                return false;
            });
        }
        
        /**
         * Callback bound to window.sizechanged event: resizes the carousel to match the height appropriate for the
         * current breakpoint.
         *
         * @param   ev      the event object itself
         * @param   sSize   the name of the new breakpoint.
         */
        function _assessHeight(ev, sSize)
        {            
            oList.css('height', oEl.data('height-'+sSize));
        }

        /**
         * Switches the carousel to the next/previous item.
         */
        function _go(iDir)
        {
            // 0. work out what's going on
            var iNextIdx = (iCurr + iDir + iNum) % iNum;
                oCurrImg = oList.children().eq(iCurr),
                oNextImg = oList.children().eq(iNextIdx);
            
            // 1. wipe classes
            oCurrImg.removeClass('-in -out -left -right');
            oNextImg.removeClass('-in -out');
            
            // 2. add them (in a timeout, to let things settle down)
            setTimeout(function()
            {
                oCurrImg.removeClass('-left -right -current').addClass((iDir < 0 ? '-right' : '-left')).addClass('-out');
                oNextImg.removeClass('-left -right -current').addClass((iDir > 0 ? '-right' : '-left')).addClass('-in -current');
            }, 10);
            
            // 2. update pointer
            iCurr = iNextIdx;
        }   
    }
    
    return {
        init: function()
        {
            $('aside.gallery:not(.-processed)').each(Gallery);
        }
    }
})();