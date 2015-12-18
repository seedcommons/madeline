FactoryGirl.define do
  factory :country do
    with_language_association
    name { Faker::Address.country }

    after(:create) do |country|
      create(:currency, country: country.name)
    end
  end
end
