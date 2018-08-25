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
        # Eventually account extraction should move to another subclass
        # when "Account"
        #   Accounting::Quickbooks::AccountExtractor.new(@object)
        else
          raise "DataExtractor instantiated with invalid object"
        end
      end
    end
  end
end
