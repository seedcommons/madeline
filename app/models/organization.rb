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
#  country_id         :integer          not null
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

class Organization < ApplicationRecord
  include Contactable # this is a placeholder concern for the shared aspects between Organization and People.
  include Notable
  include MediaAttachable
  include DivisionBased

  belongs_to :division
  belongs_to :country
  belongs_to :primary_contact, class_name: 'Person'

  has_many :loans, dependent: :destroy
  has_many :people, foreign_key: :primary_organization_id, dependent: :nullify

  validates :name, :division, :country, presence: true

  validate :primary_contact_is_member
  with_options if: ->(org) { org&.country&.iso_code == "US" } do |us_org|
    us_org.validates :state, :postal_code, presence: true
  end

  def loans_count
    loans.size
  end

  def active_loans
    loans.where(status_value: Loan::STATUS_ACTIVE_VALUE)
  end

  private

  def primary_contact_is_member
    return if primary_contact.blank?
    return if person_ids.include?(primary_contact_id)

    errors.add(:primary_contact, :invalid)
  end
end
