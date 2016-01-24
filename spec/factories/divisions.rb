# == Schema Information
#
# Table name: divisions
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  name            :string
#  description     :text
#  parent_id       :integer
#  currency_id     :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  internal_name   :string
#
# Indexes
#
#  index_divisions_on_currency_id      (currency_id)
#  index_divisions_on_organization_id  (organization_id)
#

def root_division
  # fetched = Division.roots
  # # puts("unexpectedly non-unique root Division - count: #{fetched.size}")  if fetched.size > 1
  # result = fetched.first
  result = Division.root
  unless result
    # puts "autocreating root Division"
    result = Division.create(name:'Root Division')
  end
  result
end


FactoryGirl.define do
  factory :division do
    description { Faker::Lorem.sentence }
    name { Faker::Company.name }
    # organization - intentionally left nil # (would cause an infinite loop)
    # parent - intentionally left nil
  end
end
