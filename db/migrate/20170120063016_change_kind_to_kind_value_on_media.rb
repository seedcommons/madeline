class ChangeKindToKindValueOnMedia < ActiveRecord::Migration
  def change
    rename_column :media, :kind, :kind_value
  end
end
