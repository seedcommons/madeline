class AddFieldsToCustomFields < ActiveRecord::Migration
  def change
    # Looks like 'required' was added to the production DB since the rails project began.
    add_column :custom_fields, :required, :boolean, default: false, null: false
    # closure_tree seems to be munging the primary position values, and we need to accommodate some
    # convoluted logic around interpreting the migrated position value to match the legacy
    # system's question ordering and filtering behavior.
    add_column :custom_fields, :migration_position, :integer
    # 'label' was never used as a direct field.  It's a translatable value.
    remove_column :custom_fields, :label, :string
  end
end
