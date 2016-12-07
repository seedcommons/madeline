class AddLocalesToDivision < ActiveRecord::Migration
  def change
    add_column :divisions, :locales, :json
  end
end
