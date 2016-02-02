# == Schema Information
#
# Table name: countries
#
#  id                  :integer          not null, primary key
#  iso_code            :string(2)
#  default_currency_id :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  name                :string
#  default_language_id :integer
#  language_id         :integer
#
# Indexes
#
#  index_countries_on_language_id  (language_id)
#

FactoryGirl.define do
  factory :country do
    iso_code { Faker::Address.country_code }
    name { Faker::Address.country }
    association :default_language, factory: :language
    association :default_currency, factory: :currency
  end
end
