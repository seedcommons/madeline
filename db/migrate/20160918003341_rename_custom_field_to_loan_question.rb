class RenameCustomFieldToLoanQuestion < ActiveRecord::Migration
  def change
    rename_table :custom_fields, :loan_questions
    rename_table :custom_field_sets, :loan_question_sets
    rename_table :custom_field_requirements, :loan_question_requirements
  end
end
