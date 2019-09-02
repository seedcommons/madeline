class StandardLoanDataExport < DataExport
  HEADERS = [
    'actual_end_date',
    'actual_first_interest_payment_date',
    'actual_first_payment_date',
    'actual_return',
    'amount',
    'change_in_interest',
    'change_in_principal',
    'cooperative',
    'country',
    'division',
    'loan_id',
    'loan_type',
    'name',
    'postal_code',
    'primary_agent',
    'projected_end_date',
    'projected_first_interest_payment_date',
    'projected_first_payment_date',
    'projected_return',
    'secondary_agent',
    'signing_date',
    'status',
    'sum_of_disbursements',
    'sum_of_repayments'
  ]

  def process_data
    data = []
    data << headers
    Loan.find_each do |l|
      row_as_hash = {
        loan_id: l.id,
        name: l.name,
        division: l.division.try(:name),
        cooperative: l.organization.try(:name),
        country: l.organization.try(:country).try(:name),
        postal_code: l.organization.try(:postal_code),
        status: l.status
      }
      data_row = Array(HEADERS.size)
      row_as_hash.each { |k, v| data_row[HEADERS.index(k.to_s)] = v }
      data << data_row
    end
    self.update(data: data)
  end

  def headers
    # get locale
    HEADERS.map do |h|
      I18n.t("standard_loan_data_exports.headers.#{h}")
    end
  end
end
