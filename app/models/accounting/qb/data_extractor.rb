module Accounting
  module QB
    class DataExtractor
      def initialize(object)
        @object = object

        case @object.qb_object_type
        when "JournalEntry"
          @extractor = Accounting::QB::JournalEntryExtractor.new(@object)
        when "Purchase"
          @extractor = Accounting::QB::PurchaseExtractor.new(@object)
        when "Bill"
          @extractor = Accounting::QB::BillExtractor.new(@object)
        when "Deposit"
          @extractor = Accounting::QB::DepositExtractor.new(@object)
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
