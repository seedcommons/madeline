class FixLegacyStepDateChangeCount < ActiveRecord::Migration
  def up
    ProjectStep.where("original_date is not null and date_change_count = 0").update_all("date_change_count = 1")
  end
end
