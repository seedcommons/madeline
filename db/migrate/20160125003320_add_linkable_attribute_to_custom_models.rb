class AddLinkableAttributeToCustomModels < ActiveRecord::Migration
  def change
    add_column :custom_value_sets, :linkable_attribute, :string
  end
end
