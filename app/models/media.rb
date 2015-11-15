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
    :banner     => {                          :desktop => '1050x375>',  :tablet => '756x270>',  :mobile => '546x195>',  :thumb => '100x100#' }
  }

  # relations
  has_and_belongs_to_many :galleries
  belongs_to :attribution_license, :foreign_key => :attribution_license_id, :class_name => "MediaLicense"

  # hooks
  has_attached_file :file,
                    :path   => ":rails_root/public/system/media/:id_partition/file/:style.:extension",
                    :url    => "/system/media/:id_partition/file/:style.:extension",
                    :styles => lambda { |attachment| t = (attachment.instance.media_type.empty? ? :general : attachment.instance.media_type.to_sym); return Media::TYPES[t] },
                    :convert_options => {
                      :all    => '-strip -quality 70'
                    }

  # validation
  validates :title, :media_type, :file, :presence => true
  validates_attachment :file, :content_type => { :content_type => /^image\/(png|gif|jpeg)/ },
                              :size => { :in => 0..1024.kilobytes }

  # scopes
  scope :general,     -> { where(:media_type => 'general'   ).order('title ASC') }
  scope :responsive,  -> { where(:media_type => 'responsive').order('title ASC') }
  scope :banner,      -> { where(:media_type => 'banner'    ).order('title ASC') }
end
