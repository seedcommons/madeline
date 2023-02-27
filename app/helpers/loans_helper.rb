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

  def statement_name(start_date, is_quarterly: false)
    if is_quarterly
      case start_date.month
      when 1
        I18n.t("statement.quarterly", quarter: "Q1", year: start_date.year)
      when 4
        I18n.t("statement.quarterly", quarter: "Q2", year: start_date.year)
      when 7
        I18n.t("statement.quarterly", quarter: "Q3", year: start_date.year)
      when 10
        I18n.t("statement.quarterly", quarter: "Q4", year: start_date.year)
      else
        I18n.t("statement.quarterly")
      end
    else
      I18n.t("statement.annual", year: start_date.year)
    end
  end
end
