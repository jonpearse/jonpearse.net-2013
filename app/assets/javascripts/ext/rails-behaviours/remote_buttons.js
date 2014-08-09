// Remote
//
//= require ./beforesend
//
// Extends `data-remote` to apply to buttons as well. When applied to a button[type=submit],
// this causes it to submit the form asynchronously, potentially to a different location
// than the form might otherwise submit.
//
//
// ### Markup
//
// `<button type="submit">`
//
// ``` definition-table
// Attribute - Description
//
// `data-remote`
//   Enables remote behavior on the element if set to anything.
//
// `data-method`
//   Changes the method of the AJAX request. Defaults to `"get"`. Maps to
//   jQuery's [type](http://api.jquery.com/jQuery.ajax/).
// ```
//
// ``` html
// <button type="submit" data-remote>Submit</button>
// ```
//
//
// ### Events
//
// Use delegated jQuery's global AJAX events to handle successful
// and error states. See jQuery's [AJAX event
// documentation](http://docs.jquery.com/Ajax_Events) for a complete
// reference.
//
// `ajaxBeforeSend`
//
// This event, which is triggered before an Ajax request is started, allows you to modify the XMLHttpRequest object (setting additional headers, if need be.)
//
// ``` definition-table
// Property - Value
//
// Synchronicity  - Sync
// Bubbles        - Yes
// Cancelable     - Yes
// Default action - Sends request
// Target         - `a` or `form` element with `[data-remote]`
// Extra arguments
//   [`jqXHR`](http://api.jquery.com/jQuery.ajax/#jqXHR) - XMLHttpRequest like object
//   [`settings`](http://api.jquery.com/jQuery.ajax/#jQuery-ajax-settings) - Object passed as `$.ajax` settings
// ```
//
// `ajaxSuccess`
//
// This event is only called if the request was successful (no errors from the server, no errors with the data).
//
// ``` definition-table
// Property - Value
//
// Synchronicity  - Sync
// Bubbles        - Yes
// Cancelable     - No
// Target         - `a` or `form` element with `[data-remote]`
// Extra arguments
//   [`jqXHR`](http://api.jquery.com/jQuery.ajax/#jqXHR) - XMLHttpRequest like object
//   [`settings`](http://api.jquery.com/jQuery.ajax/#jQuery-ajax-settings) - Object passed as `$.ajax` settings
//   `data` - The data returned from the server
// ```
//
// `ajaxError`
//
// This event is only called if an error occurred with the request (you can never have both an error and a success callback with a request).
//
// ``` definition-table
// Property - Value
//
// Synchronicity  - Sync
// Bubbles        - Yes
// Cancelable     - No
// Target         - `a` or `form` element with `[data-remote]`
// Extra arguments
//   [`jqXHR`](http://api.jquery.com/jQuery.ajax/#jqXHR) - XMLHttpRequest like object
//   `textStatus` - `"timeout"`, `"error"`, `"abort"`, or `"parsererror"`
//   `errorThrown` - Exception object
// ```
//
// `ajaxComplete`
//
// This event is called regardless of if the request was successful, or not. You will always receive a complete callback, even for synchronous requests.
//
// ``` definition-table
// Property - Value
//
// Synchronicity  - Sync
// Bubbles        - Yes
// Cancelable     - No
// Target         - `a` or `form` element with `[data-remote]`
// Extra arguments
//   [`jqXHR`](http://api.jquery.com/jQuery.ajax/#jqXHR) - XMLHttpRequest like object
//   `textStatus` - `"timeout"`, `"error"`, `"abort"`, or `"parsererror"`
// ```
//
//     $(document).on 'ajaxBeforeSend', '.new-comment', ->
//        $(this).addClass 'loading'
//
//     $(document).on 'ajaxComplete', '.new-comment', ->
//        $(this).removeClass 'loading'
//
//     $(document).on 'ajaxSuccess', '.new-comment', (event, xhr, settings, data) ->
//       $('.comments').append data.commentHTML
//
//     $(document).on 'ajaxError', '.new-comment', ->
//       alert "Something went wrong!"
//

// Intercept all button clicks with data-remote and turn
// it into a XHR request instead.
$(document).on('click', 'button[type=submit][data-remote]', function(event)
{
    var button      = $(this),
        form        = button.parents('form').eq(0),
        settings    = {},
        url         = null,
        data        = null,
        method      = null,
        button_name = null;
                
    // Setting `context` to the form will cause all global
    // AJAX events to bubble up from it.
    settings.context = this

    // Grab the submission URL
    if (((url = button.data('remote')) !== '') ||
        (url = form.attr('action')))
        settings.url = url;
    
    // Grab the submission method
    if (((method = button.data('method')) !== undefined) ||
        (method = form.attr('method')))
        settings.type = method;    
    
    // Serialise form out
    if (data = form.serializeArray())
        settings.data = data;

    // Add name of button, if we have one
    if (button_name = button.attr('name'))
        settings.data.push({ name: button_name, value: button.val() });
    
    // hack a header that the back-end can pick up
    settings.headers = { "X-RJS": true }    
    
    // Pickle request off
    $.ajax(settings);
    
    // prevent default action of clicking the button
    event.preventDefault();
    return false;
});
  
// Hold a reference to sent XHR object.
/*$(document).on('ajaxSend', '[data-remote]', function(event, xhr)
{
    $(this).data('remote-xhr', xhr);
    return;
}).on('ajaxComplete', '[data-remote]'), function(event, xhr)
{
    $(this).removeData('remote-xhr');
    return;
}
*/