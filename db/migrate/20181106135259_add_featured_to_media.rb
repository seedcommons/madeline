class AddFeaturedToMedia < ActiveRecord::Migration[5.2]
  def change
    add_column :media, :featured, :boolean, default: false, null: false
  end
end
