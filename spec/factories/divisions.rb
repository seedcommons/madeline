# == Schema Information
#
# Table name: divisions
#
#  id              :integer          not null, primary key
#  created_at      :datetime         not null
#  currency_id     :integer
#  description     :text
#  name            :string
#  organization_id :integer
#  parent_id       :integer
#  updated_at      :datetime         not null
#  internal_name   :string
#
# Indexes
#
#  index_divisions_on_currency_id      (currency_id)
#  index_divisions_on_organization_id  (organization_id)
#

FactoryGirl.define do
  factory :division do
    description { Faker::Lorem.sentence }
    name { Faker::Company.name }
##    organization  ## this was causing an infinite loop
  end
end
