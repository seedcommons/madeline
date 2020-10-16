# == Schema Information
#
# Table name: media
#
#  created_at            :datetime         not null
#  featured              :boolean          default(FALSE), not null
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
#  fk_rails_...  (uploader_id => people.id)
#

require 'open-uri'

FactoryBot.define do
  factory :media do
    item { File.open(Rails.root.join('spec', 'support', 'assets', 'images', file_name)) }
    kind_value { "image" }
    caption { Faker::Hipster.paragraph(2) }
    media_attachable_type { %w(Organization Person).sample }
    transient_division
    featured { false }

    trait :contract do
      kind_value { :contract }
    end

    transient do
      file_name { 'the_swing.jpg' }
    end
  end
end
