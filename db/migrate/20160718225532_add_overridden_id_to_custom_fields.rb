class AddOverriddenIdToCustomFields < ActiveRecord::Migration
  def change
    add_reference :custom_fields, :overridden, references: :custom_fields
  end
end
