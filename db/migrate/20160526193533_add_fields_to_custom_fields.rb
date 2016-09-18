class AddFieldsToCustomFields < ActiveRecord::Migration
  def change
    # Looks like 'required' was added to the production DB since the rails project began.
    add_column :loan_questions, :required, :boolean, default: false, null: false

    # Migrated from LoanQuestions.IFrame
    # Indicates that a google spreadsheet may be attached to this question.
    # Note, this is orthogonal from the data_type of the question.
    add_column :loan_questions, :has_embeddable_media, :boolean, default: false, null: false

    # Closure_tree seems to be munging the primary position values, and the raw 'orden' value is
    # useful to be able to reference post migration since there is some convoluted
    # logic around interpreting the migrated position value to match the legacy
    # system's question ordering and filtering behavior.
    add_column :loan_questions, :migration_position, :integer

    # 'label' was never used as a direct field.  It's a translatable value pulled from the
    # translations table..
    remove_column :loan_questions, :label, :string
  end
end
