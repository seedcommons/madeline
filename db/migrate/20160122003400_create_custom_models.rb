class CreateCustomModels < ActiveRecord::Migration
  def change
    create_table :custom_models do |t|
      # note, the default polymorphic index name was too long
      t.references :custom_model_linkable, polymorphic: true, null: false, index: { name: 'custom_models_on_linkable' }
      t.references :custom_field_set, index: true, null: false, foreign_key: true
      t.json :custom_data

      t.timestamps null: false
    end
  end
end
