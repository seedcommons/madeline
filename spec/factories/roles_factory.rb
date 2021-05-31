FactoryBot.define do
  factory :role do
    name { 'member' }
    association :resource, factory: :division
  end
end
