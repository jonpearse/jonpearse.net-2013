(function($)
{
    /**
     * Custom selector, for fun and profit
     */
    $.expr[':'].changed = function(oEl, index, meta, stack)
    {        
        // 0. drop out
        var sN = oEl.nodeName.toLowerCase();
        if ((sN !== 'input') && (sN !== 'textarea') && (sN !== 'select'))
            return false;
        if (oEl.getAttribute('data-no-check') != null)
            return false;

        // 1. custom hook for SELECT boxes
        if (sN == 'select')
        {
            // a. iterate through all options. If one has changed, we've changed
            for (var i = 0; i < oEl.options.length; i++)
                if (oEl.options[i].defaultSelected != oEl.options[i].selected)
                    return true;
    
            // b. nothing has changed
            return false;
        }

        // 2. otherwise, for radios and checkboxen, use (default)checked
        var sType = oEl.getAttribute('type');
        if ((sType !== null) && ((sType.toLowerCase() == 'radio') || (sType.toLowerCase() == 'checkbox')))
            return (oEl.checked != oEl.defaultChecked);

        // 3. everything else uses (default)value
        return (oEl.defaultValue != oEl.value);
    }
})(jQuery);