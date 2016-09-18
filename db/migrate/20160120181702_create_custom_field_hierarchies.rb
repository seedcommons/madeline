class CreateCustomFieldHierarchies < ActiveRecord::Migration
  def change
    create_table :loan_question_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :loan_question_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name: "loan_question_anc_desc_idx"

    add_index :loan_question_hierarchies, [:descendant_id],
      name: "loan_question_desc_idx"
  end
end
