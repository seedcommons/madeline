class RemoveInternalNameFromQuestions < ActiveRecord::Migration[6.1]
  def up
    remove_column :questions, :internal_name
  end

  def down
    add_column :questions, :internal_name, :string
  end
end
