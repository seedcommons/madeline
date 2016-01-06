FactoryGirl.define do
  factory :note do
    notable { create(:person) }
    person
# need to make sure parent saved before assigning this
    # text { Faker::Lorem.sentence }
  end
end
