class RenameQuestionSetsInternalNameToKind < ActiveRecord::Migration[6.1]
  def change
    rename_column :question_sets, :internal_name, :kind
  end
end
