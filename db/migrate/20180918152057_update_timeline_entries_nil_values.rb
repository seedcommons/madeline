class UpdateTimelineEntriesNilValues < ActiveRecord::Migration[5.1]
  def up
    # non-root groups have summary
    ProjectGroup.all.reject(&:root?).each { |group| group.update!(summary: 'Group summary') if group.summary.blank? }

    # steps have scheduled_start_date, summary and details
    no_schedule_dates = ProjectStep.where(scheduled_start_date: nil).sort_by(&:sort_key)
    no_summary_or_details = ProjectStep.select(&:has_no_summary_or_details)

    project_steps = (no_schedule_dates + no_summary_or_details).uniq

    # WIP - query is not updating all steps; validations clashing with validations
    project_steps.each do |step|
      if step.scheduled_start_date.nil?
        if step.schedule_parent
          step.scheduled_start_date = step.schedule_parent.dependent_step_start_date
        elsif step.old_start_date.present?
          step.scheduled_start_date = step.old_start_date
        else
          step.scheduled_start_date = Date.today
        end
      end

      step.summary = 'Step summary' if step.summary.blank?
      step.details = 'Step details' if step.details.blank?

      step.save
    end
  end

  def down
  end
end
