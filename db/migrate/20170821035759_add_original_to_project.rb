class AddOriginalToProject < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :original_id, :integer, foreign_key: { references: :projects }
  end
end
