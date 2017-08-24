class AddOriginalToProject < ActiveRecord::Migration
  def change
    add_column :projects, :original_id, :integer, foreign_key: { references: :projects }
  end
end
