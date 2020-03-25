class AddQbReadOnlyToDivision < ActiveRecord::Migration[5.2]
  def change
    add_column :divisions, :qb_read_only, :boolean, null: false, default: true
  end
end
