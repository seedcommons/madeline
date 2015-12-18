FactoryGirl.define do
  factory :division do
    description { Faker::Lorem.sentence }
    name { Faker::Company.name }
    external_name { name }

    after(:create) do |division|
      division.super_division ||= division.id
      division.save
    end

    factory :division_with_country do
      before(:create) do |division|
        country_name = Faker::Address.country
        division.country = (Country.where(name: country_name).first.try(:name) || create(:country, name: country_name).name)
      end
    end
  end
end
