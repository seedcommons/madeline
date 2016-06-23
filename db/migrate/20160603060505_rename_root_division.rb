class RenameRootDivision < ActiveRecord::Migration
  def change
    execute("UPDATE divisions SET name = '-' WHERE name = 'None'")
  end
end
