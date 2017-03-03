# == Schema Information
#
# Table name: translations
#
#  created_at             :datetime
#  id                     :integer          not null, primary key
#  locale                 :string
#  text                   :text
#  translatable_attribute :string
#  translatable_id        :integer
#  translatable_type      :string
#  updated_at             :datetime
#
# Indexes
#
#  index_translations_on_translatable_type_and_translatable_id  (translatable_type,translatable_id)
#

FactoryGirl.define do
  factory :translation do
    association :translatable, factory: :loan
    translatable_attribute :summary
    text { Faker::Hipster.paragraph(sentence_count = 2) }
    locale { I18n.default_locale }
    transient_division
  end
end
