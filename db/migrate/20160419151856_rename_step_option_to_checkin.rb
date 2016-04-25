class RenameStepOptionToCheckin < ActiveRecord::Migration
  def up
    execute("UPDATE options SET value = 'checkin' WHERE value = 'step'")
    execute("UPDATE translations SET text = 'Check-in' WHERE text = 'Step'")
  end
end
