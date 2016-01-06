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
#  notes                   :text
#  first_name              :string
#  last_name               :string
#
# Indexes
#
#  index_people_on_division_id  (division_id)
#

class Person < ActiveRecord::Base
  include Contactable  # this is a placeholder concern for the shared aspects between Organization and People.
  include Notable
 
  belongs_to :division
  belongs_to :country
  belongs_to :primary_organization, class_name: 'Organization'

  has_many :primary_agent_loans,   class_name: 'Loan', foreign_key: :primary_agent_id
  has_many :secondary_agent_loans, class_name: 'Loan', foreign_key: :secondary_agent_id
  has_many :representative_loans,  class_name: 'Loan', foreign_key: :representative_id


  validates :division_id, presence: true
  validates :first_name, presence: true


  #JE todo: this is a placeholder until we implement an automatic update or decide on different handling around the full name
  def name
    "#{first_name} #{last_name}"
  end



end
