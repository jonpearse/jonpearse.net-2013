json.status "OK"
json.html render :partial => 'comment.html.haml', :locals => { :comment => @comment }
json.comment_id @comment.id
