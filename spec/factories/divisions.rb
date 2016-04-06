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
    parent { root_division }
    # organization - intentionally left nil # (would cause an infinite loop)
  end
end

# Defines a global trait for models that delegate their divisions
# allowing us to assign them directly
FactoryGirl.define do
  trait :transient_division do
    transient do
      division { create(:division) }
    end

    after(:create) do |instance, evaluator|
      instance.division = evaluator.division if evaluator.division.present?
    end
  end
end
