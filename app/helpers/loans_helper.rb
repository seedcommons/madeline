module LoansHelper
  def back_to_loans
    session[:loans_path] || public_loans_path
  end

  def txn_mode_options
    Loan::TXN_MODES.map { |m| [t("activerecord.attributes.loan.#{m}"), m] }
  end

  def source_of_capital_choices
    Loan::SOURCE_OF_CAPITAL_OPTIONS.map { |c| [t("loan.source_of_capital_type.#{c}"), c] }
  end

  def likelihood_closing_choices
    Loan::LIKELIHOOD_CLOSING_OPTIONS.map { |c| [t("loan.likelihood_closing.#{c}"), c] }
  end
end
