json.status "OK"
json.html render :partial => 'list.html.haml', :locals => { :comments => @comments }
