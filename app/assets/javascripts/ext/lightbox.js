/**
 * Additional jQuery plugins
 */
(function($)
{
    /**
     * New, improved lightbox code.
     *
     * Options:
     *
     * -EITHER- 
     *  sUri        the URI to load the content from (mutex with oDom)
     *  sData       any POST/GET data to send with the request for content (only if using sUri)
     *  sMethod     the method to use while loading the data (using sUri)
     * -OR-
     *  oDom        a jQuery object or HTML string to use as the content of the lightbox (mutex with sUri)
     *
     *  complete        a function to call once the lightbox is loaded and rendered
     *  sTitle          the title to use of the lightbox
     *  bDynWidth       dynamically use the width of the content
     *  bAutoClose      true to automatically close the lightbox after a given time—useful for status flashes
     *  iCloseTimeout   the length of time the lightbox is displayed before being auto-closed (if set. Default: 1 second)
     *
     * @author  Jon Pearse
     */
    $.lightbox = function(opt)
    {
        // 0. various configuration options
        var option = $.extend(true, {
            sUri: null,
            oDom: null,
            sData: null,
            sMethod: 'get',
            complete: null,
            sTitle: 'Lightbox',
            bDynWidth: false,
            bAutoClose: false,
            iCloseTimeout: 1000,
            sAddnClass: ''
        }, opt);
        var oWin = $(window);
        var bIsOldIE = (navigator.appVersion.match(/MSIE (7|8)/) !== null);

        var toAutoClose = null;
        
        var iLastHeight = 0;

        // 1. get the element
        var oLb = $('#lightbox');
        if (oLb.length === 0) 
        {
            var sHtml = '<div id="lightbox" class="lb-container">'+
            '<div class="lb-masq"></div>'+
            '<div class="lb-wrapper">'+
            (option.sTitle === null ? '' : '<h2>'+option.sTitle+'</h2>')+
            '<a href="#" class="lb-close lb-main-close">close</a>'+
            '<div class="lb-content"></div>'+
            '</div>'+
            '</div>';
            oLb = $(sHtml).appendTo($('body'));
            oLb.delegate('.lb-close, .lb-masq', 'click.mblb', function()
            {
                oWin.unbind('.mblb');
                oLb.hide();
                oLb.find('.lb-content').css({ height: '' }).empty();
                
                // unhook hack
                if (navigator.appVersion.match('iPad'))
                {
                    oLb.unbind('touchmove.mblb', function(e) { return false; });
                }

                return false;
            });

            // hook a window resize handler
            oWin.bind('resize.mblbrs', function()
            {
                oLb.css({
                    height: oWin.height(),
                    width: oWin.width(),
                    top: 0,
                    left: 0
                });
            }).trigger('resize.mblbrs');

            // this is really, really stupid, but MobileSafari doesn’t grok position:fixed in the way we expect, so we’ll
            // handle it nastily by disabling scrolling
            if (navigator.appVersion.match('iPad|iPhone'))
            {
                oLb.bind('touchmove.mblb', function(e) { return false; }).css('top', oWin.scrollTop());
            }

            // deal with lack of CSS3 in IE 7+8 by hooking in some extra markup to wrap background images around. Don’t touch
            // IE6 because it’ll just be Nasty
            if (bIsOldIE)
            {
                oLb.addClass('lb-container-ie').find('.lb-wrapper').append('<div class="lb-wrapper-bottom"></div>');
            }

            // get native height and store
            oLb.show().data('content-height', oLb.find('.lb-content').height()).data('content-width', oLb.find('.lb-content').width()).hide();

            // trigger height adjust
            oLb.bind('contentLoaded', function()
            {
                // get target height
                var oContent= oLb.find('.lb-content'),
                    oWrap   = oLb.find('.lb-wrapper'),
                    iH      = Math.min(oWin.height() * 0.8, Math.max(oLb.data('content-height'), oContent.height()));
                    iOff    = (oWin.height() - (iH + (oWrap.innerHeight() - oContent.innerHeight()))) / 2;
                    
                oWrap.animate({ top: iOff+'px'}, { queue: false, duration: 100 });
                oContent.animate({ height: iH+'px' }, { queue: false, duration: 100 });

                // if we’re handling width, or the lightbox is in the wrong place…
                var iCurrW = oContent.width();
                if ((oLb.data('auto-width') === 'yes') ||
                    ((oLb.data('auto-width') === 'no') && (iCurrW !== oLb.data('content-width'))))
                {
                    // get dimensions            
                    var iW = (oLb.data('auto-width') === 'yes')
                                ? Math.max(oLb.data('content-width'), oContent.css('width', ((bIsOldIE) ? '' : 'auto')).width())
                                : oLb.data('content-width');

                    // work out difference
                    iDelta = iW - iCurrW;

                    // animate
                    if (iDelta > 0)
                    {
                        oWrap.css({ left: '-='+(iDelta / 2) }, { queue: false, duration: 1 });
                        oContent.animate({ width: iW+'px' }, { queue: false, duration: 1 });
                    }
                    else
                    {
                        iDelta = Math.abs(iDelta);
                        oWrap.animate({ left: '+='+(iDelta / 2) }, { queue: false, duration: 1 });
                        oContent.animate({ width: iW+'px' }, { queue: false, duration: 1 });
                    }
                }

                // hook up escape key
                oWin.unbind('keydown.mblb').bind('keydown.mblb', function(oEv)
                {
                    if ((oEv.which === 27) && (!$(oEv.target).is(':input')))
                    {
                        oLb.find('a.lb-close').click();
                        return false;
                    }
                });
                
                // call last height
                iLastHeight = iH;
            });            
        }
        else
        {
            oLb.find('h2').html(option.sTitle);
        }

        // b. set width param
        oLb.data('auto-width', (option.bDynWidth ? 'yes' : 'no'));
        clearTimeout(toAutoClose);

        // 2. get hooks on everything
        var oWrap = oLb.children('.lb-wrapper').removeClass().addClass('lb-wrapper '+option.sAddnClass);
        var oContent = oLb.find('.lb-content');

        // 3. if it’s hidden, position it right and show it
        if (oLb.is(':hidden'))
        {
            // a. show everything so we can do height/width stuff
            oLb.show();
            
            // b. reset content height
            oContent.empty().css('height', '');

            // c. initial position
            oWrap.css({
                top: ((oWin.height() - oWrap.innerHeight()) / 2),
                left: ((oWin.width() - oWrap.innerWidth())  / 2)                
            });

            // d. fade everything in
            oLb.hide().show();
        }
        else
        {
            oContent.empty().css('height', '');
        }

        // 4. construct callback function
        var fCb = function()
        {
            // remove loading class
            oWrap.removeClass('lb-wrapper-loading');

            // trigger ‘contentLoaded’ hook
            oLb.trigger('contentLoaded');

            // trigger ‘complete’, if specified
            if (typeof option.complete === 'function')
            {
                option.complete();
            }

            // if we’re set to autoclose, do so
            if (option.bAutoClose)
            {
                toAutoClose = setTimeout(function()
                {
                    oLb.find('.lb-close').click();
                }, option.iCloseTimeout);
            }
        };

        // 5. if we’ve got DOM content specitied…
        if (option.oDom !== null)
        {
            // append the DOM
            oContent.append(option.oDom);

            // callback
            fCb();
            return true;
        }

        // 6. otherwise we’re loading from the server, which we do on a timeout… for some reason.
        setTimeout(function()
        {
            $.ajax(option.sUri, {
                type: option.sMethod,
                data: option.sData,
                success: function(data)
                {
                    oContent.html(data);

                    // callback
                    fCb();
                }
            });
        }, 100);

        return true;
    };
    
    /**
     * Custom plugin that returns the height of all content within a given container—this is useful when dealing with
     * scrollable containers.
     *
     * @author  Jon Pearse/E3 Media
     */
    $.fn.totalHeight = function()
    {
        var iH = 0;
        this.children().each(function()
        {
            iH += $(this).outerHeight(true);
        });
        return iH;
    };
})(Zepto);