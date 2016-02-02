# == Schema Information
#
# Table name: people
#
#  id                      :integer          not null, primary key
#  birth_date              :date
#  city                    :string
#  contact_notes           :text
#  country_id              :integer
#  created_at              :datetime         not null
#  division_id             :integer
#  email                   :string
#  fax                     :string
#  first_name              :string
#  last_name               :string
#  legal_name              :string
#  name                    :string
#  neighborhood            :string
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
#  fk_rails_20168ebb0e  (primary_organization_id => organizations.id)
#  fk_rails_7aab1f72a5  (division_id => divisions.id)
#  fk_rails_fdfb048ae6  (country_id => countries.id)
#

class Person < ActiveRecord::Base
  include Contactable  # this is a placeholder concern for the shared aspects between Organization and People.
  include Notable
  include MediaAttachable


  belongs_to :division
  belongs_to :country
  belongs_to :primary_organization, class_name: 'Organization'

  has_many :primary_agent_loans,   class_name: 'Loan', foreign_key: :primary_agent_id
  has_many :secondary_agent_loans, class_name: 'Loan', foreign_key: :secondary_agent_id
  has_many :representative_loans,  class_name: 'Loan', foreign_key: :representative_id

  has_one :user, foreign_key: :profile_id

  validates :division_id, presence: true
  validates :first_name, presence: true


  #JE todo: this is a placeholder until we implement an automatic update or decide on different handling around the full name
  def name
    "#{first_name} #{last_name}"
  end



end
