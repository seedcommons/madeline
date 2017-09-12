class ProjectDuplicator
  attr_reader :orig, :copy, :step_map

  def initialize(orig)
    @orig = orig
    @step_map = {}
  end

  def duplicate
    @copy = orig.amoeba_dup
    copy.original = orig

    duplicate_timeline_entry(orig.root_timeline_entry)
    copy_schedule_info

    copy.save!
    copy
  end

  # make sure to set project_id on copy
  def duplicate_timeline_entry(orig_entry, copy_parent_entry = nil)
    copy_entry = orig_entry.amoeba_dup
    copy_entry.project = copy

    # amoeba does not set the project_step_id
    copy_entry.project_logs.each do |log|
      log.project_step = copy_entry
    end

    # closure_tree doesn't seem to fire properly unless we save here.
    copy_entry.parent = copy_parent_entry
    copy_entry.save!

    step_map[orig_entry] = copy_entry

    orig_entry.children.each do |child|
      duplicate_timeline_entry(child, copy_entry)
    end
  end

  def copy_schedule_info
    scheduled_entries = step_map.keys
      .select(&:scheduled_start_date)
      .sort_by(&:scheduled_start_date)

    scheduled_entries.each do |old_step|
      new_step = step_map[old_step]

      if old_step.schedule_parent_id
        new_step.schedule_parent_id = step_map[old_step.schedule_parent].id
      else
        new_step.scheduled_start_date = old_step.scheduled_start_date
      end
      new_step.scheduled_duration_days = old_step.scheduled_duration_days

      new_step.save!
    end
  end
end
