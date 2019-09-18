module Accounting
  class TransactionDataMissingError < StandardError
    def message
      "Loan has transactions with no change in interest. Do you need to run a QB update?"
    end
  end
end
