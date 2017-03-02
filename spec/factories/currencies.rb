# == Schema Information
#
# Table name: currencies
#
#  code         :string
#  created_at   :datetime         not null
#  id           :integer          not null, primary key
#  name         :string
#  short_symbol :string
#  symbol       :string
#  updated_at   :datetime         not null
#

FactoryGirl.define do
  factory :currency do
    code "USD"
    symbol "US$"
    short_symbol "$"
  end
end
