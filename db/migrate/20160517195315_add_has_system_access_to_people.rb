class AddHasSystemAccessToPeople < ActiveRecord::Migration
  def change
    add_column :people, :has_system_access, :boolean, default: false, null: false
  end
end
