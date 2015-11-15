json.status   'OK'
json.html     render :partial => 'screen_link.html.haml', :locals => { :comment => @comment }
json.screened @comment.screened
