class AddShortNameToDivision < ActiveRecord::Migration[5.1]
  def change
    add_column :divisions, :short_name, :string
    add_index :divisions, :short_name, unique: true
  end
end
