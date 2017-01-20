class ChangeMediaKindFilesToDocuments < ActiveRecord::Migration
  def up
    execute "UPDATE media SET kind = 'document' WHERE kind = 'file'"
  end

  def down
    execute "UPDATE media SET kind = 'file' WHERE kind = 'document'"
  end
end
