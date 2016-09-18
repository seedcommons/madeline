class Translation < ActiveRecord::Base; end

class RenameCustomFieldToLoanQuestion < ActiveRecord::Migration
  def change
    rename_table :custom_fields, :loan_questions
    rename_table :custom_field_sets, :loan_question_sets
    rename_table :custom_field_requirements, :loan_question_requirements
    rename_table :custom_field_hierarchies, :loan_question_hierarchies

    rename_column :loan_questions, :custom_field_set_id, :loan_question_set_id
    rename_column :loan_question_requirements, :custom_field_id, :loan_question_id

    Translation.where(translatable_type: 'CustomField').update_all(translatable_type: 'LoanQuestion')
  end
end
