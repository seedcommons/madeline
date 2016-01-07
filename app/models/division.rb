# == Schema Information
#
# Table name: divisions
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  name            :string
#  description     :text
#  parent_id       :integer
#  currency_id     :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_divisions_on_currency_id      (currency_id)
#  index_divisions_on_organization_id  (organization_id)
#

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
