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
#  kind_value            :string
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

require 'open-uri'

FactoryGirl.define do
  factory :media do
    item { File.open(Rails.root.join('spec', 'support', 'assets', 'images', 'the swing.jpg')) }
    kind_value "image"
    caption { Faker::Hipster.paragraph(2) }
    transient_division

    trait :contract do
      kind_value :contract
    end
  end
end
