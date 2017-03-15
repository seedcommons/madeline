module Accounting
  module Quickbooks
    class TransactionFetcher < FetcherBase
      def types
        Accounting::Transaction::TRANSACTION_TYPES
      end
    end
  end
end
