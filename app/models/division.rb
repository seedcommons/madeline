class Division < ActiveRecord::Base
  has_closure_tree
  alias_attribute :super_division, :parent


  #JE: I like to keep a reference for the implicit db attributes here in the model class
  # create_table :divisions do |t|
  #   t.references :organization, index: true, foreign_key: true
  #   t.string :name
  #   t.text :description
  #   t.integer :parent_id
  #   t.references :currency, index: true, foreign_key: true
  #   t.timestamps null: false
  # end

  has_many :loans   #, dependent: :destroy  - should probably require owned models to be explicitly deleted
  has_many :people
  has_many :organizations


  belongs_to :parent, class_name: 'Division'
  belongs_to :default_currency, class_name: 'Currency'
  belongs_to :organization  # the organization which represents this loan agent division

  validates :name, presence: true



  # For now the id of a special system root node.
  # Currently convient as an owning divison of migrated orgs and people, but may not be needed in the long run.
  # Will revisit once full requirements are more clear.
  def self.root_id
    99
  end


  def root?
    id == Division.root_id
  end

  def accessible_organizations
    # for now hack access to current or root division owned entities
    if root?
      Organization.all
    else
      Organization.where(division_id: [id, Division.root_id]).order(:name)
    end
  end

  def accessible_people
    # for now hack access to current or root division owned entities
    if root?
      Person.all
    else
      Person.where(division_id: [id, Division.root_id]).order(:last_name)
    end
  end

  def accessible_loans
    if root?
      Loan.all
    else
      Loan.where(division_id: [id, Division.root_id]).order(signing_date: :desc)
    end
  end

  def loans_count
    loans.size
  end

end
