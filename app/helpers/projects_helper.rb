module ProjectsHelper
  def health_status_info(health_check)
    render partial: "admin/dashboard/message", locals: {
      status_message: health_status_message(health_check)
    }
  end

  def health_status_message(health_check)
    if health_check.healthy?
      status_message = {
        icon: "fa-check-circle healthy",
        message: I18n.t("health_status.healthy"),
        warnings: []
      }
    else
      warnings = health_check.health_warnings.map { |w| I18n.t("health_status.warnings.#{w}") }
      status_message = {
        icon: "fa-exclamation-triangle unhealthy",
        message: I18n.t('health_status.unhealthy'),
        warnings: warnings
      }
    end
  end

  def summary_info(project)
    render partial: "admin/dashboard/message", locals: {
      status_message: summary_message(project)
    }
  end

  def summary_message(project)
    status_message = {
      icon: "fa-info-circle",
      message: project.summary,
      warnings: []
    }
  end
end
