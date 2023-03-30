class RemoveCustomDataFromResponseSets < ActiveRecord::Migration[6.1]
  def up
    remove_column :response_sets, :custom_data
  end

  def down
    add_column :response_sets, :custom_data, :jsonb
  end
end
