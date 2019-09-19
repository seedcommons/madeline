module Accounting
  class TransactionDataMissingError < StandardError
    def message
      I18n.t('loan.errors.transaction_data_missing')
    end
  end
end
