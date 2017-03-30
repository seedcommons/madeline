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

    if step.completed?
      if days && days > 0
        I18n.t('project_step.status.completed_late', days: days)
      else
        I18n.t('project_step.status.completed')
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
