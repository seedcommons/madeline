class AddDisplayInSummaryToQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :display_in_summary, :boolean, null: false, default: false
  end
end
