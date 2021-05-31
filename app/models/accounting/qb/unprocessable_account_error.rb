module Accounting
  module QB
    class UnprocessableAccountError < StandardError
      attr_accessor :loan, :transaction

      def initialize(message: nil, loan:, transaction:)
        super(message)
        self.loan = loan
        self.transaction = transaction
      end
    end
  end
end
