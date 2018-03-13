# == Schema Information
#
# Table name: organizations
#
#  alias              :string
#  city               :string
#  contact_notes      :text
#  country_id         :integer
#  created_at         :datetime         not null
#  custom_data        :json
#  division_id        :integer
#  email              :string
#  fax                :string
#  id                 :integer          not null, primary key
#  industry           :string
#  is_recovered       :boolean
#  last_name          :string
#  legal_name         :string
#  name               :string
#  neighborhood       :string
#  postal_code        :string
#  primary_contact_id :integer
#  primary_phone      :string
#  qb_id              :string
#  referral_source    :string
#  secondary_phone    :string
#  sector             :string
#  state              :string
#  street_address     :text
#  tax_no             :string
#  updated_at         :datetime         not null
#  website            :string
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
    city { Faker::Address.city }
    name { Faker::Company.name }
    sector { Faker::Company.profession }
    industry { Faker::Company.profession }
  end
end
