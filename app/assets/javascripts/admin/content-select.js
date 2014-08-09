function ContentSelector(sTitle, sContentType, fCallback, aParam)
{
    // 0. defaults
    aParam = aParam || {};

    // 1. listen out for an ajax load
    $(window).one('content-selector-loaded', _payAttention);

    // 2. ping request to the server
    $.get('/m/'+sContentType+'/choose', aParam);

    // --- UTILITY FUNCTIONS ---
    function _payAttention()
    {        
        // form submission
        $('#lightbox').on('submit', 'form.select', function()
        {
            var aIds = [];
            $(this).find('input:checked').each(function() { aIds.push(this.value); });
            fCallback(aIds);
            _close();
            
            return false;
        }).on('change', 'input[type=radio]', function()
        {
            fCallback([this.value]);
            _close();
            
            return false;
        }).find('h2').text(sTitle);
        
        // also pay attention to uploads
        $(window).on('content_created', function(ev, id)
        {
            fCallback([id]);
            _close();
            return false;
        })
    }
    
    function _close()
    {
        $('#lightbox .lb-close').trigger('click');
    }
}

$('.single-media-selector').each(function()
{
    // 0. setup
    var oWrap   = $(this),
        oInput  = oWrap.find('select').hide(),
        oSpan   = $('<span class="display"/>').insertAfter(oInput),
        sType   = oWrap.data('type'),
        sTitle  = oWrap.data('title') || 'Select media',
        oRem;
    
    // 1. create an ‘add’ button
    $('<button class="-small -blue">Select</button>').insertAfter(oSpan).on('click', function()
    {
        ContentSelector(sTitle, 'media', _select, { type: sType });
        
        return false;
    });
    
    // 2. remove button
    oRem = $('<button class="-small">Remove</a>').appendTo(oWrap).hide().on('click', _remove).before('<br>');
    
    // 3. call load function
    _load();
    
    function _select(aId)
    {
        var id = aId[0];
        
        // 1. if there's an option 
        if (oInput.find('option[value="'+id+'"]').length == 0)
            $('<option/>').value(id).text('[ new item ]').appendTo(oInput);
        
        // 2. set up
        oInput.val(id);
        
        // 3. load things
        _load();
    }
    
    function _remove()
    {
        // 1. teardown
        oInput[0].selectedIndex = 0;
        
        // 2. trigger
        _load();
        
        return false;
    }
    
    function _load()
    {
        // 0. prep: hide everything
        oSpan.empty().removeClass('-empty -loading');
        oRem.hide();
        
        // 1. if there's nothing doing
        if (oInput.val() === '')
        {
            oSpan.text('No media selected').addClass('-empty');
            return;
        }
        
        // 2. otherwise
        oSpan.addClass('-loading').html('<i class="fa fa-spin fa-refresh"/> Loading…');
        
        // 3. query
        $.get('/m/media/'+oInput.val()+'/embed', function(sHtml)
        {
            oSpan.removeClass('-loading').html(sHtml);
            oRem.show();
        });
    }
    
});

$('.multi-media-selector').each(function()
{
    // 0. setup
    var oWrap   = $(this),
        oList   = oWrap[0].nodeName.toLowerCase() == 'ul' ? oWrap : oWrap.find('ul'),
        sField  = oWrap.data('field'),
        sType   = oWrap.data('type') || 'general';
        
    // 1. rewrite any existing inputs
    oWrap.find('input[type=checkbox]').attr('type', 'hidden');
    
    // 2. add an ‘add’ button
    $('<button class="-small -blue">Add</a>').on('click', function()
    {
        ContentSelector('Select Media', 'media', function(aId)
        {
            for (var i = 0; i < aId.length; i++)
                _select(aId[i]);
                
        }, { multiple: true, type: sType });
        return false;
    }).insertAfter(oList);
    
    // 3. add delete buttons to existing
    oList.children().each(_addDelete);
    
    // 4. bind on delete
    oList.on('click', 'button.act-delete', function()
    {
        if (confirm('Are you sure you wish to remove this item?'))
            $(this).parent().remove();
        
        return false;
    });
    
    // 5. make the list sortable
    oList.dragswap();
    
    // --- CALLBACKS ---
    function _select(id)
    {
        // 0. check!
        if (oList.find('input[value="'+id+'"]').length > 0)
            return;
        
        // 1. create a new item
        var oLi = $('<li class="item -loading -unsaved">').appendTo(oList).html('<i class="fa fa-spin fa-refresh"/> Loading…');
                
        // 2. now load
        $.get('/m/media/'+id+'/embed', function(sHtml)
        {
            // a. preview DOM
            oLi.removeClass('-loading').empty().append(sHtml);
            
            // b. field
            $('<input>').appendTo(oLi).attr({
                type:   'hidden',
                name:   sField,
                value:  id
            });
            
            // c. add a remove button
            _addDelete.call(oLi[0]);
        });
        
        // 3. remove thingie
        oList.siblings('p.nothing').remove();
    }
    
    function _addDelete()
    {
        $('<button class="act-delete -inline"></button>').appendTo($(this));
    }
    
    
});
