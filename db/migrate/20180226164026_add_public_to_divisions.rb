class AddPublicToDivisions < ActiveRecord::Migration[5.1]
  def change
    add_column :divisions, :public, :boolean, default: true, null: false
  end
end
