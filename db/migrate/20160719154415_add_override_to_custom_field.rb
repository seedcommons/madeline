class AddOverrideToCustomField < ActiveRecord::Migration
  def change
    # Full conceptual meaning of this flag:
    # "This question specifies its own set of required loan types rather than inheriting from its
    # parent question"
    add_column :loan_questions, :override_associations, :boolean, default: false, null: false
  end
end
