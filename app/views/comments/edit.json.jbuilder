json.status "OK"
json.html render :partial => 'edit.html.haml', :locals => { :comment => @comment }
