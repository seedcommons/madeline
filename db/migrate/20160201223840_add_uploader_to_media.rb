class AddUploaderToMedia < ActiveRecord::Migration
  def change
    add_reference :media, :uploader, references: :people
    add_foreign_key :media, :people, column: :uploader_id
  end
end
