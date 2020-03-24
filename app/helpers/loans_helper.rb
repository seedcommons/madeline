module LoansHelper
  def back_to_loans
    session[:loans_path] || public_loans_path
  end

  def txn_mode_options
    Loan::TXN_MODES.map{ |m| [t("activerecord.attributes.loan.#{m}"), m] }
  end
end
