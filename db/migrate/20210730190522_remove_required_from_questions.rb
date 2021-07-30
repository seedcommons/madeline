class RemoveRequiredFromQuestions < ActiveRecord::Migration[6.1]
  def change
    remove_column :questions, :required, :boolean
  end
end
