class Person < ActiveRecord::Base
  include Contactable  # this is a placeholder concern for the shared aspects between Organization and People.
#  include ::Notable  ##JE todo: for next integration pass

  # create_table :people do |t|
  #   ## base Contact fields
  #   t.references :division, index: true
  #   t.string :name   # note agreeing with mel's change of this from 'display_name' as a more consistent field to hold the full name
  #   t.string :legal_name
  #   t.string :primary_phone
  #   t.string :secondary_phone
  #   t.string :fax
  #   t.string :email
  #   t.text :street_address
  #   t.string :city
  #   t.string :neighborhood
  #   t.string :state
  #   t.references :country
  #   t.string :tax_no
  #   t.string :website
  #   t.text :notes
  #   #t.date :birth_date  # todo: birth_date not used in current system.  confirm if really still desired
  #   t.timestamps null: false
  #   ## distinct Person fields
  #   t.string :first_name
  #   t.string :last_name
  #   t.references :primary_organization, references: :organizations, index: true


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
