module LoansHelper
  def back_to_loans
    session[:loans_path] || loans_path
  end

  def health_status_icon(loan)
    if loan.loan_health_check.healthy?
      sanitize "<i class='fa fa-check-circle' data-toggle='tooltip' data-placement='right' title=#{health_status_message(loan)}></i> ", tags: %w(i), attributes: %w(class data title)
    else
      sanitize "<i class='fa fa-exclamation-triangle' data-toggle='tooltip' data-placement='right' title=#{health_status_message(loan)}></i> ", tags: %w(i), attributes: %w(class data title)
    end
  end

  def health_status_message(loan)
    if loan.loan_health_check.healthy?
      I18n.t("health_status.healthy")
    else
      "Unhealthy"
    end
  end
end
