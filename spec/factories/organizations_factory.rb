# == Schema Information
#
# Table name: organizations
#
#  id                 :integer          not null, primary key
#  alias              :string
#  city               :string
#  contact_notes      :text
#  custom_data        :json
#  email              :string
#  fax                :string
#  industry           :string
#  is_recovered       :boolean
#  last_name          :string
#  legal_name         :string
#  name               :string
#  neighborhood       :string
#  postal_code        :string
#  primary_phone      :string
#  referral_source    :string
#  secondary_phone    :string
#  sector             :string
#  state              :string
#  street_address     :text
#  tax_no             :string
#  website            :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  country_id         :integer
#  division_id        :integer
#  primary_contact_id :integer
#
# Indexes
#
#  index_organizations_on_division_id  (division_id)
#
# Foreign Keys
#
#  fk_rails_...  (country_id => countries.id)
#  fk_rails_...  (division_id => divisions.id)
#  fk_rails_...  (primary_contact_id => people.id)
#

FactoryBot.define do
  factory :organization do
    division { root_division }
    country
    city { Faker::Address.city }
    name { Faker::Company.name }
    sector { Faker::Company.profession }
    industry { Faker::Company.profession }
    postal_code { Faker::Address.postcode }
    state { Faker::Address.state }
  end
end
