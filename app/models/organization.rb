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
