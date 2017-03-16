module Accounting
  module Quickbooks
    class AccountFetcher < FetcherBase
      def types
        ['Account']
      end
    end
  end
end
