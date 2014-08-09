# This is a useful controller that allows us to do things with the user’s authentication tokens without having to
# mess around with {Devise}[https://github.com/plataformatec/devise].
class Admin::PasswordController < Admin::AdminController
  
  # Displays a ‘change password’ form to the current user.
  def edit
    @user = current_user
  end
  
  # Callback from #edit, that actally changes the user’s password. If this fails, the #edit template is rendered with
  # appropriate messaging
  #
  # === Expected parameters
  #
  # [user]  hash containing the user’s new password
  def update
    @user = User.find(current_user.id)
        
    if @user.update_with_password params.require(:user).permit(:current_password, :password, :password_confirmation)
      sign_in @user, :bypass => true
      flash[:notice] = "Your password has been updated"
      redirect_to 
    else
      render :action => 'edit'
    end
  end
  
  # This renders a view shown to the user the first time they log into the site, prompting them to enable two-factor
  # authentication.
  def first_time
    @user = current_user
    
    if !@user.first_time?
      redirect_to root_path
    end
    
    if params[:user]
      params[:user][:updated] = true
      if @user.update_attributes params.require(:user).permit(:password, :password_confirmation)
        sign_in @user, :bypass => true
        redirect_to admin_twofa_path
        return
      else
        flash[:notice] = "Because this is your first time here, you'll need to change your password"
        flash[:error] = @user.errors.full_messages.join(', ')
      end
    end
    render :action => 'first_time'      
  end
  
  # Allows the user to control two-factor authentication.
  def twofa
    @user = current_user
    
    if params[:user]
      if @user.update_attributes params.require(:user).permit(:gauth_enabled,:password,:password_confirmation)
        if (params[:user][:gauth_enabled] == '1')
          flash[:info] = "Two-factor authentication has been enabled"
        else
          flash[:warn] = "Two-factor authentication was not enabled"
        end
        redirect_to admin_twofa_path
        return        
      else
        flash[:error] = "Something went wrong while trying to update your settings"
      end
    end
    
    if !@user.twofa_enabled?
      @user.regenerate_secret!
    end
  end
  
  # Quick utility method that allows the user to disable two-factor authentication.
  def twofa_disable
    if current_user.update_attributes( :gauth_enabled => false )
      flash[:info] = "Two-factor authentication has been disabled"
      redirect_to admin_twofa_path
      return
    end
    
    flash[:error] = "Something went wrong while trying to turn off two-factor authentication"
    redirect_to admin_change_password_path
  end
end