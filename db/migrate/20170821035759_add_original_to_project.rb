class AddOriginalToProject < ActiveRecord::Migration
  def change
    add_column :projects, :original_id, :integer, polymorphic: true, foreign_key: { references: :projects}
    # add_reference :projects, :original
    # add_foreign_key :projects, :original, column: :original_id
    # add_index :projects, [:id, :original_id]
  end
end
