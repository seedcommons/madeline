class AddIndexToValueOnOptions < ActiveRecord::Migration[4.2]
  def change
    add_index :options, :value
  end
end
