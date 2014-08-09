# OK, so previews are a little bit of a kludge… a more normal way might be to add a @:preview@ flag to each individual
# model class, and then have some kinda weird duplication/versioning system to handle it.   
# This is a mess.
#
# The other normal way of doing this would be to store the model instance currently being edited in the session, which
# means you don’t have to involve mucking around in databases.   
# This is dirty, non-performant (because Rails sessions are stored in cookies), and it is <em>very</em> easy to exceed
# the session size limit… not good.
#
# Instead, I’ve created a preview model which is instantiated and used to store the ‘preview’ state of the content
# being edited that we can replay it into a new instance of that content model at a later date.
#
# Of course, I could have just changed session handling to use the database, but that seemed a little easy…
#
# :D
class Preview < ActiveRecord::Base
  
  # Relations
  belongs_to  :user
    
  # parse the data on load
  after_find  :parse_data
  
  class << self
    
    # This should be called instead of the constructor, and will return a suitable instance of this class tailored to
    # what you’re trying to do.
    #
    # If there’s already a preview for the content/user combination, it’ll return that. Otherwise, it’ll return a new
    # object keyed to that content/user.
    #
    # === Parameters
    #
    # [model_name]    the name of the ActiveRecord model class to get a preview for
    # [user]          the currently logged-in user
    def acquire( model_name, user )
      
      preview = find_by_model_name_and_user_id(model_name, user.id)
      
      preview = new({ :model_name => model_name, :user_id => user.id }) if preview.nil?
      
      preview      
    end
    
    # Cleans all previews for the given ActiveRecord model and user.
    #
    # === Parameters
    #
    # [model_name]    the name of the ActiveRecord model class to get a preview for
    # [user]          the currently logged-in user
    def clean( model_name, user )
      
      delete_all :model_name => model_name, :user_id => user.id
      
    end
    
    # Utility function that removes all previews older than two hours, irrespective of model and user.
    def clean_old
      
      delete_all [ 'created_on < ?', 2.hours.ago ]
      
    end
    
  end  
  
  # Updates the preview state of the current object.
  #
  # === Parameters
  #
  # [d]   the data to store in this preview
  def store( d )

    update_attribute( :model_data, d )
  
  end
  
  private
    def parse_data
      
      self.model_data = YAML::load(model_data) if model_data.is_a?(String)
      
    end

end