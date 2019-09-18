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
    @child_errors = []
    data = []
    data << header_row
    Loan.find_each do |l|
      begin
        data << hash_to_row(loan_data_as_hash(l))
      rescue => e
        @child_errors << {loan_id: l.id, message: e.message}
        next
      end
    end
    self.update(data: data)
    unless @child_errors.empty?
      raise DataExportError.new(message: "Data export had child errors.", child_errors: @child_errors)
    end
  end

  private

  def loan_data_as_hash(l)
    {
      loan_id: l.id,
      name: l.name,
      division: l.division.try(:name),
      cooperative: l.coop_name,
      country: l.coop_country.try(:name),
      postal_code: l.coop_postal_code,
      status: l.status_text,
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
      primary_agent: l.primary_agent_name,
      secondary_agent: l.secondary_agent_name,
      sum_of_disbursements: l.sum_of_disbursements(start_date: start_date, end_date: end_date),
      sum_of_repayments: l.sum_of_repayments(start_date: start_date, end_date: end_date),
      change_in_principal: l.change_in_principal(start_date: start_date, end_date: end_date),
      change_in_interest: l.change_in_interest(start_date: start_date, end_date: end_date)
    }
  end

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
