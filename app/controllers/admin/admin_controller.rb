# Superclass for all controllers in the namespace. This provides no functionality, but simply includes a @before_filter@
# hook that requires a user to be logged in.
class Admin::AdminController < ApplicationController
  before_filter :authenticate_user!

  layout 'admin'
end