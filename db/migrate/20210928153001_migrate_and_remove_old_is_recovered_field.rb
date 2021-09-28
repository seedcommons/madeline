class MigrateAndRemoveOldIsRecoveredField < ActiveRecord::Migration[6.1]
  def up
    execute("UPDATE organizations SET inception_value = 'recovered' WHERE is_recovered = 't'")
    remove_column(:organizations, :is_recovered)
  end

  def down
    add_column(:organizations, :is_recovered, :boolean)
  end
end
