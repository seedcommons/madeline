class Division < ActiveRecord::Base
  has_closure_tree
  alias_attribute :super_division, :parent

  belongs_to :organization
  # For now the id of a special system root node.
  # Currently convient as an owning divison of migrated orgs and people, but may not be needed in the long run.
  # Will revisit once full requirements are more clear.
  def self.root_id
    99
  end



end
