module Accounting
  module QB
    class NegativeBalanceError < StandardError
      attr_accessor :prev_balance

      def initialize(message: nil, prev_balance: nil)
        super(message)
        self.prev_balance = prev_balance
      end
    end
  end
end
