class AddPublicColorFieldsToDivision < ActiveRecord::Migration[6.1]
  def change
    add_column :divisions, :public_primary_color, :string
    add_column :divisions, :public_secondary_color, :string
    add_column :divisions, :public_accent_color, :string
  end
end
