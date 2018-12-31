class AddQbParentClassNameToDivision < ActiveRecord::Migration[5.2]
  def change
    add_column :divisions, :qb_parent_class_name, :string
  end
end
