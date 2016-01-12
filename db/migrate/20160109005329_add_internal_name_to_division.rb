class AddInternalNameToDivision < ActiveRecord::Migration
  def change
    add_column :divisions, :internal_name, :string, index: true
  end
end
