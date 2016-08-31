class AddAccentColorsToDivision < ActiveRecord::Migration
  def change
    add_column :divisions, :accent_main_color, :string
    add_column :divisions, :accent_fg_color, :string
  end
end
