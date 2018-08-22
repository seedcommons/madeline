module Accounting
  module Quickbooks
    class DataExtractor
      def initialize(object)
        @object = object
      end

      def extract!
        case @object.qb_object_type
        when "JournalEntry", "Purchase", "Deposit", "Bill"
          Accounting::Quickbooks::TransactionExtractor.new(@object)
        end
      end
    end
  end
end
