module OldSystemHelper
  DISBURSEMENT_TRANSACTION_TYPE = 12
  REPAYMENT_TRANSACTION_TYPE = 57

  BASE_URI = 'http://internal.labase.org/'.freeze

  # Returns the new disbursement url, as well as addtional loan and org information.
  # This information maybe be required, if the loan does not exist in the old system.
  def old_system_new_disbursement_url(loan:)
    old_system_url('transactionManager.php', loan,
      'Preset': true, 'TransactionType': DISBURSEMENT_TRANSACTION_TYPE, 'Loan': loan.id)
  end

  # Returns the new repayment url, as well as addtional loan and org information.
  # This information maybe be required, if the loan does not exist in the old system.
  def old_system_new_repayment_url(loan:)
    old_system_url('transactionManager.php', loan,
      'Preset': true, 'TransactionType': REPAYMENT_TRANSACTION_TYPE, 'Loan': loan.id)
  end

  # Returns the schedule url, as well as addtional loan and org information.
  # This information maybe be required, if the loan does not exist in the old system.
  def old_system_schedule_url(loan:)
    old_system_url('LoanSchedule.php', loan, 'LoanID': loan.id)
  end

  # Takes the page_url merges old_system values, with loan values, and returns properly formatted URI
  def old_system_url(page_url, loan, old_system_query_values)
    uri = Addressable::URI.parse(BASE_URI + page_url)
    uri.query_values = old_system_query_values.merge(to_query_values(loan)).merge(to_query_values(loan.organization))
    uri.to_s
  end

  # Returns serializable attribs as rails standard post data
  #
  # to_query_values(loan)
  # =>
  # {"loan[id]"=>1364,
  #  "loan[amount]"=>#<BigDecimal:7feb498d5658,'0.1E5',9(18)>,
  #  "loan[currency_id]"=>2 ... }
  def to_query_values(object)
    return {} if !object
    allowed_attribs = object.attributes.select do |_key, value|
      [Fixnum, String, BigDecimal, Date].any? { |type| value.is_a?(type) }
    end

    allowed_attribs.inject({}) { |acc, (key, value)| acc.update("#{object.class.to_s.downcase}[#{key}]" => value.to_s) }
  end
end
