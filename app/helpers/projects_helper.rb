module ProjectsHelper
  def health_status_info(health_check)
    render partial: "admin/dashboard/loan_health_message", locals: {
      status_message: health_status_message(health_check)
    }
  end

  def health_status_message(health_check)
    if health_check.healthy?
      status_message = {
        status: "healthy",
        message: I18n.t("health_status.healthy"),
        warnings: [],
        icon: "fa-check-circle"
      }
    else
      warnings = health_check.health_warnings.collect {|w| I18n.t("health_status.warnings.#{w}")}
      status_message = {
        status: "unhealthy",
        message: I18n.t('health_status.unhealthy'),
        warnings: warnings,
        icon: "fa-exclamation-triangle"
      }
    end
  end
end
