class AddUploaderToMedia < ActiveRecord::Migration
  def change
    add_reference :media, :uploader, references: :people
  end
end
