jjp.forms = (function()
{
    function setup()
    {
        $('#container').on('submit.jjpform', 'form', function()
        {
            $(this).find('button[type=submit]').prop('disabled',true);
        }).on('click', 'button[type=submit]', function()
        {
            $(this).append('<i class="fa fa-refresh fa-spin"/>');
        });
    }
    
    
    return {
        init: setup
    }
})();