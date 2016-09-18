class CreateCustomFieldRequirements < ActiveRecord::Migration
  def change
    create_table :loan_question_requirements do |t|
      t.integer :loan_question_id
      t.integer :option_id
    end
  end
end
