jjp.comments = (function()
{
    /**
     * Binds to any RJS-enabled link in the comments section, and adds loading state to enclosing SECTION when clicked.
     */
    function handleLoading()
    {
        $('#comments').find('a[data-remote]').on('click', function(e)
        {
        	$(this).find('i').addClass('fa-spin fa-refresh').parents('section').eq(0).addClass('-loading');
        });
    }
    
    function bindChaseClicks()
    {
        $('#comments').on('click', 'a[data-comment-id]', function()
        {
            var iCommentId = $(this).data('comment-id'),
                oComment   = $('#comment-'+iCommentId);

            if (oComment.length > 0)
            {
                oComment.removeClass('-this');
                setTimeout(function() { oComment.addClass('-this'); }, 10);
            }
        });
    }
    
    /**
     * Shows form opening animation
     */
    function animateFormIn(oForm)
    {   
        // remove spin styles
        $('#comments a i.fa-spin').removeClass('fa-spin fa-refresh');
        
        // hide the appropriate trigger so we can't do it again
        if (oForm.parent().is('#comments'))
            oForm.parent().children('header').find('a').addClass('-hide');
        else
            oForm.siblings('footer').find('a').addClass('-hide');
            
        // accost any cancel links
        oForm.on('click', '.act-cancel', function()
        {
            if (!oForm.find(':input').is(':changed') || confirm("Are you sure you want to do this?"))
            {
                oForm.remove();
                $('#comments').find('a.-hide').removeClass('-hide');
            }
            
            return false;
        });
    }
    
    return {
        init: function()
        {
            handleLoading();
            bindChaseClicks();
        },
        markLoaded: function()
        {
            $('#comments').removeClass('-loading');
        },
        openForm: animateFormIn
    };
})();