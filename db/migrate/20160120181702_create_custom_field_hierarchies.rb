class CreateCustomFieldHierarchies < ActiveRecord::Migration
  def change
    create_table :custom_field_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :custom_field_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name: "custom_field_anc_desc_idx"

    add_index :custom_field_hierarchies, [:descendant_id],
      name: "custom_field_desc_idx"
  end
end
