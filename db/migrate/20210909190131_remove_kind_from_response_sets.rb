class RemoveKindFromResponseSets < ActiveRecord::Migration[6.1]
  def change
    remove_column :response_sets, :kind, :string
  end
end
