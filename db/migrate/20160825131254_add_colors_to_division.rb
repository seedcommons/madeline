class AddColorsToDivision < ActiveRecord::Migration
  def change
    add_column :divisions, :banner_fg_color, :string
    add_column :divisions, :banner_bg_color, :string
  end
end
