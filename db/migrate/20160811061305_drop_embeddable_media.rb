class DropEmbeddableMedia < ActiveRecord::Migration
  def change
    drop_table :embeddable_media
  end
end
