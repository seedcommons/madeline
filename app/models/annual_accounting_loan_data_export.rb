class AnnualAccountingLoanDataExport < DataExport

  protected

  def scope
    Loan.where(division_id: division.self_and_descendants.pluck(:id))
  end

  private

  def object_data_as_hash(loan)
    result = {}
    result[:loan_id] = loan.id
    date_ranges.each do |pair|
      s = pair[0]
      e = pair[1]
      year_string = year_string(s)
      result["#{year_string}_sum_disbursements"] = loan.sum_of_disbursements(start_date: s, end_date: e)
      result["#{year_string}_sum_repayments"] = loan.sum_of_repayments(start_date: s, end_date: e)
      result["#{year_string}_interest_accrued"] = loan.accrued_interest(start_date: s, end_date: e)
    end
    result[:total_sum_disbursements] = loan.sum_of_disbursements(start_date: start_date, end_date: end_date)
    result[:total_sum_repayments] = loan.sum_of_repayments(start_date: start_date, end_date: end_date)
    result[:total_interest_accrued] = loan.accrued_interest(start_date: start_date, end_date: end_date)
    result[:end_principal_balance] = loan.final_principal_balance(start_date: start_date, end_date: end_date)
    result[:end_interest_balance] = loan.final_interest_balance(start_date: start_date, end_date: end_date)
    result[:end_total_balance] = result[:end_principal_balance] + result[:end_interest_balance]
    result
  end

  def date_ranges
    #uses report start date and end date, see data_export.rb
    @date_ranges ||= calculate_date_ranges
  end

  #start_date is the data export's start date; end_date is the data export's end_date
  def calculate_date_ranges
    date_ranges = []
    next_start_date = start_date
    next_end_date = start_date.end_of_year
    while next_end_date < end_date.beginning_of_year
      date_ranges << [next_start_date, next_end_date]
      next_end_date = next_end_date + 1.year
      next_start_date = next_end_date.beginning_of_year
    end
    date_ranges << [end_date.beginning_of_year, end_date]
  end



  def year_string(date)
    date.strftime("%Y")
  end

  def header_symbols
    @header_symbols ||= make_header_symbols
  end

  def make_header_symbols
    headers = [:loan_id]
    date_ranges.each do |pair|
      year_string = pair[0].strftime("%Y")
      headers << "#{year_string}_sum_disbursements"
      headers << "#{year_string}_sum_repayments"
      headers << "#{year_string}_interest_accrued"
    end
    # iterate over date ranges
    headers += [:total_sum_disbursements, :total_sum_repayments, :total_interest_accrued, :end_principal_balance, :end_interest_balance, :end_total_balance]
    headers
  end

  def header_rows
    [main_header_row, header_symbols]
  end

  #TODO this needs actual dates in it babe
  def main_header_row
    year_to_start_and_end = year_to_date_range
    #puts header_symbols.count
    result = []
    header_symbols.each do |h|
      #puts h
      if /^(20)[\d]{2,2}\S*$/.match(h) #is a year header
        year_string = h[0..3] #h[4] is an _
        remainder = h[5..]
        start_date = year_to_date_range[year_string][0].strftime("%d-%b-%Y")
        end_date  = year_to_date_range[year_string][1].strftime("%d-%b-%Y")
        header = I18n.t("annual_accounting_loan_data_exports.headers.#{remainder}", start_date: start_date, end_date: end_date)
        #puts header
        result << header
      else
        result << I18n.t("annual_accounting_loan_data_exports.headers.#{h}", start_date: start_date, end_date: end_date)
      end
    end
    #puts result
    result
  end

  def year_to_date_range
    @year_to_date_range ||= calculate_year_to_date_range
  end

  def calculate_year_to_date_range
    result = {}
    date_ranges.each do |pair|
      result[year_string(pair[0])] = pair
    end
    result
  end
end



# todo
# implement the two header row concept from enhance dloan data exports so key & headers can be diff
