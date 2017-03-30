module ProjectStepHelper
  def project_step_icon(step)
    case step.step_type_value
    when 'checkin'
      '<i class="fa fa-calendar-check-o"></i> '.html_safe
    when 'milestone'
      '<i class="fa fa-flag"></i> '.html_safe
    end
  end

  def project_step_status(step)
    days = step.days_late

    if !step.is_finalized
      I18n.t("project_step.timeline_table.draft")
    elsif step.completed?
      if days && days > 0
        sanitize "<i class='fa fa-check'></i> #{I18n.t('project_step.status.completed_late',
          days: days)}", tags: %w(i), attributes: %w(class)
      else
        sanitize "<i class='fa fa-check'></i> #{I18n.t('project_step.status.completed')}",
          tags: %w(i), attributes: %w(class)
      end
    elsif days
      if days <= 0
        I18n.t('project_step.status.on_time')
      else
        I18n.t('project_step.status.days_late', days: days)
      end
    else
      I18n.t(:none)
    end
  end
end
