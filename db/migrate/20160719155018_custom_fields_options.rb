class CustomFieldsOptions < ActiveRecord::Migration
  def change
    create_table :custom_fields_options, :id => false do |t|
      t.integer :custom_field_id
      t.integer :option_id
    end
  end
end
