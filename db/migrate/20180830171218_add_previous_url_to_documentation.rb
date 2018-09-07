class AddPreviousUrlToDocumentation < ActiveRecord::Migration[5.1]
  def change
    add_column :documentations, :previous_url, :string
  end
end
