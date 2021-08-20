class AddHomepageToDivisions < ActiveRecord::Migration[6.1]
  def change
    add_column :divisions, :homepage, :text
  end
end
