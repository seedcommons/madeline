module LoansHelper
  def back_to_loans
    session[:loans_path] || loans_path
  end

  def health_status_icon(loan)
    if loan.loan_health_check.healthy?
      sanitize "<i class='fa fa-check-circle ms-tooltip' data-ms-title=#{health_status_message(loan)}></i> ", tags: %w(i), attributes: %w(class data-ms-title)
    else
      sanitize "<i class='fa fa-exclamation-triangle ms-tooltip' data-ms-title=#{health_status_message(loan)}></i> ", tags: %w(i), attributes: %w(class data-ms-title)
    end
  end

  def health_status_message(loan)
    if loan.loan_health_check.healthy?
      status_message = {
        status: "healthy",
        message: I18n.t("health_status.healthy")
      }
    else
      status_message = {
        status: "unhealthy",
        message: I18n.t('health_status.unhealthy'),
        warnings: loan.loan_health_check.health_warnings
      }
    end
  end
end
