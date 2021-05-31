FactoryBot.define do
  factory :person do
    division { root_division }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    primary_organization { root_division.organization }
    birth_date { Faker::Date.between(100.years.ago, 18.years.ago) }
  end

  trait :with_note do
    after(:create) do |person|
      create(:note, author: person)
    end
  end

  trait :with_member_access do
    has_system_access { true }
    access_role { :member }
  end

  trait :with_admin_access do
    has_system_access { true }
    access_role { :admin }
    with_password
  end

  trait :with_password do
    password { 'xxxxxxxx' }
    password_confirmation { 'xxxxxxxx' }
  end

end
