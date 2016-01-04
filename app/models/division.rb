class Division < ActiveRecord::Base
  has_closure_tree
  alias_attribute :super_division, :parent

  belongs_to :organization
end
