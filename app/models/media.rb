class Media < ActiveRecord::Base
  include Translatable
  belongs_to :media_attachable, polymorphic: true

  mount_uploader :item, MediaItemUploader
  attr_translatable :caption, :description

  scope :media_type, ->(media_type) { where(kind: media_type) }
  scope :images_only, -> { media_type('image') }

  def alt
    self.try(:caption) || self.media_attachable.try(:name)
  end
end
