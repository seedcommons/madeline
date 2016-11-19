# == Schema Information
#
# Table name: people
#
#  id                      :integer          not null, primary key
#  name                    :string
#  primary_organization_id :integer
#  birth_date              :date
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  division_id             :integer
#  legal_name              :string
#  primary_phone           :string
#  secondary_phone         :string
#  fax                     :string
#  email                   :string
#  street_address          :text
#  city                    :string
#  neighborhood            :string
#  state                   :string
#  country_id              :integer
#  tax_no                  :string
#  website                 :string
#  contact_notes           :text
#  first_name              :string
#  last_name               :string
#
# Indexes
#
#  index_people_on_division_id  (division_id)
#

FactoryGirl.define do
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
    has_system_access true
    owning_division_role :member
  end

  trait :with_admin_access do
    has_system_access true
    owning_division_role :admin
    with_password
  end

  trait :with_password do
    password 'xxxxxxxx'
    password_confirmation 'xxxxxxxx'
  end

end
