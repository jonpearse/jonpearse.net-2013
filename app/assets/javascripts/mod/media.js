/**
 * Media Handler
 */
jjp.mediaHandler = (function()
{
    var aoResolution = [
        { color: '#F00', slug: 'desktop' },
        { color: '#0F0', slug: 'tablet'  },
        { color: '#00F', slug: 'mobile'  } 
    ],
        sCurrentSize    = '',
        oSense          = $('#sense'),
        oLookup         = {},
        oWin            = $(window),
        oTo             = null;
    
    function __init()
    {
        // 1. normalise resolutions
        var oTmp = $('<span/>');
        for (var i = 0; i < aoResolution.length; i++)
        {
            oTmp.css('background-color', aoResolution[i].color);
            oLookup[oTmp.css('background-color')] = aoResolution[i].slug;
        }
    
        // 2. bind on resize
        oWin.on('resize', function()
        {
            clearTimeout(oTo);
            oTo = setTimeout(checkSize, 100);
        })
    
        // 3. force it to check
        checkSize();
    }
    
    // functions
    function checkSize()
    {
        // a. grab current sense colour and check
        var sNewSize = oLookup[oSense.css('background-color')];
        
        // b. default for IE *sigh*
        if ((sNewSize === undefined) || (sNewSize === ''))
            sNewSize = 'desktop'
        
        // c. if we've changed
        if ((sNewSize !== undefined) && (sNewSize != sCurrentSize))
        {
            sCurrentSize = sNewSize;
            ping();
            sizeChanged();
            oWin.trigger('resolutionchange', sNewSize); // in case it comes in handy
        }
        
        // d. trigger a fallthru anyways
        oWin.trigger('resized');
    }
    
    function ping()
    {
        $.get('/media/ping/'+sCurrentSize, null, function() {});
    }
    
    function sizeChanged()
    {
        $('img, .resimg').each(function()
        {
            var oT   = $(this),
                bImg = (oT[0].nodeName.toLowerCase() == 'img'),
                sSrc = bImg ? oT.attr('src') : oT.css('background-image').replace(/url\((.*)\)/, '$1'),
                aM   = [],
                sU   = '';

            // 1. if it doesn't quack like a duck, fall out
            if ((aM = sSrc.match(/^((?:http:\/\/(?:.*?))?\/media\/(?:\d+))(?:\/([a-z])+)?$/)) === null)
                return;
                                    
            // 2. if we're already the right size, fall out
            if ((aM[2] !== undefined) && (aM[2] == sCurrentSize))
                return;
            
            // 3. generate the new URI
            sU = aM[1]+'/'+sCurrentSize;
            
            // 4. load
            if (bImg)
                oT.attr('src', sU);
            else
                oT.css('background-image', 'url('+sU+')');
        });
        
        oWin.trigger('sizechanged', sCurrentSize);
    }
    
    return {
        init:           __init,
        getCurrentSize: function()
        {
            return sCurrentSize;
        }
    }
})();