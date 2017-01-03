module ProjectStepHelper
  def project_step_icon(step)
    case step.step_type_value
    when 'checkin'
      '<i class="fa fa-calendar-check-o"></i> '.html_safe
    when 'milestone'
      '<i class="fa fa-flag"></i> '.html_safe
    end
  end
end
