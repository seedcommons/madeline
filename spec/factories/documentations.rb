# == Schema Information
#
# Table name: documentations
#
#  calling_action     :string
#  calling_controller :string
#  created_at         :datetime         not null
#  html_identifier    :string
#  id                 :integer          not null, primary key
#  updated_at         :datetime         not null
#

FactoryBot.define do
  factory :documentation do
    html_identifier { Faker::Lorem.word }
    calling_controller { Faker::Lorem.word }
    calling_action { Faker::Lorem.word }

    trait :with_translations do
      summary_content { Faker::Hipster.sentence }
      page_content { Faker::Hipster.paragraph }
    end

    trait :with_foreign_translations do
      summary_content_es { Faker::Lorem.sentence }
      page_content_es { Faker::Lorem.paragraph(2) }
    end
  end
end
