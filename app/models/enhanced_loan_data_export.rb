# == Schema Information
#
# Table name: data_exports
#
#  created_at  :datetime         not null
#  data        :json
#  division_id :bigint(8)        not null
#  end_date    :datetime
#  id          :bigint(8)        not null, primary key
#  locale_code :string           not null
#  name        :string           not null
#  start_date  :datetime
#  type        :string           not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_data_exports_on_division_id  (division_id)
#
# Foreign Keys
#
#  fk_rails_...  (division_id => divisions.id)
#

class EnhancedLoanDataExport < DataExport
  BASE_HEADERS = [
    'loan_id',
    'name',
    'division',
    'cooperative',
    'country',
    'address',
    'city',
    'state',
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
    'num_accounting_warnings',
    'num_accounting_errors',
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
    data << question_id_row
    Loan.find_each do |loan|
      begin
        data << hash_to_row(loan_data_as_hash(loan))
      rescue => e
        @child_errors << {loan_id: loan.id, message: e.message}
        next
      end
    end
    self.update(data: data)

    unless @child_errors.empty?
      raise DataExportError.new(message: "Data export had child errors.", child_errors: @child_errors)
    end
  end

  private

  def loan_data_as_hash(loan)
    result = {
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
      actual_first_interest_payment_date: loan.actual_first_interest_payment_date,
      projected_end_date: loan.projected_end_date,
      projected_first_payment_date: loan.projected_first_payment_date,
      projected_first_interest_payment_date: loan.projected_first_interest_payment_date,
      signing_date: loan.signing_date,
      loan_type: loan.type,
      currency: loan.currency&.name,
      amount: loan.amount,
      primary_agent: loan.primary_agent&.name,
      secondary_agent: loan.secondary_agent&.name,
      num_accounting_warnings: loan.num_problem_loan_txns_by_level(:warning),
      num_accounting_errors: loan.num_problem_loan_txns_by_level(:error),
      sum_of_disbursements: loan.sum_of_disbursements(start_date: start_date, end_date: end_date),
      sum_of_repayments: loan.sum_of_repayments(start_date: start_date, end_date: end_date),
      change_in_principal: loan.change_in_principal(start_date: start_date, end_date: end_date),
      change_in_interest: loan.change_in_interest(start_date: start_date, end_date: end_date)
    }
    result.merge(response_hash(loan))
  end

  def response_hash(loan)
    return {} if loan.criteria.blank?
    result = {}
    response_set = loan.criteria
    response_set.custom_data.each do |q_id, response_data|
      if questions_map.keys.include?(q_id)
        response = Response.new(loan: loan, question: Question.find(q_id), response_set: response_set, data: response_data)
        if response.has_rating?
          result[q_id] = response.rating
        elsif response.has_number?
          result[q_id] = response.number
        end
      end
    end
    result
  end

  def question_id_row
    row = [I18n.t("standard_loan_data_exports.headers.question_id")]
    row[BASE_HEADERS.size - 1] = nil
    row + questions_map.keys.sort
  end

  def header_row
    @header_row ||= make_header_row
  end

  def make_header_row
    headers = BASE_HEADERS.map do |h|
      I18n.t("standard_loan_data_exports.headers.#{h}")
    end
    headers + questions_map.keys.sort.map { |k| questions_map[k] }
  end

  def questions_map
    @questions_map ||= make_questions_map
  end

  def make_questions_map
    q_data_types = ['number', 'percentage', 'rating', 'currency']
    q_id_to_label_map = {}
    Question.where(data_type: q_data_types).find_each { |q| q_id_to_label_map[q.id.to_s] = q.label.to_s }
    q_id_to_label_map
  end

  # Methods below decouple order in BASE_HEADERS constant from order values are added to data row
  def headers_key
    @headers_key = @headers_key || BASE_HEADERS + questions_map.keys.sort
  end

  def hash_to_row(hash)
    data_row = []
    hash.each { |k, v| insert_in_row(k, data_row, v) }
    data_row
  end

  def insert_in_row(column_name, row_array, value)
    row_array[headers_key.index(column_name.to_s)] = value
  end
end
