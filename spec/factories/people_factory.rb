# == Schema Information
#
# Table name: people
#
#  birth_date              :date
#  city                    :string
#  contact_notes           :text
#  country_id              :integer
#  created_at              :datetime         not null
#  division_id             :integer
#  email                   :string
#  fax                     :string
#  first_name              :string
#  has_system_access       :boolean          default(FALSE), not null
#  id                      :integer          not null, primary key
#  last_name               :string
#  legal_name              :string
#  name                    :string
#  neighborhood            :string
#  postal_code             :string
#  primary_organization_id :integer
#  primary_phone           :string
#  secondary_phone         :string
#  state                   :string
#  street_address          :text
#  tax_no                  :string
#  updated_at              :datetime         not null
#  website                 :string
#
# Indexes
#
#  index_people_on_division_id  (division_id)
#
# Foreign Keys
#
#  fk_rails_...  (country_id => countries.id)
#  fk_rails_...  (division_id => divisions.id)
#  fk_rails_...  (primary_organization_id => organizations.id)
#

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
    has_system_access true
    access_role :member
  end

  trait :with_admin_access do
    has_system_access true
    access_role :admin
    with_password
  end

  trait :with_password do
    password 'xxxxxxxx'
    password_confirmation 'xxxxxxxx'
  end

end
