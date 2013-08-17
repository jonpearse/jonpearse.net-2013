# Represents a media item of some kind within the system.
#
# At the moment, this only handles images, but at some point it’ll be extended to additionally handle video and possibly
# even audio as the need arises.
#
# This class makes use of the excellent {paperclip}[https://github.com/thoughtbot/paperclip]
class Media < ActiveRecord::Base
  include Errorable
  
  # constants
  TYPES = {
    :general    => { :original => '550x490>', :desktop => '100%',       :tablet => '69%',       :mobile => '44%',       :thumb => '100x100#' },
    :responsive => {                          :desktop => '900>',       :tablet => '680>',      :mobile => '380>',      :thumb => '100x100#' },
    :banner     => {                          :desktop => '1050x378>',  :tablet => '700x250>',  :mobile => '400x145>',  :thumb => '100x100#' } 
  }
  
  # relations
  
  # accessors
  attr_accessible :title, :alt_text, :title_text, :media_type, :file, :default_align
  
  # hooks
  has_attached_file :file,
                    :styles => lambda { |attachment| t = (attachment.instance.media_type.empty? ? :general : attachment.instance.media_type.to_sym); return Media::TYPES[t] }
  
  # validation
  validates :title, :media_type, :file, :presence => true
  validates_attachment :file, :content_type => { :content_type => /^image\/(png|gif|jpeg)/ },
                              :size => { :in => 0..512.kilobytes }
  
end