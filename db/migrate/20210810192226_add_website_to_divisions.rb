class AddWebsiteToDivisions < ActiveRecord::Migration[6.1]
  def change
    add_column :divisions, :website, :text
  end
end
