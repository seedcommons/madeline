class RemoveProjectTypeFromTimelineEntries < ActiveRecord::Migration
  def change
    remove_column :timeline_entries, :project_type, :string

    # Need to add this because the previous index went away with the above.
    add_index :timeline_entries, :project_id

    # We can now add this where we couldn't before due to polymorphism.
    # Hopefully it doesn't fail! It shouldn't!
    add_foreign_key :timeline_entries, :projects
  end
end
