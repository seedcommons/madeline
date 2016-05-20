class DeleteEmptyMediaObjects < ActiveRecord::Migration
  def up
    execute("DELETE FROM media WHERE item IS NULL")
  end
end
