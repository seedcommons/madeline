# == Schema Information
#
# Table name: currencies
#
#  code         :string
#  country_code :string
#  created_at   :datetime         not null
#  id           :integer          not null, primary key
#  name         :string
#  short_symbol :string
#  symbol       :string
#  updated_at   :datetime         not null
#

FactoryBot.define do
  factory :currency do
    code "USD"
    symbol "US$"
    short_symbol "$"
    country_code "US"
  end
end
