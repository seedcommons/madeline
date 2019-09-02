class StandardLoanDataExport < DataExport
  HEADERS = ['loan_id', 'name', 'division']

  def process_data
    data = []
    data << headers
    Loan.find_each do |l|
      data << [
        l.id,
        l.name,
        l.division.name
      ]
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
