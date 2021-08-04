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
