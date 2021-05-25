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

    trait :random_image do
      item { open(Faker::Avatar.image) }
    end

    transient do
      file_name { 'the_swing.jpg' }
    end
  end
end
