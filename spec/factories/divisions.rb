FactoryGirl.define do
  factory :division do
    description { Faker::Lorem.sentence }
    name { Faker::Company.name }
##    organization  ## this was causing an infinite loop
  end
end
