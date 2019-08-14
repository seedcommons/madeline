class AddErrorInfoFieldToTask < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :error_info, :string, limit: 64.kilobytes
  end
end
