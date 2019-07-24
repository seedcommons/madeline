class AddAttachmentToDataExports < ActiveRecord::Migration[5.2]
  def change
    add_column :data_exports, :attachment, :string
  end
end
