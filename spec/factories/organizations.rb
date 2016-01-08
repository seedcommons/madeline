# == Schema Information
#
# Table name: organizations
#
#  id                       :integer          not null, primary key
#  sector                   :string
#  industry                 :string
#  referral_source          :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  division_id              :integer
#  name                     :string
#  legal_name               :string
#  primary_phone            :string
#  secondary_phone          :string
#  fax                      :string
#  email                    :string
#  street_address           :text
#  city                     :string
#  neighborhood             :string
#  state                    :string
#  country_id               :integer
#  tax_no                   :string
#  website                  :string
#  notes                    :text
#  alias                    :string
#  last_name                :string
#  organization_snapshot_id :integer
#  primary_contact_id       :integer
#
# Indexes
#
#  index_organizations_on_division_id  (division_id)
#

FactoryGirl.define do
  factory :organization do
    division
    country
    name { Faker::Company.name }
    sector { Faker::Company.profession }
    industry { Faker::Company.profession }
  end
end
