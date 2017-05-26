class SetDefaultLockVersion < ActiveRecord::Migration
  def change
    change_column :loan_response_sets, :lock_version, :integer, default: 0, null: false
  end
end
