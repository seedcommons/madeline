class AddIndexToValueOnOptions < ActiveRecord::Migration
  def change
    add_index :options, :value
  end
end
