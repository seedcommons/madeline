class RemoveQbIdFromDivisions < ActiveRecord::Migration[5.2]
  def up
    remove_column :divisions, :qb_id
  end

  def down
    add_column :divisions, :qb_id, :string
  end
end
