module LoansHelper
  def back_to_loans
    session[:loans_path] || loans_path
  end

  def health_status_icon(loan)
    if loan.loan_health_check.healthy?
      sanitize "<i class='fa fa-check-circle'></i> ", tags: %w(i), attributes: %w(class)
    else
      sanitize "<i class='fa fa-exclamation-triangle'></i> ", tags: %w(i), attributes: %w(class)
    end
  end
end
