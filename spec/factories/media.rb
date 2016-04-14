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

FactoryGirl.define do
  factory :media do
    item { File.open(Rails.root.join('spec', 'support', 'assets', 'images', 'the swing.jpg')) }
    transient_division
  end
end
