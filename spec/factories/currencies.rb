# == Schema Information
#
# Table name: currencies
#
#  id           :integer          not null, primary key
#  code         :string
#  symbol       :string
#  short_symbol :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  name         :string
#

FactoryGirl.define do
  factory :currency do
    code "USD"
    symbol "US$"
    short_symbol "$"
  end
end
