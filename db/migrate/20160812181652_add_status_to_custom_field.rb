class AddStatusToCustomField < ActiveRecord::Migration
  def change
    add_column :custom_fields, :status, :string, default: 'active', null: false
  end
end
