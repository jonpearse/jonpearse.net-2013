//= require ext/jquery
//= require ext/plugins
//= require ext/elementquery
//= require ext/rails-behaviours/index
//= require ext/swipe
//= require mod/ns
//= require_tree ./mod

// init all loaded modules
$(function()
{
    for (module in jjp)
        jjp[module].init();
});