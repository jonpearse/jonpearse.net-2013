$('a.sortable').on('click', function()
{
    $(this).addClass('current').find('i').toggleClass('fa-play fa-refresh fa-spin');
})