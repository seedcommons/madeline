class AddLegacyIdToResponseSetsAndQuestions < ActiveRecord::Migration[6.1]
  def change
    add_column :response_sets, :legacy_id, :integer
    add_column :questions, :legacy_id, :integer
  end
end
