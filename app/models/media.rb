# == Schema Information
#
# Table name: media
#
#  created_at            :datetime         not null
#  id                    :integer          not null, primary key
#  item                  :string
#  item_content_type     :string
#  item_file_size        :integer
#  item_height           :integer
#  item_width            :integer
#  kind                  :string
#  media_attachable_id   :integer
#  media_attachable_type :string
#  sort_order            :integer
#  updated_at            :datetime         not null
#  uploader_id           :integer
#
# Indexes
#
#  index_media_on_media_attachable_type_and_media_attachable_id  (media_attachable_type,media_attachable_id)
#
# Foreign Keys
#
#  fk_rails_d64ff8d67d  (uploader_id => people.id)
#

class Media < ActiveRecord::Base
  include Translatable

  belongs_to :media_attachable, polymorphic: true
  belongs_to :uploader, class_name: 'Person'

  mount_uploader :item, MediaItemUploader
  validates :item, :kind, presence: true
  attr_translatable :caption, :description

  delegate :division, :division=, to: :media_attachable

  scope :images_only, -> { where(kind: 'image') }

  def alt
    self.try(:caption) || self.media_attachable.try(:name)
  end

  def thumbnail?
    kind == 'image'
  end
end
