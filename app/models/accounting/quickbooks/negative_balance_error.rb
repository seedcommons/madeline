module Accounting
  module Quickbooks
    class NegativeBalanceError < StandardError
      attr_accessor :prev_balance

      def initialize(message: nil, prev_balance: nil)
        super(message)
        self.prev_balance = prev_balance
      end
    end
  end
end
