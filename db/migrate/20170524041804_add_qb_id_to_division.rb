class AddQbIdToDivision < ActiveRecord::Migration
  def change
    add_column :divisions, :qb_id, :string
  end
end
