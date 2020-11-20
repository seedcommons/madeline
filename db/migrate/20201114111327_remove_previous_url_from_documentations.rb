class RemovePreviousUrlFromDocumentations < ActiveRecord::Migration[5.2]
  def change
    remove_column :documentations, :previous_url, :string
  end
end
