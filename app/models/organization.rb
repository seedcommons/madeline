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

class Organization < ApplicationRecord
  include Contactable  # this is a placeholder concern for the shared aspects between Organization and People.
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
  validate :us_required_fields

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

  def us_required_fields
    return if !country_is_us?
    return if postal_code.present? && state.present?
    if postal_code.blank?
      errors.add(:postal_code, :required_for_us)
    end
    if state.blank?
      errors.add(:state, :required_for_us)
    end
  end

  def country_is_us?
    us_id = Country.find_by(name: 'United States').try(:id)
    us_id.present? && country_id == us_id
  end
end
