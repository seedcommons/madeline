class StandardLoanDataExport < DataExport
  HEADERS = [
    :loan_id,
    :name,
    :division,
    :cooperative,
    :country,
    :address,
    :city,
    :state,
    :postal_code,
    :status,
    :actual_end_date,
    :actual_first_payment_date,
    :projected_end_date,
    :projected_first_payment_date,
    :signing_date,
    :length_months,
    :loan_type,
    :currency,
    :amount,
    :rate,
    :source_of_capital,
    :final_repayment_formula,
    :primary_agent,
    :secondary_agent,
    :num_accounting_warnings,
    :num_accounting_errors,
    :sum_of_disbursements,
    :sum_of_repayments,
    :repayments_of_principal,
    :repayments_of_interest,
    :accrued_interest,
    :change_in_principal,
    :change_in_interest,
    :final_principal_balance,
    :final_interest_balance
  ]

  protected

  def scope
    Loan.where(division_id: division.self_and_descendants.pluck(:id))
  end

  private

  def object_data_as_hash(loan)
    {
      loan_id: loan.id,
      name: loan.name,
      division: loan.division_name,
      cooperative: loan.coop_name,
      address: loan.coop_street_address,
      city: loan.coop_city,
      state: loan.coop_state,
      country: loan.coop_country&.name,
      postal_code: loan.coop_postal_code,
      status: loan.status.to_s,
      actual_end_date: loan.actual_end_date,
      actual_first_payment_date: loan.actual_first_payment_date,
      projected_end_date: loan.projected_end_date,
      projected_first_payment_date: loan.projected_first_payment_date,
      signing_date: loan.signing_date,
      length_months: loan.length_months,
      loan_type: loan.type,
      currency: loan.currency&.name,
      amount: loan.amount,
      rate: loan.rate,
      source_of_capital: loan.source_of_capital,
      final_repayment_formula: loan.final_repayment_formula,
      primary_agent: loan.primary_agent&.name,
      secondary_agent: loan.secondary_agent&.name,
      num_accounting_warnings: loan.num_sync_issues_by_level(:warning),
      num_accounting_errors: loan.num_sync_issues_by_level(:error),
      sum_of_disbursements: loan.sum_of_disbursements(start_date: start_date, end_date: end_date),
      sum_of_repayments: loan.sum_of_repayments(start_date: start_date, end_date: end_date),
      repayments_of_principal: loan.repayments_of_principal(start_date: start_date, end_date: end_date),
      repayments_of_interest: loan.repayments_of_interest(start_date: start_date, end_date: end_date),
      accrued_interest: loan.accrued_interest(start_date: start_date, end_date: end_date),
      change_in_principal: loan.change_in_principal(start_date: start_date, end_date: end_date),
      change_in_interest: loan.change_in_interest(start_date: start_date, end_date: end_date),
      final_principal_balance: loan.final_principal_balance(start_date: start_date, end_date: end_date),
      final_interest_balance: loan.final_interest_balance(start_date: start_date, end_date: end_date)
    }
  end

  # Returns the list of symbols representing headers in the order they should appear.
  def header_symbols
    HEADERS
  end

  def header_rows
    [HEADERS.map { |h| I18n.t("standard_loan_data_exports.headers.#{h}") }]
  end
end
