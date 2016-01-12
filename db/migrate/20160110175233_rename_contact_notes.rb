class RenameContactNotes < ActiveRecord::Migration
  def change
    rename_column :organizations, :notes, :contact_notes
    rename_column :people, :notes, :contact_notes
  end
end
