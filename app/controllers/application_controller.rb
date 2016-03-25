# Root application controller. This provides a number of useful functions that’re common to all controllers.
class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :set_default_meta_content
  attr_accessor :meta_description, :og_image
  
  layout 'site'
  
  # Convenience function that renders a 403 page
  def forbidden
    render_error 403, :forbidden
  end

  # Convenience function that renders a 404 page  
  def not_found
    render_error 404, :not_found
  end
  
  # Convenience function that renders a 401 page
  def unauthorised
    render_error 401, :unauthorized
  end
  
  # Utility function that overrides devise’s default functionality after a user logs in. In this case, if it’s the user’s
  # first time, they are bounced to a first-time log in page (see Admin::PasswordController#first_time)
  def after_sign_in_path_for user
    if user.first_time?
      flash[:alert] = "Because this is your first time here, you'll need to change your password"
      admin_first_login_path
    else
      admin_root_path
    end
  end
  
  # Utility function that overrides devise’s default functionality after a user logs out.
  def after_sign_out_path_for user
    new_user_session_path
  end
    
  private
    # Utility function for use with any of the error functions that serves the appropriate response based on status
    # code and request method.
    def render_error( code, action )
      respond_to do |format|
        format.html { render :action => action, :layout => 'site', :status => code }
        format.all  { render :nothing => true,  :status => code }
      end
    end
    
    # Sets the default meta content (description, OG:IMAGE) for the current request.
    def set_default_meta_content
      self.meta_description = t('site.desc')
      self.og_image = 'content/og_me.jpg'
    end
end
