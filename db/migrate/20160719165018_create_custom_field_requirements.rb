class CreateCustomFieldRequirements < ActiveRecord::Migration
  def change
    create_table :custom_field_requirements do |t|
      t.integer :custom_field_id
      t.integer :option_id
    end
  end
end
