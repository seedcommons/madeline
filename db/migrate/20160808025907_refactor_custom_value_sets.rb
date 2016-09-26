class RefactorCustomValueSets < ActiveRecord::Migration
  def up
    execute("DELETE FROM custom_value_sets WHERE linkable_attribute IN ('old_criteria', 'criteria')")
    execute("UPDATE custom_value_sets SET linkable_attribute = 'criteria'
      WHERE linkable_attribute = 'loan_criteria'")
    execute("UPDATE custom_value_sets SET linkable_attribute = 'post_analysis'
      WHERE linkable_attribute = 'loan_post_analysis'")
    remove_column :custom_value_sets, :custom_field_set_id
    remove_column :custom_value_sets, :custom_value_set_linkable_type
    rename_column :custom_value_sets, :custom_value_set_linkable_id, :loan_id
    rename_column :custom_value_sets, :linkable_attribute, :kind
    rename_table :custom_value_sets, :loan_response_sets
  end
end
