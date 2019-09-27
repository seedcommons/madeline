class StandardLoanDataExport < DataExport
  HEADERS = [
    'loan_id',
    'name',
    'division',
    'cooperative',
    'country',
    'postal_code',
    'status',
    'actual_end_date',
    'actual_first_payment_date',
    'actual_first_interest_payment_date',
    'projected_end_date',
    'projected_first_payment_date',
    'projected_first_interest_payment_date',
    'signing_date',
    'loan_type',
    'currency',
    'amount',
    'primary_agent',
    'secondary_agent',
    'sum_of_disbursements',
    'sum_of_repayments',
    'change_in_principal',
    'change_in_interest'
  ]

  # Subclass exists only to implement process_data. No additional public methods should be added to this subclass.
  def process_data
    data = []
    data << header_row
    Loan.find_each do |l|
      row_as_hash = {
        loan_id: l.id,
        name: l.name,
        division: l.division.try(:name),
        cooperative: l.coop_name,
        country: l.coop_country.try(:name),
        postal_code: l.coop_postal_code,
        status: l.status,
        actual_end_date: l.actual_end_date,
        actual_first_payment_date: l.actual_first_payment_date,
        actual_first_interest_payment_date: l.actual_first_interest_payment_date,
        projected_end_date: l.projected_end_date,
        projected_first_payment_date: l.projected_first_payment_date,
        projected_first_interest_payment_date: l.projected_first_interest_payment_date,
        signing_date: l.signing_date,
        loan_type: l.type,
        currency: l.currency.try(:name),
        amount: l.amount,
        primary_agent: l.primary_agent,
        secondary_agent: l.secondary_agent,
        sum_of_disbursements: l.sum_of_disbursements(start_date: start_date, end_date: end_date),
        sum_of_repayments: l.sum_of_repayments(start_date: start_date, end_date: end_date),
        change_in_principal: l.change_in_principal(start_date: start_date, end_date: end_date),
        change_in_interest: l.change_in_interest(start_date: start_date, end_date: end_date)
      }
      data << hash_to_row(row_as_hash)
    end
    self.update(data: data)
  end

  private

  # decouples order in HEADERS constant from order values are added to data row
  def hash_to_row(hash)
    data_row = Array(HEADERS.size)
    hash.each { |k, v| insert_in_row(k, data_row, v) }
    data_row
  end

  def insert_in_row(column_name, row_array, value)
    row_array[HEADERS.index(column_name.to_s)] = value
  end

  def header_row
    HEADERS.map do |h|
      I18n.t("standard_loan_data_exports.headers.#{h}", locale: locale_code)
    end
  end
end
