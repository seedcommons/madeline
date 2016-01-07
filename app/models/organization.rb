class Organization < ActiveRecord::Base
  include Contactable  # this is a placeholder concern for the shared aspects between Organization and People.
#  include ::Notable  ##JE todo: for next integration pass

  # create_table :organizations do |t|
  #   ## base Contact fields
  #   t.references :division, index: true
  #   t.string :name  # note, also renamed from display_name
  #   t.string :legal_name
  #   t.string :primary_phone
  #   t.string :secondary_phone
  #   t.string :fax
  #   t.string :email
  #   t.text :street_address  # note, this existing data has some verbose directions stored in this field
  #   t.string :city
  #   t.string :neighborhood
  #   t.string :state
  #   t.references :country
  #   t.string :tax_no
  #   t.string :website
  #   t.text :notes
  #   t.timestamps
  #   ## distinct Organization fields
  #   t.string :alias
  #   t.references :primary_contact, references: :people
  #   t.string :sector
  #   t.string :industry
  #   t.string :referral_source
  #   t.references :organization_snapshot


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
