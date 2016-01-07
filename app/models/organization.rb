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

class Organization < ActiveRecord::Base
  include Contactable  # this is a placeholder concern for the shared aspects between Organization and People.
  #  include ::Notable  ##JE todo: for next integration pass


  belongs_to :division
  belongs_to :country
  belongs_to :primary_contact, class_name: 'Person'
  belongs_to :organization_snapshot # the latest data

  has_many :loans
  has_many :people, foreign_key: :primary_organization_id
  has_many :organization_snapshots  # all historical data

  validates :name, presence: true
  validates :division_id, presence: true



  def loans_count
    loans.size
  end

  def active_loans
    loans.where({status_option_id: Loan.status_active_id})
  end

  def recent_snapshots
    organization_snapshots.where("date is not null").order({date: :desc}).limit(5)
  end

end
