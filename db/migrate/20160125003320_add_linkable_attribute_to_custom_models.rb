class AddLinkableAttributeToCustomModels < ActiveRecord::Migration
  def change
    add_column :custom_models, :linkable_attribute, :string
  end
end
