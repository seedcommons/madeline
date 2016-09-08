class AddLogoTextToDivisions < ActiveRecord::Migration
  def change
    add_column :divisions, :logo_text, :string
  end
end
