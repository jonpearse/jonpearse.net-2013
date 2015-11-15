status ||= "OK"
json.status status
json.html render :partial => 'new.html.haml', :locals => { :comment => @comment }
