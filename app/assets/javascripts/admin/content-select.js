$('li.content_selector').each(function()
{
    var oWrap   = $(this),
        oInput  = oWrap.find('input').hide(),
        oSpan   = $('<span class="display">').insertAfter(oInput),
        sModel  = oWrap.data('model'),
        sPath   = ROOT_URI+'/'+sModel+'/choose',
        sSParm  = oWrap.data('filter'),
        oRem;
    
    // 1. normalise stuff
    if (path = oWrap.data('select-path'))
        sPath = path;
    if (sSParm !== undefined)
        sPath += '?'+sSParm;
    
    // 2. drop a button in...
    $('<a class="button -small -blue" data-remote>Select</a>').insertAfter(oSpan).attr('href', sPath).on('click', function()
    {
        $(window).one('content_selected', function(ev, id)
        {
            oInput.val(id).trigger('change');
        });
    })
    
    // 3. removal button
    oRem = $('<a class="button -small">Remove</a>').appendTo(oWrap).hide().on('click', function()
    {
        oInput.val('').trigger('change');
        return false;
    });
    
    // 4. bind to the change event
    oInput.on('change', function()
    {
        // a. reset and check
        oSpan.removeClass('-empty').empty();
        oRem.hide();
        
        if (oInput.val() === '')
        {
            oSpan.addClass('-empty');
            return;
        }
            
        // b. set status
        oSpan.addClass('-loading').html('Loading…');

        // c. query
        $.get(ROOT_URI+'/'+sModel+'/'+oInput.val()+'/embed', function(data)
        {
            oSpan.html(data).removeClass('-loading');
            oRem.show();
        });
    }).trigger('change');
});

$(document).on('click', '.content_select a.select', function()
{
    $(window).trigger('content_selected', [ $(this).data('content-id') ]);
    $('#lightbox .lb-close').trigger('click');
    return false;
});