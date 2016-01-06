class AddItemToMedia < ActiveRecord::Migration
  def change
    add_column :media, :item, :string
    add_column :media, :item_file_size, :integer
    add_column :media, :item_content_type, :string
    add_column :media, :item_height, :integer
    add_column :media, :item_width, :integer
  end
end
