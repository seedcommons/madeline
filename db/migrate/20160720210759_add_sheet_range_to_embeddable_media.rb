class AddSheetRangeToEmbeddableMedia < ActiveRecord::Migration
  def change
    add_column :embeddable_media, :document_key, :string
    add_column :embeddable_media, :sheet_number, :string
    add_column :embeddable_media, :start_cell, :string
    add_column :embeddable_media, :end_cell, :string
  end
end
