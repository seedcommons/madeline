class MakeHtmlIdentifierUnique < ActiveRecord::Migration[5.1]
  def change
    add_index :documentations, :html_identifier, unique: true
  end
end
