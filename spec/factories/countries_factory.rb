# == Schema Information
#
# Table name: countries
#
#  id                  :integer          not null, primary key
#  iso_code            :string(2)        not null
#  name                :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  default_currency_id :integer          not null
#
# Foreign Keys
#
#  fk_rails_...  (default_currency_id => currencies.id)
#

FactoryBot.define do
  factory :country do
    iso_code { Faker::Address.country_code }
    name { Faker::Address.country }
    default_currency { Currency.all.sample || create(:currency) }

    # compatibility with policy specs
    transient do
      division { nil }
    end
  end
end
