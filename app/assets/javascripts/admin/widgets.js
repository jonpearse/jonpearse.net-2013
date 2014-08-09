$('.flashes li.-can-dismiss').append('<i class="fa fa-times" title="remove"></i>').on('click', function()
{
    $(this).animate('fade-and-zip', { duration: 500, complete: function() { $(this).remove(); }});
})

$('.widget.-dynamic').each(function()
{
    var oWidget = $(this),
        sSource = oWidget.data('src'),
        oContent = null,
        oHead    = null;
        
    // 0. if there's nothing to do
    if (sSource === undefined)
        return;
    
    // 1. grab content
    oContent = oWidget.children('div').eq(0);
    oHead    = oWidget.children('header');
    if (oHead.children('span').length == 0)
        oHead.prepend('<span class="icons">');
    oHead = oHead.children('span');    
    
    // 2. callback
    function _load()
    {
        oWidget.addClass('-loading').removeClass('-loaded').find('.fa-refresh').addClass('fa-spin');
        $.ajax({
            type:       'GET',
            url:        sSource,
            timeout:    1000,
            success:    function(sHtml)
            {
                oWidget.removeClass('-error').addClass('-loaded');
                oContent.empty().html(sHtml);
            },
            error:      function()
            {
                oWidget.addClass('-error');
            },
            complete:   function()
            {
                oWidget.removeClass('-loading').find('.fa-refresh').removeClass('fa-spin');
            }
        });
        return false;
    }
    _load();    
    
    // 3. append to header
    $('<a href="#" class="act-refresh"><i class="fa fa-refresh"/></a>').on('click', _load).appendTo(oHead).wrap('<span>');
});
