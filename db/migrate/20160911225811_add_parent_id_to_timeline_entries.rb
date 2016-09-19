class AddParentIdToTimelineEntries < ActiveRecord::Migration
  def change
    add_column :timeline_entries, :parent_id, :integer, index: true

    add_foreign_key :timeline_entries, :timeline_entries, column: :parent_id
  end
end
