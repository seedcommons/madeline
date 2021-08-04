FactoryBot.define do
  factory :documentation do
    calling_controller { Faker::Lorem.word }
    calling_action { %w(index show new create edit update destroy).sample }
    html_identifier { [calling_controller, calling_action, Faker::Lorem.word].map(&:parameterize).join("-") }
    division { root_division }

    trait :with_translations do
      summary_content { Faker::Hipster.sentence }
      page_content { Faker::Hipster.paragraph(2) }
    end

    trait :with_foreign_translations do
      summary_content_es { Faker::Lorem.sentence }
      page_content_es { Faker::Lorem.paragraph(2) }
    end
  end
end
