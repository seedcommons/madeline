class CreateDocumentations < ActiveRecord::Migration[5.1]
  def change
    create_table :documentations do |t|
      t.string :html_identifier
      t.string :calling_controller
      t.string :calling_action

      t.timestamps
    end
  end
end
