class AddParentIdToTimelineEntries < ActiveRecord::Migration
  def change
    add_column :timeline_entries, :parent_id, :integer
  end
end
