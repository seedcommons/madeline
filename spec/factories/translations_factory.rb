FactoryBot.define do
  factory :translation do
    association :translatable, factory: :loan
    translatable_attribute { :summary }
    text { Faker::Hipster.paragraph(sentence_count = 2) }
    locale { I18n.default_locale }
    transient_division
  end
end
