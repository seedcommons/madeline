module Accounting
  module QB
    class AnnotatedIntuitRequestException < StandardError
      attr_accessor :transaction

      def initialize(message: nil, transaction:)
        super(message)
        self.transaction = transaction
      end
    end
  end
end
