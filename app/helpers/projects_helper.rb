module ProjectsHelper
  def health_status_info(project)
    if project.health_status_available?
      render partial: "admin/dashboard/loan_health_message", locals: {
        status_message: health_status_message(project)
      }
    end
  end

  def health_status_message(project)
    if project.loan_health_check.healthy?
      status_message = {
        status: "healthy",
        message: I18n.t("health_status.healthy"),
        warnings: []
      }
    else
      warnings = project.loan_health_check.health_warnings.collect {|w| I18n.t("health_status.warnings.#{w}")}
      status_message = {
        status: "unhealthy",
        message: I18n.t('health_status.unhealthy'),
        warnings: warnings
      }
    end
  end
end
