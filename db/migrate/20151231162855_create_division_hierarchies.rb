class CreateDivisionHierarchies < ActiveRecord::Migration
  def change
    create_table :division_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :division_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name: "division_anc_desc_idx"

    add_index :division_hierarchies, [:descendant_id],
      name: "division_desc_idx"
  end
end
