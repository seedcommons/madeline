class Division < ActiveRecord::Base
  has_closure_tree
  alias_attribute :super_division, :parent

  belongs_to :organization

  #JE: I like to keep a reference for the implicit db attributes here in the model class
  # create_table :divisions do |t|
  #   t.references :organization, index: true, foreign_key: true
  #   t.string :name
  #   t.text :description
  #   t.integer :parent_id
  #   t.references :currency, index: true, foreign_key: true
  #   t.timestamps null: false
  # end


  # For now the id of a special system root node.
  # Currently convient as an owning divison of migrated orgs and people, but may not be needed in the long run.
  # Will revisit once full requirements are more clear.
  ROOT_ID = 99


end
