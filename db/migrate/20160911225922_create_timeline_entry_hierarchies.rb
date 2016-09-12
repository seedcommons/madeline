class CreateTimelineEntryHierarchies < ActiveRecord::Migration
  def change
    create_table :timeline_entry_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :timeline_entry_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name: "timeline_entry_anc_desc_idx"

    add_index :timeline_entry_hierarchies, [:descendant_id],
      name: "timeline_entry_desc_idx"
  end
end
