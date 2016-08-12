class AddActiveToCustomField < ActiveRecord::Migration
  def change
    add_column :custom_fields, :is_active, :boolean, default: true, null: false
  end
end
