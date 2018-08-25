module Accounting
  module Quickbooks
    class DataExtractor
      def initialize(object)
        @object = object

        case @object.qb_object_type
        when "JournalEntry", "Purchase", "Deposit", "Bill"
          @extractor = Accounting::Quickbooks::TransactionExtractor.new(@object)
        # Eventually account extraction should move to another subclass
        # when "Account"
        #   Accounting::Quickbooks::AccountExtractor.new(@object)
        else
          raise "DataExtractor instantiated with invalid object"
        end
      end

      def extract!
        @extractor.extract!
      end
    end
  end
end
