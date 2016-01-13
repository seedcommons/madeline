# == Schema Information
#
# Table name: media
#
#  id                    :integer          not null, primary key
#  media_attachable_id   :integer
#  media_attachable_type :string
#  sort_order            :integer
#  kind                  :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  item                  :string
#  item_file_size        :integer
#  item_content_type     :string
#  item_height           :integer
#  item_width            :integer
#
# Indexes
#
#  index_media_on_media_attachable_type_and_media_attachable_id  (media_attachable_type,media_attachable_id)
#

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

  def filename
    item.file.filename
  end
end
