class AddOwnerToEmbeddableMedia < ActiveRecord::Migration
  def change
    add_reference :embeddable_media, :owner, polymorphic: true, index: true
    add_column :embeddable_media, :owner_attribute, :string
  end
end
